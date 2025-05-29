@isTest
private class TST_SLT_CaseAutomationScheduler {
    
    @testSetup
    private static void dataSetup(){
        UserRole portalRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'CSM' LIMIT 1];
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User adminUser = New User(Alias = 'su', UserRoleId = portalRole.Id, ProfileId = adminProfile.Id, Email = 'adminUser12@iqvia.com', IsActive =true , Username ='adminUser12@iqvia.com.csm', 
                                  LastName= 'testLastName', EmployeeNumber='4345702', CommunityNickname ='testSuNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                  LanguageLocaleKey='en_US', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description');
        insert adminUser;
        
        System.runAs(adminUser){
            Product2 productRecord = UTL_TestData.createProduct();
            insert productRecord;
            Account accRecord = UTL_TestData.createAccount();
            insert accRecord;
            Asset assetRecord = new Asset(Name = 'TestAsset', AccountId = accRecord.Id, Product2Id = productRecord.Id);
            insert assetRecord;
            Id techRecordTypeId =  Schema.SObjectType.Case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
            CSM_QI_Case_Categorization__c categorization = new CSM_QI_Case_Categorization__c(Product__c = productRecord.Id, SubType1__c = 'TestSubtype1', 
                                                                                             SubType2__c = 'TestSubtype2 2', SubType3__c = 'TestSubtype3 2', 
                                                                                             RecordTypeId__c = techRecordTypeId, Pillar__c = CON_CSM.S_TECHNOLOGY_SOLUTIONS, Type__c = 'Categorization');
            insert categorization;
            
            Queue_User_Relationship__c queue = new Queue_User_Relationship__c();
            queue.Name ='Tech Queue';
            queue.QueueName__c ='Tech Queue';
            queue.Type__c ='Queue';
            insert queue;
            Queue_User_Relationship__c queueUser1 = new Queue_User_Relationship__c();
            queueUser1.Name ='Tech Queue';
            queueUser1.QueueName__c ='Tech Queue';
            queueUser1.Type__c ='User';
            queueUser1.User__c = UserInfo.getUserId();
            insert queueUser1;
            Queue_User_Relationship__c queueUser2 = new Queue_User_Relationship__c();
            queueUser2.Name ='Tech Queue';
            queueUser2.QueueName__c ='Tech Queue';
            queueUser2.Type__c ='User';
            queueUser2.User__c = adminUser.Id;
            insert queueUser2;
            
            CSM_QI_CaseAutomationScheduler__c caseAutoRecord = new CSM_QI_CaseAutomationScheduler__c();
            caseAutoRecord.Account_Name__c = accRecord.Id;
            caseAutoRecord.Frequency__c = 'Daily';
            caseAutoRecord.Subject__c = 'Test subject';
            caseAutoRecord.Description__c = 'Test description';
            caseAutoRecord.Primary_Owner__c = UserInfo.getUserId();
            caseAutoRecord.Secondary_Owner__c = adminUser.Id;
            caseAutoRecord.Start_Date__c = Date.today();
            caseAutoRecord.Asset_Name__c = assetRecord.Id;
            insert caseAutoRecord;
        }
    }
    
    @isTest
    static void testSelectById(){
        CSM_QI_CaseAutomationScheduler__c autoRecord = [SELECT Id FROM CSM_QI_CaseAutomationScheduler__c LIMIT 1];
        
        Test.startTest();
        new SLT_CaseAutomationScheduler().selectById(new Set<Id>{autoRecord.Id});
        Test.stopTest();
    }
}