@isTest(SeeAllData=False)
public class TST_CNT_TPA_ReportsNavigation {
    private static CNT_TPA_ReportsNavigation tPAReportsNavigationInstance;
    private static Contact tpaContact;
    private static Account testAccount;
    private static Address__c testAddress;
    
    public static testMethod void testTPA_ReportsNavigation() { 
        tPAReportsNavigationInstance = new CNT_TPA_ReportsNavigation();
        UTL_TPA_SetupTestData.createTPASettingData();
        System.debug(tPAReportsNavigationInstance.baseURL);

    }
    @TestSetup
    static void setupTestData() 
    {
        UTL_TPA_SetupTestData.createAMASetting();
        
        // create account 
        testAccount = new Account(Name = 'Test Account', CurrencyIsoCode = 'USD', Region_Territory__c = 'India', BillingStreet = 'test', BillingCity = 'test', BillingCountry = 'test', BillingPostalCode = 'test', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert testAccount;
        
        // create address
        testAddress =  new Address__c(Name = 'Test Account', recordTypeId = UTL_TPA_SetupTestData.getTPAVendorAddressRecordTypeId, CurrencyIsoCode = 'USD', Account__c = testAccount.Id, Industry__c = 'Biotech', Vendor_Tier__c = 'Y', Is_Payment_Risk__c = true, Vendor_Registration_Number__c = 9999, is_TPA_Account__c=true, Street__c = 'test', City__c = 'test', Country__c = 'test', PostalCode__c = 'test');
        insert testAddress;
        
        // Create Contact
        tpaContact = new Contact(FirstName = 'TestFirstName', LastName = 'Test', AccountId = testAccount.Id, CurrencyIsoCode = 'USD', Email = 'test@mail.com', Title = 'Dev');
        insert tpaContact;
    }

}