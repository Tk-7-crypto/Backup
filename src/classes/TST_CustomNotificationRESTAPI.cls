@istest
public class TST_CustomNotificationRESTAPI {
    
     @istest
    public static void testsendNotificationBell(){
        Account acct1 = new Account(
            Name = 'TestAcc',
            Website='http://www.iqvia.com',
            RDCategorization__c = 'Site',
            CustomerSegment__c = 'GOVERNMENT',
            Sub_Industry__c = 'STATE');
        insert acct1;
        
        Contact Con1 = new Contact( 
            Firstname='Brian', 
            Lastname='Dent', 
            Phone='(619)852-4569', 
            Department='Mission Control', 
            Title='Mission Specialist - Neptune', 
            Email='briandent@trailhead.com',
            AccountId = acct1.Id);
        insert Con1;
        
        Entitlement ent = new Entitlement(Name='Testing', AccountId=acct1.Id,Type = 'TECHNO',
                                          BusinessHoursId = [select id from BusinessHours where Name = 'Default'].Id,
                                          StartDate=Date.valueof(System.now().addDays(-2)), 
                                          EndDate=Date.valueof(System.now().addYears(2)));
        insert ent;
        
        User userRescord = new User(id = UserInfo.getUserId());
        userRescord.Email ='aKANSHA.gupta@metacube.com';
        userRescord.employeeNumber= '080808081';
        update userRescord;
        User u = [Select id,Email,Name from User where Id = :UserInfo.getUserId() and ProfileId = :UserInfo.getProfileId()];
        system.debug('Urser'+u+'UseREam'+u.Email+u.Name);
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
                AccountId = acct1.Id,
                ContactId = con1.Id,
                Origin = 'Agent Initiated',
                Status = 'New',
                InitialQueue__c = 'group name',
                AssignCaseToCurrentUser__c = false,
                OwnerId = g1.Id,
                EntitlementId = ent.Id,
                RecordTypeId = RecordTypeIdCase,
                Subject ='Subject'
            );
            insert c;
            List<Case> caseRecord =[Select id,Subject,CurrentQueue__r.Name from Case where Subject ='Subject'];
            List<Queue_User_Relationship__c> queueUser = [select id,Owner.Name, OwnerId,owner.Type,Name from Queue_User_Relationship__c where Name =:caseRecord[0].CurrentQueue__r.Name];
            id owneridd ;
            String queueName = null;
            for(Queue_User_Relationship__c dd :queueUser){
                owneridd = dd.OwnerId;
                queueName = dd.Name;
            }
            Test.startTest();
            CustomNotificationRESTAPI.sendCustomNotificationAfter21Winter('NotificationBellForCaseComment', JSON.serialize(caseRecord),  JSON.serialize(new list<Id>{owneridd}),queueName,'Worknote');
            CustomNotificationRESTAPI.sendCustomNotificationAfter21Winter('NotificationBellForCaseComment', JSON.serialize(caseRecord),  JSON.serialize(new list<Id>{owneridd}),null,'By Assign');
            Test.stopTest();
        }
    }

}