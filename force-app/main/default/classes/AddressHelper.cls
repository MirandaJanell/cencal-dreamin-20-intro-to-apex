public with sharing class AddressHelper {
	/**
	 * Creates an open street map url for the provided address
	 * @param  street     street component of the address
	 * @param  city       city component of the address
	 * @param  state      state component of the address
	 * @param  postalCode postalCode component of the address
	 * @return            a url that resolves to the open streep map of the provided address
	 */
	public String getOpenStreetMapUrl(
		String street,
		String city,
		String state,
		String postalCode
	) {
		String osmUrl;

		// if street components are all provided
		if (
			street != null &&
			city != null &&
			state != null &&
			postalCode != null
		) {
			osmUrl =
				'https://www.openstreetmap.org/search?query=' +
				urlEncodeAddress(street, city, state, postalCode);
		}

		return osmUrl;
	}
	
	/**
	 * Sets the mailing address on contacts to the associated accounts billing address when
	 * the mailing address street, city, and state components are not set.
	 * @param  acctMap a map of Account source records to update associated contacts addresses
	 */
	public void syncAddresses(Map<Id, Account> acctMap) {
		// get the account id set from the map collection of new or updated accounts
		Set<Id> acctIds = acctMap.keySet();
		// Query the account contacts that do not have an address set
		List<Contact> conts = [
			SELECT
				Id,
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
			Account acct = acctMap.get(cont.AccountId);
			cont.MailingStreet = acct.BillingStreet;
			cont.MailingCity = acct.BillingCity;
			cont.MailingState = acct.BillingState;
			cont.MailingPostalCode = acct.BillingPostalCode;
			cont.MailingCountry = acct.BillingCountry;
		}

		update conts;
	}

	/**
	 * Creates a string representation of the supplied address components and encodes for inclusion in url query parameters.
	 * @param  street     street component of the address
	 * @param  city       city component of the address
	 * @param  state      state component of the address
	 * @param  postalCode postalCode component of the address
	 * @return            a url embededdable version of the address
	 */
	public String urlEncodeAddress(
		String street,
		String city,
		String state,
		String postalCode
	) {
		String addr = String.format(
			'{0}, {1}, {2} {3}',
			new List<String>{ street, city, state, postalCode }
		);

		return EncodingUtil.urlEncode(addr, 'UTF-8');
	}
}
