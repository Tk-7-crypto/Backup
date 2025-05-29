@isTest
private class TST_WSC_CSM_ROCHERestCallout {
    @testSetup
    static void setup() {
        Account acct = new Account(Name = 'TestAcc', RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert acct;
        CSM_ExternalClient_info__c cc = new CSM_ExternalClient_info__c();
        cc.Name = 'ROCHESNOW';
        cc.Client_Url__c = 'https://dev-de-c1.apis.roche.com/fg-snow-incident-cloud-exp-dev/incident/updateIncident';
        cc.Password__c = 'ROCHESNOW';
        cc.client_id__c = 'ROCHESNOW';
        cc.client_secret__c = 'ROCHESNOW';
        insert cc;
        Contact Con = new Contact( Firstname='rochetest', Lastname='rochetest', Phone='(619)852-4569', 
            Department='Mission Control', Title='Mission Specialist - Neptune', Email='csm.rochetest@roche.com',
            AccountId = acct.Id);
        insert Con;
        Id bhId = [select id from BusinessHours where Name = 'Default'].Id;
        Entitlement ent = new Entitlement(Name='Testing', AccountId=acct.Id,Type = 'TECHNO', BusinessHoursId = bhId,
        StartDate=Date.valueof(System.now().addDays(-2)), EndDate=Date.valueof(System.now().addYears(2)));
        insert ent;
        User u = [Select id from User where Id = :UserInfo.getUserId() and ProfileId = :UserInfo.getProfileId()];
        List<ServiceNow_Group__c> snwList = new List<ServiceNow_Group__c>();
        ServiceNow_Group__c snw1 = new ServiceNow_Group__c(Name='BI-ITEFP-IQVIA-ENGAGE-SUPPORT',SystemType__c = 'IQVIA', Queue__c = 'Q1',Order__c = 1);
        snwList.add(snw1);
        ServiceNow_Group__c snw2 = new ServiceNow_Group__c(Name='BI-EC-ENGAGE-NON-US',SystemType__c = 'BISM', Queue__c = 'Q1',Order__c = 1);
        snwList.add(snw2);
        insert snwList;
        system.runAs(u) {
            
            Group g1 = new Group(Name='Q1', type='Queue',DoesSendEmailToMembers = true, Email ='testQueue@iqvia.com');
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
            cs.Priority = 'Priority 1';
            cs.Urgency__c = 'High';
            cs.Techno_Impact__c  = 'Significant';
            cs.External_System_Type__c = 'ROCHESNOW';
            cs.Origin = 'Phone';
            cs.Mail_CC_List__c = 'nodata@info.com';
            cs.Subject = 'Techno case';
            cs.Description = 'Test class to check case creation';
            cs.Status = 'New';
            cs.RecordTypeId = rt;
            cs.OwnerId = g1.Id;
            cs.Resolution__c = 'Test';
            insert cs;
            
            Contentversion cv = new Contentversion();
            cv.Title = 'ABC22';
            cv.PathOnClient = 'test';
            cv.VersionData = EncodingUtil.base64Decode(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));
            cv.FirstPublishLocationId = cs.Id;
            insert cv;
            
            CaseComment cce= new CaseComment(ParentId = cs.Id,CommentBody = 'Test Comment Case CommentBoby1',IsPublished = true);
            insert cce;
        }
    }
    
    @isTest
    private static void testUpdateInsident(){
        List<Case> cList = Database.query('Select Id, CreatedDate, Origin,CaseNumber,ContactId,AccountId,Description,Priority,Urgency__c,Techno_Impact__c,Status,Service_Now_Incident_Number__c,Resolution__c,ResolvedDatetime__c,External_System_Type__c From Case Limit 1');
        if(cList != null && !cList.isEmpty()){
            Test.setMock(HttpCalloutMock.class, new TST_WSC_CSM_ROCHERestCallout_Mock());
            WSC_CSM_ROCHERestCallout.updateIncident(JSON.serialize(cList[0]), 'ROCHESNOW','ROCHESNOW');
        }
    }
    
    @isTest
    private static void testResolveIncident(){
        List<Case> cList = Database.query('Select Id, CreatedDate, Origin,CaseNumber,ContactId,AccountId,Description,Priority,Urgency__c,Techno_Impact__c,Status,Service_Now_Incident_Number__c,Resolution__c,ResolvedDatetime__c,External_System_Type__c From Case Limit 1');
        if(cList != null && !cList.isEmpty()){
            Test.setMock(HttpCalloutMock.class, new TST_WSC_CSM_ROCHERestCallout_Mock());
            WSC_CSM_ROCHERestCallout.resolveIncident(JSON.serialize(cList[0]));
        }
    }
    
    @isTest
    private static void testAddIncidentComment(){
        List<Case> cList = Database.query('Select Id, CreatedDate, Origin,CaseNumber,ContactId,AccountId,Description,Priority,Urgency__c,Techno_Impact__c,Status,Service_Now_Incident_Number__c,Resolution__c,ResolvedDatetime__c,External_System_Type__c From Case Limit 1');
        if(cList != null && !cList.isEmpty()){
            Map<String,Case> cMap = new Map<String,Case>();
            for(Case c : cList){
                cMap.put(c.Id, c);
            }
            List<CaseComment> ccList = Database.query('SELECT Id,CommentBody,ParentId FROM CaseComment LIMIT 1');
            Map<String,CaseComment> ccMap = new Map<String,CaseComment>();
            for(CaseComment cc : ccList){
                ccMap.put(cc.ParentId, cc);
            }
            Test.setMock(HttpCalloutMock.class, new TST_WSC_CSM_ROCHERestCallout_Mock());
            WSC_CSM_ROCHERestCallout.addIncidentComment(JSON.serialize(cMap),JSON.serialize(ccMap),'CaseComment');
        }
    }
    
    @isTest static void AttachmentCallOut() {
        Case cs =[Select Id, CreatedDate, Origin,CaseNumber,ContactId,AccountId,Description,Priority,Urgency__c,Techno_Impact__c,Status,Service_Now_Incident_Number__c,Resolution__c,ResolvedDatetime__c,External_System_Type__c From Case Limit 1];
        
        try { 
            Test.setMock(HttpCalloutMock.class, new TST_WSC_CSM_ROCHERestCallout_Mock());
            String caseId = cs.Id;
            List<ContentVersion> cvList = Database.query('select Id, FirstPublishLocationId, ContentDocumentId From ContentVersion where FirstPublishLocationId = : caseId');
            Map<String,Case> csList = new Map<String,Case>();
            csList.put(cvList[0].ContentDocumentId, cs);
            WSC_CSM_ROCHERestCallout.addIncidentAttachment(JSON.serialize(csList));
        } catch ( CalloutException ce) { 
            System.debug('Exce : '+ce.getCause());
        } catch ( Exception e) { 
            // Standard Exception Handling 
        }
        
    }
}