@isTest
private class TST_WSC_CSM_BISMIncidentMgmt{
    @testSetup
    static void setup() {
        Account acct = new Account(Name = 'TestAcc', RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert acct;
        CSM_ExternalClient_info__c cc = new CSM_ExternalClient_info__c();
        cc.Name = 'BISM';
        cc.Client_Url__c = 'https://api-dev.boehringer-ingelheim.com:8443/incident-management-api/v1/ticket';
        cc.Password__c = 'BISM';
        insert cc;
        Contact Con = new Contact( Firstname='Brian', Lastname='Dent', Phone='(619)852-4569', 
            Department='Mission Control', Title='Mission Specialist - Neptune', Email='udo.rischa@boehringer-ingelheim.com',
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
            cs.External_System_Type__c = 'BISM';
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
        }
    }
    
    @isTest static void createTicket() {
        WSC_CSM_BISMIncidentMgmt.messageHeaderType header = new WSC_CSM_BISMIncidentMgmt.messageHeaderType();
        WSC_CSM_BISMIncidentMgmt.ticketInformationType createTicket = new WSC_CSM_BISMIncidentMgmt.ticketInformationType();
        WSC_CSM_BISMIncidentMgmt.systemAddressType sender = new WSC_CSM_BISMIncidentMgmt.systemAddressType();
        WSC_CSM_BISMIncidentMgmt.systemAddressType receiver = new WSC_CSM_BISMIncidentMgmt.systemAddressType();
        WSC_CSM_BISMIncidentMgmt.configItem configItem = new WSC_CSM_BISMIncidentMgmt.configItem();
        WSC_CSM_BISMIncidentMgmt.person customer = new WSC_CSM_BISMIncidentMgmt.person();
        WSC_CSM_BISMIncidentMgmt.person contact = new WSC_CSM_BISMIncidentMgmt.person();
        WSC_CSM_BISMIncidentMgmt.historyEntries_element historyEntries = null;
        WSC_CSM_BISMIncidentMgmt.historyEntry_element historyEntry = null;
        Case cs =[Select Id,CaseNumber,description,Techno_Impact__c,Urgency__c,Priority,Status,Service_Now_Incident_Number__c,Service_Now_Type__c,Resolution__c From Case Limit 1];
        header.transactionId = cs.Id;
        header.initiator = 'POLARIS';
        header.currentOwner = 'POLARIS';
        //callerid
        sender.id = cs.CaseNumber;
        sender.name = 'POLARIS';
        header.sender = sender;
        receiver.id = '1234';
        receiver.name = 'BISNOW';
        header.receiver = receiver;
        contact.reference ='udo.rischa@boehringer-ingelheim.com';
        contact.globalId ='gi00017169';
        contact.userId ='x2acdepolaris';
        contact.eMail ='udo.rischa@boehringer-ingelheim.com';
        contact.firstName ='Udo';
        contact.surname ='Rischa';
        contact.telephoneNumber ='+49 (7351) 54-2949';
        contact.mobileNumber ='+49 (151) 15022949';
        contact.facsimileNumber ='+49 (7351) 54-2653';
        contact.location ='Biberach';
        contact.country = 'Germany';
        createTicket.contact = contact;
        configItem.reference  = 'BOEHRINGER_EPB_ACCEPTANCE (APPL259517)';
        configItem.title = 'BI-PAAS-SAP-EPB';
        configItem.description = 'Cloud System for all SAP Hosting';
        configItem.type_x = 'Cloud Service';
        configItem.status = 'In Production';
        configItem.physicalLocation = '';
        configItem.location = 'Unspecified';
        configItem.country = '';
        configItem.serialNumber = '';
        createTicket.configItem = configItem;
        createTicket.description = cs.description;
        createTicket.location = '';
        createTicket.serviceClassification = '';
        createTicket.ticketType = '';
        createTicket.impact = CON_CSM.PL_TECHNO_IMPACT.get(cs.Techno_Impact__c); //<!-- 3:low | 2:medium | 1:high -->
        createTicket.urgency = CON_CSM.PL_TECHNO_URGENCY.get(cs.Urgency__c); // <!-- 3:low | 2:medium | 1:high -->
        createTicket.priority = cs.Priority.remove('Priority ');
        createTicket.ticketCreationDate = System.now();
        createTicket.slaTargetDate = System.now();
        createTicket.issueDate = System.now();
        createTicket.currentGroup = 'ITB-IAS';
        //createTicket.assignGroup = 'DS.ISD.HU.7X24.BUD';
        createTicket.assignGroup = 'BI-ITINF-KM-MPS-SOFTWARE-ISSUE';
        createTicket.category = 'Business Administration';
        createTicket.subcategory = 'Manage Ratings definition';
        createTicket.majorIncident = false;
        createTicket.medium= 'Phone';
        createTicket.ticketStatus = cs.Status;
        historyEntry = new WSC_CSM_BISMIncidentMgmt.historyEntry_element();
        historyEntry.orderNumber  = 1;
        historyEntry.activityInformation = 'Test Case Comment';
        historyEntry.date_x = System.now();
        historyEntry.creator = Userinfo.getName();  
        try { 
            Test.startTest();
            Test.setMock(WebServiceMock.class, new TST_WSC_CSM_BISMIncidentMgmt_WSMock());
            System.debug('header.sender.id : '+header.sender.id);
            WSC_CSM_BISMIncidentMgmt.message_element res = TST_WSC_CSM_BISMSOAPCallout.CreateTicket(header, createTicket);
            WSC_CSM_BISMSOAPCallout.insertIntegrationLog(cs.CaseNumber, cs.Id,header.sender.Id,'Success','ok',header.transactionId,'createTicket',true,false,false);
            Test.stopTest();
            //System.debug('res.header.sender.id : '+res.header.sender.id);
            
            
        } catch ( CalloutException ce) { 
            System.debug('Exce : '+ce.getCause());
            System.debug('Stack'+ ce.getStackTraceString());
            
        } catch ( Exception e) { 
            // Standard Exception Handling 
        }
        
        }
    
    @isTest static void closeTicket() {
        WSC_CSM_BISMIncidentMgmt.messageHeaderType header = new WSC_CSM_BISMIncidentMgmt.messageHeaderType();
        WSC_CSM_BISMIncidentMgmt.systemAddressType sender = new WSC_CSM_BISMIncidentMgmt.systemAddressType();
        WSC_CSM_BISMIncidentMgmt.systemAddressType receiver = new WSC_CSM_BISMIncidentMgmt.systemAddressType();
        WSC_CSM_BISMIncidentMgmt.configItem configItem = new WSC_CSM_BISMIncidentMgmt.configItem();
        WSC_CSM_BISMIncidentMgmt.closeTicketType closeTicket = new WSC_CSM_BISMIncidentMgmt.closeTicketType();
        Case cs =[Select Id,CaseNumber,description,Techno_Impact__c,Urgency__c,Priority,Status,Service_Now_Incident_Number__c,Service_Now_Type__c,Resolution__c From Case Limit 1];
        header.transactionId = cs.Id;
        header.initiator = 'POLARIS';
        header.currentOwner = 'POLARIS';
        //callerid
        sender.id = cs.CaseNumber;
        sender.name = 'POLARIS';
        header.sender = sender;
        receiver.id = '1234';
        receiver.name = 'BISNOW';
        header.receiver = receiver;
        
        closeTicket.closeDate = System.now();
        closeTicket.closeGroup = 'BI-ITINF-KM-MPS-SOFTWARE-ISSUE';
        
        
        try { 
            Test.startTest();
            Test.setMock(WebServiceMock.class, new TST_WSC_CSM_BISMIncidentMgmt_WSMock());
            WSC_CSM_BISMIncidentMgmt.message_element closed = TST_WSC_CSM_BISMSOAPCallout.CloseTicket(header, closeTicket);
            WSC_CSM_BISMIncidentMgmt.responseType rst = closed.response; 
            Test.stopTest();
            
        } catch ( CalloutException ce) { 
            System.debug('Exce : '+ce.getCause());
            System.debug('Stack'+ ce.getStackTraceString());
            
        } catch ( Exception e) { 
            // Standard Exception Handling 
        }
        
        }
    @isTest static void ResolveTicket() {
        WSC_CSM_BISMIncidentMgmt.messageHeaderType header = new WSC_CSM_BISMIncidentMgmt.messageHeaderType();
        WSC_CSM_BISMIncidentMgmt.systemAddressType sender = new WSC_CSM_BISMIncidentMgmt.systemAddressType();
        WSC_CSM_BISMIncidentMgmt.systemAddressType receiver = new WSC_CSM_BISMIncidentMgmt.systemAddressType();
        WSC_CSM_BISMIncidentMgmt.resolveTicketType resolveTicket = new WSC_CSM_BISMIncidentMgmt.resolveTicketType();
        Case cs =[Select Id,CaseNumber,description,Techno_Impact__c,Urgency__c,Priority,Status,Service_Now_Incident_Number__c,Service_Now_Type__c,Resolution__c From Case Limit 1];
        header.transactionId = cs.Id;
        header.initiator = 'POLARIS';
        header.currentOwner = 'POLARIS';
        //callerid
        sender.id = cs.CaseNumber;
        sender.name = 'POLARIS';
        header.sender = sender;
        receiver.id = '1234';
        receiver.name = 'BISNOW';
        header.receiver = receiver;
        resolveTicket.reason = cs.Resolution__c;
        resolveTicket.solution = cs.Resolution__c;
        resolveTicket.solvedDirectly = false;
        resolveTicket.resolveDate = System.now();
        resolveTicket.resolveStatus = 'Closed/Resolved by Caller';
        
        try { 
            Test.startTest();
            Test.setMock(WebServiceMock.class, new TST_WSC_CSM_BISMIncidentMgmt_WSMock());
            WSC_CSM_BISMIncidentMgmt.message_element resolve = TST_WSC_CSM_BISMSOAPCallout.ResolveTicket(header, resolveTicket);
            WSC_CSM_BISMIncidentMgmt.responseType rst = resolve.response; 
            Test.stopTest();
            System.debug('Response : '+resolve.header.sender.Id);
                        
        } catch ( CalloutException ce) { 
            System.debug('Exce : '+ce.getCause());
            System.debug('Stack'+ ce.getStackTraceString());
            
        } catch ( Exception e) { 
            // Standard Exception Handling 
        }
        
        }
    @isTest static void updateTicket() {
        WSC_CSM_BISMIncidentMgmt.messageHeaderType header = new WSC_CSM_BISMIncidentMgmt.messageHeaderType();
        WSC_CSM_BISMIncidentMgmt.ticketInformationType createTicket = new WSC_CSM_BISMIncidentMgmt.ticketInformationType();
        WSC_CSM_BISMIncidentMgmt.systemAddressType sender = new WSC_CSM_BISMIncidentMgmt.systemAddressType();
        WSC_CSM_BISMIncidentMgmt.systemAddressType receiver = new WSC_CSM_BISMIncidentMgmt.systemAddressType();
        WSC_CSM_BISMIncidentMgmt.configItem configItem = new WSC_CSM_BISMIncidentMgmt.configItem();
        WSC_CSM_BISMIncidentMgmt.person customer = new WSC_CSM_BISMIncidentMgmt.person();
        WSC_CSM_BISMIncidentMgmt.person contact = new WSC_CSM_BISMIncidentMgmt.person();
        WSC_CSM_BISMIncidentMgmt.activityUpdateType activityUpdate = new WSC_CSM_BISMIncidentMgmt.activityUpdateType();
        WSC_CSM_BISMIncidentMgmt.historyEntries_element historyEntries = null;
        WSC_CSM_BISMIncidentMgmt.historyEntry_element historyEntry = null;
        WSC_CSM_BISMIncidentMgmt.closeTicketType closeTicket = new WSC_CSM_BISMIncidentMgmt.closeTicketType();
        WSC_CSM_BISMIncidentMgmt.resolveTicketType resolveTicket = new WSC_CSM_BISMIncidentMgmt.resolveTicketType();
        Case cs =[Select Id,CaseNumber,description,Techno_Impact__c,Urgency__c,Priority,Status,Service_Now_Incident_Number__c,Service_Now_Type__c,Resolution__c From Case Limit 1];
        header.transactionId = cs.Id;
        header.initiator = 'POLARIS';
        header.currentOwner = 'POLARIS';
        //callerid
        sender.id = cs.CaseNumber;
        sender.name = 'POLARIS';
        header.sender = sender;
        receiver.id = '1234';
        receiver.name = 'BISNOW';
        header.receiver = receiver;
        contact.reference ='udo.rischa@boehringer-ingelheim.com';
        contact.globalId ='gi00017169';
        contact.userId ='x2acdepolaris';
        contact.eMail ='udo.rischa@boehringer-ingelheim.com';
        contact.firstName ='Udo';
        contact.surname ='Rischa';
        contact.telephoneNumber ='+49 (7351) 54-2949';
        contact.mobileNumber ='+49 (151) 15022949';
        contact.facsimileNumber ='+49 (7351) 54-2653';
        contact.location ='Biberach';
        contact.country = 'Germany';
        createTicket.contact = contact;
        configItem.reference  = 'BOEHRINGER_EPB_ACCEPTANCE (APPL259517)';
        configItem.title = 'BI-PAAS-SAP-EPB';
        configItem.description = 'Cloud System for all SAP Hosting';
        configItem.type_x = 'Cloud Service';
        configItem.status = 'In Production';
        configItem.physicalLocation = '';
        configItem.location = 'Unspecified';
        configItem.country = '';
        configItem.serialNumber = '';
        createTicket.configItem = configItem;
        createTicket.description = cs.description;
        createTicket.location = '';
        createTicket.serviceClassification = '';
        createTicket.ticketType = '';
        createTicket.impact = CON_CSM.PL_TECHNO_IMPACT.get(cs.Techno_Impact__c); //<!-- 3:low | 2:medium | 1:high -->
        createTicket.urgency = CON_CSM.PL_TECHNO_URGENCY.get(cs.Urgency__c); // <!-- 3:low | 2:medium | 1:high -->
        createTicket.priority = cs.Priority.remove('Priority ');
        createTicket.ticketCreationDate = System.now();
        createTicket.slaTargetDate = System.now();
        createTicket.issueDate = System.now();
        createTicket.currentGroup = 'ITB-IAS';
        //createTicket.assignGroup = 'DS.ISD.HU.7X24.BUD';
        createTicket.assignGroup = 'BI-ITINF-KM-MPS-SOFTWARE-ISSUE';
        createTicket.category = 'Business Administration';
        createTicket.subcategory = 'Manage Ratings definition';
        createTicket.majorIncident = false;
        createTicket.medium= 'Phone';
        createTicket.ticketStatus = cs.Status;
        historyEntry = new WSC_CSM_BISMIncidentMgmt.historyEntry_element();
        historyEntry.orderNumber  = 1;
        historyEntry.activityInformation = 'Test Case Comment';
        historyEntry.date_x = System.now();
        historyEntry.creator = Userinfo.getName();  
        
        try {
            Test.startTest();
            Test.setMock(WebServiceMock.class, new TST_WSC_CSM_BISMIncidentMgmt_WSMock());
            WSC_CSM_BISMIncidentMgmt.message_element resUpd = TST_WSC_CSM_BISMSOAPCallout.UpdateTicket(header, createTicket);
            WSC_CSM_BISMIncidentMgmt.responseType rst = resUpd.response; 
            Test.stopTest();
            
        } catch ( CalloutException ce) { 
            System.debug('Exce : '+ce.getCause());
            System.debug('Stack'+ ce.getStackTraceString());
            
        } catch ( Exception e) { 
            // Standard Exception Handling 
        }
        
        }
    
    @isTest static void activityUpdate() {
        WSC_CSM_BISMIncidentMgmt.messageHeaderType header = new WSC_CSM_BISMIncidentMgmt.messageHeaderType();
        WSC_CSM_BISMIncidentMgmt.ticketInformationType createTicket = new WSC_CSM_BISMIncidentMgmt.ticketInformationType();
        WSC_CSM_BISMIncidentMgmt.systemAddressType sender = new WSC_CSM_BISMIncidentMgmt.systemAddressType();
        WSC_CSM_BISMIncidentMgmt.systemAddressType receiver = new WSC_CSM_BISMIncidentMgmt.systemAddressType();
        WSC_CSM_BISMIncidentMgmt.configItem configItem = new WSC_CSM_BISMIncidentMgmt.configItem();
        WSC_CSM_BISMIncidentMgmt.person customer = new WSC_CSM_BISMIncidentMgmt.person();
        WSC_CSM_BISMIncidentMgmt.person contact = new WSC_CSM_BISMIncidentMgmt.person();
        WSC_CSM_BISMIncidentMgmt.activityUpdateType activityUpdate = new WSC_CSM_BISMIncidentMgmt.activityUpdateType();
        WSC_CSM_BISMIncidentMgmt.historyEntries_element historyEntries = null;
        WSC_CSM_BISMIncidentMgmt.historyEntry_element historyEntry = null;
        WSC_CSM_BISMIncidentMgmt.closeTicketType closeTicket = new WSC_CSM_BISMIncidentMgmt.closeTicketType();
        WSC_CSM_BISMIncidentMgmt.resolveTicketType resolveTicket = new WSC_CSM_BISMIncidentMgmt.resolveTicketType();
        Case cs =[Select Id,CaseNumber,description,Techno_Impact__c,Urgency__c,Priority,Status,Service_Now_Incident_Number__c,Service_Now_Type__c,Resolution__c,External_System_Type__c From Case Limit 1];
        header.transactionId = cs.Id;
        header.initiator = 'POLARIS';
        header.currentOwner = 'POLARIS';
        //callerid
        sender.id = cs.CaseNumber;
        sender.name = 'POLARIS';
        header.sender = sender;
        receiver.id = '1234';
        receiver.name = 'BISNOW';
        header.receiver = receiver;
        historyEntry = new WSC_CSM_BISMIncidentMgmt.historyEntry_element();
        historyEntry.orderNumber  = 1;
        historyEntry.activityInformation = 'Test Case Comment';
        historyEntry.date_x = System.now();
        historyEntry.creator = Userinfo.getName();  
        activityUpdate.historyEntry = historyEntry;
        try { 
            Test.startTest();
            Test.setMock(WebServiceMock.class, new TST_WSC_CSM_BISMIncidentMgmt_WSMock());
            WSC_CSM_BISMIncidentMgmt.message_element resactUpd = TST_WSC_CSM_BISMSOAPCallout.activityUpdate(header, activityUpdate);
            WSC_CSM_BISMIncidentMgmt.responseType rst = resactUpd.response; 
            Test.stopTest();
            
        } catch ( CalloutException ce) { 
            System.debug('Exce : '+ce.getCause());
            System.debug('Stack'+ ce.getStackTraceString());
            
        } catch ( Exception e) { 
            // Standard Exception Handling 
        }
        
        }
    
    
    @isTest static void activityUpdateTicketCallOut() {
        Case cs =[Select Id, CreatedDate, Origin,CaseNumber,ContactId,AccountId,Description,Priority,Urgency__c,Techno_Impact__c,Status,Service_Now_Incident_Number__c,Resolution__c,ResolvedDatetime__c,External_System_Type__c From Case Limit 1];
        Map<Id,Case> jscaseIds = new Map<Id,Case>();
        Map<Id,CaseComment> jscomments = new Map<Id,CaseComment>();
        Map<String,String> jsstr = new Map<String,String>();
        jscaseIds.put(cs.Id,cs);
        CaseComment cc = new CaseComment(ParentId = cs.Id,CommentBody = 'Test Comment Case CommentBoby',IsPublished = true);
        insert cc;
        jscomments.put(cs.Id,cc);
        jsstr.put(cs.Id,'Str');
        try { 
            WSC_CSM_BISMSOAPCallout.ActivityUpdateCSM2BISMComments(JSON.serialize(jscaseIds),JSON.serialize(jscomments));
            WSC_CSM_BISMSOAPCallout.ActivityUpdateCSM2BISMCommentsSendEmail(JSON.serialize(jscaseIds),JSON.serialize(jsstr));
        } catch ( CalloutException ce) { 
            System.debug('Exce : '+ce.getCause());
            System.debug('Stack'+ ce.getStackTraceString());
            
        } catch ( Exception e) { 
            // Standard Exception Handling 
        }
        
        }
    
    @isTest static void createTicketCallOut() {
        Case cs =[Select Id, CreatedDate, Origin,CaseNumber,ContactId,AccountId,Description,Priority,Urgency__c,Techno_Impact__c,Status,Service_Now_Incident_Number__c,Resolution__c,ResolvedDatetime__c,External_System_Type__c From Case Limit 1];
        
        try { 
            WSC_CSM_BISMSOAPCallout.CreateTicketCSM2BISM(JSON.serialize(cs));
        } catch ( CalloutException ce) { 
            System.debug('Exce : '+ce.getCause());
            System.debug('Stack'+ ce.getStackTraceString());
            
        } catch ( Exception e) { 
            // Standard Exception Handling 
        }
        
        }
    
    @isTest static void updateTicketCallOut() {
        Case cs =[Select Id, CreatedDate, Origin,CaseNumber,ContactId,AccountId,Description,Priority,Urgency__c,Techno_Impact__c,Status,Service_Now_Incident_Number__c,Resolution__c,ResolvedDatetime__c,External_System_Type__c From Case Limit 1];
        try { 
            WSC_CSM_BISMSOAPCallout.updateTicketCSM2BISM(JSON.serialize(cs),'BISM','IQVIA');
        } catch ( CalloutException ce) { 
            System.debug('Exce : '+ce.getCause());
        } catch ( Exception e) { 
            // Standard Exception Handling 
        }
        
        }
    
    @isTest static void AttachmentCallOut() {
        Case cs =[Select Id, CreatedDate, Origin,CaseNumber,ContactId,AccountId,Description,Priority,Urgency__c,Techno_Impact__c,Status,Service_Now_Incident_Number__c,Resolution__c,ResolvedDatetime__c,External_System_Type__c From Case Limit 1];
        
        try { 
            String caseId = cs.Id;
            List<ContentVersion> cvList = Database.query('select Id, FirstPublishLocationId, ContentDocumentId From ContentVersion where FirstPublishLocationId = : caseId');
            Map<String,Case> csList = new Map<String,Case>();
            csList.put(cvList[0].ContentDocumentId, cs);
            WSC_CSM_BISMSOAPCallout.UpdateTicketCSM2BISMAttachment(JSON.serialize(csList));
        } catch ( CalloutException ce) { 
            System.debug('Exce : '+ce.getCause());
        } catch ( Exception e) { 
            // Standard Exception Handling 
        }
        
        }
    
    @isTest static void resolveTicketCallOut() {
        Case cs =[Select Id, CreatedDate, Origin,CaseNumber,ContactId,AccountId,Description,Priority,Urgency__c,Techno_Impact__c,Status,Service_Now_Incident_Number__c,Resolution__c,ResolvedDatetime__c From Case Limit 1];
        try { 
            WSC_CSM_BISMSOAPCallout.resolveTicketCSM2BISM(JSON.serialize(cs),'IQVIA');
        } catch ( CalloutException ce) { 
            System.debug('Exce : '+ce.getCause());
            System.debug('Stack'+ ce.getStackTraceString());
            
        } catch ( Exception e) { 
            // Standard Exception Handling 
        }
        
        }
    @isTest static void closeTicketCallOut() {
        Case cs =[Select Id, CreatedDate, Origin,CaseNumber,ContactId,AccountId,Description,Priority,Urgency__c,Techno_Impact__c,Status,Service_Now_Incident_Number__c,Resolution__c,ResolvedDatetime__c From Case Limit 1];
        
        try { 
            WSC_CSM_BISMSOAPCallout.closeTicketCSM2BISM(JSON.serialize(cs),'IQVIA');
        } catch ( CalloutException ce) { 
            System.debug('Exce : '+ce.getCause());
        } catch ( Exception e) { 
            // Standard Exception Handling 
        }
        
        }
    
    @isTest static void confirmTicketCallOut() {
        Case cs =[Select Id, CreatedDate, Origin,CaseNumber,ContactId,AccountId,Description,Priority,Urgency__c,Techno_Impact__c,Status,Service_Now_Incident_Number__c,Resolution__c,ResolvedDatetime__c From Case Limit 1];
        
        WSC_CSM_BISMIncidentMgmt.message_element_confirm response_x = new WSC_CSM_BISMIncidentMgmt.message_element_confirm();
        WSC_CSM_BISMIncidentMgmt.messageHeaderType headerR = new WSC_CSM_BISMIncidentMgmt.messageHeaderType();
        WSC_CSM_BISMIncidentMgmt.systemAddressType sender = new WSC_CSM_BISMIncidentMgmt.systemAddressType();
        WSC_CSM_BISMIncidentMgmt.systemAddressType receiver = new WSC_CSM_BISMIncidentMgmt.systemAddressType();
        WSC_CSM_BISMIncidentMgmt.responseType response = new WSC_CSM_BISMIncidentMgmt.responseType();
        sender.id = cs.CaseNumber;
        sender.name = 'IQVIA';
        headerR.sender = sender;
        receiver.id = 'ISNOW011';
        receiver.name = 'BISNOW';
        headerR.receiver = receiver;
        headerR.transactionId = 'transactionId';
        response_x.header = headerR;
        response.type_x = 'confirmTicket';
        response.ownershipTransferred = false;
        response.status = 'ok'; // ok or nok
        response.message = cs.CaseNumber;
        response_x.response = response;
        
        
        try { 
            WSC_CSM_BISMSOAPCallout.confirmTicketCSM2BISM(JSON.serialize(response_x));
        } catch ( CalloutException ce) { 
            System.debug('Exce : '+ce.getCause());
        } catch ( Exception e) { 
            // Standard Exception Handling 
        }
        
        }
} 