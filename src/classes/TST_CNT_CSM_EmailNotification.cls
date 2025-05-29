@istest
public class TST_CNT_CSM_EmailNotification {
    
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
        userRescord.Case_Comment_Work_Note__c ='Comment - Email';
        userRescord.EmployeeNumber = '070707071';
        update userRescord;
        User u = [Select id,Email,Name from User where Id = :UserInfo.getUserId() and ProfileId = :UserInfo.getProfileId()];
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
                Group_Id__c = grpUser.groupId,User__c = u.id);
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
            List<Case> caseRecord =[SELECT id,OrgURL__c ,CreatedDate,LastModifiedDate, CurrentQueue__r.Name, Account_Name_Article__c,CaseNumber,Status,Subject,AccountCountry__c,Description, ProductName__c ,Priority,Origin,LastCaseComment__c,RecordTypeName__c from Case where Subject ='Subject'];
            CaseComment caseCom = new CaseComment(CommentBody ='Body1',ParentId =caseRecord[0].id);
            insert caseCom;
            Test.startTest();
            //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
            CNT_CSM_EmailNotification.sendEmailNotification(caseRecord,new List<Id>{u.Id},'Body1CaseComment');
            CNT_CSM_EmailNotification.sendEmailNotificationForLQ();
            Test.stopTest();
        }
    }

}