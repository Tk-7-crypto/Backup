@isTest
private class TST_SCH_CSM_CaseAutomationScheduler {

    @isTest
    static void testCaseAutomationScheduler(){
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
            queueUser1.TECH_QueueUser__c = queue.id;
            queueUser1.Type__c ='User';
            queueUser1.User__c = UserInfo.getUserId();
            insert queueUser1;
            Queue_User_Relationship__c queueUser2 = new Queue_User_Relationship__c();
            queueUser2.Name ='Tech Queue';
            queueUser2.QueueName__c ='Tech Queue';
            queueUser2.Type__c ='User';
            queueUser2.TECH_QueueUser__c = queue.id;
            queueUser2.User__c = adminUser.Id;
            insert queueUser2;
            
            OutOfOffice officeRecord = new OutOfOffice(UserId = UserInfo.getUserId(), isEnabled = true, StartDate = Date.today(), EndDate = Date.today(), Message = 'Test1');
            insert officeRecord;
            
            List<CSM_QI_CaseAutomationScheduler__c> autoList = new List<CSM_QI_CaseAutomationScheduler__c>();
            for(Integer i=0; i<3; i++){
                CSM_QI_CaseAutomationScheduler__c caseAutoRecord = new CSM_QI_CaseAutomationScheduler__c();
                caseAutoRecord.Account_Name__c = accRecord.Id;
                caseAutoRecord.Frequency__c = 'Daily';
                caseAutoRecord.Subject__c = 'Test subject '+i;
                caseAutoRecord.Description__c = 'Test description '+i;
                caseAutoRecord.Primary_Owner__c = UserInfo.getUserId();
                caseAutoRecord.Primary_Owner_Current_Queue__c = queueUser1.Id;
                caseAutoRecord.Secondary_Owner__c = adminUser.Id;
                caseAutoRecord.Secondary_Owner_Current_Queue__c = queueUser2.Id;
                caseAutoRecord.Start_Date__c = Date.today();
                caseAutoRecord.Asset_Name__c = assetRecord.Id;
                caseAutoRecord.Case_Categorization__c = categorization.Id;
                autoList.add(caseAutoRecord);
            }
            insert autoList;
            
            CSM_QI_Frequency__c freqRecord1 = new CSM_QI_Frequency__c();
            freqRecord1.Frequency__c = 'Daily';
            freqRecord1.Month_Date__c = '';
            freqRecord1.Month_Interval__c = '';
            freqRecord1.Week__c = '';
            freqRecord1.Weekday__c = '';
            
            CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord1), autoList[0].Id);
            CNT_CSM_Frequency.saveFrequency(JSON.serialize(freqRecord1), autoList[1].Id);
            
            for(CSM_QI_CaseAutomationScheduler__c record : autoList){
                record.Active__c = True;
            }
            update autoList;
            Test.startTest();
            SCH_CSM_CaseAutomationScheduler autoSchedule = new SCH_CSM_CaseAutomationScheduler();
            String sch = '0 0 * * * ?';
            String jobID = System.schedule('SCH_CSM_CaseAutomationScheduler_Batch_Test', sch, autoSchedule);
            Test.stopTest();
        }
    }
}