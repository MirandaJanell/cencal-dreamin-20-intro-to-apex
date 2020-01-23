trigger RUS_OpportunityTrigger on Opportunity(
	after insert,
	after update,
	after delete,
	after undelete
) {
	Set<Id> refreshAcctIds = new Set<Id>();

	if (Trigger.isInsert || Trigger.isUndelete) {
		for (Opportunity opp : Trigger.new) {
			if (!opp.IsClosed && opp.AccountId != null) {
				refreshAcctIds.add(opp.AccountId);
			}
		}
	} else if (Trigger.isUpdate) {
		// did something relevant change?
		for (Opportunity opp : Trigger.new) {
			Opportunity old = Trigger.oldMap.get(opp.Id);
			if (
				opp.IsClosed != old.IsClosed ||
				opp.AccountId != old.AccountId
			) {
				refreshAcctIds.add(opp.AccountId);
				refreshAcctIds.add(old.AccountId);
			}
		}

		refreshAcctIds.remove(null);
	} else if (Trigger.isDelete) {
		// same as insert / undelete but with trigger.old instead of trigger.new
		for (Opportunity opp : Trigger.old) {
			if (!opp.IsClosed && opp.AccountId != null) {
				refreshAcctIds.add(opp.AccountId);
			}
		}
	}

	if (!refreshAcctIds.isEmpty()) {
		List<Account> refreshAccts = [
			SELECT Id, Num_of_Open_Opps_Apex__c
			FROM Account
			WHERE Id IN :refreshAcctIds
		];

		for (Account acct : refreshAccts) {
			acct.Num_of_Open_Opps_Apex__c = null;
		}

		update refreshAccts;
	}
}
