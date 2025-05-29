/**
* @Description : Test Class for BCH_TPA_MoveTPARequests
*/
@isTest(SeeAllData=false)
private class TST_BCH_TPA_MoveTPARequests {
    @TestSetup static void setup() {
        TPA_Settings__c tpaSetting = UTL_TPA_SetupTestData.createTPASettingsData();
        tpaSetting.SystemAdminId__c = tpaSetting.Id;
        update tpaSetting;

        Date todayDate = Date.today();
		Account acc = new Account(Name = 'Test Account', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert acc;
        
        Address__c testAccount = UTL_TPA_SetupTestData.getAccount();
        testAccount.Account__c = acc.Id;
        insert testAccount;

        Contact tpaContact = UTL_TPA_SetupTestData.getContact();
        tpaContact.AccountId = testAccount.Account__c;
        insert tpaContact;

        Profile profile = [SELECT Id FROM Profile WHERE Name like 'TPA Processor Profile CCP' LIMIT 1]; 

        User user = UTL_TPA_SetupTestData.getUser();
        user.ProfileId = profile.Id;
        user.ContactId= tpaContact.Id;
        insert user;

        TPA_Request__c tpaRequest1 = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest1.OwnerId = UserInfo.getUserId();
        tpaRequest1.Service_Provider_Address__c = testAccount.Id;
        tpaRequest1.Client_Address__c = testAccount.Id;
        tpaRequest1.Client_Language__c = 'Japanese';
        tpaRequest1.Vendor_Language__c = 'Japanese';
        tpaRequest1.Vendor_Billing_Mailing_Country__c = 'united states';
		tpaRequest1.Purpose_List__c = 'Test Purpose List';
		tpaRequest1.Data_Asset_List__c = 'AAN';
		tpaRequest1.Vendor_Billing_Mailing_Country__c = 'united states';
		tpaRequest1.IMS_Legal_Entity_List__c = 'test';
		tpaRequest1.Agreement_Number__c = '123';
		tpaRequest1.Secondary_Data_Asset_List__c = 'Test';
		tpaRequest1.Client_Request_Submission__c = todayDate.addDays(2);
        insert tpaRequest1;

    }



    @isTest static void test_MoveRequest() {
        Test.startTest();
        List<Contact> contactList = [SELECT Id, AccountId FROM Contact LIMIT 1];
        List<TPA_Request__c> requestList = [SELECT Id, OwnerId, Client_Address__c, Name, Client_Company_Name_Address__c, ClientContact__c, Request_Status__c, CurrencyIsoCode, Data_Access_End_Date__c FROM TPA_Request__c LIMIT 1];
        if(contactList.size() > 0 && requestList.size() > 0) {
            DateTime calculatedTime = DateTime.newInstance(1472515200000L);

            String tparequestList = '[{"Id":"' + requestList[0].Id + '","OwnerId":"' + requestList[0].OwnerId + '","Client_Address__c":"' + requestList[0].Client_Address__c + '","Name":"' + requestList[0].Name + '","Client_Company_Name_Address__c":"' + requestList[0].Client_Company_Name_Address__c + '","ClientContact__c":"' + requestList[0].ClientContact__c + '","Request_Status__c":"' + requestList[0].Request_Status__c + '","Data_Access_End_Date__c":' + String.valueOf(calculatedTime.getTime()) + ',"CurrencyIsoCode":"' + requestList[0].CurrencyIsoCode + '"}]' ;
            CNT_TPA_Admin_Utility_Controller classObj = new CNT_TPA_Admin_Utility_Controller();
            CNT_TPA_Admin_Utility_Controller.moveTPARequests('"' + contactList[0].Id + '"', '"' + contactList[0].AccountId + '"', tparequestList);
        }
		// BCH_TPA_MoveTPARequests batchObj = new BCH_TPA_MoveTPARequests();
        //Database.executebatch(batchObj, 2);
        Test.stopTest();
    }
}