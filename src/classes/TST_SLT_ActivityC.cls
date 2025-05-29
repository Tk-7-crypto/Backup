@isTest
private class TST_SLT_ActivityC {
    
    @testSetup
    static void dataSetup() {
        Account acc = CSM_Util.createAccount();
        insert acc;
        Account acc2 = CSM_Util.createRDAccount();
        insert acc2;
        Contact cnt = CSM_Util.createContact(acc.Id,'CaseTestContact');
        insert cnt;
        
        List<Account> accList = new List<Account>();

        Account acct1 = new Account(Name = 'testSetupTestSiteAccount2', RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        accList.add(acct1);
        Account acct2 = new Account(Name = 'testSetupTestSponsorAccount1', RDCategorization__c = 'Sponsor',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        accList.add(acct2);
        insert accList;
        
        Contact contact = UTL_TestData.createContact(acc.Id);
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
            AccountId = acc.Id,
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
            AccountId = acc.Id,
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
    
    /**
* This test method used for insert and update Case record
*/ 
    static testMethod void testAuditforActivity() {
        CNT_CSM_FieldHistoryTracking.saveFields('Activity__c','ActivityOrigin__c,ActivityOwner__c,AppointmentType__c,Case__c,CloseDate__c,Comments__c,Contact__c,CreatedById,CurrencyIsoCode,Description__c,Duration__c,EndDate__c,EscalationType__c,FirstName__c,Language__c,LastModifiedById,LastName__c,LOS__c,PassFail__c,RecordTypeId,ResponseSyntellectId__c,Site__c,StartDate__c,Status__c,Study__c,SystemModstamp,Team__c,TeamLocation__c,Type__c');
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'CaseTestAccount' LIMIT 1];
        Account acct2= [SELECT Id, Name FROM Account WHERE Name = 'CaseRDTestAccount' LIMIT 1];
        Contact cnt = [SELECT Id, Name FROM Contact WHERE Name = 'CaseTestContact CaseTestContact' LIMIT 1];
        Contact cnt2 = CSM_Util.createContact(acc.Id,'CaseTestContact2');
        insert cnt2;
        Study__c study= CSM_Util.createStudy(acct2.Id);
        insert study;
        Study__c study2= CSM_Util.createStudy(acct2.Id);
        insert study2;
        Product2 product = CSM_Util.createProduct2();
        insert product;
        Asset aset = CSM_Util.createAsset('CaseTestProduct',product.Id,acc.Id,cnt.Id,study.Id);
        insert aset;
        ServiceNow_Group__c service=new ServiceNow_Group__c();
        service.Group_ID__c='GRP123';
        service.Name = 'Service GRP123';
        insert service;
        
        ServiceNow_Group__c service2=new ServiceNow_Group__c();
        service2.Group_ID__c='GRP123';
        service2.Name = 'Service GRP123';
        insert service2;
        
        BusinessHours bHours = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='Default' LIMIT 1];
        BusinessHours bHours2 = [select Id,Name,IsActive,IsDefault from BusinessHours where IsActive=true and name='EU Business Hours' LIMIT 1];
        
        Entitlement ent = new Entitlement(Name='Testing', AccountId=acc.Id,Type = 'R_D',
                                          BusinessHoursId = bHours.Id,
                                          StartDate=Date.valueof(System.now().addDays(-2)), 
                                          EndDate=Date.valueof(System.now().addYears(2)));
        
        Entitlement ent2 = new Entitlement(Name='Testing2', AccountId=acc.Id,Type = 'R_D',
                                           BusinessHoursId = bHours2.Id,
                                           StartDate=Date.valueof(System.now().addDays(-2)), 
                                           EndDate=Date.valueof(System.now().addYears(2)));
        
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
        Queue_User_Relationship__c queues2=new Queue_User_Relationship__c();
        queues2.Name ='Q2';
        queues2.QueueName__c ='Q2';
        queues2.Type__c ='Queue';
        queues2.User__c = UserInfo.getUserId();
        insert queues2; 
        Queue_User_Relationship__c queueUser2=new Queue_User_Relationship__c();
        queueUser2.Name ='Q2';
        queueUser2.QueueName__c ='Q2';
        queueUser2.Type__c ='User';
        queueUser2.User__c = UserInfo.getUserId();
        insert queueUser2;
        
        Id RecordTypeIdCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Assistance Request Case').getRecordTypeId();
        Id RecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Activity Plan Case').getRecordTypeId();
        List<Case> csList=new List<Case>();
        Case cse = null,cseParent = null;
        cse = new Case(
            AccountId = acc.Id,
            ContactId = cnt.Id,
            Study__c = study.Id,
            Sponsor__c = acct2.Id,
            ServiceNow_Group__c=service.Id,
            CurrentQueue__c=queues.Id,
            Origin = 'Chat',
            Status = 'In Progress',
            InitialQueue__c = 'Q1',
            OwnerId = UserInfo.getUserId(),
            EntitlementId = ent.Id,
            RecordTypeId = RecordTypeId
        );
        csList.add(cse);
        cseParent = new Case(
            AccountId = acc.Id,
            ContactId = cnt.Id,
            Study__c = study.Id,
            Sponsor__c = acct2.Id,
            ServiceNow_Group__c=service.Id,
            CurrentQueue__c=queues.Id,
            Origin = 'Chat',
            Status = 'In Progress',
            InitialQueue__c = 'Q1',
            OwnerId = UserInfo.getUserId(),
            EntitlementId = ent.Id,
            RecordTypeId = RecordTypeIdCase
        );
        csList.add(cseParent);
        insert csList;
        Activity__c act = new Activity__c(ActivityOwner__c=UserInfo.getUserId(),Site__c=acc.Id,Study__c=study.Id,Case__c=cseParent.Id,Status__c='Open' );
        Test.startTest();
        insert act;
        SLT_ActivityC slt= new SLT_ActivityC();
        slt.getSObjectFieldList();
        slt.getSObjectType();
        slt.selectByActivityId(new Set<Id>{act.Id}, new Set<String> {CON_CSM.S_ID, CON_CSM.S_NAME});
        Test.stopTest();
    }

    @IsTest 
    static void testSelectByActivityCaseId(){
        Case caseRecord = [SELECT Id FROM Case WHERE Subject = 'ParentActivityPlanCase'];
        
        Test.startTest();
            List<Activity__c> activitiyList = new SLT_ActivityC().selectByActivityCaseId(new Set<Id>{caseRecord.Id});
        Test.stopTest();
        
        System.assertEquals(true, activitiyList != null, 'Should get related activities');
    }
    
    @IsTest 
    static void testSelectActivityByCaseId(){
        Case caseRecord = [SELECT Id FROM Case WHERE Subject = 'ParentActivityPlanCase'];
        
        Test.startTest();
        List<Activity__c> activitiyList = new SLT_ActivityC().selectActivityByCaseId(new Set<Id>{caseRecord.Id}, new Set<String>{'Id', 'Name'});
        Test.stopTest();
        
        System.assertEquals(true, activitiyList != null, 'Should get related activities');
    }
    
    @IsTest 
    static void testGetAllRelatedActivities(){
        Case caseRecord = [SELECT Id FROM Case WHERE Subject = 'ParentActivityPlanCase'];
        
        Test.startTest();
            List<Activity__c> activitiyList = new SLT_ActivityC().selectActivityByCaseIdOrdered(new Set<Id>{caseRecord.Id});
        Test.stopTest();
        
        System.assertEquals(true, activitiyList != null, 'Should get related activities');
    }
}