@isTest
private class TST_CNT_CSM_CreateTechnoTaskAction {
    
public testmethod static void TestAccEntitlement1() {
        
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
        
        Entitlement ent = new Entitlement(Name='CSM TECHNO New Contract Entitlement Process', AccountId=acct.Id,Type = 'TECHNO',
                                          BusinessHoursId = [select id from BusinessHours where Name = 'Default'].Id,
                                          StartDate=Date.valueof(System.now().addDays(-2)), 
                                          EndDate=Date.valueof(System.now().addYears(2)));
    
        insert ent;
        
        
        User u = [Select id from User where Id = :UserInfo.getUserId() and ProfileId = :UserInfo.getProfileId()];
        
        system.runAs(u) {
            Group g1 = new Group(Name='TECH group name', type='Queue');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
            insert q1;
            
            GroupMember grpUser = new GroupMember (
                UserOrGroupId = u.Id,
                GroupId = g1.Id);
            
            insert grpUser;
            Queue_User_Relationship__c quer = new Queue_User_Relationship__c(
                Name = grpUser.group.Name,
                Type__c = 'Queue',
                Group_Id__c = grpUser.groupId);
            
            insert quer;
            
            Queue_User_Relationship__c qur = new Queue_User_Relationship__c(
                Name = grpUser.group.Name,User__c = grpUser.UserOrGroupId,
                Type__c = 'User',QueueManager__c = true,Tier__c='Tier 1',
                TECH_QueueUser__c = quer.Id, Group_Id__c = grpUser.groupId);
            
            insert qur;
            
            Id RecordTypeIdCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
            
            Case c = new Case(
                AccountId = acct.Id,
                ContactId = con.Id,
                Origin = 'Chat',
                Status = 'New',
                AssignCaseToCurrentUser__c = false,
                InitialQueue__c = 'TECH group name',
                OwnerId = u.Id,
                IsEscalated = true,
                EntitlementId = ent.Id,
                RecordTypeId = RecordTypeIdCase
            );
            insert c;
            CNT_CSM_CreateTechnoTaskAction.getCaseRecord(c.Id);
            List<EXT_CSM_CheckboxDetails> action = CNT_CSM_CreateTechnoTaskAction.getCaseTechnoTaskList(c.Id,'T3');
            CNT_CSM_CreateTechnoTaskAction.saveTasktoCreate(c,c.Id, CON_CSM.S_RCA_REQ);
            CNT_CSM_CreateTechnoTaskAction.saveTasktoCreate(c,c.Id, CON_CSM.S_COMMUNICATION_UPD);
            CNT_CSM_CreateTechnoTaskAction.saveTasktoCreate(c,c.Id, CON_CSM.S_RESOLUTION_PLAN_PROVID);
            CNT_CSM_CreateTechnoTaskAction.saveTasktoCreate(c,c.Id, CON_CSM.S_RESOLUTION_PLAN);
            CNT_CSM_CreateTechnoTaskAction.saveTasktoCreate(c,c.Id, CON_CSM.S_RCA_DELIVERED);
            CNT_CSM_CreateTechnoTaskAction.getCasePostUserQueueMembers(c.Id,c.InitialQueue__c,null);
         }
    
    }
}