@isTest
private class TST_DAOH_TPADataAsset {
    static testMethod void myUnitTest() {
    	
    	Address__c testAccount1 = UTL_TPA_SetupTestData.getAccount();
        testAccount1.Name = 'Test Acc';
        insert testAccount1;

        Contact testContact = UTL_TPA_SetupTestData.getContact();
        testContact.AccountId = testAccount1.Account__c;
        insert testContact;
    	
    	TPA_Request__c tpaRequest1 = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest1.OwnerId = UserInfo.getUserId();
        tpaRequest1.Service_Provider_Address__c = testAccount1.Id;
        tpaRequest1.Client_Address__c = testAccount1.Id;
        tpaRequest1.Client_Language__c = 'Japanese';
        tpaRequest1.Vendor_Language__c = 'Japanese';
        tpaRequest1.Vendor_Billing_Mailing_Country__c = 'united states';
        tpaRequest1.Request_Status__c = 'Expired';
        tpaRequest1.Data_Access_End_Date__c = Date.today().addDays(-1);
        tpaRequest1.ClientContact__c = testContact.Id;
        tpaRequest1.Is_Renewed__c = false;
        tpaRequest1.Purpose_List__c = 'Test Purpose List';
        tpaRequest1.Data_Asset_List__c = 'AAN';
        tpaRequest1.IMS_Legal_Entity_List__c = 'test';
        tpaRequest1.Secondary_Data_Asset_List__c = 'Test';
        tpaRequest1.Client_Request_Submission__c = Date.today().addDays(2);
        tpaRequest1.Request_Status__c = 'In Effect';
        tpaRequest1.TP_Processor_Email__c = 'test@mail.com';
        tpaRequest1.Data_access_end_date__c = (Date.today()).addDays(3);
        tpaRequest1.Vendor_Language__c =  'English';
        insert tpaRequest1;
    	
        TPA_Purpose__c tpaPurpose = UTL_TPA_SetupTestData.createTpaPurposeByReqId(tpaRequest1);
        insert tpaPurpose;
        
        TPA_Data_Asset__c tpaDataAsset = UTL_TPA_SetupTestData.getTpaDataAsset(tpaPurpose.Id);
        insert tpaDataAsset;
        update tpaDataAsset;
        delete tpaDataAsset;
    }
}