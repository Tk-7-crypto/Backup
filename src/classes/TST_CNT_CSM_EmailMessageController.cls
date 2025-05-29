@isTest
private class TST_CNT_CSM_EmailMessageController {

    @testSetup
    static void dataSetup(){
        Product2 product = UTL_TestData.createProduct();
        insert product;
        Account account = UTL_TestData.createAccount();
        insert account;
        Asset asset = new Asset(Name = 'TestAsset', AccountId = account.Id, Product2Id = product.id);
        insert asset;
        Contact contact = UTL_TestData.createContact(account.Id);
        contact.Contact_User_Type__c = 'HO User';
        insert contact;

        Id recordType =  Schema.SObjectType.Case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
       
        CSM_QI_Case_Categorization__c categorization = new CSM_QI_Case_Categorization__c(Product__c = product.Id, SubType1__c='TestSubtype1', SubType2__c='TestSubtype2 1',SubType3__c='TestSubtype3 1',RecordTypeId__c=recordType);
        categorization.Pillar__c = 'Information Offering';
        insert categorization;
        categorization = new CSM_QI_Case_Categorization__c(Product__c = product.Id, SubType1__c='TestSubtype1', SubType2__c='TestSubtype2 2',SubType3__c='TestSubtype3 2',RecordTypeId__c=recordType);
        categorization.Pillar__c = 'Technology Solutions';
        insert categorization;
        
        categorization = new CSM_QI_Case_Categorization__c(Los__c ='Los' ,SubType1__c='TestSubtype1', SubType2__c='TestSubtype22',SubType3__c='TestSubtype33',RecordTypeId__c='0126A000000hC34QAE');
        categorization.Pillar__c = 'Technology Solutions';
        insert categorization;
        
        Queue_User_Relationship__c queues=new Queue_User_Relationship__c();
        queues.Name ='Q1';
        queues.QueueName__c ='Q1';
        queues.Type__c ='Queue';
        queues.User__c = UserInfo.getUserId();
        insert queues;
        Queue_User_Relationship__c queueUser=new Queue_User_Relationship__c();
        queueUser.Name ='Q1';
        queueUser.QueueName__c ='Q1';
        queueUser.Type__c ='User';
        queueUser.User__c = UserInfo.getUserId();
        insert queueUser;
        Case c = New Case(Subject = 'TestCase', RecordTypeId=recordType, ContactId = contact.Id, AccountId = account.Id, Status = 'New', Priority = 'Medium', Origin = 'Email',CurrentQueue__c=queues.Id, InitialQueue__c = 'Q1');
        insert c;
        
        EmailMessage mailRecord = new EmailMessage();
        mailRecord.CcAddress = 'testuser1@mail.com';
        mailRecord.CreatedById = UserInfo.getUserId();
        mailRecord.CreatedDate = Datetime.now();
        mailRecord.ParentId = c.Id;
        mailRecord.ToAddress = 'testuser2@mail.com';
        mailRecord.FromAddress = 'no.reply.support@iqvia.com';
        mailRecord.Incoming = true;
        mailRecord.Subject = 'Test Subject {!Case.CaseNumber}';
        mailRecord.HtmlBody = '<p>Test Body {!Contact.FirstName}</p><p>Thanks</br>{!User.FirstName}</p>';
        insert mailRecord;
    }
    
    @isTest
    private static void testGetEmailMessages(){
        EmailMessage mailRecord = [SELECT Id FROM EmailMessage LIMIT 1];
        Test.startTest();
        CNT_CSM_EmailMessageController.getEmailMessages(mailRecord.Id);
        Test.stopTest();
    }
    
    @isTest
    private static void testGetParentDetails(){
        EmailMessage mailRecord = [SELECT Id, ParentId FROM EmailMessage LIMIT 1];
        Test.startTest();
        CNT_CSM_EmailMessageController.getParentDetails(mailRecord.ParentId);
        Test.stopTest();
    }
    
    @isTest
    private static void testGetQueueRelatedEmailAddress(){
        Case caseRecord = [SELECT Id, RecordTypeId FROM Case LIMIT 1];
        Test.startTest();
        CNT_CSM_EmailMessageController.getQueueRelatedEmailAddress('DATA', caseRecord.RecordTypeId, 'Q1');
        CNT_CSM_EmailMessageController.getQueueRelatedEmailAddress('DATA', '0126A000000hC33QAE', 'Data Global E-service');
        Test.stopTest();
    }
    
    @isTest
    private static void testSendMailToUsers(){
        EmailMessage mailRecord = [SELECT Id, ParentId, FromAddress, ToAddress, CcAddress, BccAddress, Subject, HtmlBody FROM EmailMessage LIMIT 1];
        Test.startTest();
        CNT_CSM_EmailMessageController.sendMailToUsers(mailRecord.FromAddress, mailRecord.ToAddress, mailRecord.CcAddress, mailRecord.BccAddress, mailRecord.Subject, mailRecord.HtmlBody, mailRecord.ParentId, new List<Id>(), mailRecord.Id);
        Test.stopTest();
    }
    
    @isTest
    private static void testLoadDataForAttachment(){
        Test.startTest();
        CNT_CSM_EmailMessageController.loadDataForAttachment('Owned');
        Test.stopTest();
    }
    
    @isTest
    private static void testLoadEmailTemplatesForMail(){
        Test.startTest();
        CNT_CSM_EmailMessageController.loadEmailTemplatesForMail('Classic', '');
        CNT_CSM_EmailMessageController.loadEmailTemplatesForMail('Classic', '00l6A000000S42LQAS');
        CNT_CSM_EmailMessageController.loadEmailTemplatesForMail('AllLightning', UserInfo.getUserId());
        CNT_CSM_EmailMessageController.loadEmailTemplatesForMail('AllLightning', '');
        CNT_CSM_EmailMessageController.loadEmailTemplatesForMail('MyLightning', '');
        CNT_CSM_EmailMessageController.loadEmailTemplatesForMail('MyLightning', UserInfo.getUserId());
        CNT_CSM_EmailMessageController.loadEmailTemplatesForMail('SampleLightning', '');
        CNT_CSM_EmailMessageController.loadEmailTemplatesForMail('SampleLightning', UserInfo.getUserId());
        Test.stopTest();
    }
    
    @isTest
    private static void testAddTemplateDataInMail(){
        Test.startTest();
        CNT_CSM_EmailMessageController.addTemplateDataInMail('00X6A000000Iuac');
        Test.stopTest();
    }
    
    @isTest
    private static void testGetOrgWideDefaultQueues(){
        Test.startTest();
        CNT_CSM_EmailMessageController.getOrgWideDefaultQueues();
        Test.stopTest();
    }
    
    @isTest
    private static void testGetFolderDetailsForTemplates(){
        Test.startTest();
        CNT_CSM_EmailMessageController.getFolderDetailsForTemplates('Classic');
        CNT_CSM_EmailMessageController.getFolderDetailsForTemplates('MyLightning');
        Test.stopTest();
    }
    
    @isTest
    private static void testGetContactLeadUserDetails(){
        Test.startTest();
        CNT_CSM_EmailMessageController.getContactLeadUserDetails('Alex');
        CNT_CSM_EmailMessageController.getContactLeadUserDetails('john.doe');
        Test.stopTest();
    }
    
    @isTest
    private static void testGetRecordRelatedToFields(){
        Test.startTest();
        
        Map<String, List<String>> objectMap = new Map<String, List<String>>();
        List<String> fieldList1 = new List<String>();
        fieldList1.add('CaseNumber');
        fieldList1.add('Subject');
        fieldList1.add('Status');
        objectMap.put('Case', fieldList1);
        List<String> fieldList2 = new List<String>();
        fieldList2.add('Name');
        fieldList2.add('AccountCountry__c');
        fieldList2.add('RDCategorization__c');
        objectMap.put('Account', fieldList2);
        List<String> fieldList3 = new List<String>();
        fieldList3.add('FirstName');
        fieldList3.add('LastName');
        fieldList3.add('Email');
        objectMap.put('Contact', fieldList3);
        List<String> fieldList4 = new List<String>();
        fieldList4.add('FirstName');
        fieldList4.add('LastName');
        objectMap.put('User', fieldList4);
        Case caseRecord = [SELECT Id FROM Case LIMIT 1];
        CNT_CSM_EmailMessageController.getRecordRelatedToFields(objectMap, caseRecord.Id);
        Test.stopTest();
    }
}