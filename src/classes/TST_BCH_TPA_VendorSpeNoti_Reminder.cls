@isTest(SeeAllData=False)
public class TST_BCH_TPA_VendorSpeNoti_Reminder {
    private static TPA_Request__c tpaRequest1;
    private static TPA_Request__c TestAgreement1;
    private static TPA_Request__c TestAgreement3;
    private static TPA_Agreement_Additional_Field__c AgrAdditionalObj;
    private static TPA_Request__c tpaRequest2;
    private static TPA_Request__c TestAgreement2;
    private static TPA_Request__c TestAgreement4;
    private static List<TPA_Request__c> listTpaRequest;
    private static TPA_Agreement_Additional_Field__c AgrAdditionalObj2;
    private static Contact tpaContact;
    private static Contact tpaContact1;
    private static Address__c testAccount;
    private static Address__c testClientAccount;
    private static Address__c testAccount1;
    private static Address__c testClientAccount1;
    private static User usr;
    
    public static testMethod void testTPABatchVendorSpeNotReminder() {
        Date todayDate = Date.today(); 
        TST_BCH_TPA_VendorSpeNoti_Reminder instance = new TST_BCH_TPA_VendorSpeNoti_Reminder();
        Test.startTest();
		instance.setupTestData();
        Test.stopTest();     
        BCH_TPA_VendorSpeNoti_Reminder agreementUpdateStatusTrigger = new BCH_TPA_VendorSpeNoti_Reminder();
        Database.executebatch(agreementUpdateStatusTrigger,5);
        AgrAdditionalObj.Pending_Cancellation_Date__c = todayDate.addDays(2);
        AgrAdditionalObj.Vendor_Specific_Notification_Response__c = 'Acknowledge';
        update AgrAdditionalObj;
        AgrAdditionalObj2.Pending_Cancellation_Date__c = todayDate.addDays(2);
        update AgrAdditionalObj2;
        
    }
    
    private void setupTestData() {
        Date todayDate = Date.today();
        
        UTL_TPA_SetupTestData.createTPASettingData();
        testAccount = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('Test_vendor',1200);
        testAccount1 = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('Account_vendor',1201);
        testClientAccount = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('Test client',1211);
        //testClientAccount1 = UTL_TPA_SetupTestData.getTestAccountByNameAndRegNum('Account client',1212);
        tpaContact = UTL_TPA_SetupTestData.getTestContact(testAccount);
        //tpaContact1 = UTL_TPA_SetupTestData.getTestContact(testAccount1);
        TPA_TP_Processor__c tpProcessor = new TPA_TP_Processor__c(TP_Processor_Name__c = 'US TP Proccessor',
                                                                  TP_Processor_Email__c = 'a.b@metacube.com'); 
        insert tpProcessor;
        
        TPA_Assigned_TP_Processor__c tpaAssignedTPProcessor = new TPA_Assigned_TP_Processor__c(Email__c = 'a.c@metacube.com', Initials__c = 'AB', Is_Active__c = true, TP_Processor__c = tpProcessor.id);
        insert tpaAssignedTPProcessor;
        
        listTpaRequest = new List<TPA_Request__c>();
        TestAgreement1 = UTL_TPA_SetupTestData.getAgreement();
        TestAgreement1.request_status__c = 'Awaiting Account Mgmt Communication';
        TestAgreement1.Is_Submitted__c = true;
        TestAgreement1.TPA_Assigned_TP_Processor__c = tpaAssignedTPProcessor.Id;
        TestAgreement1.Vendor_App_Submitted__c = todayDate.addDays(3);
        TestAgreement1.is_LAAD_Response_Required__c = true;
        TestAgreement1.Service_Provider_Address__c = testClientAccount.Id;
        TestAgreement1.ClientContact__c = tpaContact.Id;
		TestAgreement1.TP_Processor_Email__c = 'test@mail.com';
        listTpaRequest.add(TestAgreement1);
        //upsert TestAgreement1;        
        
        TestAgreement2 = UTL_TPA_SetupTestData.getAgreement();
        TestAgreement2.request_status__c = UTL_TPA.AWAITING_CLIENT_CONFIRMATION;
        TestAgreement2.Is_Submitted__c = true;
        TestAgreement2.TPA_Assigned_TP_Processor__c = tpaAssignedTPProcessor.Id;
        TestAgreement2.Vendor_App_Submitted__c = todayDate.addDays(1);
        TestAgreement2.is_LAAD_Response_Required__c = true;
        TestAgreement2.Service_Provider_Address__c = testAccount.Id;
        TestAgreement2.Client_Address__c = testClientAccount.Id;
        TestAgreement2.ClientContact__c = tpaContact.Id;
		TestAgreement2.TP_Processor_Email__c = 'test@mail.com';
        listTpaRequest.add(TestAgreement2);
        
		TestAgreement3 = UTL_TPA_SetupTestData.getAgreement();
        TestAgreement3.request_status__c = 'Pending Cancellation';
        TestAgreement3.Is_Submitted__c = true;
        TestAgreement3.TPA_Assigned_TP_Processor__c = tpaAssignedTPProcessor.Id;
        TestAgreement3.Vendor_App_Submitted__c = todayDate.addDays(3);
        TestAgreement3.is_LAAD_Response_Required__c = false;
        TestAgreement3.Service_Provider_Address__c = testAccount1.Id;
        TestAgreement3.Client_Address__c = testAccount1.Id;
        TestAgreement3.ClientContact__c = tpaContact.Id;
		TestAgreement3.TP_Processor_Email__c = 'test@mail.com';
        listTpaRequest.add(TestAgreement3);
        
        TestAgreement4 = UTL_TPA_SetupTestData.getAgreement();
        TestAgreement4.request_status__c = 'Awaiting Account Mgmt Communication';
        TestAgreement4.Is_Submitted__c = true;
        TestAgreement4.TPA_Assigned_TP_Processor__c = tpaAssignedTPProcessor.Id;
        TestAgreement4.Vendor_App_Submitted__c = todayDate.addDays(3);
        TestAgreement4.is_LAAD_Response_Required__c = true;
        TestAgreement4.Service_Provider_Address__c = testAccount.Id;
        TestAgreement4.Client_Address__c = testAccount.Id;
        TestAgreement4.ClientContact__c = tpaContact.Id;
		TestAgreement4.TP_Processor_Email__c = 'test@mail.com';
        listTpaRequest.add(TestAgreement4);
        upsert listTpaRequest; 
        
        DateTime vendorSubmissionDateTime = TestAgreement2.Vendor_App_Submitted__c;
        Date vendorSubmissionDate = date.newinstance(vendorSubmissionDateTime.year(), vendorSubmissionDateTime.month(), vendorSubmissionDateTime.day());
        Integer dayDiff = vendorSubmissionDate.daysBetween(todayDate); 
        System.debug('dayDiff: '+math.mod(dayDiff, 1)); 
        
        AgrAdditionalObj = UTL_TPA_SetupTestData.getTPAAgreementAdditionalFieldObj(TestAgreement3);
        AgrAdditionalObj2 = UTL_TPA_SetupTestData.getTPAAgreementAdditionalFieldObj(TestAgreement2);
        UTL_TPA_SetupTestData.addAttachmentToParent(TestAgreement3.Id,'Offerings Notification.pdf'); 
        UTL_TPA_SetupTestData.addAttachmentToParent(TestAgreement2.Id,'Offerings Notification.pdf'); 
        
       // List<TPA_Request__c> lstTestAgreement = [select id , name , request_status__c, Related_TPA_Request__c, Is_Submitted__c from TPA_Request__c];
      //  system.debug('lstTestAgreement'+lstTestAgreement);
    }    
}
