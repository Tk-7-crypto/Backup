@istest
public class TST_CNT_CSM_EmailView {
    
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
    private static void testgetData(){
        EmailMessage mailRecord = [SELECT Id, ParentId FROM EmailMessage LIMIT 1];
        Test.startTest();
        CNT_CSM_EmailView.getData(mailRecord.Id);
        Test.stopTest();
    }
    
    @isTest
    private static void testgetEmailMessageRelations(){
        EmailMessage mailRecord = [SELECT Id, ParentId FROM EmailMessage LIMIT 1];
        Test.startTest();
        CNT_CSM_EmailView.getEmailMessageRelations(mailRecord.Id);
        Test.stopTest();
    }
    
    @isTest
    private static void testgetAttachments(){
        EmailMessage mailRecord = [SELECT Id, ParentId FROM EmailMessage LIMIT 1];
        Test.startTest();
        CNT_CSM_EmailView.getAttachments(mailRecord.Id);
        Test.stopTest();
    }
    
    @isTest
    private static void testupdatePIIDataIdentified(){
        EmailMessage mailRecord = [SELECT Id, ParentId FROM EmailMessage LIMIT 1];
        Test.startTest();
        CNT_CSM_EmailView.updatePIIDataIdentified(mailRecord.Id, true);
        Test.stopTest();
    }
    

}