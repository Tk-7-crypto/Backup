/*
* Author    :  Ritik Kumawat
* Purpose    : Test class for SRV_PSA_SyncCSMTimecard, BCH_PSA_SyncCSMTimecard, SRV_PSA_SyncCSMTimecardService
*/
@isTest
public with sharing class TST_SRV_PSA_SyncCSMTimecardService {
    
    @testSetup
    static void dataSetup() 
    {
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
            pse__Is_Resource__c=true,
            pse__Is_Resource_Active__c=true,
            AccountId = acct.Id);
        insert Con;
        
        Entitlement ent = new Entitlement(Name='Testing', AccountId=acct.Id,Type = 'TECHNO',
            BusinessHoursId = [select id from BusinessHours where Name = 'Default'].Id,
            StartDate=Date.valueof(System.now().addDays(-2)), 
            EndDate=Date.valueof(System.now().addYears(2)));
        insert ent;
        
        
        User u = [Select id from User where Id = :UserInfo.getUserId() and ProfileId = :UserInfo.getProfileId()];
        
        System.runas(u)
        {
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
            TimeSheet__c s1 = new TimeSheet__c(AssignmentId__c='a1N03000001JxXNEA0',ProjectId__c='a1p03000001705mAAA',MilestoneId__c='a1h03000002RgwaAAC',LITimecardId__c='a1h03000002RgwaAAC',StartTime__c=System.today(),PSA_Sync_Status__c='FAILED',Timeinhours__c=5,PSA_Sync_Count__c=5,Status__c='Stop',PSA_Sync_Date__c=system.now(),Type__c = 'System', Case__c = cs2.Id, Time_Type__c = 'Estimated effort');
            insert s1; 
        }
    }
    @isTest 
    static void testmanualSyncPSATimecard1() {
        CSM_case_Trigger_Handler__c am = new CSM_case_Trigger_Handler__c(CSM_Activity_Open_Validation__c = true,CSM_Sender_Email_Id__c ='replytocsm@iqvia.com',StopCSMTimesheetSync__c=true,EnableTimesheetPartialDataSync__c=true,SyncNumberOfAttempts__c=10);
        insert am;
        SRV_PSA_SyncCSMTimecard.manualSyncPSATimecard();
        am.StopCSMTimesheetSync__c=false;
        update am;
        SRV_PSA_SyncCSMTimecard.manualSyncPSATimecard();
        am.EnableTimesheetPartialDataSync__c=false;
        update am;
        SRV_PSA_SyncCSMTimecard.manualSyncPSATimecard();
    }
    @isTest 
    static void testmanualSyncPSATimecard2() {
        SRV_PSA_SyncCSMTimecard.manualSyncPSATimecard();
    }
    @isTest 
    static void testSaveTimecardApiRequest1() {
        List<TimeSheet__c> timesheetList = [SELECT id,AssignmentId__c, ProjectId__c, StartTime__c,Timeinhours__c , MilestoneId__c, PSA_Sync_Status__c, PSA_Sync_Count__c, CreatedById,Comment__c FROM TimeSheet__c WHERE Status__c = 'Stop' AND StartTime__c != null AND  AssignmentId__c != null AND ProjectId__c!= null AND Timeinhours__c > 0 AND PSA_Sync_Status__c!= 'Success' AND PSA_Sync_Status__c!= 'Sync in progress' AND (PSA_Sync_Count__c = null OR PSA_Sync_Count__c <10) AND createdBy.Id =: Userinfo.getUserId()];
        
        test.startTest();
        TST_PSASyncCSMTimecard_HttpMock mock = new TST_PSASyncCSMTimecard_HttpMock(JSON.serialize('Success'),200);
        Test.setMock(HttpCalloutMock.class, mock);
        SRV_PSA_SyncCSMTimecard.saveTimecardApiRequest(SRV_PSA_SyncCSMTimecard.getTimecardApiRequest(timesheetList),timesheetList);
        test.stoptest();
        
    }
    
    @isTest 
    static void testSaveTimecardApiRequest2() {
        List<TimeSheet__c> timesheetList = [SELECT id,AssignmentId__c, ProjectId__c, StartTime__c,Timeinhours__c , MilestoneId__c, PSA_Sync_Status__c, PSA_Sync_Count__c, CreatedById,Comment__c FROM TimeSheet__c WHERE Status__c = 'Stop' AND StartTime__c != null AND  AssignmentId__c != null AND ProjectId__c!= null AND Timeinhours__c > 0 AND PSA_Sync_Status__c!= 'Success' AND PSA_Sync_Status__c!= 'Sync in progress' AND (PSA_Sync_Count__c = null OR PSA_Sync_Count__c <10) AND createdBy.Id =: Userinfo.getUserId()];
        TST_PSASyncCSMTimecard_HttpMock mock = new TST_PSASyncCSMTimecard_HttpMock(JSON.serialize('Success'),400);
        Test.setMock(HttpCalloutMock.class, mock);
        test.startTest();
        SRV_PSA_SyncCSMTimecard.saveTimecardApiRequest(SRV_PSA_SyncCSMTimecard.getTimecardApiRequest(timesheetList),timesheetList);
        
        test.stoptest();
        
    }
    @isTest 
    static void testSaveTimecardApiRequest3() {
        List<TimeSheet__c> timesheetList = [SELECT id,AssignmentId__c, ProjectId__c, StartTime__c,Timeinhours__c , MilestoneId__c, PSA_Sync_Status__c, PSA_Sync_Count__c, CreatedById,Comment__c FROM TimeSheet__c WHERE Status__c = 'Stop' AND StartTime__c != null AND  AssignmentId__c != null AND ProjectId__c!= null AND Timeinhours__c > 0 AND PSA_Sync_Status__c!= 'Success' AND PSA_Sync_Status__c!= 'Sync in progress' AND (PSA_Sync_Count__c = null OR PSA_Sync_Count__c <10) AND createdBy.Id =: Userinfo.getUserId()];
        TST_PSASyncCSMTimecard_HttpMock mock = new TST_PSASyncCSMTimecard_HttpMock(JSON.serialize('Success'),302);
        Test.setMock(HttpCalloutMock.class, mock);
        test.startTest();
        SRV_PSA_SyncCSMTimecard.saveTimecardApiRequest(SRV_PSA_SyncCSMTimecard.getTimecardApiRequest(timesheetList),timesheetList);
        test.stoptest();
        
    }
    
    @isTest 
    static void testProcessTimecardAPIResponse() {
        List<TimeSheet__c> timesheetList = [SELECT id,AssignmentId__c, ProjectId__c, StartTime__c,Timeinhours__c , MilestoneId__c, PSA_Sync_Status__c, PSA_Sync_Count__c,LITimecardId__c,PSA_Sync_Date__c, CreatedById FROM TimeSheet__c WHERE Status__c = 'Stop' AND StartTime__c != null AND  AssignmentId__c != null AND ProjectId__c!= null AND Timeinhours__c > 0 AND PSA_Sync_Status__c!= 'Success' AND PSA_Sync_Status__c!= 'Sync in progress' AND (PSA_Sync_Count__c = null OR PSA_Sync_Count__c <10) AND createdBy.Id =: Userinfo.getUserId()];
        String response = '[{"SyncStatus":"Failed","SyncErrorMessage":["Given milestone is not valid"],"SourceTimecardId":"'+ timesheetList[0].id +'"'+',"LITimecardId":"a1N03000005KvFdEAK"}]';
        test.startTest();
        SRV_PSA_SyncCSMTimecard.processTimecardAPIResponse(response,timesheetList);
        test.stoptest();
        
    }
    @isTest 
    static void testGetPartialSyncTimecardsList() {
        List<TimeSheet__c> timesheetList = [SELECT id,AssignmentId__c, ProjectId__c, StartTime__c,Timeinhours__c , MilestoneId__c, PSA_Sync_Status__c, PSA_Sync_Count__c, CreatedById FROM TimeSheet__c WHERE Status__c = 'Stop' AND StartTime__c != null AND  AssignmentId__c != null AND ProjectId__c!= null AND Timeinhours__c > 0 AND PSA_Sync_Status__c!= 'Success' AND PSA_Sync_Status__c!= 'Sync in progress' AND (PSA_Sync_Count__c = null OR PSA_Sync_Count__c <10) AND createdBy.Id =: Userinfo.getUserId()];
        CSM_case_Trigger_Handler__c am = new CSM_case_Trigger_Handler__c(CSM_Activity_Open_Validation__c = true,CSM_Sender_Email_Id__c ='replytocsm@iqvia.com',StopCSMTimesheetSync__c=true,EnableTimesheetPartialDataSync__c=true,SyncNumberOfAttempts__c=10);
        am.SetupOwnerId=timesheetList[0].CreatedById;
        insert am;
        Id batchJobId = Database.executeBatch(new BCH_PSA_SyncCSMTimecard(), 200);
        SRV_PSA_SyncCSMTimecard.getPartialSyncTimecardsList(timesheetList);
    }
    @isTest 
    static void testsetInprocessStatus() {
        List<TimeSheet__c> timesheetList = [SELECT id,AssignmentId__c, ProjectId__c, StartTime__c,Timeinhours__c , MilestoneId__c, PSA_Sync_Status__c, PSA_Sync_Count__c, CreatedById FROM TimeSheet__c WHERE Status__c = 'Stop' AND StartTime__c != null AND  AssignmentId__c != null AND ProjectId__c!= null AND Timeinhours__c > 0 AND PSA_Sync_Status__c!= 'Success' AND PSA_Sync_Status__c!= 'Sync in progress' AND (PSA_Sync_Count__c = null OR PSA_Sync_Count__c <10) AND createdBy.Id =: Userinfo.getUserId()];
        SRV_PSA_SyncCSMTimecard.setInprocessStatus(timesheetList);
    }
    @isTest
    static void testUpdateTimecardSyncProcessStatus1(){
        
        String myJSON = JSON.serialize(null);
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        request.requestUri =URL.getOrgDomainUrl().toExternalForm()+'/services/apexrest/synCSMTimecardUpdate';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON);
        
        RestContext.request = request;
        RestContext.response = res;
        
        SRV_PSA_SyncCSMTimecardService.updateTimecardSyncProcessStatus();
    }
    @isTest
    static void testUpdateTimecardSyncProcessStatus2(){
        List<TimeSheet__c> timesheetList = [SELECT id,AssignmentId__c, ProjectId__c, StartTime__c,Timeinhours__c , MilestoneId__c, PSA_Sync_Status__c, PSA_Sync_Count__c, CreatedById FROM TimeSheet__c WHERE Status__c = 'Stop' AND StartTime__c != null AND  AssignmentId__c != null AND ProjectId__c!= null AND Timeinhours__c > 0 AND PSA_Sync_Status__c!= 'Success' AND PSA_Sync_Status__c!= 'Sync in progress' AND (PSA_Sync_Count__c = null OR PSA_Sync_Count__c <10) AND createdBy.Id =: Userinfo.getUserId()];
        String myJSON = JSON.serialize(timesheetList);
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        request.requestUri =URL.getOrgDomainUrl().toExternalForm()+'/services/apexrest/synCSMTimecardUpdate';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueof(myJSON);
        
        RestContext.request = request;
        RestContext.response = res;
        
        SRV_PSA_SyncCSMTimecardService.updateTimecardSyncProcessStatus();
    }
}
