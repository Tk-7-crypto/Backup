/**
    * This test class is used to test all methods in Task Domain class.
    * version : 1.0
    */
@isTest
private class TST_DAO_Task {
    
    /**
    * This method used to set up testdata
    */ 
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        
        /*CSM Start*/
        Account accCSM = CSM_Util.createAccount();
        insert accCSM;
        Contact conCSM = CSM_Util.createContact(acc.Id,'CaseTestContact');
        insert conCSM;
        /*CSM END*/
        
        CRM_Config__c crmConfigCustomSetting = CRM_Config__c.getOrgDefaults();
        crmConfigCustomSetting.Lead_Email_Domains__c = 'infusemedia.com:madisonlogic.com';
        upsert crmConfigCustomSetting;
    }
    
    /**
    * This test method used for insert task record
    */ 
    static testMethod void testInsertTask() {   
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Task tsk = new Task();
        tsk.WhatId = opp.Id;
        tsk.Subject = 'test';
        test.startTest();
            insert tsk;
        test.stopTest();
    }
    
    /**
    * This test method used for insert task record for CSM Data Audit Trail Test
    */ 
    static testMethod void testAuditLogTask() {
        CNT_CSM_FieldHistoryTracking.saveFields('Task','AccountId,CurrencyIsoCode,IsArchived,OwnerId,CallDurationInSeconds,CallObject,CallDisposition,CallType,Description,IsRecurrence,ActivityDate,Email,IsHighPriority,WhoId,Phone,Priority,RecurrenceActivityId,RecurrenceDayOfMonth,RecurrenceDayOfWeekMask,RecurrenceEndDateOnly,RecurrenceInstance,RecurrenceInterval,RecurrenceMonthOfYear,RecurrenceStartDateOnly,RecurrenceTimeZoneSidKey,RecurrenceType,WhatId,WhatCount,WhoCount,ReminderDateTime,IsReminderSet,RecurrenceRegeneratedType,Status,TaskSubtype,Type');
         Account acct = new Account(
            Name = 'TestAcc',
            RDCategorization__c = 'Site',
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
            Group g1 = new Group(Name='group name', type='Queue');
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
			
            try{
                delete tsk;
            }catch(DMLexception e){
                system.assert(e.getMessage().contains('Cannot delete Task with related to Case'),'Cannot delete Task with related to Case');                       
            }
            test.stopTest();
        }
    }
}