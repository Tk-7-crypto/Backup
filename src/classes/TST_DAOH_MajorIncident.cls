@isTest
public class TST_DAOH_MajorIncident {

    @testSetup
    private static void dataSetup(){
        List<Major_Incident__c> majorList = new List<Major_Incident__c>();
        Major_Incident__c majorRecordOne = CSM_TestDataFactory.createMajorIncident();
        majorList.add(majorRecordOne);
        Major_Incident__c majorRecordTwo = CSM_TestDataFactory.createMajorIncident();
        majorList.add(majorRecordTwo);
        insert majorList;
        
        Account accountRecord = CSM_TestDataFactory.createAccount();
        insert accountRecord;
        Contact contactRecord = CSM_TestDataFactory.createContact(accountRecord.Id,  'UditUser0110','UdUser0110','noreplyUdit10@dummy.com');
        insert contactRecord;
        
        Account accountRecord2 = CSM_TestDataFactory.createAccount();
        insert accountRecord2;
        Contact contactRecord2 = CSM_TestDataFactory.createContact(accountRecord2.Id, 'SumitUser0110','SumUser0110','noreplySumit10@dummy.com');
        insert contactRecord2;
        
        List<Queue_User_Relationship__c> queueList = new List<Queue_User_Relationship__c>();
        Queue_User_Relationship__c queues = new Queue_User_Relationship__c();
        queues.Name = 'Techno Services';
        queues.QueueName__c = 'Techno Services';
        queues.Type__c = 'Queue';
        insert queues;
        
        Queue_User_Relationship__c queueUser = new Queue_User_Relationship__c();
        queueUser.Name = 'Techno Services';
        queueUser.QueueName__c = 'Techno Services';
        queueUser.Type__c = 'User';
        queueUser.User__c = UserInfo.getUserId();
        queueUser.IsDefaultQueue__c = true;
        queueUser.TECH_QueueUser__c = queues.Id;
        insert queueUser;
        
        Id technoCaseRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
        List<Case> caseList = new List<Case>();
        Case caseRecordOne = CSM_TestDataFactory.createCase(accountRecord.Id, contactRecord.Id, technoCaseRecordTypeId, null, 'Customer Portal', null, 'Techno Case 1', 'Techno Description 1', queueUser.Id);
        caseList.add(caseRecordOne);
        Case caseRecordTwo = CSM_TestDataFactory.createCase(accountRecord.Id, contactRecord.Id, technoCaseRecordTypeId, null, 'Agent Initiated', null, 'Techno Case 2', 'Techno Description 2', queueUser.Id);
        caseList.add(caseRecordTwo);
        insert caseList;
    }
    
    @isTest
    public static void testValidateInternalEmailAddresses(){
        Major_Incident__c majorRecord = [SELECT Id, Name FROM Major_Incident__c LIMIT 1];
        majorRecord.Internal_Email_Addresses__c = 'testMail; ;testUser@info.com;';
        Test.startTest();
        try{
            update majorRecord;
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown = ex.getMessage().contains('Invalid Email Address Format In Internal Email Addresses') ? true : false;
        }
        Test.stopTest();
    }
    
    @isTest
    public static void testRestrictNewMajorIncident(){
        List<Major_Incident__c> majorList = [SELECT Id, Name FROM Major_Incident__c];
        Account accountRecord = [SELECT Id, Name FROM Account LIMIT 1];
        List<Case> caseList = [SELECT Id, CaseNumber FROM Case];
        for(Major_Incident__c majorRecord : majorList){
            MI_AccountRelationship__c miaRecord = new MI_AccountRelationship__c();
            miaRecord.Major_Incident__c = majorRecord.Id;
            miaRecord.Accounts_Impacted__c = accountRecord.Id;
            insert miaRecord;
            List<MI_CaseRelationship__c> micList = new List<MI_CaseRelationship__c>();
            for(Case caseObject : caseList){
                MI_CaseRelationship__c micRecord = new MI_CaseRelationship__c();
                micRecord.Major_Incident__c = majorRecord.Id;
                micRecord.Cases_Relationship__c = caseObject.Id;
                micList.add(micRecord);
            }
            insert micList;
        }
        update majorList;
        
        majorList[0].Status__c = 'Resolved';
        update majorList[0];
        
        for(Major_Incident__c majorRecord : majorList){
            majorRecord.Status__c = 'In Progress';
        }
        Test.startTest();
        try{
            update majorList;
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown = ex.getMessage().contains('New Major Incident can\'t be progressed while other is ongoing') ? true : false;
        }
    }
    
    @isTest
    private static void testSendEmailtoAccountContactUsers(){
        List<Major_Incident__c> majorList = [SELECT Id, Name FROM Major_Incident__c];
        List<Account> accountList = [SELECT Id, Name FROM Account];
        List<Case> caseList = [SELECT Id, caseNumber FROM Case];
        List<MI_AccountRelationship__c> miaList = new List<MI_AccountRelationship__c>();
        MI_AccountRelationship__c miaRecord1 = new MI_AccountRelationship__c();
        miaRecord1.Major_Incident__c = majorList[0].Id;
        miaRecord1.Accounts_Impacted__c = accountList[0].Id;
        miaList.add(miaRecord1);
        MI_AccountRelationship__c miaRecord2 = new MI_AccountRelationship__c();
        miaRecord2.Major_Incident__c = majorList[1].Id;
        miaRecord2.Accounts_Impacted__c = accountList[1].Id;
        miaList.add(miaRecord2);
        insert miaList;
        
        List<MI_CaseRelationship__c> micList = new List<MI_CaseRelationship__c>();
        MI_CaseRelationship__c micRecord1 = new MI_CaseRelationship__c();
        micRecord1.Major_Incident__c = majorList[0].Id;
        micRecord1.Cases_Relationship__c = caseList[0].Id;
        micList.add(micRecord1);
        MI_CaseRelationship__c micRecord2 = new MI_CaseRelationship__c();
        micRecord2.Major_Incident__c = majorList[1].Id;
        micRecord2.Cases_Relationship__c = caseList[1].Id;
        micList.add(micRecord2);
        insert micList;
        
        Test.startTest();
        majorList[0].Status__c = 'In Progress';
        majorList[1].Status__c = 'Closed';
        update majorList;
        Test.stopTest();
    }
}