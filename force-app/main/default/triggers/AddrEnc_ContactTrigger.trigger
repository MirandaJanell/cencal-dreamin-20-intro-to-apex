trigger AddrEnc_ContactTrigger on Contact(before insert, before update) {
	AddressHelper addrHelper = new AddressHelper();

	for (Contact cont : Trigger.new) {
		cont.MailingOpenStreetMap__c =
			'https://www.openstreetmap.org/search?query=' +
			addrHelper.urlEncodeAddress(
				cont.MailingStreet,
				cont.MailingCity,
				cont.MailingState,
				cont.MailingPostalCode
			);
	}
}
