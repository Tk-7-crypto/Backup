@isTest(seeAllData = false)
private class TST_SCH_TPA_SendHelpfulHints { 
	static TPA_Request__c tpaRequest;
    static void setup() {
        UTL_TPA_SetupTestData.createTPASettingData();
        UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();
        // create account 
        Account testAccount = new Account(Name = 'Test Account', CurrencyIsoCode = 'USD', Region_Territory__c = 'India', Industry_IMS__c = 'Biotech',  Is_Payment_Risk__c = true,  BillingStreet = 'test', BillingCity = 'test', BillingCountry = 'test', BillingPostalCode = 'test',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert testAccount;
        System.debug('CD::01.Number of Queries used in this apex code so far: ' + Limits.getQueries());
		
		Address__c testAddress = new Address__c(Account__c = testAccount.Id, recordTypeId = UTL_TPA_SetupTestData.getTPAVendorAddressRecordTypeId, is_TPA_Account__c=true, Vendor_Tier__c = 'Y', Vendor_Registration_Number__c = 9999);
		insert testAddress;
        System.debug('CD::02.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        // Create Contact
        Contact tpaContact = new Contact(FirstName = 'Test',LastName = 'Test', AccountId = testAccount.Id, CurrencyIsoCode = 'USD', Email = 'test@mail.com', Title = 'Dev');
        insert tpaContact;
        System.debug('CD::03.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        
        tpaRequest = UTL_TPA_SetupTestData.getTPARequestByVendorAccount(testAddress.id);
        System.debug('CD::04.Number of Queries used in this apex code so far: ' + Limits.getQueries());
		UTL_TPA_SetupTestData.addAttachmentToParent(tpaRequest.Id, [Select Name from TPA_Request__c where Id = :tpaRequest.Id].get(0).Name + '_TLLA' + '.pdf');
        System.debug('CD::05.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        UTL_TPA_SetupTestData.addAttachmentToParent(tpaRequest.Id, [Select Name from TPA_Request__c where Id = :tpaRequest.Id].get(0).Name + '_TLLA' + '.pdf_Completed');
        System.debug('CD::06.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        tpaRequest.Request_Status__c = UTL_TPA.SIGNATURE_UNDER_VALIDATION;
        update tpaRequest;
        System.debug('CD::07.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        UTL_TPA_SetupTestData.createTpaTestEditorData('TPA Email Footer', 'Test', 'emailFooter', 'emailFooter');
    }
    
    static testMethod void unitTest1() {
        setup();
        Test.startTest();
        
        String query = 'Select Id, Vendor_Contact_e_mail__c, TP_Processor_Email__c, ClientContact__c, Authorized_Signer_Email__c, (Select Email__c from TPA_Request_Contacts__r where Type__c = \'Additional Vendor Contact\') from TPA_Request__c where Request_Status__c = \'In Effect\' AND In_Effect_Date__c = YESTERDAY';
        System.debug('----------------------------> ' + Database.Query(query));
        tpaRequest.Data_Access_Start_Date__c  = date.newInstance(2017, 1, 1);
        tpaRequest.Data_Access_End_Date__c  = date.today();
        tpaRequest.Vendor_Contact_e_mail__c = 'test@test.com';
        tpaRequest.Authorized_Signer_Email__c = 'test@test.com';
        tpaRequest.In_Effect_Date__c = Date.today().addDays(-1);
        update tpaRequest;
        UTL_TPA_SetupTestData.getTPAAgreementAdditionalFieldObj(tpaRequest);
        System.debug('CD::08.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        System.debug('CD::09.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        	System.schedule('Helpfull Hints Unit Test', '0 0 13 1/1 * ? *', new SCH_TPA_SendHelpfulHints());
        System.debug('CD::10.Number of Queries used in this apex code so far: ' + Limits.getQueries());
        Test.stopTest();
    }
}