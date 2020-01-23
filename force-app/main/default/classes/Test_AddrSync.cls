@IsTest
private class Test_AddrSync {
	@TestSetup
	static void setupTestData() {
		// create test accounts
		Account acct1 = new Account();
		acct1.Name = 'Test Account 1';
		acct1.BillingStreet = '1 Some St.';
		acct1.BillingCity = 'Anytown';
		acct1.BillingState = 'CA';
		acct1.BillingPostalCode = '92801';
		Account acct2 = new Account();
		acct2.Name = 'Test Account 2';
		List<Account> accts = new List<Account>{ acct1, acct2 };
		insert accts;

		// create test contacts
		List<Contact> conts = new List<Contact>();

		// create 50 contacts per account
		for (Account acct : accts) {
			for (Integer i = 0; i < 50; i++) {
				Contact cont = new Contact();
				cont.FirstName = 'Test';
				cont.LastName = 'Contact ' + i;
				cont.AccountId = acct.Id;

				// only set an address for every other contact
				if (Math.mod(i, 2) == 0) {
					cont.MailingStreet = '1 Another Pl. #' + i;
					cont.MailingCity = 'Anytown';
					cont.MailingState = 'CA';
					cont.MailingPostalCode = '92801';
				}

				conts.add(cont);
			}
		}

		insert conts;
	}

	@isTest
	static void testBaseline() {
		List<Contact> conts = [
			SELECT Id
			FROM Contact
			WHERE MailingStreet != null
		];

		System.assertEquals(50, conts.size());
	}

	@isTest
	static void testUpdateSingleAddress() {
		Test.startTest();
		
		Account acct1 = [
			SELECT Id, BillingStreet
			FROM Account
			WHERE Name = 'Test Account 1'
		];
		acct1.BillingStreet = acct1.BillingStreet + '#42';
		update acct1;
		
		Test.stopTest();

		List<Contact> conts = [
			SELECT Id
			FROM Contact
			WHERE MailingStreet != null
		];
		System.assertEquals(75, conts.size());
	}
	
	@isTest
	static void testUpdateMultipleAddresses() {
		Test.startTest();
		
		List<Account> accts = [
			SELECT Id, BillingStreet
			FROM Account
			ORDER BY Name
		];
		accts.get(0).BillingStreet = accts.get(0).BillingStreet + '#42';
		accts.get(1).BillingStreet = '1234 Electric Ave.';
		accts.get(1).BillingCity = 'Anytown';
		accts.get(1).BillingState = 'CA';
		accts.get(1).BillingPostalCode = '92806';
		update accts;
		
		Test.stopTest();

		List<Contact> conts = [
			SELECT Id
			FROM Contact
			WHERE MailingStreet != null
		];
		System.assertEquals(100, conts.size());
	}
}
