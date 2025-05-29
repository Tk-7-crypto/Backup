@isTest
private class TST_TGR_FeedItem {
    
    @isTest
    static void testQueueCompleted(){
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
            cs.Priority = 'Priority 4';
            cs.Origin = 'Phone';
            cs.Mail_CC_List__c = 'nodata@info.com';
            cs.Subject = 'Techno case';
            cs.Description = 'Test class to check case creation';
            cs.Status = 'New';
            cs.OwnerId = g1.Id;
            insert cs;
            Test.startTest();
            FeedItem fi = new FeedItem(ParentId = cs.Id, Body ='Test Contat',Type = 'TextPost');
            insert fi;
            Test.stopTest();
        }
    }

}