@isTest
private class TST_WSC_CSM_BS_ContactPhone {
    
    @testSetup
    static void setup() {
        Account acct = new Account(Name = 'TestAcc', RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert acct;
        
        Contact Con = new Contact( Firstname='Brian', Lastname='Dent', Phone='1234567890', 
            Department='Mission Control', Title='Mission Specialist - Neptune', Email='udo.rischa@boehringer-ingelheim.com',
            AccountId = acct.Id);
        insert Con;
        Id bhId = [select id from BusinessHours where Name = 'Default'].Id;
        Entitlement ent = new Entitlement(Name='Testing', AccountId=acct.Id,Type = 'TECHNO', BusinessHoursId = bhId,
        StartDate=Date.valueof(System.now().addDays(-2)), EndDate=Date.valueof(System.now().addYears(2)));
        insert ent;
        
        User u = [Select id from User where Id = :UserInfo.getUserId() and ProfileId = :UserInfo.getProfileId()];
        
        system.runAs(u) {
            
            Group g1 = new Group(Name='Q1', type='Queue', DoesSendEmailToMembers = true, Email ='testQueue@iqvia.com');
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
            
            Group g2 = new Group(Name='Q2', type='Queue',DoesSendEmailToMembers = true, Email ='testQueue2@iqvia.com');
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
            cs.RecordTypeId = rt;
            cs.OwnerId = g1.Id;
            cs.Resolution__c = 'Test';
            insert cs;
            List<Task> tList = new List<Task>();
            Task tsk1 = new Task(WhatId = cs.Id, Subject = 'test1', Description ='Test Case for Task',Status = 'Completed',Priority ='High',WhoId = con.Id,CSM_QI_CTI_Phone__c ='3425.ANI:1234567890',CallType ='Inbound');
            tList.add(tsk1);
            Task tsk2 = new Task(WhatId = cs.Id, Subject = 'test2', Description ='Test Case for Task',Status = 'Completed',Priority ='High',CSM_QI_CTI_Phone__c ='High.ANI:1234567890',CallType ='Inbound');
            tList.add(tsk2);
            Task tsk3 = new Task(Subject = 'test3', Description ='Test Case for Task',Status = 'Completed',Priority ='High',WhoId = con.Id,CSM_QI_CTI_Phone__c ='Low.ANI:1234567890',CallType ='Inbound');
            tList.add(tsk3);
            Task tsk4 = new Task( Subject = 'test4', Description ='Test Case for Task',Status = 'Completed',Priority ='High',CSM_QI_CTI_Phone__c ='123.ANI:1234567890',CallType ='Inbound');
            tList.add(tsk4);
            insert tList;
              
            
            
        }
    }

    public static testMethod void getPhoneUser() {
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/v1/getCaseDetailsbyPhone'; 
        req.params.put('phone', '1234567890');
        req.params.put('date', '2019-09-17T07:23:11.977Z');
        req.httpMethod = 'GET';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res;
        List<Case> usr1 = WSC_CSM_BS_ContactPhone.getCasebyContactPhone();
        System.debug(usr1);
   Test.stopTest();
    }
    
    public static testMethod void getPhoneUserTest() {
        
        Test.startTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/v1/getCaseDetailsbyPhone/post'; 
        req.httpMethod = 'POST';
        req.addHeader('Content-Type', 'application/json'); 
        RestContext.request = req;
        RestContext.response = res;
        List<WSC_CSM_BS_ContactPhone.responseWrapper> usr1 = WSC_CSM_BS_ContactPhone.getCasebyPhone('1234567890');
        System.debug(usr1);
   Test.stopTest();
    }
}