@isTest
private class TST_TRG_TimeSheet {
    @isTest
    private static void testTimeSheet(){
        Account acct = new Account(
            Name = 'TestAccTime',
            RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert acct;
        
        Contact Con = new Contact( 
            Firstname='BrianTime', 
            Lastname='DentTime', 
            Phone='(619)852-4569', 
            Department='Mission Control', 
            Title='Mission Specialist - Neptune', 
            Email='briandenta@tratilhead.com',
            AccountId = acct.Id);
        insert Con;
        
        Entitlement ent = new Entitlement(Name='Testing', AccountId=acct.Id,Type = 'TECHNO',
                                          BusinessHoursId = [select id from BusinessHours where Name = 'Default'].Id,
                                          StartDate=Date.valueof(System.now().addDays(-2)), 
                                          EndDate=Date.valueof(System.now().addYears(2)));
        insert ent;
        
        
        User u = [Select id from User where Id = :UserInfo.getUserId() and ProfileId = :UserInfo.getProfileId()];
        
        system.runAs(u) {
            Group g1 = new Group(Name='Q1', type='Queue');
            insert g1;
            QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Case');
            insert q1;
            GroupMember grpUser = new GroupMember (UserOrGroupId = UserInfo.getUserId(), GroupId = g1.Id);
            insert grpUser;
            Queue_User_Relationship__c qur = new Queue_User_Relationship__c(
                Name = grpUser.group.Name,Type__c = 'Queue',Group_Id__c = grpUser.groupId);
            insert qur;
            
            Queue_User_Relationship__c qurUser = new Queue_User_Relationship__c(TECH_QueueUser__c = qur.Id,
                                                                                Name = grpUser.group.Name, User__c = grpUser.UserOrGroupId, Type__c = 'User',Group_Id__c = grpUser.groupId);
            insert qurUser;
            
            Id RecordTypeIdCase = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
            
            Case cs2 = new Case();
            cs2.ContactId = con.Id;
            cs2.AccountId = acct.Id;
            cs2.AssignCaseToCurrentUser__c = false;
            cs2.OwnerId = UserInfo.getUserId();
            cs2.CurrentQueue__c = qur.Id;
            cs2.RecordTypeId = RecordTypeIdCase;
            cs2.Origin = 'Chat';
            cs2.Mail_CC_List__c = 'nodata@info.com';
            cs2.Subject = 'Techno case';
            cs2.Description = 'Test class to check case creation';
            cs2.Status = 'New';
            insert cs2;
            EXT_CSM_Validator_Cls cs = new EXT_CSM_Validator_Cls();
            EXT_CSM_Validator_Cls.setCloseChildDone();
            EXT_CSM_Validator_Cls.hasCloseChildDone();
            EXT_CSM_Validator_Cls.hasAlreadyDone();
            EXT_CSM_Validator_Cls.setAlreadyDone();
            EXT_CSM_Validator_Cls.setSNowCallFirstTime();
            EXT_CSM_Validator_Cls.hasSNowCallFirstTime();
            TimeSheet__c s1 = new TimeSheet__c(Type__c = 'System',StartTime__c = System.now(), Case__c = cs2.Id, Status__c = 'stop',Time_Type__c = 'Estimated effort');
            insert s1;
            
        }
    }
}