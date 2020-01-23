trigger AddrEnc_LeadTrigger on Lead (before insert, before update) {
	for(Lead ld : trigger.new) {
		ld.OpenStreetMap__c = null;

		if(ld.Street != null && ld.City != null && ld.State != null && ld.PostalCode != null) {
			String addr = ld.Street + ', ' + ld.City + ', ' + ld.State + ' ' + ld.PostalCode;
			ld.OpenStreetMap__c = 'https://www.openstreetmap.org/search?query=' + EncodingUtil.urlEncode(addr, 'UTF-8');
		}
	}
}