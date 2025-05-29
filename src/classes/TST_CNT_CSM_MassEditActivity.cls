@IsTest
private class TST_CNT_CSM_MassEditActivity {
    @testSetup
    static void dataSetup() {
        List<Account> accList = new List<Account>();
        Account account = UTL_TestData.createAccount();
        accList.add(account);
        Account acct1 = new Account(Name = 'testSetupTestSiteAccount2', RDCategorization__c = 'Site', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        accList.add(acct1);
        Account acct2 = new Account(Name = 'testSetupTestSponsorAccount1', RDCategorization__c = 'Sponsor', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        accList.add(acct2);
        insert accList;
        
        Contact contact = UTL_TestData.createContact(account.Id);
        insert contact;

        Id recordTypeActivityPlan =  Schema.SObjectType.Case.getRecordTypeInfosByName().get('R&D - Activity Plan Case').getRecordTypeId();
        
        Queue_User_Relationship__c queues = new Queue_User_Relationship__c();
        queues.Name ='Q1';
        queues.QueueName__c ='Q1';
        queues.Type__c ='Queue';
        queues.User__c = UserInfo.getUserId();
        insert queues;
        
        Study__c study1 = CSM_Util.createStudy(acct2.Id);
        study1.Name = 'STUDY12';
        study1.StudyID__c = 'PROJ0012';
        study1.LabProjectCode__c = 'LABPROJ0012';
        insert study1;
        
        StudySiteContactRelationship__c siteConR1 = new StudySiteContactRelationship__c(Study__c = study1.Id, Investigator_Name__c = contact.Id, Site_Name__c = acct1.Id);
        siteConR1.SiteNumber__c = 'SITE01';
        siteConR1.Lab_Site_Number__c = 'LABSITE01';
        insert siteConR1;
        
        Case parentRndCase = new Case(
            AccountId = account.Id,
            ContactId = contact.Id,
            Study__c = study1.Id,
            Site_Related_to_the_Study__c = siteConR1.Id,
            Sponsor__c = acct2.Id,
            CurrentQueue__c = queues.Id,
            Origin = 'Email',
            AssignCaseToCurrentUser__c = false,
            Status = 'New',
            Subject = 'ParentActivityPlanCase',
            RandD_Location__c = 'Dalian',
            InitialQueue__c = 'Q1',
            RnD_Email_Flag__c = true,
            OwnerId = UserInfo.getUserId(),
            AFU_Email_Addresses__c = 'testmail@mailer.com; noreply@mailer.com',
            RecordTypeId = recordTypeActivityPlan
        );
        insert new List<Case>{parentRndCase};
            
        Case childRndCase = new Case(
            ParentId = parentRndCase.Id,
            AccountId = account.Id,
            ContactId = contact.Id,
            Study__c = study1.Id,
            Site_Related_to_the_Study__c = siteConR1.Id,
            Sponsor__c = acct2.Id,
            CurrentQueue__c = queues.Id,
            Origin = 'Email',
            AssignCaseToCurrentUser__c = false,
            Status = 'New',
            Subject = 'ChildActivityPlanCase',
            RandD_Location__c = 'Dalian',
            InitialQueue__c = 'Q1',
            RnD_Email_Flag__c = true,
            OwnerId = UserInfo.getUserId(),
            AFU_Email_Addresses__c = 'testmail@mailer.com; noreply@mailer.com',
            RecordTypeId = recordTypeActivityPlan
        );
        insert new List<Case>{childRndCase};
        Activity__C activityRecord = new Activity__C(Case__c = childRndCase.Id, status__c = 'Open');
        Activity__C activity = new Activity__C(Case__c = parentRndCase.Id, status__c = 'Open');
        insert new List<Activity__C>{activity, activityRecord};
    }
    
    @IsTest 
    static void testUpdateActivities(){
        Case caseRecord = [SELECT Id FROM Case WHERE Subject = 'ParentActivityPlanCase'];
        Activity__C activity = [SELECT Id, Status__c FROM Activity__C WHERE Case__c =: caseRecord.Id];
        activity.Status__c = 'Done';
        
        Test.startTest();
            CNT_CSM_MassEditActivity.updateActivities(JSON.serialize(new List<Activity__C>{activity}));
        Test.stopTest();
        
        Activity__C updatedActivity = [SELECT Id, Status__c FROM Activity__C WHERE Case__c =: caseRecord.Id];
        System.assertEquals('Done', updatedActivity.Status__c, 'Activity should be updated');
    }
    
    @IsTest 
    static void testGetAllRelatedActivities(){
        Case caseRecord = [SELECT Id FROM Case WHERE Subject = 'ParentActivityPlanCase'];
        
        Test.startTest();
            String activitiyWrapperList = CNT_CSM_MassEditActivity.getAllRelatedActivities(caseRecord.Id);
        Test.stopTest();
        
        System.assertEquals(true, activitiyWrapperList != null, 'Should get all related activities');
    }
    
    @IsTest 
    static void testGetPickListValues(){
        Case caseRecord = [SELECT Id FROM Case WHERE Subject = 'ParentActivityPlanCase'];
        
        Test.startTest();
            String picklistWrapperInstance = CNT_CSM_MassEditActivity.getPickListValues();
        Test.stopTest();
        
        System.assertEquals(true, picklistWrapperInstance != null, 'Should get picklist values');
    }
}