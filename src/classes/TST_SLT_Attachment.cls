@isTest
private class TST_SLT_Attachment {

    static Apttus__APTS_Agreement__c getAgreementData(Id opportuntiyId) {

        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        OWF_Config__c owfConfig = UTL_OWF_TestData.createOWFConfig(grp.Id);
        insert owfConfig;

        Apttus__APTS_Agreement__c testAgreement = UTL_TestData.createAgreement();
        testAgreement.Apttus__Related_Opportunity__c = opportuntiyId;
        insert testAgreement;
        return testAgreement;
    }
    
    static Opportunity setOpportunityData(Id accountId){

        Opportunity testOpportunity= UTL_TestData.createOpportunity(accountId);
        testOpportunity.Line_of_Business__c = CON_CPQ.SAMPLE_LINE_OF_BUSINESS;
        testOpportunity.Is_this_IQVIA_Biotech__c = 'Yes';
        insert testOpportunity;
        return testOpportunity;
    }

    static Account setAccountData(){

        Account testAccount = UTL_TestData.createAccount();
        insert testAccount;
        return testAccount;
    }
    
    static Attachment getAttachment(Id parentId){
        
        Attachment attach = UTL_TestData.createAttachment();
        attach.Name = CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_NOBI_APP_NAME;
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId = parentId;
        attach.contentType = CON_CPQ.ATTACHMENT_CONTENT_TYPE;
        insert attach;
        return attach;
    }
    
    @isTest
    static void testSelectByIdShouldReturnAttachment(){

        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        Apttus__APTS_Agreement__c testAgreement = getAgreementData(testOpportunity.Id);
        Attachment testAttachment = getAttachment(testAgreement.Id);

        Test.startTest();
            List<Attachment> attachmentList = new SLT_Attachment().selectById(new Set<Id>{testAttachment.Id});
        Test.stopTest();

        system.assertEquals(true, attachmentList.size() > 0, 'Should Return Attachment');
    }
    
    @isTest
    static void testSelectAttachmentFieldsByIdShouldReturnAttachment(){

        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        Apttus__APTS_Agreement__c testAgreement = getAgreementData(testOpportunity.Id);
        Attachment testAttachment = getAttachment(testAgreement.Id);
        Set<String> fieldSet = new Set<String>{CON_CPQ.Id, CON_CPQ.Id, CON_CPQ.PARENTID, CON_CPQ.NAME, CON_CPQ.LAST_MODIFIED_BY_NAME};

        Test.startTest();
            List<Attachment> attachmentList = new SLT_Attachment().selectAttachmentFieldsById(fieldSet, new Set<Id>{testAttachment.Id});
        Test.stopTest();

        system.assertEquals(true, attachmentList.size() > 0, 'Should Return Attachment');
    }

    @isTest
    static void testGetAttachmentListByParentIdSetShouldReturnList(){
        Apttus__APTS_Agreement__c testAgreement = TST_CLM_TestDataFactory.createAgreement(null, true); 
        Attachment testAttachment = TST_CLM_TestDataFactory.createAttachment(testAgreement.Id, 'Test Attachment', true);
        Set<String> fieldSet = new Set<String>{'Id'};

        Test.startTest();
            List<Attachment> attachmentList = new SLT_Attachment().getAttachmentListByParentIdSet(fieldSet, new Set<Id>{testAgreement.Id});
        Test.stopTest();

        system.assertNotEquals(0, attachmentList.size(), 'Should Return Attachment');
    }

    @isTest
    private static void testGetAttachmentListByParentIdShouldReturnAttachment() {
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(null, true);
        Attachment attach = getAttachment(agreement.Id);
        
        Test.startTest();
            Attachment resultAttachment = new SLT_Attachment().getAttachmentListByParentId(new Set<String>{'Id', 'Name'}, agreement.Id).get(0);
        Test.stopTest();
        
        System.assertEquals(attach.Id, resultAttachment.Id, 'Attachments are not matched when not expected.');
    }

    @isTest
    private static void testGetAttachmentsShouldReturnList(){
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(null, true);
        Attachment attach = getAttachment(agreement.Id);
        Set<String> fieldsForAttachment = new Set<String>{'Id','Description','Body','Name','ContentType','BodyLength'};
        String conditionForAttachment= 'parentId = \'' + agreement.id +'\'' ;
                
        Test.startTest();
            List<Attachment> resultAttachment = new SLT_Attachment().getAttachments(fieldsForAttachment, conditionForAttachment);
        Test.stopTest();

        System.assertEquals(1, resultAttachment.size(), 'Should Return List of Attachment');
    }
    
    @isTest
    private static void testGetAttachmentsWithParentRecordTypeNameShouldReturnList(){
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(null, true);
        Attachment attach = getAttachment(agreement.Id);
        String conditionForAttachment= 'parentId = \'' + agreement.id +'\'' ;
                
        Test.startTest();
            List<Attachment> resultAttachment = new SLT_Attachment().getAttachments(new Set<Id>{attach.Id}, conditionForAttachment,
                'Project Specific Agreement');
        Test.stopTest();

        System.assertEquals(1, resultAttachment.size(), 'Should Return List of Attachment');
    }

    @isTest
    static void testSelectAttachmentsByParentId(){
        Account accountRecord = new Account(Name = 'TestAcc',RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert accountRecord;
        
        Contact contactRecord = new Contact( 
            Firstname='Brian', 
            Lastname='Dent', 
            Phone='(619)852-4569', 
            Department='Mission Control', 
            Title='Mission Specialist - Neptune', 
            Email='briandent@trailhead.com',
            AccountId = accountRecord.Id);
        insert contactRecord;
        
        Entitlement ent = new Entitlement(Name='Testing', AccountId=accountRecord.Id,Type = 'TECHNO',
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
        
        Case caseRecord = new Case(
            Subject = 'R&D - Activity Plan Case 01',
            Description = 'R&D AP Case Description',
            AccountId = accountRecord.Id,
            ContactId = contactRecord.Id,
            Origin = 'Email',
            Status = 'New',
            InitialQueue__c = 'group name',
            RandD_Location__c = 'Dalian',
            OwnerId = UserInfo.getUserId(),
            EntitlementId = ent.Id,
            RecordTypeId = RecordTypeIdCaseRD,
            CurrentQueue__c = queueUser.Id
        );
        insert caseRecord;
        
        EmailMessage message = new EmailMessage(FromAddress = 'dummyuser@mail.com', ToAddress = 'caseContact@mail.com', Subject = 'Test subject',
                                                TextBody = 'Test dummy body', ParentId = caseRecord.Id, Incoming = True);
        insert message;
        
        Attachment attachment1 = new Attachment();
        attachment1.OwnerId = UserInfo.getUserId();
        attachment1.Name= 'Logo.png';
        attachment1.ContentType = 'image/png';
        attachment1.body= Blob.valueOf('Test Body');
        attachment1.ParentId = message.Id;
        insert attachment1;
        
        Test.startTest();
        new SLT_Attachment().selectAttachmentsByParentId(new Set<Id>{message.Id});
        Test.stopTest();
    }
    
    @isTest
    private static void testGetOldAttachmentsForParent(){
        Apttus__APTS_Agreement__c objAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, true);
        Attachment objAttachment1 = TST_CLM_TestDataFactory.createAttachment(objAgreement.Id, 
            'Test Attachment.pdf', true);
        Attachment objAttachment2 = TST_CLM_TestDataFactory.createAttachment(objAgreement.Id, 
            '_Original_GCE Work Order_.pdf', true);
        Set<String> fields = new Set<String>{'Id','Description','Body','Name','ContentType','BodyLength'};
        Set<Id> attachmentIds = new Set<Id>{objAttachment2.Id};
        Set<Id> parentIds = new Set<Id>{objAgreement.Id};
        String condition = 'Parent.RecordTypeId = \'' + CON_CLM.PSA_RECORDTYPEID 
            + '\' And Name like \'%_Original_GCE Work Order_%\''
            +' AND Id NOT IN :attachmentIds'
            +' AND ParentId IN :parentIds';
        
        Test.startTest();
            List<Attachment> lstAttachment = new SLT_Attachment().getOldAttachmentsForParent(fields,
                attachmentIds, parentIds, condition);
        Test.stopTest();
        
        System.assertEquals(0, lstAttachment.size(), 'Should not return Attachment.');
    }
}