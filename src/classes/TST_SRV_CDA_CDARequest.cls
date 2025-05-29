@isTest(seeAllData=false)
public class TST_SRV_CDA_CDARequest {

    @testSetup
    public static void setupData() {
        TST_CDA_SetupData testSetup = new TST_CDA_SetupData();
        testSetup.setUpCustomSetting();
        testSetup.setUpContactForEmail();
        testSetup.setupUserRequestor();
        testSetup.setupUserNegotiator();

        //Added by Vikram Singh under CR-11576 Start
        CDA_Approved_Governing_Law_Location__c governingLaw = TST_CDA_SetupData.getGoverningLaw('Test GL');
        insert governingLaw;

        QI_Legal_Entity__c testQiLegalEntity = TST_CDA_SetupData.createQiLegalEntity('Test Entity1', UTL_CDAUtility.CDA_BUSINESS_PART_LQ, governingLaw); //Updated by Vikram Singh under CR-11576
        insert testQiLegalEntity;

        //create Legal POC Attorney record
        CDA_Legal_POC_Cross_Walk__c testLegalPOC = new CDA_Legal_POC_Cross_Walk__c(CDA_Language__c='Chinese',Legal_POC_First_Name__c='TestChinese',Legal_POC_Last_Name__c='Attorney',Legal_POC_Email_Address__c='test@abc.com');
        insert testLegalPOC;

        CDA_Request__c cdaRequest = testSetup.setupTestDataForCustomer(testQiLegalEntity);
        cdaRequest.Originating_Requestor_Flag__c = 'Yes';
        cdaRequest.Originating_Requestor_IQVIA_Email__c = 'orignating@req.com';
        cdaRequest.What_documents_would_you_like_to_provide__c = UTL_CDAUtility.CDA_RESPONSE_DOCTYPE_REDLINED;
        update cdaRequest;
        CDA_Request__c cdaRequest4 = testSetup.setupTestDataForCustomer(testQiLegalEntity);
        cdaRequest4.Originating_Requestor_Flag__c = 'Yes';
        cdaRequest4.Originating_Requestor_IQVIA_Email__c = 'orignating@req.com';
        cdaRequest4.What_documents_would_you_like_to_provide__c = UTL_CDAUtility.CDA_RESPONSE_DOCTYPE_CLEANED;
        update cdaRequest4;
        CDA_Request__c cdaRequest5 = testSetup.setupTestDataForCustomer(testQiLegalEntity);
        cdaRequest5.Originating_Requestor_Flag__c = 'Yes';
        cdaRequest5.Originating_Requestor_IQVIA_Email__c = 'orignating@req.com';
        cdaRequest5.What_documents_would_you_like_to_provide__c = UTL_CDAUtility.CDA_RESPONSE_DOCTYPE_REDLINED_AND_CLEANED;
        update cdaRequest5;
        CDA_Request__c cdaRequest2 = testSetup.setupTestDataForAuditor(testQiLegalEntity);
        CDA_Request__c cdaRequest6 = testSetup.setupTestDataForAuditor(testQiLegalEntity);        
        CDA_Request__c cdaRequest3 = testSetup.setupTestDataForCustomer(testQiLegalEntity);
        cdaRequest3.CDA_Language__c = 'Chinese';
        cdaRequest3.Legal_POC_Cross_Walk__c = testLegalPOC.Id;
        cdaRequest3.Date_Sent_for_Language_Review__c = Date.today().addDays(-2);
        cdaRequest3.CDA_Source__c = UTL_CDAUtility.CDASOURCE_QUINTILESIMS;
        cdaRequest3.CDA_Format__c = UTL_CDAUtility.CDA_FORMAT_PROWORD;
        cdaRequest3.status__c = UTL_CDAUtility.STATUS_LANGUAGE_REVIEW;
        update cdaRequest3;
        CDA_Request__c cdaRequest7 = testSetup.setupTestDataForCustomer(testQiLegalEntity);
        dsfs__DocuSign_Status__c testDSStatus = TST_CDA_SetupData.getDSStatusByRequestId(cdaRequest7.Name);
        testDSStatus.CDA_Request__c = cdaRequest7.Id;
        testDSStatus.dsfs__Envelope_Status__c = 'Completed';
        update testDSStatus;

        CDA_Account__c testCdaAccount = testSetup.cdaAccount;

        Attachment testAttachment1 = testSetup.getAttachment(UTL_CDAUtility.GENERATED_DOCUMENT_KEYWORD + '_Test Attachment' + UTL_CDAUtility.EXTENTION_DOC , cdaRequest2.Id, false);
        Attachment testAttachment2 = testSetup.getAttachment(UTL_CDAUtility.RED_LINE_KEYWORD , cdaRequest.Id, false);
        Attachment testAttachment3 = testSetup.getAttachment(UTL_CDAUtility.RED_LINE_KEYWORD + UTL_CDAUtility.COMPLETED_KEYWORD, cdaRequest.Id, false);
        Attachment testAttachment4 = testSetup.getAttachment(UTL_CDAUtility.RED_LINE_KEYWORD + UTL_CDAUtility.CLEANED_DOC_KEYWORD, cdaRequest.Id, false);
        Attachment testAttachment5 = testSetup.getAttachment(UTL_CDAUtility.GENERATED_DOCUMENT_KEYWORD + '_Test Attachment' + UTL_CDAUtility.EXTENTION_DOC +'_'+UTL_CDAUtility.EXTERNAL_KEYWORD , cdaRequest6.Id, false);       
        Attachment testAttachment6 = testSetup.getAttachment(UTL_CDAUtility.RED_LINE_KEYWORD , cdaRequest4.Id, false);
        Attachment testAttachment7 = testSetup.getAttachment(UTL_CDAUtility.RED_LINE_KEYWORD + UTL_CDAUtility.COMPLETED_KEYWORD, cdaRequest4.Id, false);
        Attachment testAttachment8 = testSetup.getAttachment(UTL_CDAUtility.RED_LINE_KEYWORD + UTL_CDAUtility.CLEANED_DOC_KEYWORD, cdaRequest4.Id, false);
        Attachment testAttachment9 = testSetup.getAttachment(UTL_CDAUtility.RED_LINE_KEYWORD , cdaRequest5.Id, false);
        Attachment testAttachment10 = testSetup.getAttachment(UTL_CDAUtility.RED_LINE_KEYWORD + UTL_CDAUtility.COMPLETED_KEYWORD, cdaRequest5.Id, false);
        Attachment testAttachment11 = testSetup.getAttachment(UTL_CDAUtility.RED_LINE_KEYWORD + UTL_CDAUtility.CLEANED_DOC_KEYWORD, cdaRequest5.Id, false);
        Attachment testAttachment12 = testSetup.getAttachment(UTL_CDAUtility.COMPLETED_KEYWORD + '_Test Attachment' + UTL_CDAUtility.CDA_FORMAT_PDF , cdaRequest7.Id, false);

        List<Attachment> lstTestAttachment = new List<Attachment>();
        lstTestAttachment.add(testAttachment1);
        lstTestAttachment.add(testAttachment2);
        lstTestAttachment.add(testAttachment3);
        lstTestAttachment.add(testAttachment4);
        lstTestAttachment.add(testAttachment5);
        lstTestAttachment.add(testAttachment6);
        lstTestAttachment.add(testAttachment7);
        lstTestAttachment.add(testAttachment8);
        lstTestAttachment.add(testAttachment9);
        lstTestAttachment.add(testAttachment10);
        lstTestAttachment.add(testAttachment11);
        lstTestAttachment.add(testAttachment12);

        insert lstTestAttachment;
    }

    @isTest
    public static void cdaRequestServiceTest() {
        Test.StartTest();

        Boolean isCdaTypeAuditor = SRV_CDA_CDARequest.isCdaTypeAuditor(UTL_CDAUtility.AUDITOR);
        system.assertEquals(true, isCdaTypeAuditor);

        Boolean isCdaTypeVendor = SRV_CDA_CDARequest.isCdaTypeVendor(UTL_CDAUtility.VENDOR);
        system.assertEquals(true, isCdaTypeVendor);

        Boolean isCdaTypeCustomer = SRV_CDA_CDARequest.isCdaTypeCustomer(UTL_CDAUtility.CUSTOMER);
        system.assertEquals(true, isCdaTypeCustomer);

        Boolean isCdaTypeCEVA = SRV_CDA_CDARequest.isCdaTypeCEVA(UTL_CDAUtility.CEVA);
        system.assertEquals(true, isCdaTypeCEVA);

        Boolean isDataAndServices = SRV_CDA_CDARequest.isDataAndServices(UTL_CDAUtility.CDA_BUSINESS_PART_LI);
        system.assertEquals(true, isDataAndServices);

        Boolean isClinicalResearch = SRV_CDA_CDARequest.isClinicalResearch(UTL_CDAUtility.CDA_BUSINESS_PART_LQ);
        system.assertEquals(true, isClinicalResearch);

        CDA_Request__c cdaRequest = new CDA_Request__c();
        String query = 'SELECT id, Name, CDA_Id__c, CDA_Type__c, Status__c, What_is_the_Study_Sponsor_situation__c, Recipient_Point_of_Contact_Name__c, Negotiator_Assigned_List__c, CDA_Language__c, OwnerId, RecordTypeId, Requestor_Admin_Email_Flag__c, Originating_Requestor_Flag__c, Originating_Requestor_IQVIA_Email__c FROM CDA_Request__c';
        List<CDA_Request__c> cdaRequestList = Database.query(query);
        
        if(cdaRequestList.size() > 0) {
            cdaRequest = cdaRequestList[0];
        }

        system.assertEquals(true, SRV_CDA_CDARequest.isCurrentUserARequestOwner(cdaRequest));
        system.assertEquals(false, SRV_CDA_CDARequest.isCurrentUserARequestOwner(null));

        system.assertNotEquals(null, SRV_CDA_CDARequest.getCDARequest(cdaRequest.Id).Id);
        system.assertNotEquals(null, SRV_CDA_CDARequest.getCDARequest(null));

        CDA_Approved_Governing_Law_Location__c testQiLegalEntityGoverningLaw = [SELECT Name, Court_of_Jurisdiction__c FROM CDA_Approved_Governing_Law_Location__c LIMIT 1]; //Added by Vikram Singh under CR-11576

        system.assertNotEquals(null, SRV_CDA_CDARequest.getGoverningLaw(testQiLegalEntityGoverningLaw.Id));
        system.assertNotEquals(null, SRV_CDA_CDARequest.getGoverningLaw(null));

        QI_Legal_Entity__c testQiLegalEntity = [SELECT Name, QI_Legal_Entity_Address__c, Location_of_Governing_Law__c, IQVIA_Business_Area__c, Court_of_Jurisdiction__c FROM QI_Legal_Entity__c LIMIT 1]; //Updated by Vikram Singh under CR-11576

        system.assertNotEquals(null, SRV_CDA_CDARequest.getQILegalEntity(testQiLegalEntity.Id));
        system.assertNotEquals(null, SRV_CDA_CDARequest.getQILegalEntity(null));

        CDA_Account__c testCdaAccount = [SELECT Id, Name, Complete_Address__c, Street__c, City__c, State__c, Country__c FROM CDA_Account__c LIMIT 1];
        system.assertNotEquals(null, SRV_CDA_CDARequest.getCDAAccount(testCdaAccount.Id));
        
        CDA_Legal_POC_Cross_Walk__c testLegalPOC = [SELECT Id, Name, CDA_Language__c, Legal_POC_First_Name__c, Legal_POC_Last_Name__c, Legal_POC_Email_Address__c FROM CDA_Legal_POC_Cross_Walk__c LIMIT 1];
        system.assertNotEquals(null, SRV_CDA_CDARequest.getCDALegalPOC(testLegalPOC.CDA_Language__c));
        
        Map<String, String> searchMap = new Map<String, String>{'CDA_Id__c' => 'ValueA', 'QuintilesIMS_Business__c' => 'ValueB', 'CDA_Type__c' => 'Customer', 'Status__c' => UTL_CDAUtility.STATUS_INREVIEWBYQUINTILES, 'Negotiator_Assigned_List__c' => 'ValueC', 'Recipient_Account__r.Name' => 'ValueC', 'Recipient_Point_of_Contact_Name__c' => 'ValueC', 'CreatedBy.Name' => 'ValueC'};
        String searchQry = SRV_CDA_CDARequest.setQueryCondition(query, searchMap, Boolean.valueOf(UTL_CDAUtility.YES));
        system.assertNotEquals(null, searchQry);

        SRV_CDA_CDARequest.runSearch(cdaRequest, 'IQVIA Inc.', 'IQVIA Inc.', 'Name', 'asc', cdaRequest.Name);   //Updated by Vikram Singh under CR-11385
        SRV_CDA_CDARequest.runSearchForReport(cdaRequest, 'Test Owner', 'Name', 'asc');   //Added by Vikram Singh under CR-11576
        SRV_CDA_CDARequest.isUserHavingApttusLicense(); //Added by Vikram Singh under CR-11576
        SRV_CDA_CDARequest scr = new SRV_CDA_CDARequest();
        scr.redirectHistoricalDataLayout(cdaRequest, 'e');   //Added by Vikram Singh under CR-11691

        Test.setMock(HttpCalloutMock.class, new WSC_CDA_HttpResponseGeneratorMock());
        SRV_CDA_CDARequest.generateCDADocument(cdaRequest);
        SRV_CDA_CDARequest.generateCDADocumentThroughBatch(JSON.serialize(cdaRequest));

        List<SelectOption> pageizeList = SRV_CDA_CDARequest.getRecordsPerPage();
        system.assertEquals(4, pageizeList.size());

        Test.StopTest();
    }

    @isTest
    public static void sendCdaNotificationTest() {
        Test.StartTest();
        CDA_Request__c cdaRequest = new CDA_Request__c();
        String query = 'SELECT id, Name, CDA_Id__c, CDA_Type__c, Status__c, What_is_the_Study_Sponsor_situation__c, Recipient_Point_of_Contact_Name__c, Negotiator_Assigned_List__c, CDA_Language__c, Requestor_Carbon_Copies__c, Requestor_Admin_Email_Flag__c, On_Behalf_of_User_Full_Name__c, On_Behalf_Of_User_Email__c, Recipient_Point_of_Contact_Email_Address__c, Recipient_Authorized_Signer_Email_Addres__c, Legal_POC_Cross_Walk__c, Legal_POC_Cross_Walk__r.Legal_POC_Full_Name__c, Legal_POC_Cross_Walk__r.Legal_POC_Email_Address__c, Negotiator_Assigned__c, What_documents_would_you_like_to_provide__c, Originating_Requestor_Flag__c, Originating_Requestor_IQVIA_Email__c, Owner.Name, Owner.Email FROM CDA_Request__c';
        List<CDA_Request__c> cdaRequestList = Database.query(query);
       
        Map <Id, CDA_Request__c> cdaIdToCdaRequestMap = new Map <Id, CDA_Request__c>();
        cdaIdToCdaRequestMap.putAll(cdaRequestList);
        List <string> ccRecipientList = new List<String>{'test@test.com'};
        UTL_CDAUtility.buttonType = UTL_CDAUtility.BUTTON_TYPE_SUBMIT;

        //Case-1
        // Test sendCdaNotification method for recipient as 'Requestor' and 'Email External Paper Review' template.
        SRV_CDA_CDARequest.sendCdaNotification(cdaIdToCdaRequestMap, UTL_CDAUtility.REQUESTOR, ccRecipientList, UTL_CDAUtility.EMAIL_EXTERNAL_PAPER_REVIEW);

        Test.StopTest();
    }
    
    @isTest
    public static void sendCdaNotificationTest2() {
        Test.StartTest();
        CDA_Request__c cdaRequest = new CDA_Request__c();
        String query = 'SELECT id, Name, CDA_Id__c, CDA_Type__c, Status__c, What_is_the_Study_Sponsor_situation__c, Recipient_Point_of_Contact_Name__c, Negotiator_Assigned_List__c, CDA_Language__c, Requestor_Carbon_Copies__c, Requestor_Admin_Email_Flag__c, On_Behalf_of_User_Full_Name__c, On_Behalf_Of_User_Email__c, Recipient_Point_of_Contact_Email_Address__c, Recipient_Authorized_Signer_Email_Addres__c, Legal_POC_Cross_Walk__c, Legal_POC_Cross_Walk__r.Legal_POC_Full_Name__c, Legal_POC_Cross_Walk__r.Legal_POC_Email_Address__c, Negotiator_Assigned__c, What_documents_would_you_like_to_provide__c, Originating_Requestor_Flag__c, Originating_Requestor_IQVIA_Email__c, Owner.Name, Owner.Email FROM CDA_Request__c';
        List<CDA_Request__c> cdaRequestList = Database.query(query);
       
        Map <Id, CDA_Request__c> cdaIdToCdaRequestMap = new Map <Id, CDA_Request__c>();
        cdaIdToCdaRequestMap.putAll(cdaRequestList);
        List <string> ccRecipientList = new List<String>{'test@test.com'};
        UTL_CDAUtility.buttonType = UTL_CDAUtility.BUTTON_TYPE_SUBMIT;

        //Case-2
        // Test sendCdaNotification method for recipient as 'RecipientPointOfContact' and 'Email Req Excu8 Aggr Recvd' template.
        SRV_CDA_CDARequest.sendCdaNotification(cdaIdToCdaRequestMap, UTL_CDAUtility.RECIPIENT, ccRecipientList, UTL_CDAUtility.EMAIL_REQ_EXCU8_AGGR_RECVD);

        Test.StopTest();
    }
    
    @isTest
    public static void sendCdaNotificationTest3() {
        Test.StartTest();
        CDA_Request__c cdaRequest = new CDA_Request__c();
        String query = 'SELECT id, Name, CDA_Id__c, CDA_Type__c, Status__c, What_is_the_Study_Sponsor_situation__c, Recipient_Point_of_Contact_Name__c, Negotiator_Assigned_List__c, CDA_Language__c, Requestor_Carbon_Copies__c, Requestor_Admin_Email_Flag__c, On_Behalf_of_User_Full_Name__c, On_Behalf_Of_User_Email__c, Recipient_Point_of_Contact_Email_Address__c, Recipient_Authorized_Signer_Email_Addres__c, Legal_POC_Cross_Walk__c, Legal_POC_Cross_Walk__r.Legal_POC_Full_Name__c, Legal_POC_Cross_Walk__r.Legal_POC_Email_Address__c, Negotiator_Assigned__c, What_documents_would_you_like_to_provide__c, Originating_Requestor_Flag__c, Originating_Requestor_IQVIA_Email__c, Owner.Name, Owner.Email FROM CDA_Request__c';
        List<CDA_Request__c> cdaRequestList = Database.query(query);
       
        Map <Id, CDA_Request__c> cdaIdToCdaRequestMap = new Map <Id, CDA_Request__c>();
        cdaIdToCdaRequestMap.putAll(cdaRequestList);
        List <string> ccRecipientList = new List<String>{'test@test.com'};
        UTL_CDAUtility.buttonType = UTL_CDAUtility.BUTTON_TYPE_SUBMIT;

        //Case-3-a
        // Test sendCdaNotification method for recipient as 'AuthorizedSigner' and 'Email Recipient Review Request' template
        // and for Red Line Documents.
        SRV_CDA_CDARequest.sendCdaNotification(cdaIdToCdaRequestMap, UTL_CDAUtility.AUTH_SIGN, ccRecipientList, UTL_CDAUtility.EMAIL_RECIPIENT_REVIEW_REQUEST);

        Test.StopTest();
    }

    @isTest
    public static void sendCdaNotificationTest1() {
        Test.StartTest();
        CDA_Request__c cdaRequest = new CDA_Request__c();
        String query = 'SELECT id, Name, CDA_Id__c, CDA_Type__c, Status__c, What_is_the_Study_Sponsor_situation__c, Recipient_Point_of_Contact_Name__c, Negotiator_Assigned_List__c, CDA_Language__c, Requestor_Carbon_Copies__c, Requestor_Admin_Email_Flag__c, On_Behalf_of_User_Full_Name__c, On_Behalf_Of_User_Email__c, Recipient_Point_of_Contact_Email_Address__c, Recipient_Authorized_Signer_Email_Addres__c, Legal_POC_Cross_Walk__c, Legal_POC_Cross_Walk__r.Legal_POC_Full_Name__c, Legal_POC_Cross_Walk__r.Legal_POC_Email_Address__c, Negotiator_Assigned__c, What_documents_would_you_like_to_provide__c, Originating_Requestor_Flag__c, Originating_Requestor_IQVIA_Email__c, Owner.Name, Owner.Email FROM CDA_Request__c';
        List<CDA_Request__c> cdaRequestList = Database.query(query);
       
        Map <Id, CDA_Request__c> cdaIdToCdaRequestMap = new Map <Id, CDA_Request__c>();
        cdaIdToCdaRequestMap.putAll(cdaRequestList);
        List <string> ccRecipientList = new List<String>{'test@test.com'};
        UTL_CDAUtility.buttonType = UTL_CDAUtility.BUTTON_TYPE_SUBMIT;

        //Case-4
        // Test sendCdaNotification method for recipient as 'Negotiator Assigned' and 'Email Recipient Review Request' template
        // and for Red Line Documents.
        SRV_CDA_CDARequest.sendCdaNotification(cdaIdToCdaRequestMap, UTL_CDAUtility.NEGO_ASSIGNED, ccRecipientList, UTL_CDAUtility.EMAIL_RECIPIENT_REVIEW_REQUEST);

        Test.StopTest();
    }
    
    @isTest
    public static void sendCdaNotificationTest4() {
        Test.StartTest();
        CDA_Request__c cdaRequest = new CDA_Request__c();
        String query = 'SELECT id, Name, CDA_Id__c, CDA_Type__c, Status__c, What_is_the_Study_Sponsor_situation__c, Recipient_Point_of_Contact_Name__c, Negotiator_Assigned_List__c, CDA_Language__c, Requestor_Carbon_Copies__c, Requestor_Admin_Email_Flag__c, On_Behalf_of_User_Full_Name__c, On_Behalf_Of_User_Email__c, Recipient_Point_of_Contact_Email_Address__c, Recipient_Authorized_Signer_Email_Addres__c, Legal_POC_Cross_Walk__c, Legal_POC_Cross_Walk__r.Legal_POC_Full_Name__c, Legal_POC_Cross_Walk__r.Legal_POC_Email_Address__c, Negotiator_Assigned__c, What_documents_would_you_like_to_provide__c, Originating_Requestor_Flag__c, Originating_Requestor_IQVIA_Email__c, Owner.Name, Owner.Email FROM CDA_Request__c';
        List<CDA_Request__c> cdaRequestList = Database.query(query);
       
        Map <Id, CDA_Request__c> cdaIdToCdaRequestMap = new Map <Id, CDA_Request__c>();
        cdaIdToCdaRequestMap.putAll(cdaRequestList);
        List <string> ccRecipientList = new List<String>{'test@test.com'};
        UTL_CDAUtility.buttonType = UTL_CDAUtility.BUTTON_TYPE_SUBMIT;
        
        //Case-5
        // Test sendCdaNotification method for recipient as 'NegotiatorCentralMailbox' and 'Email Recipient Review Request' template
        // and for Red Line Documents.
        SRV_CDA_CDARequest.sendCdaNotification(cdaIdToCdaRequestMap, UTL_CDAUtility.CENTRALMAILBOX, ccRecipientList, UTL_CDAUtility.EMAIL_RECIPIENT_REVIEW_REQUEST);

        Test.StopTest();
    }
    
    @isTest
    public static void sendCdaNotificationTest5() {
        Test.StartTest();
        CDA_Request__c cdaRequest = new CDA_Request__c();
        String query = 'SELECT id, Name, CDA_Id__c, CDA_Type__c, Status__c, What_is_the_Study_Sponsor_situation__c, Recipient_Point_of_Contact_Name__c, Negotiator_Assigned_List__c, CDA_Language__c, Requestor_Carbon_Copies__c, Requestor_Admin_Email_Flag__c, On_Behalf_of_User_Full_Name__c, On_Behalf_Of_User_Email__c, Recipient_Point_of_Contact_Email_Address__c, Recipient_Authorized_Signer_Email_Addres__c, Legal_POC_Cross_Walk__c, Legal_POC_Cross_Walk__r.Legal_POC_Full_Name__c, Legal_POC_Cross_Walk__r.Legal_POC_Email_Address__c, Negotiator_Assigned__c, What_documents_would_you_like_to_provide__c, Originating_Requestor_Flag__c, Originating_Requestor_IQVIA_Email__c, Owner.Name, Owner.Email FROM CDA_Request__c';
        List<CDA_Request__c> cdaRequestList = Database.query(query);
       
        Map <Id, CDA_Request__c> cdaIdToCdaRequestMap = new Map <Id, CDA_Request__c>();
        cdaIdToCdaRequestMap.putAll(cdaRequestList);
        List <string> ccRecipientList = new List<String>{'test@test.com'};
        UTL_CDAUtility.buttonType = UTL_CDAUtility.BUTTON_TYPE_SUBMIT;

        //Case-6
        // Test sendCdaNotification method for recipient as 'Legal POC' for 'Legal POC Assignment' and 'Legal POC Reminder' template
        SRV_CDA_CDARequest.sendCdaNotification(cdaIdToCdaRequestMap, UTL_CDAUtility.LEGAL_POC, ccRecipientList, UTL_CDAUtility.EMAIL_LEGAL_POC_ASSIGNMENT);
        SRV_CDA_CDARequest.sendCdaNotification(cdaIdToCdaRequestMap, UTL_CDAUtility.LEGAL_POC, ccRecipientList, UTL_CDAUtility.EMAIL_LEGAL_POC_REMINDER);

        Test.StopTest();
    }

    @isTest
    public static void getUserPermissionTest() {
        Test.StartTest();
        User requestor = new User();
        User negotiator = new User();
        for(User user : [SELECT id, Profile.Name FROM User WHERE isActive=true LIMIT 1]) {
            if(user.Profile.Name == 'CDA Requestor') {
                requestor = user;
            }
            else if(user.Profile.Name == 'CDA Negotiator') {
                negotiator = user;
            }
        }

        //Case-1 : Get User permission with System Admin Profile
        system.assertEquals(UTL_CDAUtility.SYS_ADMIN, SRV_CDA_CDARequest.getUserPermission());

        //Case-2 : Get User permission with CDA Requestor Profile
        SRV_CDA_CDARequest.logedInUser = requestor;
        //system.runAs(requestor) {
        //    system.assertEquals(UTL_CDAUtility.REQUESTOR, SRV_CDA_CDARequest.getUserPermission());
        //}

        //Case-3 : Get User permission with CDA Negotiator Profile
        SRV_CDA_CDARequest.logedInUser = negotiator;
        //system.runAs(negotiator) {
        //    system.assertEquals(UTL_CDAUtility.NEGOTIATOR, SRV_CDA_CDARequest.getUserPermission());
        //}

        Test.StopTest();
    }

    @isTest
    public static void requestNevigationTest() {
        Test.StartTest();

        CDA_Request__c cdaRequest = [SELECT id FROM CDA_Request__c LIMIT 1];

        // Go to a new request creation page.
        PageReference pageRef1 = SRV_CDA_CDARequest.goToNewRequest();
        system.assertEquals('new', pageRef1.getParameters().get('reqType'));

        //View an existing request
        PageReference pageRef2 = SRV_CDA_CDARequest.goToViewRequest(cdaRequest.Id);
        system.assertEquals(cdaRequest.Id, pageRef2.getParameters().get('id'));

        //View an existing request
        PageReference pageRef3 = SRV_CDA_CDARequest.goToEditRequest(cdaRequest.Id);
        system.assertEquals(cdaRequest.Id, pageRef3.getParameters().get('id'));
        system.assertEquals('edit', pageRef3.getParameters().get('reqType'));
        SRV_CDA_CDARequest.cancelRequest(cdaRequest.id);
        Test.StopTest();
    }
}