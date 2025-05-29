@isTest(seeAllData=false)
public class TST_CNT_TPA_OfferingsDetails {
    @testsetup
    private static void setupTestData() {
         Account acc = new Account(Name = 'Test acc', CurrencyIsoCode = 'USD', Region_Territory__c = 'China', BillingStreet = 'test1', BillingCity = 'test1', BillingCountry = 'test1', BillingPostalCode = 'test1', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert acc;
         Contact  con = new Contact(FirstName = 'TestFirstName', LastName = 'Test Contact', Email = 'testuser@test1.com', AccountId = acc.id);
        
        insert con;
        Profile p = [SELECT Id, Name FROM Profile WHERE Name like 'US TP Processor Profile CCP%' Limit 1];
        User user = new User(Alias = 'standt', Email='standarduser123@testorg.com', EmailEncodingKey='UTF-8', LastName='Testing',
                             ProfileId = p.id, LanguageLocaleKey='en_US', LocaleSidKey='en_US', UserName='testuser123@testing123.com',
                             TimeZoneSidKey='America/Los_Angeles', ContactId = con.id, TPA_Is_Privacy_Policy_Agreed__c = false, TPA_Is_Show_TPA_Down_Message__c = false);
        insert user;
        
        UTL_TPA_SetupTestData.createTPASettingData();
        Address__c TestAccount = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('Test Account',9999);
        tpa_request__c tpaRequest = UTL_TPA_SetupTestData.getTPARequestByVendorAccount(TestAccount.Id);
    }
    
    public static testMethod void testTPARecords(){ 
        User testUser = [select id, Name,Profile.Name, Email, TimeZoneSidKey, TPA_Is_Privacy_Policy_Agreed__c,TPA_Is_Show_TPA_Down_Message__c, UserName from User Limit 1];
        TPA_Request__c testRequest = [select id from TPA_Request__c limit 1];
        
        Test.startTest();
        System.runAs(testUser) {
           testRequest = CNT_TPA_OfferingsDetails.fetchTPARecords(testRequest.id);
           Assert.areEqual(testUser.Profile.Name , CNT_TPA_OfferingsDetails.currentUserProfileName , 'Not Equal');
           //Assert.areEqual(testUser, CNT_TPA_OfferingsDetails.currentLoggedInUser, 'Not Equal');
           Assert.areEqual(String.valueOf(URL.getOrgDomainUrl()), CNT_TPA_OfferingsDetails.tpaCommunityUrl, 'Are not Equal');
       }
       Test.stopTest();
   }
}