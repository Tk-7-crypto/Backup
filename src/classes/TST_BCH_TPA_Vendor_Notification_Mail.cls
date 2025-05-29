/**
 * @Author: Chandra Prakash Pandey
 * @Description: Test class for BCH_TPA_Vendor_Notification_Mail Batch which sends reminder mail to the vendors who haven't submitted there part.
 */
@isTest(seeAllData=false)
private class TST_BCH_TPA_Vendor_Notification_Mail { 

    @TestSetup static void setup() {
        UTL_TPA_SetupTestData.createCrossWalkData();
        UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();
        UTL_TPA_SetupTestData.createTPASettingsData();
        UTL_TPA_SetupTestData.createTPASettingsDataBasedOnOrganization();

        Date todayDate = Date.today();

        Account acc =  new Account(Name = 'Test_Account', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert acc;
        
        Address__c testAccountparant1 = UTL_TPA_SetupTestData.getAddress();
        testAccountparant1.Name = 'ABC Acc Patent1';
        testAccountparant1.Account__c = acc.Id;
        testAccountparant1.Is_TPA_Account__c = true;
        testAccountparant1.Vendor_Registration_Number__c = 1241;
        testAccountparant1.Primary_Vendor_Address__c = true;
        insert testAccountparant1;
        
        Address__c testAccount1 = UTL_TPA_SetupTestData.getAccount();
        testAccount1.Name = 'Test_Acc';
        testAccount1.Account__c = acc.Id;
        testAccount1.Parent_Vendor_Name__c = testAccountparant1.id;
        insert testAccount1;

        Contact testContact = UTL_TPA_SetupTestData.getContact();
        testContact.AccountId = testAccount1.Account__c;
        insert testContact;
        
        TPA_TP_Processor__c tpProcessor = new TPA_TP_Processor__c(TP_Processor_Name__c = 'US TP Proccessor',
                                                                  TP_Processor_Email__c = 'a.b@metacube.com'); 
        insert tpProcessor;
        
        TPA_Assigned_TP_Processor__c tpaAssignedTPProcessor = new TPA_Assigned_TP_Processor__c(Email__c = 'a.c@metacube.com', Initials__c = 'AB', Is_Active__c = true, TP_Processor__c = tpProcessor.id);
        insert tpaAssignedTPProcessor;

        List<TPA_Request__c> reqLst = new List<TPA_Request__c>();

        TPA_Request__c testAgreement1 = UTL_TPA_SetupTestData.getAgreement();
        testAgreement1.Vendor_App_Sent__c = todayDate;
        testAgreement1.TPA_Assigned_TP_Processor__c = tpaAssignedTPProcessor.Id;
        testAgreement1.Request_Status__c = 'Awaiting Vendor Submission';
		testAgreement1.Service_Provider_Address__c = testAccount1.Id;
		testAgreement1.Data_Access_End_Date__c = todayDate.addDays(3);
		testAgreement1.Vendor_e_mail__c = 'test@mail.com';
		testAgreement1.Vendor_contact_email_client__c = 'test@mail.com';
		testAgreement1.Vendor_Language__c = 'Japanese';
        testAgreement1.Is_Vendor_Id_Invalid__c = False;
        //insert testAgreement1;
        reqLst.add(testAgreement1);

        TPA_Request__c testAgreement2 = UTL_TPA_SetupTestData.getAgreement();
        testAgreement2.Sent_for_Signature__c = todayDate;
        testAgreement2.Vendor_App_Sent__c = todayDate;
        testAgreement2.TPA_Assigned_TP_Processor__c = tpaAssignedTPProcessor.Id;
        testAgreement2.Vendor_Language__c = 'Japanese';
        testAgreement2.Request_Status__c = 'Awaiting Vendor Signature';
		testAgreement2.Service_Provider_Address__c = testAccount1.Id;
		testAgreement2.Vendor_Company_Name__c = 'Test Vendor Company';
		testAgreement2.Data_Access_End_Date__c = todayDate.addDays(3);
		testAgreement2.Vendor_e_mail__c = 'test@mail.com';
		testAgreement2.Vendor_contact_email_client__c = 'test@mail.com';
        testAgreement2.Is_Vendor_Id_Invalid__c = False;
        reqLst.add(testAgreement2);
        //insert testAgreement2;
        
        TPA_Request__c testAgreement3 = UTL_TPA_SetupTestData.getAgreement();
        testAgreement3.Sent_for_Signature__c = todayDate;
        testAgreement3.Vendor_App_Sent__c = todayDate;
        testAgreement3.TPA_Assigned_TP_Processor__c = tpaAssignedTPProcessor.Id;
        testAgreement3.Vendor_Language__c = 'English';
        testAgreement3.Request_Status__c = 'Pending Vendor Response on Data Destruction from Prior TPAs';
		testAgreement3.Service_Provider_Address__c = testAccount1.Id;
        testAgreement3.Global_Branding_Vendor_Address__c = testAccountparant1.Id;
		testAgreement3.Vendor_Company_Name__c = 'Test Vendor Company';
		testAgreement3.Data_Access_End_Date__c = todayDate.addDays(3);
		testAgreement3.Vendor_e_mail__c = 'test@mail.com';
		testAgreement3.Vendor_contact_email_client__c = 'test@mail.com';
        testAgreement3.Is_Vendor_Id_Invalid__c = False;
        reqLst.add(testAgreement3);
        //insert testAgreement3;
        
        TPA_Request__c testAgreement4 = UTL_TPA_SetupTestData.getAgreement();
        testAgreement4.Sent_for_Signature__c = todayDate;
        testAgreement4.Vendor_App_Sent__c = todayDate;
        testAgreement4.TPA_Assigned_TP_Processor__c = tpaAssignedTPProcessor.Id;
        testAgreement4.Vendor_Language__c = 'English';
        testAgreement4.Request_Status__c = 'Expired';
		testAgreement4.Service_Provider_Address__c = testAccount1.Id;
		testAgreement4.Vendor_Company_Name__c = 'Test Vendor Company';
		testAgreement4.Data_Access_End_Date__c = todayDate.addDays(3);
		testAgreement4.Vendor_e_mail__c = 'test@mail.com';
		testAgreement4.Vendor_contact_email_client__c = 'test@mail.com';
        testAgreement4.Is_Vendor_Id_Invalid__c = False;
        reqLst.add(testAgreement4);
        //insert reqLst;
        
        TPA_Request__c testAgreement5 = UTL_TPA_SetupTestData.getAgreement();
        testAgreement5.Sent_for_Signature__c = todayDate;
        testAgreement5.Vendor_App_Sent__c = todayDate;
        testAgreement5.TPA_Assigned_TP_Processor__c = tpaAssignedTPProcessor.Id;
        testAgreement5.Vendor_Language__c = 'English';
        testAgreement5.Request_Status__c = 'In Review By IQVIA';
		testAgreement5.Service_Provider_Address__c = testAccount1.Id;
		testAgreement5.Vendor_Company_Name__c = 'Test Vendor Company';
		testAgreement5.Data_Access_End_Date__c = todayDate.addDays(3);
		testAgreement5.Vendor_e_mail__c = 'test@mail.com';
		testAgreement5.Vendor_contact_email_client__c = 'test@mail.com';
        testAgreement5.Is_Vendor_Id_Invalid__c = False;
        reqLst.add(testAgreement5);
        insert reqLst;
        
        TPA_Request__c reqObj = [Select id,name from TPA_Request__c where Request_Status__c = 'Expired'];
        TPA_Master_Extension_Information__c vendorOffRetAckObj = new TPA_Master_Extension_Information__c(
            TPA_Accounts_Address__c = testAccountparant1.Id,
            DDN_Ack_Pending_Requests__c = reqObj.name,
            Return_Destruction_Ack_Outstanding__c = true);
        
        insert vendorOffRetAckObj;

        reqObj.Vendor_Address_Extension_Record__c = vendorOffRetAckObj.id;
        update reqObj;

        TPA_Contact__c tpaContact = UTL_TPA_SetupTestData.getTestTPAContact(testAgreement1);
        insert tpaContact;
        
    }

    @isTest static void test_SendRemainderMail(){
        BCH_TPA_Vendor_Notification_Mail vendorNotificationTrigger = new BCH_TPA_Vendor_Notification_Mail();
        vendorNotificationTrigger.remindTPProcessortype = true;
        Database.executebatch(vendorNotificationTrigger, 3);
    }

    @isTest static void test_SendVendorNotificationMail() {
        Test.startTest();

        BCH_TPA_Vendor_Notification_Mail vendorNotificationTrigger = new BCH_TPA_Vendor_Notification_Mail();
        Database.executebatch(vendorNotificationTrigger, 3);

        List<TPA_Request__c> agreementList = [SELECT Id, Name, Request_Status__c,Vendor_Language__c
                                              ,Vendor_Contact_Email_Client__c, TP_Processor_Email__c,TPA_Assigned_TP_Processor__c,TPA_Assigned_TP_Processor__r.Initials__c, TPA_Assigned_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c
                                              FROM TPA_Request__c where Request_Status__c in ('Awaiting Vendor Signature','Awaiting Vendor Submission','Pending Vendor Response on Data Destruction from Prior TPAs')];
        List<TPA_Request__c> agreementList1 = [Select id, Service_Provider_f__c, Service_Provider_Contact_f__c, 
                                                Vendor_Contact_e_mail__c, name, ClientContact__r.Email 
                                                , Vendor_e_mail__c, TP_Processor_Email__c, Authorized_Signer_Email__c,TPA_Assigned_TP_Processor__c,TPA_Assigned_TP_Processor__r.Initials__c, TPA_Assigned_TP_Processor__r.Is_Active__c, Co_Assigned_Global_TP_Processor__c, Co_Assigned_Global_TP_Processor__r.Is_Active__c,  Co_Assigned_Global_TP_Processor__r.Initials__c, 
                                                (select id, Email__c from TPA_Request_Contacts__r) FROM TPA_Request__c where Request_Status__c in ('Expired')];

        
        for(TPA_Request__c agreement : agreementList) {
            if(agreement.Request_Status__c == 'Awaiting Vendor Signature') {
                vendorNotificationTrigger.sendAwaitingSignatureReminderMailToClient(agreement, agreement.Id, new List<String>{'test@gmail.com'}, 'Japanese', new List<String>{'test@gmail.com'});
            } else if(agreement.Request_Status__c == 'Awaiting Vendor Submission') {
                vendorNotificationTrigger.sendAwaitingVendorSubmissionReminderMailToClient(agreement, agreement.Id, new List<String>{'test@gmail.com'}, 'Japanese', new List<String>{'test@gmail.com'});
            } else if(agreement.Request_Status__c == 'Pending Vendor Response on Data Destruction from Prior TPAs') {
                vendorNotificationTrigger.sendDataDestructionAckOutstandingMail(agreementList1, agreement);
            }
        }
        Test.stopTest();
    }
}
