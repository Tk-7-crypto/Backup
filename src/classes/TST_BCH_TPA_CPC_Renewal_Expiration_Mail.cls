@isTest(SeeAllData=false)
private class TST_BCH_TPA_CPC_Renewal_Expiration_Mail {

    @TestSetup static void setup() {
        Date todayDate = Date.today();
        UTL_TPA_SetupTestData.createTPASettingsDataBasedOnOrganization();
        UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();
		
        Account acc = new Account(Name = 'Test Account', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert acc;
        
        Address__c testAccount = UTL_TPA_SetupTestData.getAccount();
        testAccount.Name = 'Test_Acc1';
        testAccount.Account__c = acc.id;
        insert testAccount;

        Address__c testAccount2 = UTL_TPA_SetupTestData.getAddress();
        testAccount2.Name = 'Test Acc2';
        testAccount2.Account__c = acc.id;
        testAccount2.Vendor_Registration_Number__c = 124;
        insert testAccount2;

        Contact tpaContact = UTL_TPA_SetupTestData.getContact();
        tpaContact.AccountId = testAccount.Account__c;
        insert tpaContact;

        Contact tpaContact2 = new Contact(firstName = 'testfirstname2',
                                          LastName = 'Test2',
                                          CurrencyIsoCode = 'USD',
                                          Email = 'test@mail.com',
                                          Title = 'Dev');
        tpaContact2.AccountId = testAccount2.Account__c;
        insert tpaContact2;

        TPA_Request__c tpaRequest1 = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest1.OwnerId = UserInfo.getUserId();
        tpaRequest1.Request_Status__c = 'In Effect';
        tpaRequest1.Data_Access_End_Date__c = todayDate.addDays(2);
        tpaRequest1.Service_Provider_Address__c = testAccount.Id;
        tpaRequest1.Client_Address__c = testAccount.Id;
        tpaRequest1.ClientContact__c = tpaContact.id;
        tpaRequest1.Client_Language__c = 'Japanese';
        tpaRequest1.Vendor_Language__c = 'Japanese';
        tpaRequest1.Vendor_Billing_Mailing_Country__c = 'united states';
        tpaRequest1.Vendor_e_mail__c = 'test@mail.com';
        insert tpaRequest1;

        TPA_Request__c tpaRequest2 = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest2.OwnerId = UserInfo.getUserId();
        tpaRequest2.Request_Status__c = 'In Effect';
        tpaRequest2.Data_Access_End_Date__c = todayDate.addDays(3);
        tpaRequest2.Service_Provider_Address__c = testAccount2.Id;
        tpaRequest2.Client_Address__c = testAccount2.Id;
        tpaRequest2.ClientContact__c = tpaContact2.id;
        tpaRequest2.Client_Language__c = 'Japanese';
        tpaRequest2.Vendor_Language__c = 'Japanese';
        tpaRequest2.Vendor_Billing_Mailing_Country__c = 'united states';
        tpaRequest2.Vendor_e_mail__c = 'test@mail.com';
        insert tpaRequest2;
    }

    @isTest static void test_BatchCPCRenewalExpirationMail() {
        Test.startTest();
        TPA_Request__c reqObj = UTL_TPA_SetupTestData.queryTPARequest();
        BCH_TPA_CPC_Renewal_Expiration_Mail batchObj = new BCH_TPA_CPC_Renewal_Expiration_Mail();
        Database.executebatch(batchObj, 2);

        BCH_TPA_CPC_Renewal_Expiration_Mail batchObj1 = new BCH_TPA_CPC_Renewal_Expiration_Mail(new List<String>{reqObj.id});
        Test.stopTest();
    }
}
