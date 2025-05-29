/**
* This test class is used to test all methods in Task trigger.
* version : 1.0
*/
@isTest
private class TST_DAOH_Task {
    
    /**
    * This method used to set up testdata
    */ 
    @testSetup
    static void dataSetup() {
        
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        
        Account acc = UTL_TestData.createAccount();
        acc.Website = 'www.test.com';
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.Is_this_IQVIA_Biotech__c = 'No';
        insert opp;
        
        /*CSM Start*/
        Account accCSM = CSM_Util.createAccount();
        accCSM.Website = 'www.testabc.com';  
        insert accCSM;
        Contact conCSM = CSM_Util.createContact(acc.Id,'CaseTestContact');
        insert conCSM;
        /*CSM END*/
        
        User user = UTL_TestData.createUser('System Administrator', 1)[0];
        user.FirstName = 'MQL Task Delete User';
        user.IsActive = true;
        insert user;
        
        MQL_Task_Delete_Setting__c mqlTaskDeleteSetting = new MQL_Task_Delete_Setting__c();
        mqlTaskDeleteSetting.Employee_Numbers__c = user.EmployeeNumber;
        insert mqlTaskDeleteSetting;
        
        CRM_Config__c crmConfigCustomSetting = CRM_Config__c.getOrgDefaults();
        crmConfigCustomSetting.Lead_Email_Domains__c = 'infusemedia.com:madisonlogic.com';
        upsert crmConfigCustomSetting;
    }

    static List<Opportunity> getOpportunityData(){
        return [SELECT Id FROM Opportunity];
    }
    
    /**
    * This test method used for insert task record for CSM Data Audit Trail Test
    */
    static testMethod void testAuditLogTask() {
        CNT_CSM_FieldHistoryTracking.saveFields('Task','AccountId,CurrencyIsoCode,IsArchived,OwnerId,CallDurationInSeconds,CallObject,CallDisposition,CallType,Description,IsRecurrence,ActivityDate,Email,IsHighPriority,WhoId,Phone,Priority,RecurrenceActivityId,RecurrenceDayOfMonth,RecurrenceDayOfWeekMask,RecurrenceEndDateOnly,RecurrenceInstance,RecurrenceInterval,RecurrenceMonthOfYear,RecurrenceStartDateOnly,RecurrenceTimeZoneSidKey,RecurrenceType,WhatId,WhatCount,WhoCount,ReminderDateTime,IsReminderSet,RecurrenceRegeneratedType,Status,TaskSubtype,Type');
         Account acct = new Account(
            Name = 'TestAcc',
            RDCategorization__c = 'Site',Website = 'www.test.com',
            CustomerSegment__c = 'GOVERNMENT',
            Sub_Industry__c = 'STATE');
        insert acct;
        
        Contact Con = new Contact( 
            Firstname='Brian', 
            Lastname='Dent', 
            Phone='(619)852-4569', 
            Department='Mission Control', 
            Title='Mission Specialist - Neptune', 
            Email='briandent@trailhead.com',
            AccountId = acct.Id);
        insert Con;
        
        Entitlement ent = new Entitlement(Name='Testing', AccountId=acct.Id,Type = 'TECHNO',
                                          BusinessHoursId = [select id from BusinessHours where Name = 'Default'].Id,
                                          StartDate=Date.valueof(System.now().addDays(-2)), 
                                          EndDate=Date.valueof(System.now().addYears(2)));
        insert ent;
        
        
        User u = [Select id from User where Id = :UserInfo.getUserId() and ProfileId = :UserInfo.getProfileId()];
        
        system.runAs(u) {
            Group g1 = new Group(Name='group name', type='Queue', DoesSendEmailToMembers = true);
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
            insert q1;
            
            GroupMember grpUser = new GroupMember (
                UserOrGroupId = u.Id,
                GroupId = g1.Id);
            
            insert grpUser;
            
            Queue_User_Relationship__c qur = new Queue_User_Relationship__c(
                Name = grpUser.group.Name,
                Type__c = 'Queue',
                Group_Id__c = grpUser.groupId);
            insert qur;
            
            Queue_User_Relationship__c qurUser = new Queue_User_Relationship__c(
                Name = grpUser.group.Name,
                User__c = grpUser.UserOrGroupId,
                Type__c = 'User',
                Group_Id__c = grpUser.groupId);
            
            insert qurUser;
            
            Id RecordTypeIdCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
            
            Case c = new Case(
                AccountId = acct.Id,
                ContactId = con.Id,
                Origin = 'Email',
                Status = 'New',
                InitialQueue__c = 'group name',
                OwnerId = g1.Id,
                EntitlementId = ent.Id,
                RecordTypeId = RecordTypeIdCase
            );
            insert c;
            Task tsk = new Task();
            tsk.WhatId = c.Id;
            tsk.Subject = 'test';
            test.startTest();
            insert tsk;
            tsk.Description ='Test Case for Task'; 
            tsk.Status = 'Open';
            tsk.Priority ='High'; 
            tsk.WhoId = con.Id;
            tsk.WhatId = acct.Id;  
            update tsk;  
            test.stopTest();
        }
    }
    
    static testMethod void testupdateStatusforLogACallonCase() {
         Account acct = new Account(
            Name = 'TestAcc',
            RDCategorization__c = 'Site',Website = 'www.test.com',
            CustomerSegment__c = 'GOVERNMENT',
            Sub_Industry__c = 'STATE');
        insert acct;
        
        Contact Con = new Contact( 
            Firstname='Brian', 
            Lastname='Dent', 
            Phone='(619)852-4569', 
            Department='Mission Control', 
            Title='Mission Specialist - Neptune', 
            Email='briandent@trailhead.com',
            AccountId = acct.Id);
        insert Con;
        
        Entitlement ent = new Entitlement(Name='Testing', AccountId=acct.Id,Type = 'TECHNO',
                                          BusinessHoursId = [select id from BusinessHours where Name = 'Default'].Id,
                                          StartDate=Date.valueof(System.now().addDays(-2)), 
                                          EndDate=Date.valueof(System.now().addYears(2)));
        insert ent;
        
        
        User u = [Select id from User where Id = :UserInfo.getUserId() and ProfileId = :UserInfo.getProfileId()];
        
        system.runAs(u) {
            Group g1 = new Group(Name='group name', type='Queue',DoesSendEmailToMembers = true, Email ='testQueue@iqvia.com');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
            insert q1;
            
            GroupMember grpUser = new GroupMember (
                UserOrGroupId = u.Id,
                GroupId = g1.Id);
            
            insert grpUser;
            
            Queue_User_Relationship__c qur = new Queue_User_Relationship__c(
                Name = grpUser.group.Name,
                Type__c = 'Queue',
                Group_Id__c = grpUser.groupId);
            insert qur;
            
            Queue_User_Relationship__c qurUser = new Queue_User_Relationship__c(
                Name = grpUser.group.Name,
                User__c = grpUser.UserOrGroupId,
                Type__c = 'User',
                Group_Id__c = grpUser.groupId);
            
            insert qurUser;
            
            Id RecordTypeIdCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
            
            Case c = new Case(
                AccountId = acct.Id,
                ContactId = con.Id,
                Origin = 'Email',
                Status = 'New',
                InitialQueue__c = 'group name',
                OwnerId = g1.Id,
                EntitlementId = ent.Id,
                RecordTypeId = RecordTypeIdCase
            );
            insert c;
            Task tsk = new Task();
            tsk.WhatId = c.Id;
            tsk.Subject = 'test';
            tsk.WhoId = Con.Id;
            test.startTest();
            insert tsk;  
            test.stopTest();
        }
            
    }
        
    static testMethod void testMQLTask() {
        Account acct = new Account(
            Name = 'TestAcc',
            RDCategorization__c = 'Site',Website = 'www.test.com',
            CustomerSegment__c = 'GOVERNMENT',
            Sub_Industry__c = 'STATE');
        insert acct;
        Lead lead = new Lead(FirstName = 'TestLead', Email = 'test@gmail.com', Country = 'USA', LastName = 'test', Company = 'test', Status = 'Not Started');
        insert lead;
        Contact Con = new Contact( 
            Firstname='Brian', 
            Lastname='Dent', 
            Phone='(619)852-4569', 
            Department='Mission Control', 
            Title='Mission Specialist - Neptune', 
            Email='briandent@trailhead.com',
            AccountId = acct.Id);
            insert Con;
            Id RecordTypeIdTask = Schema.SObjectType.Task.getRecordTypeInfosByName().get('MQL Task').getRecordTypeId();
            Task tsk = new Task();
            tsk.Subject = 'test';
            tsk.WhoId = Con.Id;
            tsk.RecordTypeId = RecordTypeIdTask;
        
            test.startTest();
            insert tsk;  
            tsk.WhoId = lead.Id;
            update tsk;
        	
        	User user = [SELECT Id from User where FirstName = 'MQL Task Delete User'];
        	System.runAs(user){
                delete tsk;
            }
        	
            test.stopTest();          
    }
    
    @isTest
    static void testSetNoOfMQLInCampaign(){
        List<Campaign> campaign = new List<campaign>();
        Campaign campaign1 = new Campaign(Name = 'test-1' , Status = 'Planned');
        Campaign campaign2 = new Campaign(Name = 'test-2' , Status = 'Planned');
        campaign.add(campaign1);
        campaign.add(campaign2);
        insert campaign;
        Task task = new Task();
        task.RecordTypeId = CON_CRM.MQL_TASK_RECORD_TYPE_ID;
        task.Disposition__c = CON_CRM.TASK_Disposition_Accept;
        task.Campaign_Name2__c = campaign[0].Id;
        Test.startTest();
        Insert task;
        task.Campaign_Name2__c = campaign[1].Id;
        Update task;
        Test.stopTest();
    }

    @isTest
    static void testCountNoOfMqlAfterTaskDelete(){
        Campaign campaign = new Campaign(Name = 'test-1' , Status = 'Planned');
        Insert campaign;
        List<Task> taskList = new List<Task>();
        taskList.add(new Task(Subject = 'test', RecordTypeId = CON_CRM.MQL_TASK_RECORD_TYPE_ID, Disposition__c = CON_CRM.TASK_Disposition_Accept, Campaign_Name2__c = campaign.Id ));
        taskList.add(new Task(Subject = 'test-1', RecordTypeId = CON_CRM.MQL_TASK_RECORD_TYPE_ID, Disposition__c = CON_CRM.TASK_Disposition_Accept, Campaign_Name2__c = campaign.Id ));
        Test.startTest();
        insert taskList;
        
        User user = [SELECT Id from User where FirstName = 'MQL Task Delete User'];
        System.runAs(user){
            delete taskList;
        }
        Test.stopTest();  
    }
    
    @isTest
    static void testPopulateCampaign(){
        Campaign campaign1 = UTL_TestData.createCampaign();
        insert campaign1;
        Task task = new Task();
        task.RecordTypeId = CON_CRM.MQL_TASK_RECORD_TYPE_ID;
        task.Disposition__c = CON_CRM.TASK_Disposition_Accept;
        task.Campaign_Name__c = 'test1';
        Test.startTest();
        insert task;
        task.Campaign_Name__c = 'test 2';
        update task;
        task.Campaign_Name__c = null;
        update task;
        Test.stopTest();
    }
    
    @isTest
    static void testMarkMQLTaskRejected(){
        
        Task task1 = UTL_TestData.createTask(null,'Not Started','Normal','Other',CON_CRM.MQL_TASK_RECORD_TYPE_ID);
        task1.Lead_Email__c = 'test@infusemedia.com';
        insert task1;
        Task task2 = UTL_TestData.createTask(null,'Not Started','Normal','Other',CON_CRM.MQL_TASK_RECORD_TYPE_ID);
        task2.Lead_Email__c = 'test@madisonlogic.com';
        Test.startTest();
        User user = [SELECT Id from User where Name = 'Eloqua App User'];
        System.runAs(user){
            task1.Interest__c = 'Analytics Solutions';
            task2.Therapy_Area__c = 'Allergy';
        }
        Test.stopTest();
    }
    
}