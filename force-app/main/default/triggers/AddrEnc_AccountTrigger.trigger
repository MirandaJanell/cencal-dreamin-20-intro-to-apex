trigger AddrEnc_AccountTrigger on Account (before insert, before update) {
	AddressHelper addrHelper = new AddressHelper();

	for (Account acct : Trigger.new) {
		acct.BillingOpenStreetMap__c =
			'https://www.openstreetmap.org/search?query=' +
			addrHelper.urlEncodeAddress(
				acct.BillingStreet,
				acct.BillingCity,
				acct.BillingState,
				acct.BillingPostalCode
			);
	}
}