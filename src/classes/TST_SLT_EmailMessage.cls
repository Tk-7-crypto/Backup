@isTest
private class TST_SLT_EmailMessage {
    static testmethod void testPreventEmailMessageDel(){
        Account acct = new Account(
            Name = 'TestAcc',
            RDCategorization__c = 'Site',
            CustomerSegment__c = 'GOVERNMENT',
            Sub_Industry__c = 'STATE' );
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
                User__c = grpUser.UserOrGroupId,
                Type__c = 'User',
                Group_Id__c = grpUser.groupId);
            
            insert qur;
            
            List<Queue_User_Relationship__c> queueList = new List<Queue_User_Relationship__c>();
            Queue_User_Relationship__c queues = new Queue_User_Relationship__c();
            queues.Name = 'Techno Services';
            queues.QueueName__c = 'Techno Services';
            queues.Type__c = 'Queue';
            queueList.add(queues);
            
            Queue_User_Relationship__c queueUser = new Queue_User_Relationship__c();
            queueUser.Name = 'Techno Services';
            queueUser.QueueName__c = 'Techno Services';
            queueUser.Type__c = 'User';
            queueUser.User__c = UserInfo.getUserId();
            queueList.add(queueUser); 
            insert queueList;
            
            Id RecordTypeIdCaseRD = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Activity Plan Case').getRecordTypeId();
            Case c1 = new Case(
                AccountId = acct.Id,
                ContactId = con.Id,
                Origin = 'Email',
                Status = 'New',
                InitialQueue__c = 'group name',
                CurrentQueue__c = queueUser.Id, 
                OwnerId = UserInfo.getUserId(),
                EntitlementId = ent.Id,
                RecordTypeId = RecordTypeIdCaseRD
            );
            Test.startTest();
            insert c1;
            List<EmailMessage> newEmail = new List<EmailMessage>();
            newEmail.add(new EmailMessage(FromAddress = 'test@abc.org', Incoming = false, ToAddress= 'm.reddy@in.imshealth.com', Subject = 'Test email', TextBody = '23456 ', ParentId = c1.Id)); 
            insert newEmail;
            
            try{
                delete newEmail;
            }catch(DMLexception e){
                system.assert(e.getMessage().contains('Cannot delete Email with related to Case'),'Cannot delete Email with related to Case');                       
            }
            Test.stopTest();
        }
    }
    
    @isTest
    static void testGetEmailRecordsById(){
        Account accountRecord = new Account(Name = 'TestAcc',RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert accountRecord;
        
        Contact contactRecord = new Contact( 
            Firstname='Brian', 
            Lastname='Dent', 
            Phone='(619)852-4569', 
            Department='Mission Control', 
            Title='Mission Specialist - Neptune', 
            Email='briandent@trailhead.com',
            AccountId = accountRecord.Id);
        insert contactRecord;
        
        Entitlement ent = new Entitlement(Name='Testing', AccountId=accountRecord.Id,Type = 'TECHNO',
                                          BusinessHoursId = [select id from BusinessHours where Name = 'Default'].Id,
                                          StartDate=Date.valueof(System.now().addDays(-2)), 
                                          EndDate=Date.valueof(System.now().addYears(2)));
        insert ent;
        
        List<Queue_User_Relationship__c> queueList = new List<Queue_User_Relationship__c>();
        Queue_User_Relationship__c queues = new Queue_User_Relationship__c();
        queues.Name = 'Data GLOBAL E-SERVICE';
        queues.QueueName__c = 'Data GLOBAL E-SERVICE';
        queues.Type__c = 'Queue'; 
        queues.User__c = UserInfo.getUserId();
        queueList.add(queues);
        
        Queue_User_Relationship__c queueUser = new Queue_User_Relationship__c();
        queueUser.Name = 'Data GLOBAL E-SERVICE';
        queueUser.QueueName__c = 'Data GLOBAL E-SERVICE';
        queueUser.Type__c = 'User';
        queueUser.User__c = UserInfo.getUserId();
        queueList.add(queueUser); 
        insert queueList;
        
        Id RecordTypeIdCaseRD = Schema.SObjectType.case.getRecordTypeInfosByName().get('R&D - Activity Plan Case').getRecordTypeId();
        
        Case caseRecord = new Case(
            Subject = 'R&D - Activity Plan Case 01',
            Description = 'R&D AP Case Description',
            AccountId = accountRecord.Id,
            ContactId = contactRecord.Id,
            Origin = 'Email',
            Status = 'New',
            InitialQueue__c = 'group name',
            RandD_Location__c = 'Dalian',
            OwnerId = UserInfo.getUserId(),
            EntitlementId = ent.Id,
            RecordTypeId = RecordTypeIdCaseRD,
            CurrentQueue__c = queueUser.Id
        );
        insert caseRecord;
        
        EmailMessage message = new EmailMessage(FromAddress = 'dummyuser@mail.com', ToAddress = 'caseContact@mail.com', Subject = 'Test subject',
                                                TextBody = 'Test dummy body', ParentId = caseRecord.Id, Incoming = True);
        insert message;
        
        Attachment attachment1 = new Attachment();
        attachment1.OwnerId = UserInfo.getUserId();
        attachment1.Name= 'Logo.png';
        attachment1.ContentType = 'image/png';
        attachment1.body= Blob.valueOf('Test Body');
        attachment1.ParentId = message.Id;
        insert attachment1;
        
        Test.startTest();
        new SLT_EmailMessage().getEmailRecordsById(new Set<Id>{message.Id});
        new SLT_EmailMessage().selectById(new Set<Id>{message.Id}, new Set<String>{'FromAddress', 'ToAddress', 'Incoming'});
        new SLT_EmailMessage().getCaseAttachmentListOnEmails(new Set<Id>{message.Id});
        new SLT_EmailMessage().getCountOnParentIds(new Set<Id>{caseRecord.Id});
        new SLT_EmailMessage().getEmailsByParendIds(new Set<Id>{caseRecord.Id});
        Test.stopTest();
    }
}