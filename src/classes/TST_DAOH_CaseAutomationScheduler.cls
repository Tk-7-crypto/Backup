@isTest
private class TST_DAOH_CaseAutomationScheduler {
    
    @testSetup
    private static void dataSetup(){
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
    }
    
    @isTest
    static void testSetPrimaryAndSecondaryCurrentQueue(){
        Account accRecord = [SELECT Id FROM Account LIMIT 1];
        Product2 prodRecord = [SELECT Id FROM Product2 LIMIT 1];
        Asset assetRecord = [SELECT Id FROM Asset LIMIT 1];
        CSM_QI_Case_Categorization__c caseCatRecord = [SELECT Id FROM CSM_QI_Case_Categorization__c LIMIT 1];
        UserRole portalRole = [SELECT Id FROM UserRole WHERE DeveloperName = 'CSM' LIMIT 1];
        Profile adminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User adminUser = New User(Alias = 'su', UserRoleId = portalRole.Id, ProfileId = adminProfile.Id, Email = 'adminUser12@iqvia.com', IsActive =true , Username ='adminUser12@iqvia.com.csm', 
                                  LastName= 'testLastName', EmployeeNumber='4345702', CommunityNickname ='testSuNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', 
                                  LanguageLocaleKey='en_US', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description');
        insert adminUser;
        System.runAs(adminUser){
            Queue_User_Relationship__c queue = new Queue_User_Relationship__c();
            queue.Name ='Tech Queue';
            queue.QueueName__c ='Tech Queue';
            queue.Type__c ='Queue';
            insert queue;
            Queue_User_Relationship__c queueUser1 = new Queue_User_Relationship__c();
            queueUser1.Name ='Tech Queue';
            queueUser1.QueueName__c ='Tech Queue';
            queueUser1.TECH_QueueUser__c = queue.Id;
            queueUser1.Type__c ='User';
            queueUser1.User__c = UserInfo.getUserId();
            insert queueUser1;
            Queue_User_Relationship__c queueUser2 = new Queue_User_Relationship__c();
            queueUser2.Name ='Tech Queue';
            queueUser2.QueueName__c ='Tech Queue';
            queueUser2.TECH_QueueUser__c = queue.Id;
            queueUser2.Type__c ='User';
            queueUser2.User__c = adminUser.Id;
            insert queueUser2;
            
            List<CSM_QI_CaseAutomationScheduler__c> caseAutoList = new List<CSM_QI_CaseAutomationScheduler__c>();
            CSM_QI_CaseAutomationScheduler__c caseAutoRecord1 = new CSM_QI_CaseAutomationScheduler__c();
            caseAutoRecord1.Account_Name__c = accRecord.Id;
            caseAutoRecord1.Frequency__c = 'Daily';
            caseAutoRecord1.Subject__c = 'Test subject 1';
            caseAutoRecord1.Description__c = 'Test description 1';
            caseAutoRecord1.Primary_Owner__c = UserInfo.getUserId();
            caseAutoRecord1.Secondary_Owner__c = adminUser.Id;
            caseAutoRecord1.Start_Date__c = Date.today();
            caseAutoRecord1.Asset_Name__c = assetRecord.Id;
            caseAutoList.add(caseAutoRecord1);
            
            CSM_QI_CaseAutomationScheduler__c caseAutoRecord2 = new CSM_QI_CaseAutomationScheduler__c();
            caseAutoRecord2.Account_Name__c = accRecord.Id;
            caseAutoRecord2.Frequency__c = 'Daily';
            caseAutoRecord2.Subject__c = 'Test subject 2';
            caseAutoRecord2.Description__c = 'Test description 2';
            caseAutoRecord2.Primary_Owner__c = UserInfo.getUserId();
            caseAutoRecord2.Secondary_Owner__c = adminUser.Id;
            caseAutoRecord2.Start_Date__c = Date.today().addDays(3);
            caseAutoRecord2.Asset_Name__c = assetRecord.Id;
            caseAutoList.add(caseAutoRecord2);
            
            Test.startTest();
            insert caseAutoList;

            caseAutoRecord1.Case_Categorization__c = caseCatRecord.Id;
            caseAutoRecord2.Case_Categorization__c = caseCatRecord.Id;
            CSM_QI_Frequency__c freqRecord = new CSM_QI_Frequency__c();
            freqRecord.Frequency__c = 'Weekly';
            freqRecord.Weekday__c = 'Wednesday';
            insert freqRecord;
            caseAutoRecord1.FrequencyId__c = freqRecord.Id;
            update caseAutoList;
            caseAutoRecord1.Active__c = True;
            caseAutoRecord1.Next_Run_Date__c = Date.parse('12/31/2019');
            caseAutoRecord2.Active__c = True;
            update caseAutoList;
            Test.stopTest();
        }
    }
}