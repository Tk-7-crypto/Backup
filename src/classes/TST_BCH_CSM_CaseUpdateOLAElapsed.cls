@isTest
private class TST_BCH_CSM_CaseUpdateOLAElapsed {
    
    static testMethod void testBCHCaseUpdateOLAElapsed() 
    {
        Account acct = new Account(Name = 'TestAcc', RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert acct;
        
        Contact Con = new Contact( Firstname='Brian', Lastname='Dent', Phone='(619)852-4569', 
                                  Department='Mission Control', Title='Mission Specialist - Neptune', Email='briandent@trailhead.com',
                                  AccountId = acct.Id);
        insert Con;
        Id bhId = [select id from BusinessHours where Name = 'Default'].Id;
        Entitlement ent = new Entitlement(Name='Testing', AccountId=acct.Id,Type = 'TECHNO', BusinessHoursId = bhId,
                                          StartDate=Date.valueof(System.now().addDays(-2)), EndDate=Date.valueof(System.now().addYears(2)));
        insert ent;
        List<CaseOLASettings__c> pList = new List<CaseOLASettings__c>();
        CaseOLASettings__c p1 = new CaseOLASettings__c(Name = CON_CSM.S_TECHNO_SOL+ ' Priority 1',Priority__c = 'Priority 1',Target_Time__c = 120);
        pList.add(p1);
        CaseOLASettings__c p2 = new CaseOLASettings__c(Name = CON_CSM.S_TECHNO_SOL+ ' Priority 2',Priority__c = 'Priority 2',Target_Time__c = 240);
        pList.add(p2);
        CaseOLASettings__c p3 = new CaseOLASettings__c(Name = CON_CSM.S_TECHNO_SOL+ ' Priority 3',Priority__c = 'Priority 3',Target_Time__c = 360);
        pList.add(p3);
        CaseOLASettings__c p4 = new CaseOLASettings__c(Name = CON_CSM.S_TECHNO_SOL+ ' Priority 4',Priority__c = 'Priority 4',Target_Time__c = 480);
        pList.add(p4);
        CaseOLASettings__c ol = new CaseOLASettings__c(Name = CON_CSM.S_TECHNO_SOL+ ' OLA',Priority__c = 'Priority 4',Target_Time__c = 1440);
        pList.add(ol);
        
        CSM_Case_Details_Global_Setting__c custsettObj1 = new CSM_Case_Details_Global_Setting__c();
        custsettObj1.Name = 'Case OLA Reminder1';
        custsettObj1.Setting_Type__c = 'Email Template';
        custsettObj1.Country__c = 'Default';
        custsettObj1.Component_Id__c = '00X6A000000hM1F';
        custsettObj1.Other_Details__c = 'New';
        custsettObj1.RecordTypeId__c = '0126A000000hC35QAE';
        insert custsettObj1;
        
        CSM_Case_Details_Global_Setting__c Obj1 = new CSM_Case_Details_Global_Setting__c();
        Obj1.Name = 'Case OLA Reminder4';
        Obj1.Setting_Type__c = 'Email Template';
        Obj1.Country__c = 'Default';
        Obj1.Component_Id__c = '00X6A000000hM1F';
        Obj1.Other_Details__c = 'New';
        Obj1.RecordTypeId__c = '0126A000000hC35QAE';
        insert Obj1;
            
        CSM_Case_Details_Global_Setting__c custsettObj2 = new CSM_Case_Details_Global_Setting__c();
        custsettObj2.Name = 'Org Wide CSM';
        custsettObj2.Setting_Type__c = 'Org Wide';
        custsettObj2.Component_Id__c = '0D26A000000L1W5';
        custsettObj2.Other_Details__c = 'Customer Portal';
        custsettObj2.Origin__c = 'Customer Portal';
        custsettObj2.RecordTypeId__c = '0126A000000hC35QAE';
        insert custsettObj2;
        
        insert pList;
        //User u = [Select id from User where Id = :UserInfo.getUserId() and ProfileId = :UserInfo.getProfileId()];
        User u = UTL_TestData.createUser('System Administrator', 1)[0];
        u.Case_Comment_Work_Note__c = 'OLA Alert - Email';
        insert u;
        
        system.runAs(u) {
            Group g1 = new Group(Name='Q1', type='Queue');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
            insert q1;
            GroupMember grpUser = new GroupMember (UserOrGroupId = UserInfo.getUserId(), GroupId = g1.Id);
            insert grpUser;
            Queue_User_Relationship__c qur = new Queue_User_Relationship__c(
                Name = grpUser.group.Name,Type__c = 'Queue',Group_Id__c = grpUser.groupId,Business_Hours__c = bhId);
            insert qur;
            
            Queue_User_Relationship__c qurUser = new Queue_User_Relationship__c(
                Name = grpUser.group.Name, User__c = grpUser.UserOrGroupId, Type__c = 'User',Group_Id__c = grpUser.groupId);
            insert qurUser;
            
            Group g2 = new Group(Name='Q2', type='Queue');
            insert g2;
            QueuesObject q2 = new QueueSObject(QueueID = g2.id, SobjectType = 'Case');
            insert q2;
            GroupMember grpUser2 = new GroupMember (UserOrGroupId = UserInfo.getUserId(), GroupId = g2.Id);
            insert grpUser2;
            Queue_User_Relationship__c qur2 = new Queue_User_Relationship__c(
                Name = grpUser2.group.Name,Type__c = 'Queue',Group_Id__c = grpUser2.groupId);
            insert qur2;
            Queue_User_Relationship__c qurUser2 = new Queue_User_Relationship__c(
                Name = grpUser.group.Name, User__c = grpUser.UserOrGroupId,Type__c = 'User',Group_Id__c = grpUser.groupId);
            insert qurUser2;
            
            Id rt = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
            
            Case cs = new Case();
            cs.ContactId = Con.Id;
            cs.AccountId = acct.Id;
            cs.RecordTypeId = rt;
            cs.Priority = 'Priority 1';
            cs.Origin = 'Phone';
            cs.Mail_CC_List__c = 'nodata@info.com';
            cs.Subject = 'Techno case';
            cs.Description = 'Test class to check case creation';
            cs.Status = 'New';
            cs.OwnerId = g1.Id;
            insert cs;
            cs.OwnerId = g2.Id;
            update cs;
            cs.OwnerId = g1.Id;
            update cs;
            CaseOLA__c ola = new CaseOLA__c(IsActive__c = true, Case__c = cs.Id,Priority__c = cs.Priority ,Current_Queue__c = 'Q1',Previous_Queue__c ='Q2');
            insert ola; 
            Datetime now = System.now();
            Test.setCreatedDate(ola.Id, now.addMinutes(-5));
            ola.OLAEndDate__c = now.addMinutes(-5);
            update ola;
            List<CaseOLA__c> olaLst = Database.query('SELECT Id,Priority__c,Case__c,Case__r.Status,Case__r.RecordTypeName__c,IsActive__c,CreatedDate,QueueId__c,Previous_Queue__c,Current_Queue__c,CompletionOLADate__c,Elapsed_OLA_Time__c,OLAEndDate__c  From CaseOLA__c Where IsActive__c = true LIMIT 2000');    
            Test.startTest();
            BCH_CSM_CaseUpdateOLAElapsed obj = new BCH_CSM_CaseUpdateOLAElapsed();
            Database.QueryLocator ql = obj.start(null);
            obj.execute(null,olaLst);
            obj.Finish(null);
            Test.stopTest();
        }
    }
    
    static testMethod void testCompleteCaseOLA() 
    {
        Account acct = new Account(Name = 'TestAcc', RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert acct;
        
        Contact Con = new Contact( Firstname='Brian', Lastname='Dent', Phone='(619)852-4569', 
            Department='Mission Control', Title='Mission Specialist - Neptune', Email='briandent@trailhead.com',
            AccountId = acct.Id);
        insert Con;
        Id bhId = [select id from BusinessHours where Name = 'Default'].Id;
        Entitlement ent = new Entitlement(Name='Testing', AccountId=acct.Id,Type = 'TECHNO', BusinessHoursId = bhId,
        StartDate=Date.valueof(System.now().addDays(-2)), EndDate=Date.valueof(System.now().addYears(2)));
        insert ent;
        List<CaseOLASettings__c> pList = new List<CaseOLASettings__c>();
        CaseOLASettings__c p1 = new CaseOLASettings__c(Name = CON_CSM.S_TECHNO_SOL+ ' Priority 1',Priority__c = 'Priority 1',Target_Time__c = 120);
        pList.add(p1);
        CaseOLASettings__c p2 = new CaseOLASettings__c(Name = CON_CSM.S_TECHNO_SOL+ ' Priority 2',Priority__c = 'Priority 2',Target_Time__c = 240);
        pList.add(p2);
        CaseOLASettings__c p3 = new CaseOLASettings__c(Name = CON_CSM.S_TECHNO_SOL+ ' Priority 3',Priority__c = 'Priority 3',Target_Time__c = 360);
        pList.add(p3);
        CaseOLASettings__c p4 = new CaseOLASettings__c(Name = CON_CSM.S_TECHNO_SOL+ ' Priority 4',Priority__c = 'Priority 4',Target_Time__c = 480);
        pList.add(p4);
        CaseOLASettings__c ol = new CaseOLASettings__c(Name = CON_CSM.S_TECHNO_SOL+ ' OLA',Priority__c = 'Priority 4',Target_Time__c = 1440);
        pList.add(ol);
        insert pList;
        User u = [Select id from User where Id = :UserInfo.getUserId() and ProfileId = :UserInfo.getProfileId()];
        
        system.runAs(u) {
        Group g1 = new Group(Name='Q1', type='Queue');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
            insert q1;
            GroupMember grpUser = new GroupMember (UserOrGroupId = UserInfo.getUserId(), GroupId = g1.Id);
            insert grpUser;
            Queue_User_Relationship__c qur = new Queue_User_Relationship__c(
                Name = grpUser.group.Name,Type__c = 'Queue',Group_Id__c = grpUser.groupId,Business_Hours__c = bhId);
            insert qur;
            
            Queue_User_Relationship__c qurUser = new Queue_User_Relationship__c(
                Name = grpUser.group.Name, User__c = grpUser.UserOrGroupId, Type__c = 'User',Group_Id__c = grpUser.groupId);
            insert qurUser;
            
            Group g2 = new Group(Name='Q2', type='Queue');
            insert g2;
            QueuesObject q2 = new QueueSObject(QueueID = g2.id, SobjectType = 'Case');
            insert q2;
            GroupMember grpUser2 = new GroupMember (UserOrGroupId = UserInfo.getUserId(), GroupId = g2.Id);
            insert grpUser2;
            Queue_User_Relationship__c qur2 = new Queue_User_Relationship__c(
                Name = grpUser2.group.Name,Type__c = 'Queue',Group_Id__c = grpUser2.groupId);
            insert qur2;
            Queue_User_Relationship__c qurUser2 = new Queue_User_Relationship__c(
                Name = grpUser.group.Name, User__c = grpUser.UserOrGroupId,Type__c = 'User',Group_Id__c = grpUser.groupId);
            insert qurUser2;
            
            Id rt = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
            
            Case cs = new Case();
            cs.ContactId = Con.Id;
            cs.AccountId = acct.Id;
            cs.RecordTypeId = rt;
            cs.Priority = 'Priority 1';
            cs.Origin = 'Phone';
            cs.Mail_CC_List__c = 'nodata@info.com';
            cs.Subject = 'Techno case';
            cs.Description = 'Test class to check case creation';
            cs.Status = 'New';
            cs.OwnerId = g1.Id;
            insert cs;
        
        CaseOLA__c ola = new CaseOLA__c(IsActive__c = true, Case__c = cs.Id,Priority__c = cs.Priority ,Current_Queue__c = 'Q1');
        insert ola;
        ola.OLAEndDate__c = System.today();
        update ola;
        List<CaseOLA__c> olaLst = Database.query('SELECT Id,Priority__c,Case__c,Case__r.RecordTypeName__c,IsActive__c,CreatedDate,QueueId__c,Previous_Queue__c,Current_Queue__c,CompletionOLADate__c,Elapsed_OLA_Time__c,OLAEndDate__c  From CaseOLA__c Where OLAEndDate__c != null and CompletionOLADate__c = null and IsActive__c = true LIMIT 2000');    
        Test.startTest();
        BCH_CSM_CompleteCaseOLA obj = new BCH_CSM_CompleteCaseOLA();
        Database.QueryLocator ql = obj.start(null);
        obj.execute(null,olaLst);
        obj.Finish(null);
        Test.stopTest();
        }
    }
}