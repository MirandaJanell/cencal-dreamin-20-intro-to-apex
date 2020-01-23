trigger OpportunityLineItemTrigger on OpportunityLineItem (before insert, before update) {
	for(OpportunityLineItem oli : trigger.new) {
		Decimal disc = 0;

		if(oli.DiscountAmount__c != null) {
			disc = oli.DiscountAmount__c;
		}

		oli.UnitPrice = (oli.QuotedSalePrice__c * oli.Quantity - disc) / oli.Quantity;
	}
}