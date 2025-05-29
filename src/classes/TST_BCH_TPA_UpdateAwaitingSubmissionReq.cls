/**
 * @author   : C.P.Pandey
 * Purpose   : Test for TPA_Batch_UpdateAwaitingSubmissionReq class.
 * 
 */
@isTest(SeeAllData = False)
private class TST_BCH_TPA_UpdateAwaitingSubmissionReq {
    private static Address__c testAccount;
    private static Address__c testAccount2;
    private static TPA_Request__c TestAgreement1;
    private static TPA_Request__c TestAgreement2;
    private static TPA_Request__c TestAgreement3;
    private static TPA_Request__c TestAgreement4;
    private static TPA_Request__c TestAgreement5;
    private static TPA_Request__c TestAgreement6;
    private static TPA_Request__c TestAgreement7;
    private static TPA_Request__c TestAgreement8;
    private static TPA_Request__c TestAgreement9;
    private static TPA_Agreement_Additional_Field__c AgrAdditionalObj;
    private static Contact tpaContact;
    private static Contact tpaContact2;
    private static Address__c testClientAccount;
    private static User usr;

    /**
    * Data Set Up Method.
    */
    @testSetup
    static void setupData() {
        UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();
        UTL_TPA_SetupTestData.createTPASettingsData();
    }
    
    /**
    * Test Method to test the create and send envelope.
    */
    @isTest
    static void testConditionAllCases()
    {
        Date todayDate = Date.today();
        testAccount = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('Test_vendor',1200);
         
        tpaContact = UTL_TPA_SetupTestData.getTestContact(testAccount);
      
        TestAgreement1 = UTL_TPA_SetupTestData.getAgreement();
        TestAgreement1.request_status__c = 'Awaiting Vendor Submission';
        TestAgreement1.Is_Submitted__c = true;
        TestAgreement1.client_Request_Submission__c = todayDate.addDays(-1);
        TestAgreement1.Client_Address__c = testAccount.id;
        TestAgreement1.ClientContact__c = tpaContact.id;  
        
        TestAgreement2 = UTL_TPA_SetupTestData.getAgreementByName();
        TestAgreement2.request_status__c = 'Awaiting Vendor Submission';
        TestAgreement2.Is_Submitted__c = true;
        TestAgreement2.client_Request_Submission__c = todayDate.addDays(-2);
        TestAgreement2.Client_Address__c = testAccount.id;
        TestAgreement2.ClientContact__c = tpaContact.id;
        
        upsert new List<TPA_Request__c> {TestAgreement1, TestAgreement2};
        TestAgreement1.client_Request_Submission__c = todayDate.addDays(-1);
        TestAgreement2.client_Request_Submission__c = todayDate.addDays(-3);
        update new List<TPA_Request__c> {TestAgreement1, TestAgreement2};
        
        Test.startTest();        
        TestAgreement3 = UTL_TPA_SetupTestData.getAgreementByName();
        TestAgreement3.request_status__c = 'Awaiting Vendor Signature';
        TestAgreement3.Is_Submitted__c = true;
        TestAgreement3.Sent_for_Signature__c = todayDate.addDays(-1);
        TestAgreement3.Client_Address__c = testAccount.id;
        TestAgreement3.ClientContact__c = tpaContact.id;
        
        TestAgreement4 = UTL_TPA_SetupTestData.getAgreementByName();
        TestAgreement4.request_status__c = 'Awaiting Vendor Signature';
        TestAgreement4.Is_Submitted__c = true;
        TestAgreement4.Sent_for_Signature__c = todayDate.addDays(-2);
        TestAgreement4.Client_Address__c = testAccount.id;
        TestAgreement4.ClientContact__c = tpaContact.id;
        
        upsert new List<TPA_Request__c> {TestAgreement3, TestAgreement4};
        TestAgreement3.Sent_for_Signature__c = todayDate.addDays(-1);
        TestAgreement3.Prevent_Cancellation__c = false;        
        TestAgreement4.Sent_for_Signature__c = todayDate.addDays(-3);
        TestAgreement4.Prevent_Cancellation__c = false;
        update new List<TPA_Request__c> {TestAgreement1, TestAgreement2, TestAgreement3};
        
        BCH_TPA_UpdateAwaitingSubmissionReq  objBatch = new BCH_TPA_UpdateAwaitingSubmissionReq();
        Database.executeBatch(objBatch,4);
        Test.stopTest();
    }
    
    /**
    * Test Method to test the create and send envelope.
    */
    @isTest
    static void testConditionAllCases_1()
    {
        Date todayDate = Date.today();
        testAccount = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('Test_vendor',1200);
         
        tpaContact = UTL_TPA_SetupTestData.getTestContact(testAccount);
      
        TestAgreement1 = UTL_TPA_SetupTestData.getAgreement();
        TestAgreement1.request_status__c = 'Awaiting Vendor Submission';
        TestAgreement1.Is_Submitted__c = true;
        TestAgreement1.client_Request_Submission__c = todayDate.addDays(-2);
        TestAgreement1.Client_Address__c = testAccount.id;
        TestAgreement1.ClientContact__c = tpaContact.id;
        
        TestAgreement2 = UTL_TPA_SetupTestData.getAgreementByName();
        TestAgreement2.request_status__c = 'Awaiting Vendor Submission';
        TestAgreement2.Is_Submitted__c = true;
        TestAgreement2.client_Request_Submission__c = todayDate.addDays(-3);
        TestAgreement2.Client_Address__c = testAccount.id;
        TestAgreement2.ClientContact__c = tpaContact.id;
        
        upsert new List<TPA_Request__c> {TestAgreement1, TestAgreement2};
        TestAgreement1.client_Request_Submission__c = todayDate.addDays(-2);
        TestAgreement2.client_Request_Submission__c = todayDate.addDays(-4);
        update new List<TPA_Request__c> {TestAgreement1, TestAgreement2};
        
        Test.startTest();
        TestAgreement3 = UTL_TPA_SetupTestData.getAgreementByName();
        TestAgreement3.request_status__c = 'Awaiting Vendor Signature';
        TestAgreement3.Is_Submitted__c = true;
        TestAgreement3.Sent_for_Signature__c = todayDate.addDays(-2);
        TestAgreement3.Client_Address__c = testAccount.id;
        TestAgreement3.ClientContact__c = tpaContact.id;
        
        TestAgreement4 = UTL_TPA_SetupTestData.getAgreementByName();
        TestAgreement4.request_status__c = 'Awaiting Vendor Signature';
        TestAgreement4.Is_Submitted__c = true;
        TestAgreement4.Sent_for_Signature__c = todayDate.addDays(-3);
        TestAgreement4.Client_Address__c = testAccount.id;
        TestAgreement4.ClientContact__c = tpaContact.id;
        
        upsert new List<TPA_Request__c> {TestAgreement3, TestAgreement4};
        TestAgreement3.Sent_for_Signature__c = todayDate.addDays(-2);
        TestAgreement3.Prevent_Cancellation__c = false;
        TestAgreement4.Sent_for_Signature__c = todayDate.addDays(-4);
        TestAgreement4.Prevent_Cancellation__c = false;
        
        update new List<TPA_Request__c> {TestAgreement3, TestAgreement4};
        
        BCH_TPA_UpdateAwaitingSubmissionReq  objBatch = new BCH_TPA_UpdateAwaitingSubmissionReq();
        Database.executeBatch(objBatch,4);
        Test.stopTest();
    }
    
    @isTest
    static void testConditionAllCases1()
    {
        Date todayDate = Date.today();
        testAccount2 = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('Test vendor',1300);
        
        tpaContact2 = UTL_TPA_SetupTestData.getTestContact(testAccount2);        
        TestAgreement1 = UTL_TPA_SetupTestData.getAgreement();
        TestAgreement1.request_status__c = 'Awaiting Vendor Submission';
        TestAgreement1.Is_Submitted__c = true;
        TestAgreement1.client_Request_Submission__c = todayDate.addDays(-2);
        TestAgreement1.Client_Address__c = testAccount2.id;
        TestAgreement1.ClientContact__c = tpaContact2.id;   
        
        TestAgreement2 = UTL_TPA_SetupTestData.getAgreementByName();
        TestAgreement2.request_status__c = 'Awaiting Vendor Submission';
        TestAgreement2.Is_Submitted__c = true;
        TestAgreement2.client_Request_Submission__c = todayDate.addDays(-3);
        TestAgreement2.Client_Address__c = testAccount2.id;
        TestAgreement2.ClientContact__c = tpaContact2.id;
        
        upsert new List<TPA_Request__c> {TestAgreement1, TestAgreement2};
        TestAgreement1.client_Request_Submission__c = todayDate.addDays(-29);
        TestAgreement2.client_Request_Submission__c = todayDate.addDays(-44);
        update new List<TPA_Request__c> {TestAgreement1, TestAgreement2};
        
        Test.startTest();
        TestAgreement3 = UTL_TPA_SetupTestData.getAgreementByName();
        TestAgreement3.request_status__c = 'Awaiting Vendor Signature';
        TestAgreement3.Is_Submitted__c = true;
        TestAgreement3.Sent_for_Signature__c = todayDate.addDays(-1);
        TestAgreement3.Client_Address__c = testAccount2.id;
        TestAgreement3.ClientContact__c = tpaContact2.id;
        
        TestAgreement4 = UTL_TPA_SetupTestData.getAgreementByName();
        TestAgreement4.request_status__c = 'Awaiting Vendor Signature';
        TestAgreement4.Is_Submitted__c = true;
        TestAgreement4.Sent_for_Signature__c = todayDate.addDays(-3);
        TestAgreement4.Client_Address__c = testAccount2.id;
        TestAgreement4.ClientContact__c = tpaContact2.id;
        
        upsert new List<TPA_Request__c> {TestAgreement3, TestAgreement4};
        TestAgreement3.Sent_for_Signature__c = todayDate.addDays(-44);
        TestAgreement3.Prevent_Cancellation__c = false;
        TestAgreement4.Sent_for_Signature__c = todayDate.addDays(-59);
        TestAgreement4.Prevent_Cancellation__c = false;
        update new List<TPA_Request__c> {TestAgreement3, TestAgreement4};
        
        BCH_TPA_UpdateAwaitingSubmissionReq  objBatch = new BCH_TPA_UpdateAwaitingSubmissionReq();
        Database.executeBatch(objBatch,9);
        Test.stopTest();
    }
    
    @isTest
    static void testConditionAllCases_2()
    {
        Date todayDate = Date.today();
        testAccount2 = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('Test vendor',1300);
         
        tpaContact2 = UTL_TPA_SetupTestData.getTestContact(testAccount2);        
        TestAgreement1 = UTL_TPA_SetupTestData.getAgreement();
        TestAgreement1.request_status__c = 'Awaiting Vendor Submission';
        TestAgreement1.Is_Submitted__c = true;
        TestAgreement1.client_Request_Submission__c = todayDate.addDays(-3);
        TestAgreement1.Client_Address__c = testAccount2.id;
        TestAgreement1.ClientContact__c = tpaContact2.id;
        
        TestAgreement2 = UTL_TPA_SetupTestData.getAgreementByName();
        TestAgreement2.request_status__c = 'Awaiting Vendor Submission';
        TestAgreement2.Is_Submitted__c = true;
        TestAgreement2.client_Request_Submission__c = todayDate.addDays(-4);
        TestAgreement2.Client_Address__c = testAccount2.id;
        TestAgreement2.ClientContact__c = tpaContact2.id;
        
        upsert new List<TPA_Request__c> {TestAgreement1, TestAgreement2};
        TestAgreement1.client_Request_Submission__c = todayDate.addDays(-30);
        TestAgreement2.client_Request_Submission__c = todayDate.addDays(-45);
        update new List<TPA_Request__c> {TestAgreement1, TestAgreement2};
        
        Test.startTest();
        TestAgreement3 = UTL_TPA_SetupTestData.getAgreementByName();
        TestAgreement3.request_status__c = 'Awaiting Vendor Signature';
        TestAgreement3.Is_Submitted__c = true;
        TestAgreement3.Sent_for_Signature__c = todayDate.addDays(-2);
        TestAgreement3.Client_Address__c = testAccount2.id;
        TestAgreement3.ClientContact__c = tpaContact2.id;
        
        TestAgreement4 = UTL_TPA_SetupTestData.getAgreementByName();
        TestAgreement4.request_status__c = 'Awaiting Vendor Signature';
        TestAgreement4.Is_Submitted__c = true;
        TestAgreement4.Sent_for_Signature__c = todayDate.addDays(-4);
        TestAgreement4.Client_Address__c = testAccount2.id;
        TestAgreement4.ClientContact__c = tpaContact2.id;
        
        upsert new List<TPA_Request__c> {TestAgreement3, TestAgreement4};
        TestAgreement3.Sent_for_Signature__c = todayDate.addDays(-45);
        TestAgreement3.Prevent_Cancellation__c = false;
        TestAgreement4.Sent_for_Signature__c = todayDate.addDays(-60);
        TestAgreement4.Prevent_Cancellation__c = false;
        
        update new List<TPA_Request__c> {TestAgreement3, TestAgreement4};
        
        BCH_TPA_UpdateAwaitingSubmissionReq  objBatch = new BCH_TPA_UpdateAwaitingSubmissionReq();
        Database.executeBatch(objBatch,9);
        Test.stopTest();
    }
    
    @isTest
    static void testConditionAllCases2()
    {
        Date todayDate = Date.today();
        
        testAccount = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('Test_vendor',1201);
        testAccount2 = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('Test vendor',1301);
        
        tpaContact = UTL_TPA_SetupTestData.getTestContact(testAccount);
        tpaContact2 = UTL_TPA_SetupTestData.getTestContact(testAccount2); 
        
        TestAgreement5 = UTL_TPA_SetupTestData.getAgreementByName();
        TestAgreement5.request_status__c = 'Awaiting Vendor Signature';
        TestAgreement5.Is_Submitted__c = true;
        TestAgreement5.Sent_for_Signature__c = todayDate.addDays(-5);
        TestAgreement5.Client_Address__c = testAccount2.id;
        TestAgreement5.ClientContact__c = tpaContact2.id;
        
        TestAgreement5.Sent_for_Signature__c = todayDate.addDays(-61);
        TestAgreement5.Prevent_Cancellation__c = false;
        
        TestAgreement1 = UTL_TPA_SetupTestData.getAgreementByName();
        TestAgreement1.request_status__c = 'Awaiting Vendor Signature';
        TestAgreement1.Is_Submitted__c = true;
        TestAgreement1.Sent_for_Signature__c = todayDate.addDays(-5);
        TestAgreement1.Client_Address__c = testAccount.id;
        TestAgreement1.ClientContact__c = tpaContact.id;
        
        //upsert new List<TPA_Request__c> {TestAgreement1, TestAgreement5};
        TestAgreement1.Sent_for_Signature__c = todayDate.addDays(-5);
        TestAgreement1.Prevent_Cancellation__c = false;
        
        update new List<TPA_Request__c> {TestAgreement1, TestAgreement5};
        
        Test.startTest();
        BCH_TPA_UpdateAwaitingSubmissionReq  objBatch = new BCH_TPA_UpdateAwaitingSubmissionReq();
        Database.executeBatch(objBatch,9);
        Test.stopTest();
    }
}