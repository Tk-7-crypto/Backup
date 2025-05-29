@isTest(seeAllData=false)
private class TST_BCH_TPA_sendTPAMailsOnIQVIA { 

    @TestSetup static void setup() {
        UTL_TPA_SetupTestData.createCrossWalkData();
        UTL_TPA_SetupTestData.createMultilingualTemplateSettingData();
        UTL_TPA_SetupTestData.createTPASettingsDataBasedOnOrganization();
        UTL_TPA_SetupTestData.createAMASetting();

        Date todayDate = Date.today();
		
        Account acc =  new Account(Name = 'Test Account', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert acc;
        
        Address__c testAccount1 = UTL_TPA_SetupTestData.getAccount();
        testAccount1.Name = 'Test Acc';
        testAccount1.Account__c = acc.Id;
        insert testAccount1;

        Contact testContact = UTL_TPA_SetupTestData.getContact();
        testContact.AccountId = testAccount1.Account__c;
        insert testContact;


        TPA_Request__c testAgreement1 = UTL_TPA_SetupTestData.getAgreement();
        testAgreement1.Vendor_App_Sent__c = todayDate;
        testAgreement1.Request_Status__c = 'Awaiting Vendor Submission';
		testAgreement1.Service_Provider_Address__c = testAccount1.Id;
		testAgreement1.Data_Access_End_Date__c = todayDate.addDays(3);
		testAgreement1.Vendor_e_mail__c = 'test@mail.com';
		testAgreement1.Vendor_contact_email_client__c = 'test@mail.com';
		testAgreement1.Vendor_Language__c = 'Japanese';
        testAgreement1.Is_Vendor_Id_Invalid__c = False;
        insert testAgreement1;

       /* TPA_Request__c testAgreement2 = UTL_TPA_SetupTestData.getAgreement();
        testAgreement2.Sent_for_Signature__c = todayDate;
        testAgreement2.Vendor_App_Sent__c = todayDate;
        testAgreement2.Vendor_Language__c = 'Japanese';
        testAgreement2.Request_Status__c = 'Awaiting Client Confirmation';
		testAgreement2.Service_Provider_Address__c = testAccount1.Id;
		testAgreement2.Vendor_Company_Name__c = 'Test Vendor Company';
		testAgreement2.Data_Access_End_Date__c = todayDate.addDays(3);
		testAgreement2.Vendor_e_mail__c = 'test@mail.com';
		testAgreement2.Vendor_contact_email_client__c = 'test@mail.com';
        testAgreement2.Is_Vendor_Id_Invalid__c = False;
        insert testAgreement2;*/

        TPA_Contact__c tpaContact = UTL_TPA_SetupTestData.getTestTPAContact(testAgreement1);
        insert tpaContact;

        AMA_Agreement_Detail__c amaObj = UTL_TPA_SetupTestData.getAMAAgreementDetailBlank(testAgreement1.Id);
        amaObj.Agreement_Start_Date__c = Date.newInstance(2016 , 10 ,20);
        amaObj.Agreement_End_Date__c = Date.newInstance(2017 , 12 ,31);
        amaObj.AMA_Howlong_SP_has_Data_Access__c = '90 days or less';
        amaObj.FrequencyOfDeliveryToServiceProvider__c = 'Quarterly';
        amaObj.AMA_TypeOfPrescriberLevelData__c = 'Birth Year;Gender Code';
        amaObj.AMA_Services_Provided__c = 'Telemarketing;Labeling';
        amaObj.Status_of_Cancelation_Request__c = 'Awaiting Vendor Cancelation Acknowledgement';
        amaObj.Last_Vendor_Reminder_Mail_Sent__c =  todayDate.addDays(-1);
        amaObj.Vendor_Reasons_for_Termination__c  = 'No AMA data was shared';
        insert amaObj; 
    }

    @isTest static void test_SendVendorNotificationMail() {
        Test.startTest();

        BCH_TPA_sendTPAMailsOnIQVIA batchUpdateAwaitingSubSign = new BCH_TPA_sendTPAMailsOnIQVIA();
        //Database.executebatch(vendorNotificationTrigger, 3);

        List<TPA_Request__c> agreementList = [SELECT Id, Name, Request_Status__c FROM TPA_Request__c LIMIT 1];

        for(TPA_Request__c agreement : agreementList) {
            if(agreement.Request_Status__c == 'Awaiting Vendor Submission') {
                batchUpdateAwaitingSubSign.query = 'Select id, Service_Provider_f__c,Request_Type__c, Client_Address__r.Name,Prevent_Cancellation__c,is_LAAD_Response_Required__c,isCancellationNoticeSentForSignature__c,isCancellationNoticeSentForSubmission__c, ClientContact__r.email, name, Request_Status__c, data_access_end_date__c, Vendor_e_mail__c, Vendor_contact_email_client__c, Vendor_App_Sent__c, Sent_for_Signature__c, Client_Address__r.TPAOtherEmailIds__c, Vendor_Language__c, Client_Language__c, TP_Processor_Email__c, Stop_TLLA_Generation_Notice_Sent_Date__c from TPA_request__c  where Vendor_contact_email_client__c != null and (Request_Status__c = \'Awaiting Vendor Submission\') and Is_Submitted__c = true and Is_Vendor_Id_Invalid__c = false and Id in (\''+ agreement.id +'\')' ;

                batchUpdateAwaitingSubSign.scriptType = 'ClientUtilization';
                Database.executebatch(batchUpdateAwaitingSubSign,1);
            } 
            

        }
        Test.stopTest();
    }
    @isTest static void test_SendClientConfirmationMail() {
        Test.startTest();

        BCH_TPA_sendTPAMailsOnIQVIA batchUpdateAwaitingSubSign = new BCH_TPA_sendTPAMailsOnIQVIA();

        List<TPA_Request__c> agreementList = [SELECT Id, Name, Request_Status__c FROM TPA_Request__c LIMIT 1];
        UTL_TPA_SetupTestData.addAttachmentToParent(agreementList[0].Id,'Offerings Notification.pdf'); 


        for(TPA_Request__c agreement : agreementList) {
            if(agreement.Request_Status__c == 'Awaiting Vendor Submission') {
                agreement.Request_Status__c = UTL_TPA.AWAITING_CLIENT_CONFIRMATION;
                update agreement;
                batchUpdateAwaitingSubSign.query = 'Select id, Vendor_Language__c,TP_Processor_Email__c, Vendor_App_Submitted__c, Vendor_Off_Notification_Ack_Date__c, Request_Status__c,is_LAAD_Response_Acknowledged__c,is_LAAD_Response_Required__c, Service_Provider_f__c, Client_Address__r.Name, ClientContact__r.email ,(SELECT id,Vendor_Specific_Notification_Response__c,Pending_Cancellation_Date__c FROM TPA_Agreement_Additional_Fields__r) from TPA_request__c where Is_Submitted__c = true and request_status__c in ( \'' + UTL_TPA.AWAITING_CLIENT_CONFIRMATION+ '\' ) and Id in (\''+ agreement.id +'\')' ;            

                batchUpdateAwaitingSubSign.scriptType = 'ClientConfirmation';
                Database.executebatch(batchUpdateAwaitingSubSign,1);
            } 

        }
        Test.stopTest();
    }
    @isTest static void test_SendAccountMgmtCommunicationMail() {
        Test.startTest();

        BCH_TPA_sendTPAMailsOnIQVIA batchUpdateAwaitingSubSign = new BCH_TPA_sendTPAMailsOnIQVIA();
        List<TPA_Request__c> agreementList = [SELECT Id, Name, Request_Status__c FROM TPA_Request__c LIMIT 1];
        UTL_TPA_SetupTestData.addAttachmentToParent(agreementList[0].Id,'Offerings Notification.pdf');

        for(TPA_Request__c agreement : agreementList) {
                agreement.Request_Status__c = 'Awaiting Account Mgmt Communication';
                update agreement;
                batchUpdateAwaitingSubSign.query = 'Select id, Vendor_Language__c,TP_Processor_Email__c, Vendor_App_Submitted__c, Vendor_Off_Notification_Ack_Date__c, Request_Status__c,is_LAAD_Response_Acknowledged__c,is_LAAD_Response_Required__c, Service_Provider_f__c, Client_Address__r.Name, ClientContact__r.email ,(SELECT id,Vendor_Specific_Notification_Response__c,Pending_Cancellation_Date__c FROM TPA_Agreement_Additional_Fields__r) from TPA_request__c where Is_Submitted__c = true and request_status__c in ( \'Awaiting Account Mgmt Communication\' ) and Id in (\''+ agreement.id +'\')' ;            
                batchUpdateAwaitingSubSign.scriptType = 'AccountMgmtCommunication';
                Database.executebatch(batchUpdateAwaitingSubSign,1);

        }
        Test.stopTest();
    }
    @isTest static void test_SendRenewalAndExpirationMail() {
        Test.startTest();
        
         Account acc = new Account(Name = 'Test Account', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert acc;
        
        Address__c testAccount2 = UTL_TPA_SetupTestData.getAddress();
        testAccount2.Name = 'Test Acc2';
        testAccount2.Account__c = acc.id;
        testAccount2.Vendor_Registration_Number__c = 124;
        insert testAccount2;
        
        Contact tpaContact2 = new Contact(firstName = 'testfirstname2',
                                          LastName = 'Test2',
                                          CurrencyIsoCode = 'USD',
                                          Email = 'test@mail.com',
                                          Title = 'Dev');
        tpaContact2.AccountId = testAccount2.Account__c;
        insert tpaContact2;

        UTL_TPA.modifyRequestForcefully = true;
        Date todayDate = Date.today();
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
        
        
        
        TPA_Contact__c tpaContact1 = UTL_TPA_SetupTestData.getTPAContactByReqId(tpaRequest2);


        BCH_TPA_sendTPAMailsOnIQVIA batchUpdateAwaitingSubSign = new BCH_TPA_sendTPAMailsOnIQVIA();
        List<TPA_Request__c> agreementList = [SELECT Id, Name, Request_Status__c FROM TPA_Request__c where Request_Status__c = 'In Effect'];

        for(TPA_Request__c agreement : agreementList) {
                //agreement.Request_Status__c = 'In Effect';
            	//agreement.Data_Access_End_Date__c = Date.today().addDays(10);
                //update agreement;
                batchUpdateAwaitingSubSign.query = 'Select id, Service_Provider_f__c,Client_Language__c,Client_Address__r.Name,Client_Address__r.TPAOtherEmailIds__c,Is_CPC_Renewal_Notice_Sent__c,Is_CPC_Expiration_Notice_Sent__c,Is_CPC_Post_Expiration_Notice_Sent__c,CPC_Renewal_Notice_Sent_Last_Date__c,CPC_Expiration_Notice_Sent_Last_Date__c,CPC_Expiration_Postnotice_Sent_Last_Date__c, Renewed_As__c, Renewed_As__r.Cancelled__c, Renewed_As__r.Request_Status__c, Client_First_Name__c,Expired_Date__c,vendor_language__c, name, request_termination_time__c,Request_Status__c, Vendor_e_mail__c, Authorized_Signer_Email__c, TP_Processor_Email__c, is_LAAD_Response_Required__c,is_LAAD_Response_Acknowledged__c, ClientContact__r.Email, (select id, Email__c from TPA_Request_Contacts__r),  (select id, Name, Early_Contract_Expiry_Date__c,Vendor_Specific_Notification_Response__c  from TPA_Agreement_Additional_Fields__r), data_access_end_date__c from TPA_Request__c where  Is_Submitted__c = true and Id in (\''+ agreement.id +'\')' ;
                batchUpdateAwaitingSubSign.scriptType = 'RenewalAndExpirationMail';
                Database.executebatch(batchUpdateAwaitingSubSign,1);

        }
        Test.stopTest();
    }

    @isTest static void test_SendDayOffExpirationMailMail() {
        Test.startTest();

        BCH_TPA_sendTPAMailsOnIQVIA batchUpdateAwaitingSubSign = new BCH_TPA_sendTPAMailsOnIQVIA();
        List<TPA_Request__c> agreementList = [SELECT Id, Name, Request_Status__c FROM TPA_Request__c LIMIT 1];

        for(TPA_Request__c agreement : agreementList) {
            agreement.Expired_Date__c =  Date.today().addDays(-16);
            agreement.Data_Access_End_Date__c = Date.today().addDays(-20);
            agreement.Request_Status__c = 'Expired';
            agreement.Is_Renewed__c = false;
            agreement.In_Effect_Date__c = Date.today().addDays(-50);
        	agreement.Request_termination_time__c = Date.today().addDays(-20);
            update agreement;
                batchUpdateAwaitingSubSign.query = 'Select id, Service_Provider_f__c, is_LAAD_Response_Required__c,is_LAAD_Response_Acknowledged__c,Renewed_As__c, Renewed_As__r.Cancelled__c, Renewed_As__r.Request_Status__c, Client_First_Name__c,Expired_Date__c,vendor_language__c, name, request_termination_time__c,Request_Status__c, Vendor_e_mail__c, Authorized_Signer_Email__c, TP_Processor_Email__c, ClientContact__r.Email, (select id, Email__c from TPA_Request_Contacts__r),  (select id, Name, Vendor_Specific_Notification_Response__c,Early_Contract_Expiry_Date__c  from TPA_Agreement_Additional_Fields__r), data_access_end_date__c from TPA_Request__c where Id in (\''+ agreement.id +'\')' ;           
                 batchUpdateAwaitingSubSign.scriptType = 'DayOffExpirationMail';
                Database.executebatch(batchUpdateAwaitingSubSign,1);

        }
        Test.stopTest();
    }

    @isTest static void test_SendAMA_OFFSHOREMail() {
        Test.startTest();

        BCH_TPA_sendTPAMailsOnIQVIA batchUpdateAwaitingSubSign = new BCH_TPA_sendTPAMailsOnIQVIA();
        
        List<AMA_Agreement_Detail__c> agreementList = [SELECT Id, Name FROM AMA_Agreement_Detail__c LIMIT 1];

        for(AMA_Agreement_Detail__c agreement : agreementList) {
                agreement.Status_of_Offshore_Process__c = UTL_TPA.AWAITING_AMA_RESPONSE_FOR_OFFSHORE_PROCESS;
                update agreement;
                batchUpdateAwaitingSubSign.query = 'Select id, Vendor_AMA_Fee_Response__c, TPA_Request__r.Vendor_Contact_Name_f__c, TPA_Request__r.Vendor_Contact_Last_Name__c, TPA_Request__r.Vendor_Company_Name__c, TPA_Request__r.Client_Company_Name_Address__c , TPA_Request__r.TP_Processor_Email__c, TPA_Request__r.Vendor_Contact_e_mail__c, TPA_Request__r.Vendor_Contact_Email_Client__c, TPA_Request__r.Authorized_Signer_Email__c, TPA_Request__r.ClientContact__c , TPA_Request__r.Request_Status__c ,TPA_Request__c, TPA_Request__r.Name, Agreement_Start_Date__c , Initial_Termination_Date__c, Agreement_End_Date__c, AMA_TypeOfPrescriberLevelData__c, AMA_Services_Provided__c , Vendor_Contact_Name__c ,Client__c, Vendor_Legal_Name__c, AMA_Howlong_SP_has_Data_Access__c,Vendor_Reasons_for_Termination__c, Vendor_Name_who_Acknowledged_Cancelation__c, REVISED_AMA_Use_and_or_Frequency__c, If_vendor_cancellation_reason_is_Other__c , Status_of_Cancelation_Request__c ,DBL__c, Contract_Type__c , Current_Year_Fees__c , Next_Year_Fees__c , Last_AMA_Reminder_Mail_Sent__c , Last_Vendor_Reminder_Mail_Sent__c, Status_of_Offshore_Questionnaire__c, Last_Vendor_Offshore_Reminder_Mail_Sent__c, Status_of_Offshore_Process__c, Last_AMA_offshore_reminder_mail_sent__c, Vendor_employee_access_data_in_country__c FROM AMA_Agreement_Detail__c where Id in (\''+ agreement.id +'\')' ;               
                batchUpdateAwaitingSubSign.scriptType = 'AMA_OFFSHORE';
                Database.executebatch(batchUpdateAwaitingSubSign,1);

        }
        Test.stopTest();
    }

    @isTest static void test_SendFEE_AcknowledgementMail() {
        Test.startTest();

        BCH_TPA_sendTPAMailsOnIQVIA batchUpdateAwaitingSubSign = new BCH_TPA_sendTPAMailsOnIQVIA();
        List<TPA_Request__c> objList = [SELECT Id, Name, Request_Status__c FROM TPA_Request__c LIMIT 1];
        objList[0].Request_Status__c = 'Pending Vendor AMA Fee Acknowledgement';
        update objList;

        List<AMA_Agreement_Detail__c> agreementList = [SELECT Id, Name,TPA_Request__r.Request_Status__c FROM AMA_Agreement_Detail__c LIMIT 1];

        for(AMA_Agreement_Detail__c agreement : agreementList) {
                //agreement.Status_of_Offshore_Process__c = UTL_TPA.AWAITING_AMA_RESPONSE_FOR_OFFSHORE_PROCESS;
               // agreement.TPA_Request__r.Request_Status__c = 'Pending Vendor AMA Fee Acknowledgement';
               // update agreement;
                batchUpdateAwaitingSubSign.query = 'Select id, Vendor_AMA_Fee_Response__c, TPA_Request__r.Vendor_Contact_Name_f__c, TPA_Request__r.Vendor_Contact_Last_Name__c, TPA_Request__r.Vendor_Company_Name__c, TPA_Request__r.Client_Company_Name_Address__c , TPA_Request__r.TP_Processor_Email__c, TPA_Request__r.Vendor_Contact_e_mail__c, TPA_Request__r.Vendor_Contact_Email_Client__c, TPA_Request__r.Authorized_Signer_Email__c, TPA_Request__r.ClientContact__c , TPA_Request__r.Request_Status__c ,TPA_Request__c, TPA_Request__r.Name, Agreement_Start_Date__c , Initial_Termination_Date__c, Agreement_End_Date__c, AMA_TypeOfPrescriberLevelData__c, AMA_Services_Provided__c , Vendor_Contact_Name__c ,Client__c, Vendor_Legal_Name__c, AMA_Howlong_SP_has_Data_Access__c,Vendor_Reasons_for_Termination__c, Vendor_Name_who_Acknowledged_Cancelation__c, REVISED_AMA_Use_and_or_Frequency__c, If_vendor_cancellation_reason_is_Other__c , Status_of_Cancelation_Request__c ,DBL__c, Contract_Type__c , Current_Year_Fees__c , Next_Year_Fees__c , Last_AMA_Reminder_Mail_Sent__c , Last_Vendor_Reminder_Mail_Sent__c, Status_of_Offshore_Questionnaire__c, Last_Vendor_Offshore_Reminder_Mail_Sent__c, Status_of_Offshore_Process__c, Last_AMA_offshore_reminder_mail_sent__c, Vendor_employee_access_data_in_country__c FROM AMA_Agreement_Detail__c where Id in (\''+ agreement.id +'\')' ;               
                batchUpdateAwaitingSubSign.scriptType = 'FEE_Acknowledgement';
                Database.executebatch(batchUpdateAwaitingSubSign,1);

        }
        Test.stopTest();
    }
    @isTest static void test_SendAMA_CANCELATIONMail1() {
        Test.startTest();

        BCH_TPA_sendTPAMailsOnIQVIA batchUpdateAwaitingSubSign = new BCH_TPA_sendTPAMailsOnIQVIA();
        
        List<AMA_Agreement_Detail__c> agreementList = [SELECT Id, Name FROM AMA_Agreement_Detail__c LIMIT 1];

        for(AMA_Agreement_Detail__c agreement : agreementList) {
                agreement.Vendor_Reasons_for_Termination__c = 'test';
                agreement.Status_of_Cancelation_Request__c = 'Awaiting Vendor Cancelation Acknowledgement';
                update agreement;
                batchUpdateAwaitingSubSign.query = 'Select id, Vendor_AMA_Fee_Response__c, TPA_Request__r.Vendor_Contact_Name_f__c, TPA_Request__r.Vendor_Contact_Last_Name__c, TPA_Request__r.Vendor_Company_Name__c, TPA_Request__r.Client_Company_Name_Address__c , TPA_Request__r.TP_Processor_Email__c, TPA_Request__r.Vendor_Contact_e_mail__c, TPA_Request__r.Vendor_Contact_Email_Client__c, TPA_Request__r.Authorized_Signer_Email__c, TPA_Request__r.ClientContact__c , TPA_Request__r.Request_Status__c ,TPA_Request__c, TPA_Request__r.Name, Agreement_Start_Date__c , Initial_Termination_Date__c, Agreement_End_Date__c, AMA_TypeOfPrescriberLevelData__c, AMA_Services_Provided__c , Vendor_Contact_Name__c ,Client__c, Vendor_Legal_Name__c, AMA_Howlong_SP_has_Data_Access__c,Vendor_Reasons_for_Termination__c, Vendor_Name_who_Acknowledged_Cancelation__c, REVISED_AMA_Use_and_or_Frequency__c, If_vendor_cancellation_reason_is_Other__c , Status_of_Cancelation_Request__c ,DBL__c, Contract_Type__c , Current_Year_Fees__c , Next_Year_Fees__c , Last_AMA_Reminder_Mail_Sent__c , Last_Vendor_Reminder_Mail_Sent__c, Status_of_Offshore_Questionnaire__c, Last_Vendor_Offshore_Reminder_Mail_Sent__c, Status_of_Offshore_Process__c, Last_AMA_offshore_reminder_mail_sent__c, Vendor_employee_access_data_in_country__c FROM AMA_Agreement_Detail__c where Id in (\''+ agreement.id +'\')' ;               
                batchUpdateAwaitingSubSign.scriptType = 'AMA_CANCELATION';
                Database.executebatch(batchUpdateAwaitingSubSign,1);

        }
        Test.stopTest();
    }
    @isTest static void test_SendAMA_CANCELATIONMail2() {
        Test.startTest();

        BCH_TPA_sendTPAMailsOnIQVIA batchUpdateAwaitingSubSign = new BCH_TPA_sendTPAMailsOnIQVIA();
        
        List<AMA_Agreement_Detail__c> agreementList = [SELECT Id, Name FROM AMA_Agreement_Detail__c LIMIT 1];

        for(AMA_Agreement_Detail__c agreement : agreementList) {
                agreement.Vendor_Reasons_for_Termination__c = 'test';
                agreement.Status_of_Cancelation_Request__c = 'Awaiting AMA Response to Vendor Cancelation Request';
                update agreement;
                batchUpdateAwaitingSubSign.query = 'Select id, Vendor_AMA_Fee_Response__c, TPA_Request__r.Vendor_Contact_Name_f__c, TPA_Request__r.Vendor_Contact_Last_Name__c, TPA_Request__r.Vendor_Company_Name__c, TPA_Request__r.Client_Company_Name_Address__c , TPA_Request__r.TP_Processor_Email__c, TPA_Request__r.Vendor_Contact_e_mail__c, TPA_Request__r.Vendor_Contact_Email_Client__c, TPA_Request__r.Authorized_Signer_Email__c, TPA_Request__r.ClientContact__c , TPA_Request__r.Request_Status__c ,TPA_Request__c, TPA_Request__r.Name, Agreement_Start_Date__c , Initial_Termination_Date__c, Agreement_End_Date__c, AMA_TypeOfPrescriberLevelData__c, AMA_Services_Provided__c , Vendor_Contact_Name__c ,Client__c, Vendor_Legal_Name__c, AMA_Howlong_SP_has_Data_Access__c,Vendor_Reasons_for_Termination__c, Vendor_Name_who_Acknowledged_Cancelation__c, REVISED_AMA_Use_and_or_Frequency__c, If_vendor_cancellation_reason_is_Other__c , Status_of_Cancelation_Request__c ,DBL__c, Contract_Type__c , Current_Year_Fees__c , Next_Year_Fees__c , Last_AMA_Reminder_Mail_Sent__c , Last_Vendor_Reminder_Mail_Sent__c, Status_of_Offshore_Questionnaire__c, Last_Vendor_Offshore_Reminder_Mail_Sent__c, Status_of_Offshore_Process__c, Last_AMA_offshore_reminder_mail_sent__c, Vendor_employee_access_data_in_country__c FROM AMA_Agreement_Detail__c where Id in (\''+ agreement.id +'\')' ;               
                batchUpdateAwaitingSubSign.scriptType = 'AMA_CANCELATION';
                Database.executebatch(batchUpdateAwaitingSubSign,1);

        }
        Test.stopTest();
    }
}
