/**
* This test class is used to test all methods in CaseComment trigger.
* version : 1.0
*/
@isTest
private class TST_DAO_CaseComment {
    static testmethod void testupdateStatusforLogAWorkNoteonCase(){
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
                Origin = 'Customer Portal',
                Status = 'New',
                AssignCaseToCurrentUser__c = false,
                InitialQueue__c = 'group name',
                OwnerId = g1.Id,
                EntitlementId = ent.Id,
                RecordTypeId = RecordTypeIdCase
            );
            insert c;
            
            
            CaseComment[] newComment = new CaseComment[0];
            newComment.add(new CaseComment(ParentId = c.Id,CommentBody = 'Test Comment Case CommentBoby',IsPublished = true)); 
            insert newComment;
            newComment[0].CommentBody = 'Test Comment Case CommentBoby 11';
            update newComment[0];
            
        }
        
        
    }
}