/**
 * @author   : Sweta Sharma
 * Purpose   : ER-3556 Test for TGRH_Attachment class.
 *
 */
@isTest(SeeAllData = False)
private class TST_DAOH_Attachment {
    private static TST_CDA_SetupData dataSetUp = new TST_CDA_SetupData();

    /**
     * Data Set Up Method.
     */
    @testSetup
    static void setupData() {
        upsert new  Mulesoft_Integration_Control__c(Enable_OLIS_JSON__c = true, Is_Mulesoft_User__c = true, Enable_OLI_Sync_Validation__c = true, Enable_Opportunity_Sync_Validation__c = true);
        dataSetUp.setupUserNegotiator();
        dataSetUp.setUpCustomSetting();
        dataSetUp.setUpContactForEmail();
        Account acct = new Account(Name = 'TestAcc',RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert acct;

        Contact Con = new Contact( 
            Firstname='Brian', 
            Lastname='Dent', 
            Phone='(619)852-4569', 
            Department='Mission Control', 
            Title='Mission Specialist - Neptune', 
            Email='briandent@trailhead.com',
            AccountId = acct.Id);
        insert Con;
        
        Entitlement ent = new Entitlement(Name='Testing', AccountId=acct.Id,Type = 'TECHNO',
                                          BusinessHoursId = [select id from BusinessHours where Name = 'Default'].Id,
                                          StartDate=Date.valueof(System.now().addDays(-2)), 
                                          EndDate=Date.valueof(System.now().addYears(2)));
        insert ent;
        List<Queue_User_Relationship__c> queueList = new List<Queue_User_Relationship__c>();
        Queue_User_Relationship__c queues = new Queue_User_Relationship__c();
        queues.Name = 'Data GLOBAL E-SERVICE';
        queues.QueueName__c = 'Data GLOBAL E-SERVICE';
        queues.Type__c = 'Queue'; 
        queues.User__c = UserInfo.getUserId();
        queueList.add(queues);
        
        Queue_User_Relationship__c queueUser = new Queue_User_Relationship__c();
        queueUser.Name = 'Data GLOBAL E-SERVICE';
        queueUser.QueueName__c = 'Data GLOBAL E-SERVICE';
        queueUser.Type__c = 'User';
        queueUser.User__c = UserInfo.getUserId();
        queueList.add(queueUser); 
        insert queueList;
        
        Id RecordTypeIdCaseRD = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Activity Plan Case').getRecordTypeId();
        
        List<Case> cList = new List<Case>();
            Case c1 = new Case(
                Subject = 'R&D - Activity Plan Case 01',
            Description = 'R&D AP Case Description',
                AccountId = acct.Id,
                ContactId = con.Id,
                Origin = 'Email',
                Status = 'New',
                InitialQueue__c = 'group name',
                RandD_Location__c = 'Dalian',
                OwnerId = UserInfo.getUserId(),
                EntitlementId = ent.Id,
                RecordTypeId = RecordTypeIdCaseRD,
                CurrentQueue__c = queueUser.Id
            );
        
        cList.add(c1);
        insert cList;
    }

    /**
     * Test Method to test the create and send envelope.
     */
    @isTest
    static void testForCompletedAttachmentInsert() {
        Test.setMock(HttpCalloutMock.class, new WSC_CDA_HttpResponseGeneratorMock());
        test.startTest();
        User user = [SELECT id FROM User WHERE Alias = 'TestUsr2' Limit 1].get(0);
        System.runas(user) {
            //Added by Vikram Singh under CR-11576 Start
            CDA_Approved_Governing_Law_Location__c governingLaw = TST_CDA_SetupData.getGoverningLaw('Test GL1');
            insert governingLaw;
            QI_Legal_Entity__c testQiLegalEntity = TST_CDA_SetupData.createQiLegalEntity('Test Entity101', UTL_CDAUtility.CDA_BUSINESS_PART_LQ, governingLaw);
            insert testQiLegalEntity;
            //Added by Vikram Singh under CR-11576 End
            dataSetUp.setupTestDataForAuditor(testQiLegalEntity);  //Updated by Vikram Singh under CR-11576
            CDA_Request__c cdaRecordAuditor = new CDA_Request__c();
            cdaRecordAuditor = [Select id, name from CDA_Request__c where id =: dataSetUp.cdaRecordAuditor.id];
            dsfs__DocuSign_Status__c testDSStatus = TST_CDA_SetupData.getDSStatusByRequestId(cdaRecordAuditor.name);
            Attachment attach = new Attachment();
            attach.Name = 'Unit Test Attachment_Completed' + UTL_CDAUtility.UPLOADED_CUSTOMER_CONSENT_TO_DISCLOSE_FILE;
            Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
            attach.body = bodyBlob;
            attach.parentId = testDSStatus.id;
            insert attach;
        }
        test.stopTest();
        //system.assertEquals(UTL_CDAUtility.STATUS_QUINTILESIMS_VALIDATING_RECIPIENT_RESPONSE, [select id, status__c from CDA_Request__c where id =: dataSetUp.cdaRecordAuditor.id].get(0).Status__c);
        List < Attachment > attachList = new List < Attachment > ();
        attachList = [Select id from Attachment where ParentId =: dataSetUp.cdaRecordAuditor.id];
        try {
            delete attachList ;
        }
        catch ( Exception e) {
            //system.assertEquals(true,e.getMessage().contains('You are not authorized to delete this attachment.'));
        }
    }

    /**
     * Test Method to test the create and send envelope.
     */
    @isTest
    static void testForCompletedAttachmentDelete() {
        Test.setMock(HttpCalloutMock.class, new WSC_CDA_HttpResponseGeneratorMock());
        User user = [SELECT id FROM User WHERE Alias = 'TestUsr2' Limit 1].get(0);
        List < Attachment > attachList = new List < Attachment > ();
        test.startTest();
        System.runas(user) {
            //Added by Vikram Singh under CR-11576 Start
            CDA_Approved_Governing_Law_Location__c governingLaw = TST_CDA_SetupData.getGoverningLaw('Test GL2');
            insert governingLaw;
            QI_Legal_Entity__c testQiLegalEntity = TST_CDA_SetupData.createQiLegalEntity('Test Entity202', UTL_CDAUtility.CDA_BUSINESS_PART_LQ, governingLaw);
            insert testQiLegalEntity;
            //Added by Vikram Singh under CR-11576 End
            dataSetUp.setupTestDataForAuditor(testQiLegalEntity);  //Updated by Vikram Singh under CR-11576
            CDA_Request__c cdaRecordAuditor = new CDA_Request__c();
            cdaRecordAuditor = [Select id, name from CDA_Request__c where id =: dataSetUp.cdaRecordAuditor.id];
            dsfs__DocuSign_Status__c testDSStatus = TST_CDA_SetupData.getDSStatusByRequestId(cdaRecordAuditor.name);
            Attachment attach = new Attachment();
            attach.Name = 'Unit Test Attachment' + UTL_CDAUtility.UPLOADED_CUSTOMER_CONSENT_TO_DISCLOSE_FILE;
            Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
            attach.body = bodyBlob;
            attach.parentId = testDSStatus.id;
            insert attach;
            attachList = [Select id from Attachment where ParentId =: dataSetUp.cdaRecordAuditor.id];
            //system.assertEquals(true, attachList.size() > 0);
            delete attachList;
        }
        test.stopTest();
        //system.assertEquals(true, attachList.size() > 0);
    }

    /**
     * Test Method to test the create and send envelope.
     */
    @isTest
    static void testForCompletedAttachmentUpdate() {
        Test.setMock(HttpCalloutMock.class, new WSC_CDA_HttpResponseGeneratorMock());
        User user = [SELECT id FROM User WHERE Alias = 'TestUsr2' Limit 1].get(0);
        test.startTest();
        System.runas(user) {
            CDA_Request__c cdaRecordAuditor = new CDA_Request__c();
            //Added by Vikram Singh under CR-11576 Start
            CDA_Approved_Governing_Law_Location__c governingLaw = TST_CDA_SetupData.getGoverningLaw('Test GL3');
            insert governingLaw;
            QI_Legal_Entity__c testQiLegalEntity = TST_CDA_SetupData.createQiLegalEntity('Test Entity31', UTL_CDAUtility.CDA_BUSINESS_PART_LQ, governingLaw);
            insert testQiLegalEntity;
            //Added by Vikram Singh under CR-11576 End
            dataSetUp.setupTestDataForAuditor(testQiLegalEntity);  //Updated by Vikram Singh under CR-11576
            cdaRecordAuditor = [Select id, name from CDA_Request__c where id =: dataSetUp.cdaRecordAuditor.id];
            dsfs__DocuSign_Status__c testDSStatus = TST_CDA_SetupData.getDSStatusByRequestId(cdaRecordAuditor.name);
            Attachment attach = new Attachment();
            attach.Name = 'Unit Test Attachment' + UTL_CDAUtility.UPLOADED_CUSTOMER_CONSENT_TO_DISCLOSE_FILE;
            Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
            attach.body = bodyBlob;
            attach.parentId = testDSStatus.id;
            insert attach;
            attach.Name = 'Unit Test Attachment1' + UTL_CDAUtility.UPLOADED_CUSTOMER_CONSENT_TO_DISCLOSE_FILE;
            update attach;
        }
        test.stopTest();
        List < Attachment > attachList = new List < Attachment > ();
        attachList = [Select id from Attachment where ParentId =: dataSetUp.cdaRecordAuditor.id];
        //system.assertEquals(true, attachList.size() > 0);
    }

    /**
     * Test Method to test the create and send envelope.
     */
    @isTest
    static void testForCompletedAttachmentUnDelete() {
        Test.setMock(HttpCalloutMock.class, new WSC_CDA_HttpResponseGeneratorMock());
        User user = [SELECT id FROM User WHERE Alias = 'TestUsr2' Limit 1].get(0);
        List < Attachment > attachList = new List < Attachment > ();
        test.startTest();
        System.runas(user) {
            //Added by Vikram Singh under CR-11576 Start
            CDA_Approved_Governing_Law_Location__c governingLaw = TST_CDA_SetupData.getGoverningLaw('Test GL4');
            insert governingLaw;
            QI_Legal_Entity__c testQiLegalEntity = TST_CDA_SetupData.createQiLegalEntity('Test Entity41', UTL_CDAUtility.CDA_BUSINESS_PART_LQ, governingLaw);
            insert testQiLegalEntity;
            //Added by Vikram Singh under CR-11576 End
            dataSetUp.setupTestDataForAuditor(testQiLegalEntity);  //Updated by Vikram Singh under CR-11576
            CDA_Request__c cdaRecordAuditor = new CDA_Request__c();
            cdaRecordAuditor = [Select id, name from CDA_Request__c where id =: dataSetUp.cdaRecordAuditor.id];
            dsfs__DocuSign_Status__c testDSStatus = TST_CDA_SetupData.getDSStatusByRequestId(cdaRecordAuditor.name);
            Attachment attach = new Attachment();
            attach.Name = 'Unit Test Attachment' + UTL_CDAUtility.UPLOADED_CUSTOMER_CONSENT_TO_DISCLOSE_FILE;
            Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
            attach.body = bodyBlob;
            attach.parentId = testDSStatus.id;
            insert attach;

            attachList = [Select id from Attachment where ParentId =: dataSetUp.cdaRecordAuditor.id];
            //system.assertEquals(true, attachList.size() > 0);
            delete attachList;
            undelete attachList;
        }
        test.stopTest();
        //system.assertEquals(true, attachList.size() > 0);
    }

    /**
     * Test Method to test the apttus generated doc through batch process.
     */
    @isTest
    static void testForBatchGeneratedApttusDoc() {
        test.startTest();
        User user = [SELECT id FROM User WHERE Alias = 'TestUsr2' Limit 1].get(0);
        System.runas(user) {
            //Added by Vikram Singh under CR-11576 Start
            CDA_Approved_Governing_Law_Location__c governingLaw = TST_CDA_SetupData.getGoverningLaw('Test GL5');
            insert governingLaw;
            QI_Legal_Entity__c testQiLegalEntity = TST_CDA_SetupData.createQiLegalEntity('Test Entity51', UTL_CDAUtility.CDA_BUSINESS_PART_LQ, governingLaw);
            insert testQiLegalEntity;
            //Added by Vikram Singh under CR-11576 End
            dataSetUp.setupTestDataForCustomer(testQiLegalEntity);  //Updated by Vikram Singh under CR-11576
            CDA_Request__c cdaRecordCustomer = new CDA_Request__c();
            cdaRecordCustomer = [Select id, name from CDA_Request__c where id =: dataSetUp.cdaRecordCustomer.id];
            cdaRecordCustomer.Status__c = UTL_CDAUtility.STATUS_SUBMITTEDFORPROCESSING;
            update cdaRecordCustomer;

            String attName = UTL_CDAUtility.GENERATED_DOCUMENT_KEYWORD + '_' + cdaRecordCustomer.Name;
            Attachment attach = dataSetUp.getAttachment(attName, cdaRecordCustomer.Id);
            Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
            attach.body = bodyBlob;
            update attach;
        }
        test.stopTest();
    }

    @isTest
    static void testForupdateContractOnAttachment() {
         CDA_Approved_Governing_Law_Location__c governingLaw = TST_CDA_SetupData.getGoverningLaw('Test GL2');
            insert governingLaw;
            QI_Legal_Entity__c testQiLegalEntity = TST_CDA_SetupData.createQiLegalEntity('Test Entity202', UTL_CDAUtility.CDA_BUSINESS_PART_LQ, governingLaw);
            insert testQiLegalEntity;
                                                      
            dataSetUp.setupTestDataForAuditor(testQiLegalEntity); 
        CDA_Request__c cdaRecordAuditor = new CDA_Request__c();
            cdaRecordAuditor = [Select id, name from CDA_Request__c where id =: dataSetUp.cdaRecordAuditor.id];
            dsfs__DocuSign_Status__c testDSStatus = TST_CDA_SetupData.getDSStatusByRequestId(cdaRecordAuditor.name);
        List<Attachment> listOfAttachment = new List<Attachment>();
        Attachment attach = new Attachment();
        attach.Name = 'Unit Test Attachment' + UTL_CDAUtility.UPLOADED_CUSTOMER_CONSENT_TO_DISCLOSE_FILE;
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId = testDSStatus.Id;
        listOfAttachment.add(attach);
        Contract testContract = new Contract(); 
        testContract.Name = 'Test Contract';
        
        List<Contract> listOfContract = new List<Contract>{testContract};
        DAOH_Attachment.testContractList = listOfContract;
        DAOH_Attachment.useMock=true;
        Test.startTest();
             DAOH_Attachment.updateContractOnAttachment(listOfAttachment);
        Test.stopTest();
        DAOH_Attachment.useMock=false;
        System.assertEquals('Signed',listOfContract[0].SOW_status__c,'Error while updating!');
    }
    
    @isTest
    static void TestDAO_DocusignEnveDoc() {
        Address__c testAccount1 = UTL_TPA_SetupTestData.getAccount();
        testAccount1.Name = 'Test Acc';
        insert testAccount1;

        TPA_Request__c tpaRequest1 = UTL_TPA_SetupTestData.getTestTPARequest();
        tpaRequest1.Request_Status__c = 'In Effect';
        tpaRequest1.OwnerId = UserInfo.getUserId();
        tpaRequest1.Service_Provider_Address__c = testAccount1.Id;
        tpaRequest1.Client_Address__c = testAccount1.Id;
        tpaRequest1.Client_Language__c = 'Japanese';
        tpaRequest1.Vendor_Language__c = 'Japanese';
        tpaRequest1.Vendor_Billing_Mailing_Country__c = 'united states';
        tpaRequest1.Is_CPC_Renewal_Notice_Sent__c = true;
        tpaRequest1.Is_CPC_Expiration_Notice_Sent__c = true;
        tpaRequest1.Is_CPC_Post_Expiration_Notice_Sent__c = true;
        insert tpaRequest1;
        
        Attachment attachment1 = new Attachment();
        attachment1.OwnerId = UserInfo.getUserId();
        attachment1.Name= 'Att1.pdf';
        attachment1.body= Blob.valueOf('Test Body');
        attachment1.ParentId = tpaRequest1.ID ;
        attachment1.IsPrivate = true;
        insert attachment1;
        update attachment1;
        delete attachment1;
    }
    
    @isTest
    static void testUpdateCaseOnOutboundMail(){
        Case caseRecord = [SELECT Id, Status, First_response_email_time__c, First_response_sent__c, Origin FROM Case WHERE RecordTypeName__c='ActivityPlan' LIMIT 1];
        EmailMessage message = new EmailMessage(FromAddress = 'dummyuser@mail.com', ToAddress = 'caseContact@mail.com', Subject = 'Test subject',
                                                TextBody = 'Test dummy body', ParentId = caseRecord.Id, Incoming=False);
        insert message;
        
        Test.startTest();
        Attachment attachment1 = new Attachment();
        attachment1.OwnerId = UserInfo.getUserId();
        attachment1.Name= 'Att1.wav';
        attachment1.ContentType = 'audio/wav';
        attachment1.body= Blob.valueOf('Test Body');
        attachment1.ParentId = message.ID ;
        attachment1.IsPrivate = true;
        insert attachment1;
        Test.stopTest();
	
    }
    
    @isTest
    static void testDeleteSignatureImageFromInboundEmail(){
        Case caseRecord = [SELECT Id, Status, Origin FROM Case WHERE RecordTypeName__c = 'ActivityPlan' LIMIT 1];
        EmailMessage message = new EmailMessage(FromAddress = 'dummyuser@mail.com', ToAddress = 'caseContact@mail.com', Subject = 'Test subject',
                                                TextBody = 'Test dummy body', ParentId = caseRecord.Id, Incoming = True);
        insert message;
        List<Attachment> attachmentList = new List<Attachment>();
        Attachment attachment1 = new Attachment();
        attachment1.OwnerId = UserInfo.getUserId();
        attachment1.Name= 'Logo.png';
        attachment1.ContentType = 'image/png';
        attachment1.body= Blob.valueOf('Test Body');
        attachment1.ParentId = message.Id;
        attachmentList.add(attachment1);
        Attachment attachment2 = new Attachment();
        attachment2.OwnerId = UserInfo.getUserId();
        attachment2.Name= 'sound.mp4';
        attachment2.ContentType = 'audio/mp4';
        attachment2.body= Blob.valueOf('Test music file attachment');
        attachment2.ParentId = message.Id;
        attachmentList.add(attachment2);
        
        Test.startTest();
        insert attachmentList;
        Test.stopTest();
    }
}