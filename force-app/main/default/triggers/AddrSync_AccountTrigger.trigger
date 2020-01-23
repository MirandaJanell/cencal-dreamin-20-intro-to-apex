trigger AddrSync_AccountTrigger on Account(after insert, after update) {
	// get the account id set from the map collection of new or updated accounts
	Set<Id> acctIds = Trigger.newMap.keySet();
	// Query the account contacts that do not have an address set
	List<Contact> conts = [
		SELECT
			Id,
			AccountId,
			MailingStreet,
			MailingCity,
			MailingState,
			MailingPostalCode,
			MailingCountry
		FROM Contact
		WHERE
			AccountId IN :acctIds
			AND MailingStreet = null
			AND MailingCity = null
			AND MailingState = null
	];

	for (Contact cont : conts) {
		Account acct = trigger.newMap.get(cont.AccountId);
		cont.MailingStreet = acct.BillingStreet;
		cont.MailingCity = acct.BillingCity;
		cont.MailingState = acct.BillingState;
		cont.MailingPostalCode = acct.BillingPostalCode;
		cont.MailingCountry = acct.BillingCountry;
	}

	update conts;
}
