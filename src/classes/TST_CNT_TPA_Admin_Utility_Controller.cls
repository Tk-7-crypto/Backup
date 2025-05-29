/**
* @Author: Babita Dadarwal
* @Description : Test Class for CNT_TPA_Admin_Utility_Controller 
*/
@isTest(SeeAllData=false)
private class TST_CNT_TPA_Admin_Utility_Controller {
    @TestSetup 
    static void setup() {
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
        
        Contact_Address_Crosswalk__c cac = new Contact_Address_Crosswalk__c(Address__c = testAccount.Id, Contact__c = tpaContact.Id);
        insert cac;
        
        User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
        System.runAs (thisUser) {
            Profile profile = [SELECT Id FROM Profile WHERE Name like 'TPA Processor Profile CCP' LIMIT 1]; //Updated by Babita Dadarwal under ER-3552
    
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
            insert tpaRequest1;
        }
    }

    @isTest 
    static void test_AdminUtilityController() {
        Test.startTest();
        List<Contact> contactList = [SELECT Id, AccountId FROM Contact LIMIT 1];
        if(contactList.size() > 0) {
            CNT_TPA_Admin_Utility_Controller.getClientContacts('"' + contactList[0].AccountId + '"');
            CNT_TPA_Admin_Utility_Controller.getTPARequests('"' + contactList[0].Id + '"');
            CNT_TPA_Admin_Utility_Controller.isUserPresent('"' + contactList[0].Id + '"');
        }
        Test.stopTest();
    }

    @isTest 
    static void test_MoveRequest() {
        Test.startTest();
        List<Contact> contactList = [SELECT Id, AccountId FROM Contact LIMIT 1];
        List<TPA_Request__c> requestList = [SELECT Id, OwnerId, Client_Address__c, Name, Client_Company_Name_Address__c, ClientContact__c, Request_Status__c, CurrencyIsoCode, Data_Access_End_Date__c FROM TPA_Request__c LIMIT 1];
        if(contactList.size() > 0 && requestList.size() > 0) {
            String tparequestList = '[{"Id":"' + requestList[0].Id + '","OwnerId":"' + requestList[0].OwnerId + '","Client_Address__c":"' + requestList[0].Client_Address__c + '","Name":"' + requestList[0].Name + '","Client_Company_Name_Address__c":"' + requestList[0].Client_Company_Name_Address__c + '","ClientContact__c":"' + requestList[0].ClientContact__c + '","Request_Status__c":"' + requestList[0].Request_Status__c + '","Data_Access_End_Date__c":1472515200000,"CurrencyIsoCode":"' + requestList[0].CurrencyIsoCode + '"}]' ;
            CNT_TPA_Admin_Utility_Controller classObj = new CNT_TPA_Admin_Utility_Controller();
            CNT_TPA_Admin_Utility_Controller.moveTPARequests('"' + contactList[0].Id + '"', '"' + contactList[0].AccountId + '"', tparequestList);
        }
        Test.stopTest();
    }
}