trigger RUS_AccountTrigger on Account(before insert, before update) {
	if (Trigger.isInsert) {
		for (Account acct : Trigger.new) {
			acct.Num_of_Open_Opps_Apex__c = 0;
		}
	}

	if (Trigger.isUpdate) {
		Set<Id> acctIds = Trigger.newMap.keySet();

		for (AggregateResult ar : [
			SELECT COUNT(Id) numOpen, AccountId acctId
			FROM Opportunity
			WHERE Id IN :acctIds AND IsClosed = false
			GROUP BY AccountId
		]) {
			Id acctId = (Id) ar.get('acctId');
			Account acct = Trigger.newMap.get(acctId);
			acct.Num_of_Open_Opps_Apex__c = (Decimal) ar.get('numOpen');
		}
	}
}
