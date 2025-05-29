@isTest
private class TST_CNT_CSM_CaseHierarchy {
    @testSetup
    static void dataSetup() {
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        String profilId2 = [select id from Profile where Name='System Administrator'].Id;
        User accOwner = New User(Alias = 'su',UserRoleId= portalRole.Id, ProfileId = profilId2,EmployeeNumber='07070707', Email = 'john2@iqvia.com',IsActive =true,Username ='john2@iqvia.com', LastName= 'testLastName', CommunityNickname ='testSuNickname', TimeZoneSidKey='America/Los_Angeles', LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', LanguageLocaleKey='en_US', Change_Request_Description__c = 'test', Change_Request_Ticket_Number__c ='test description', UserPermissionsKnowledgeUser = true);
        insert accOwner;
        System.runAs (accOwner) {
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

            Id recordType =  Schema.SObjectType.Case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
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
            
            Case parentCase = New Case(Subject = 'Parent TestCase',RecordTypeId=recordType, ContactId = contact.Id, AccountId = account.Id, Status = 'New', Priority = 'Medium', Origin = 'Email',CurrentQueue__c=queues.Id,InitialQueue__c = 'Q1');
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
            insert new List<Case>{parentCase, parentRndCase};
                
            Case c = [SELECT id FROM Case WHERE Subject='Parent TestCase'];
            Case childCase = New Case(ParentId = c.Id,Subject = 'TestCase',RecordTypeId=recordType, ContactId = contact.Id, AccountId = account.Id, Status = 'New', Priority = 'Medium', Origin = 'Email',CurrentQueue__c=queues.Id,InitialQueue__c = 'Q1');
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
            insert new List<Case>{childCase, childRndCase};
            Activity__C newActivity = new Activity__C(Case__c = childRndCase.Id, status__c = 'Open');
            insert newActivity;
        }
    }
    
    @IsTest
    static void testFindHierarchyData(){
        List<CNT_CSM_CaseHierarchy.HierarchyData> objects = new List<CNT_CSM_CaseHierarchy.HierarchyData>();  
        Case c = [SELECT id FROM Case WHERE Subject='TestCase'];
        String caseId = c.Id;
        Test.startTest();
        objects = CNT_CSM_CaseHierarchy.findHierarchyData(caseId);
        Test.stopTest();
        System.assert(objects.size() > 0);
    }
    
    @IsTest 
    static void testGetUltimateParentId(){
        Case c = [SELECT id FROM Case WHERE Subject='TestCase'];
        String caseId = c.Id;
        Test.startTest();
        String recId = CNT_CSM_CaseHierarchy.GetUltimateParentId(caseId);
        Test.stopTest();
        System.assert((recId != ''));
    }
  
    @IsTest 
    static void testShowMassEditActivityButton(){
        Case caseRecord = [SELECT Id FROM Case WHERE Subject = 'ParentActivityPlanCase'];
        
        Test.startTest();
            Boolean isShowActivityEditButton = CNT_CSM_CaseHierarchy.showMassEditActivityButton(caseRecord.Id);
        Test.stopTest();
        
        System.assertEquals(true, isShowActivityEditButton, 'Show Activity Button should be true');
    }
}