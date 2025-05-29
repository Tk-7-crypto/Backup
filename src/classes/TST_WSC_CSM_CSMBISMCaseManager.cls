@isTest
private class TST_WSC_CSM_CSMBISMCaseManager {
    @testSetup
    static void setup() {
        WSC_CSM_CSMBISMCaseManager.messageHeaderType header = new WSC_CSM_CSMBISMCaseManager.messageHeaderType();
        WSC_CSM_CSMBISMCaseManager.ticketInformationType createTicket = new WSC_CSM_CSMBISMCaseManager.ticketInformationType();
        WSC_CSM_CSMBISMCaseManager.systemAddressType sender = new WSC_CSM_CSMBISMCaseManager.systemAddressType();
        WSC_CSM_CSMBISMCaseManager.systemAddressType receiver = new WSC_CSM_CSMBISMCaseManager.systemAddressType();
        WSC_CSM_CSMBISMCaseManager.configItem configItem = new WSC_CSM_CSMBISMCaseManager.configItem();
        WSC_CSM_CSMBISMCaseManager.person customer = new WSC_CSM_CSMBISMCaseManager.person();
        WSC_CSM_CSMBISMCaseManager.person contact = new WSC_CSM_CSMBISMCaseManager.person();
        WSC_CSM_CSMBISMCaseManager.activityUpdateType activityUpdate = new WSC_CSM_CSMBISMCaseManager.activityUpdateType();
        WSC_CSM_CSMBISMCaseManager.historyEntries_element historyEntries = null;
        WSC_CSM_CSMBISMCaseManager.historyEntry_element historyEntry = null;
        Account acct = new Account(Name = 'TestAcc', RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert acct;
        CSM_ExternalClient_info__c cc = new CSM_ExternalClient_info__c();
        cc.Name = 'BISM';
        cc.Client_Url__c = 'BISM';
        cc.Password__c = 'BISM';
        cc.Account_Id__c = acct.Id;
        insert cc;
        CSM_ExternalClient_info__c cr = new CSM_ExternalClient_info__c();
        cr.Name = 'ROCHESNOW';
        cr.Client_Url__c = 'ROCHESNOW';
        cr.Password__c = 'ROCHESNOW';
        cr.Account_Id__c = acct.Id;
        insert cr;
        Contact Con = new Contact( Firstname='Brian', Lastname='Dent', Phone='(619)852-4569', 
            Department='Mission Control', Title='Mission Specialist - Neptune', Email='udo.rischa@boehringer-ingelheim.com',
            AccountId = acct.Id);
        insert Con;
        Id bhId = [select id from BusinessHours where Name = 'Default'].Id;
        Entitlement ent = new Entitlement(Name='Testing', AccountId=acct.Id,Type = 'TECHNO', BusinessHoursId = bhId,
        StartDate=Date.valueof(System.now().addDays(-2)), EndDate=Date.valueof(System.now().addYears(2)));
        insert ent;
        
        User u = [Select id from User where Id = :UserInfo.getUserId() and ProfileId = :UserInfo.getProfileId()];
        
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
            List<CSM_QI_Data_Portal_Queue_User_details__c> dlist = new List<CSM_QI_Data_Portal_Queue_User_details__c>();
            CSM_QI_Data_Portal_Queue_User_details__c d1 = new CSM_QI_Data_Portal_Queue_User_details__c();
            d1.Queue_User_Relationship__c = qur.Id;
            d1.Account__c = acct.Id;
            d1.All_Current_Users__c = true;
            d1.AccountCountry__c = acct.AccountCountry__c;
            d1.CaseRecordType__c = 'TechnologyCase';
            d1.Type__c ='Queue Assignment';
            d1.Order__c = 1;
            dlist.add(d1);
            CSM_QI_Data_Portal_Queue_User_details__c d2 = new CSM_QI_Data_Portal_Queue_User_details__c();
            d2.Queue_User_Relationship__c = qur2.Id;
            d2.Account__c = acct.Id;
            d2.All_Current_Users__c = true;
            d2.AccountCountry__c = acct.AccountCountry__c;
            d2.CaseRecordType__c = 'DATACase';
            d2.Type__c ='Queue Assignment';
            d2.Order__c = 1;
            dlist.add(d2);
            insert dlist;
            CSM_QI_Data_Portal_Queue_User_details__c dT = new CSM_QI_Data_Portal_Queue_User_details__c();
            dT.Queue_User_Relationship__c = qur.Id;
            dT.Account__c = acct.Id;
            dT.All_Current_Users__c = true;
            dT.AccountCountry__c = acct.AccountCountry__c;
            dT.CaseRecordType__c = 'TechnologyCase';
            dT.Type__c ='Queue Assignment';
            dT.Order__c = 20;
            insert dT;
            CSM_QI_Data_Portal_Queue_User_details__c dpT = new CSM_QI_Data_Portal_Queue_User_details__c();
            dpT.Queue_User_Relationship__c = qur2.Id;
            dpT.Account__c = acct.Id;
            dpT.All_Current_Users__c = true;
            dpT.AccountCountry__c = acct.AccountCountry__c;
            dpT.CaseRecordType__c = 'TechnologyCase';
            dpT.Type__c ='Queue Assignment';
            dpT.Order__c = 20;
            insert dpT;
            Id rt = Schema.SObjectType.case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
            List<ServiceNow_Group__c> sngList = new List<ServiceNow_Group__c>();
            ServiceNow_Group__c sng = new ServiceNow_Group__c();
            sng.Account_Id__c = acct.Id;
            sng.Name ='BI-ITINF-KM-MPS-SOFTWARE-ISSUE';
            sng.Group_ID__c ='BI-ITINF-KM-MPS-SOFTWARE-ISSUE';
            sng.Queue__c = 'Q1';
            sng.SystemType__c ='IQVIA';
			sng.Order__c = 1;
            sngList.add(sng);
            ServiceNow_Group__c sng1 = new ServiceNow_Group__c();
            sng1.Account_Id__c = acct.Id;
            sng1.Name ='BI-ITINF-KM-MPS-SOFTWARE-ISSUE';
            sng1.Group_ID__c ='BI-ITINF-KM-MPS-SOFTWARE-ISSUE';
            sng1.Queue__c = 'Q1';
            sng1.SystemType__c ='BISM';
			sng1.Order__c = 1;
            sngList.add(sng1);
            
            ServiceNow_Group__c sng2 = new ServiceNow_Group__c();
            sng2.Account_Id__c = acct.Id;
            sng2.Name ='IQVIA Group';
            sng2.Group_ID__c ='IQVIA Group';
            sng2.Queue__c = 'Q1';
            sng2.SystemType__c ='IQVIA';
			sng2.Order__c = 1;
            sngList.add(sng2);
            ServiceNow_Group__c sng3 = new ServiceNow_Group__c();
            sng3.Account_Id__c = acct.Id;
            sng3.Name ='ROCHE Group';
            sng3.Group_ID__c ='ROCHE Group';
            sng3.Queue__c = 'Q1';
            sng3.SystemType__c ='ROCHESNOW';
			sng3.Order__c = 1;
            sngList.add(sng3);
            insert sngList;
            Product2 p1 = UTL_TestData.createProduct();
            p1.Name = 'STAR';
            p1.SpecificToCSM__c = True;
            insert p1;
            Asset a1 = new Asset(Name = 'STAR', AccountId = acct.Id, Product2Id = p1.id);
            insert a1;
            Case cs = new Case();
            cs.ContactId = Con.Id;
            cs.AccountId = acct.Id;
            cs.RecordTypeId = rt;
            cs.Priority = 'Priority 4';
            cs.Origin = 'Phone';
            cs.Mail_CC_List__c = 'nodata@info.com';
            cs.Subject = 'Techno case';
            cs.Description = 'Test class to check case creation';
            cs.Status = CON_CSM.S_IN_PROGRESS;
            cs.RecordTypeId = rt;
            cs.InitialQueue__c = 'Q1';
            cs.OwnerId = g1.Id;
            cs.Service_Now_Incident_Number__c = '1234';
            cs.ServiceNowSystemType__c = CON_CSM.S_BISM;
            cs.External_System_Type__c = CON_CSM.S_BISM;
            insert cs;
        }
    }
    
    @isTest static void createTicket() {
        
        WSC_CSM_CSMBISMCaseManager.messageHeaderType header = new WSC_CSM_CSMBISMCaseManager.messageHeaderType();
        WSC_CSM_CSMBISMCaseManager.ticketInformationType createTicket = new WSC_CSM_CSMBISMCaseManager.ticketInformationType();
        WSC_CSM_CSMBISMCaseManager.systemAddressType sender = new WSC_CSM_CSMBISMCaseManager.systemAddressType();
        WSC_CSM_CSMBISMCaseManager.systemAddressType receiver = new WSC_CSM_CSMBISMCaseManager.systemAddressType();
        WSC_CSM_CSMBISMCaseManager.configItem configItem = new WSC_CSM_CSMBISMCaseManager.configItem();
        WSC_CSM_CSMBISMCaseManager.person customer = new WSC_CSM_CSMBISMCaseManager.person();
        WSC_CSM_CSMBISMCaseManager.person contact = new WSC_CSM_CSMBISMCaseManager.person();
        WSC_CSM_CSMBISMCaseManager.activityUpdateType activityUpdate = new WSC_CSM_CSMBISMCaseManager.activityUpdateType();
        WSC_CSM_CSMBISMCaseManager.historyEntries_element historyEntries = null;
        WSC_CSM_CSMBISMCaseManager.historyEntry_element historyEntry = null;
        Test.setMock(WebServiceMock.class, new TST_WSC_CSM_BISMIncidentMgmt_WSMock());
        header.transactionId = '';
        header.initiator = 'POLARIS';
        header.currentOwner = 'POLARIS';
        //callerid
        sender.id = '1234';
        sender.name = 'BISNOW';
        header.sender = sender;
        receiver.id = '';
        receiver.name = 'IQVIA';
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
        createTicket.description = 'Test';
        createTicket.location = '';
        createTicket.serviceClassification = '';
        createTicket.ticketType = '';
        createTicket.impact = '1'; //<!-- 3:low | 2:medium | 1:high -->
        createTicket.urgency = '1'; // <!-- 3:low | 2:medium | 1:high -->
        createTicket.priority = '1';
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
        createTicket.ticketStatus = '2';
        historyEntries = new WSC_CSM_CSMBISMCaseManager.historyEntries_element();
        historyEntry = new WSC_CSM_CSMBISMCaseManager.historyEntry_element();
        historyEntry.orderNumber  = 1;
        historyEntry.activityInformation = 'Test Case Comment';
        historyEntry.date_x = System.now();
        historyEntry.creator = Userinfo.getName();  
        activityUpdate.historyEntry = historyEntry;
        historyEntries.historyEntry = new List<WSC_CSM_CSMBISMCaseManager.historyEntry_element>{historyEntry};
        createTicket.historyEntries = historyEntries;
        WSC_CSM_CSMBISMCaseManager.attachment_element att = new WSC_CSM_CSMBISMCaseManager.attachment_element();
        att.filename ='Test.txt'; 
        att.data = String.valueOf(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));
        WSC_CSM_CSMBISMCaseManager.attachments_element atts = new WSC_CSM_CSMBISMCaseManager.attachments_element();
        atts.attachment = new List<WSC_CSM_CSMBISMCaseManager.attachment_element>{att};
        activityUpdate.attachments = atts;
        createTicket.attachments = atts;
        try { 
            WSC_CSM_CSMBISMCaseManager.message_element res = WSC_CSM_CSMBISMCaseManager.CreateTicket(header, createTicket);
            sender.id = '1234';
            sender.name = 'ROCHESNOW';
            header.sender = sender;
            receiver.id = '';
            receiver.name = 'IQVIA';
            header.receiver = receiver;
            Test.startTest();
            WSC_CSM_CSMBISMCaseManager.message_element resRoche = WSC_CSM_CSMBISMCaseManager.CreateTicket(header, createTicket);
            Test.stopTest();
        } catch ( CalloutException ce) { 
            System.debug('Exce : '+ce.getCause());
            System.debug('Stack'+ ce.getStackTraceString());
            
        } catch ( Exception e) { 
            // Standard Exception Handling 
        }
        
    }

        @isTest static void updateTicketAwaiting() {
        Test.setMock(WebServiceMock.class, new TST_WSC_CSM_BISMIncidentMgmt_WSMock());
        Case c = [Select Id,Status from Case where Subject = 'Techno case' limit 1];
        c.Status = CON_CSM.S_AWAITING;    
            update c;
        WSC_CSM_CSMBISMCaseManager.messageHeaderType header = new WSC_CSM_CSMBISMCaseManager.messageHeaderType();
        WSC_CSM_CSMBISMCaseManager.ticketInformationType createTicket = new WSC_CSM_CSMBISMCaseManager.ticketInformationType();
        WSC_CSM_CSMBISMCaseManager.systemAddressType sender = new WSC_CSM_CSMBISMCaseManager.systemAddressType();
        WSC_CSM_CSMBISMCaseManager.systemAddressType receiver = new WSC_CSM_CSMBISMCaseManager.systemAddressType();
        WSC_CSM_CSMBISMCaseManager.configItem configItem = new WSC_CSM_CSMBISMCaseManager.configItem();
        WSC_CSM_CSMBISMCaseManager.person customer = new WSC_CSM_CSMBISMCaseManager.person();
        WSC_CSM_CSMBISMCaseManager.person contact = new WSC_CSM_CSMBISMCaseManager.person();
        WSC_CSM_CSMBISMCaseManager.activityUpdateType activityUpdate = new WSC_CSM_CSMBISMCaseManager.activityUpdateType();
        WSC_CSM_CSMBISMCaseManager.historyEntries_element historyEntries = null;
        WSC_CSM_CSMBISMCaseManager.historyEntry_element historyEntry = null;
         Case cs =[Select Id,CaseNumber,description,Techno_Impact__c,Urgency__c,Priority,Status,Service_Now_Incident_Number__c,Service_Now_Type__c,Resolution__c From Case Limit 1];
        header.transactionId = '';
        header.initiator = 'POLARIS';
        header.currentOwner = 'POLARIS';
        //callerid
        sender.id = '1234';
        sender.name = 'BISNOW';
        header.sender = sender;
        receiver.id = cs.CaseNumber;
        receiver.name = 'IQVIA';
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
        createTicket.description = 'Test';
        createTicket.location = '';
        createTicket.serviceClassification = '';
        createTicket.ticketType = '';
        createTicket.impact = '2'; //<!-- 3:low | 2:medium | 1:high -->
        createTicket.urgency = '2'; // <!-- 3:low | 2:medium | 1:high -->
        createTicket.priority = '2';
        createTicket.currentGroup = 'ITB-IAS';
        //createTicket.assignGroup = 'DS.ISD.HU.7X24.BUD';
        createTicket.assignGroup = 'BI-ITINF-KM-MPS-SOFTWARE-ISSUE';
        createTicket.category = 'Business Administration';
        createTicket.subcategory = 'Manage Ratings definition';
        createTicket.majorIncident = false;
        createTicket.medium= 'Phone';
        createTicket.ticketStatus = '2';
        historyEntries = new WSC_CSM_CSMBISMCaseManager.historyEntries_element();
        historyEntry = new WSC_CSM_CSMBISMCaseManager.historyEntry_element();
        historyEntry.orderNumber  = 1;
        historyEntry.activityInformation = 'Test Case Comment';
        historyEntry.date_x = System.now();
        historyEntry.creator = Userinfo.getName();  
        historyEntries.historyEntry = new List<WSC_CSM_CSMBISMCaseManager.historyEntry_element>{historyEntry};
        createTicket.historyEntries = historyEntries;  
        WSC_CSM_CSMBISMCaseManager.attachment_element att = new WSC_CSM_CSMBISMCaseManager.attachment_element();
        att.filename ='Test.txt'; 
        att.data = String.valueOf(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));
        WSC_CSM_CSMBISMCaseManager.attachments_element atts = new WSC_CSM_CSMBISMCaseManager.attachments_element();
        atts.attachment = new List<WSC_CSM_CSMBISMCaseManager.attachment_element>{att};
        createTicket.attachments = atts;
        try { 
            Test.startTest();
            WSC_CSM_CSMBISMCaseManager.message_element resUpd = WSC_CSM_CSMBISMCaseManager.UpdateTicket(header, createTicket);
            WSC_CSM_CSMBISMCaseManager.responseType rst = resUpd.response;
            Test.stopTest();
        } catch ( CalloutException ce) {
            System.debug('Exce : '+ce.getCause());
            System.debug('Stack'+ ce.getStackTraceString());
            
        } catch ( Exception e) { 
            // Standard Exception Handling 
        }
        
        }
    @isTest static void updateTicket() {
        
        WSC_CSM_CSMBISMCaseManager.messageHeaderType header = new WSC_CSM_CSMBISMCaseManager.messageHeaderType();
        WSC_CSM_CSMBISMCaseManager.ticketInformationType createTicket = new WSC_CSM_CSMBISMCaseManager.ticketInformationType();
        WSC_CSM_CSMBISMCaseManager.systemAddressType sender = new WSC_CSM_CSMBISMCaseManager.systemAddressType();
        WSC_CSM_CSMBISMCaseManager.systemAddressType receiver = new WSC_CSM_CSMBISMCaseManager.systemAddressType();
        WSC_CSM_CSMBISMCaseManager.configItem configItem = new WSC_CSM_CSMBISMCaseManager.configItem();
        WSC_CSM_CSMBISMCaseManager.person customer = new WSC_CSM_CSMBISMCaseManager.person();
        WSC_CSM_CSMBISMCaseManager.person contact = new WSC_CSM_CSMBISMCaseManager.person();
        WSC_CSM_CSMBISMCaseManager.activityUpdateType activityUpdate = new WSC_CSM_CSMBISMCaseManager.activityUpdateType();
        WSC_CSM_CSMBISMCaseManager.historyEntries_element historyEntries = null;
        WSC_CSM_CSMBISMCaseManager.historyEntry_element historyEntry = null;
        Case cs =[Select Id,CaseNumber,description,Techno_Impact__c,Urgency__c,Priority,Status,Service_Now_Incident_Number__c,Service_Now_Type__c,Resolution__c From Case Limit 1];
        Test.setMock(WebServiceMock.class, new TST_WSC_CSM_BISMIncidentMgmt_WSMock());
        header.transactionId = '';
        header.initiator = 'POLARIS';
        header.currentOwner = 'POLARIS';
        //callerid
        sender.id = '1234';
        sender.name = 'BISNOW';
        header.sender = sender;
        receiver.id = cs.CaseNumber;
        receiver.name = 'IQVIA';
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
        createTicket.description = 'Test';
        createTicket.location = '';
        createTicket.serviceClassification = '';
        createTicket.ticketType = '';
        createTicket.impact = '2'; //<!-- 3:low | 2:medium | 1:high -->
        createTicket.urgency = '2'; // <!-- 3:low | 2:medium | 1:high -->
        createTicket.priority = '2';
        createTicket.currentGroup = 'ITB-IAS';
        //createTicket.assignGroup = 'DS.ISD.HU.7X24.BUD';
        createTicket.assignGroup = 'BI-ITINF-KM-MPS-SOFTWARE-ISSUE';
        createTicket.category = 'Business Administration';
        createTicket.subcategory = 'Manage Ratings definition';
        createTicket.majorIncident = false;
        createTicket.medium= 'Phone';
        createTicket.ticketStatus = '2';
        historyEntries = new WSC_CSM_CSMBISMCaseManager.historyEntries_element();
        historyEntry = new WSC_CSM_CSMBISMCaseManager.historyEntry_element();
        historyEntry.orderNumber  = 1;
        historyEntry.activityInformation = 'Test Case Comment';
        historyEntry.date_x = System.now();
        historyEntry.creator = Userinfo.getName();  
        historyEntries.historyEntry = new List<WSC_CSM_CSMBISMCaseManager.historyEntry_element>{historyEntry};
        createTicket.historyEntries = historyEntries;  
        WSC_CSM_CSMBISMCaseManager.attachment_element att = new WSC_CSM_CSMBISMCaseManager.attachment_element();
        att.filename ='Test.txt'; 
        att.data = String.valueOf(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));
        WSC_CSM_CSMBISMCaseManager.attachments_element atts = new WSC_CSM_CSMBISMCaseManager.attachments_element();
        atts.attachment = new List<WSC_CSM_CSMBISMCaseManager.attachment_element>{att};
        createTicket.attachments = atts;
        try { 
            WSC_CSM_CSMBISMCaseManager.message_element resUpd = WSC_CSM_CSMBISMCaseManager.UpdateTicket(header, createTicket);
            WSC_CSM_CSMBISMCaseManager.responseType rst = resUpd.response; 
            
        } catch ( CalloutException ce) { 
            System.debug('Exce : '+ce.getCause());
            System.debug('Stack'+ ce.getStackTraceString());
            
        } catch ( Exception e) { 
            // Standard Exception Handling 
        }
        
    }
    
    @isTest static void activityUpdateTicket() {
        
        WSC_CSM_CSMBISMCaseManager.messageHeaderType header = new WSC_CSM_CSMBISMCaseManager.messageHeaderType();
        WSC_CSM_CSMBISMCaseManager.systemAddressType sender = new WSC_CSM_CSMBISMCaseManager.systemAddressType();
        WSC_CSM_CSMBISMCaseManager.systemAddressType receiver = new WSC_CSM_CSMBISMCaseManager.systemAddressType();
        WSC_CSM_CSMBISMCaseManager.activityUpdateType activityUpdate = new WSC_CSM_CSMBISMCaseManager.activityUpdateType();
        WSC_CSM_CSMBISMCaseManager.historyEntries_element historyEntries = null;
        WSC_CSM_CSMBISMCaseManager.historyEntry_element historyEntry = null;
        Case cs =[Select Id,CaseNumber,description,Techno_Impact__c,Urgency__c,Priority,Status,Service_Now_Incident_Number__c,Service_Now_Type__c,Resolution__c From Case Limit 1];
        Test.setMock(WebServiceMock.class, new TST_WSC_CSM_BISMIncidentMgmt_WSMock());
        header.transactionId = cs.Id;
        header.initiator = 'POLARIS';
        header.currentOwner = 'POLARIS';
        //callerid
        sender.id = '1234';
        sender.name = 'BISNOW';
        header.sender = sender;
        receiver.id = cs.CaseNumber;
        receiver.name = 'IQVIA';
        header.receiver = receiver;
        historyEntries = new WSC_CSM_CSMBISMCaseManager.historyEntries_element();
        historyEntry = new WSC_CSM_CSMBISMCaseManager.historyEntry_element();
        historyEntry.orderNumber  = 1;
        historyEntry.activityInformation = 'Test Case Comment';
        historyEntry.date_x = System.now();
        historyEntry.creator = Userinfo.getName();  
        activityUpdate.historyEntry = historyEntry;
        historyEntries.historyEntry = new List<WSC_CSM_CSMBISMCaseManager.historyEntry_element>{historyEntry};
        WSC_CSM_CSMBISMCaseManager.attachment_element att = new WSC_CSM_CSMBISMCaseManager.attachment_element();
        att.filename ='Test.txt'; 
        att.data = String.valueOf(EncodingUtil.urlEncode('Unit Test Attachment Body','UTF-8'));
        WSC_CSM_CSMBISMCaseManager.attachments_element atts = new WSC_CSM_CSMBISMCaseManager.attachments_element();
        atts.attachment = new List<WSC_CSM_CSMBISMCaseManager.attachment_element>{att};
            activityUpdate.attachments = atts;
        try { 
            
            WSC_CSM_CSMBISMCaseManager.message_element resactUpd = WSC_CSM_CSMBISMCaseManager.activityUpdate(header, activityUpdate);
            WSC_CSM_CSMBISMCaseManager.responseType rst = resactUpd.response; 
        
            
        } catch ( CalloutException ce) { 
            System.debug('Exce : '+ce.getCause());
            System.debug('Stack'+ ce.getStackTraceString());
            
        } catch ( Exception e) { 
            // Standard Exception Handling 
        }
        
    }
    
    @isTest static void resolveTicketMandatoryNull() {
        Case c = [Select Id,Status,SubStatus__c from Case where Subject = 'Techno case' limit 1];
        c.Status = CON_CSM.S_AWAITING;
        c.SubStatus__c = CON_CSM.S_SS_CI;
        update c;
        WSC_CSM_CSMBISMCaseManager.messageHeaderType header = new WSC_CSM_CSMBISMCaseManager.messageHeaderType();
        WSC_CSM_CSMBISMCaseManager.systemAddressType sender = new WSC_CSM_CSMBISMCaseManager.systemAddressType();
        WSC_CSM_CSMBISMCaseManager.systemAddressType receiver = new WSC_CSM_CSMBISMCaseManager.systemAddressType();
        WSC_CSM_CSMBISMCaseManager.resolveTicketType resolveTicket = new WSC_CSM_CSMBISMCaseManager.resolveTicketType();
        Case cs =[Select Id,CaseNumber,description,Techno_Impact__c,Urgency__c,Priority,Status,Service_Now_Incident_Number__c,Service_Now_Type__c,Resolution__c From Case Limit 1];
        Test.setMock(WebServiceMock.class, new TST_WSC_CSM_BISMIncidentMgmt_WSMock());
        header.transactionId = cs.Id;
        header.initiator = 'POLARIS';
        header.currentOwner = 'POLARIS';
        //callerid
        sender.id = '1234';
        sender.name = 'BISNOW';
        header.sender = sender;
        receiver.id = cs.CaseNumber;
        receiver.name = 'IQVIA';
        header.receiver = receiver;
        
        try { 
            //resolveTicket.reason = null;
            //resolveTicket.solution = null;
            resolveTicket.solvedDirectly = false;
            resolveTicket.resolveDate = System.now();
            //resolveTicket.resolveStatus = null;
            
            WSC_CSM_CSMBISMCaseManager.message_element resolve = WSC_CSM_CSMBISMCaseManager.ResolveTicket(header, resolveTicket);
            WSC_CSM_CSMBISMCaseManager.responseType rst = resolve.response; 
        
            
        } catch ( CalloutException ce) { 
            System.debug('Exce : '+ce.getCause());
            System.debug('Stack'+ ce.getStackTraceString());
            
        } catch ( Exception e) { 
            // Standard Exception Handling 
        }
        
    }
    
    @isTest static void resolveTicket() {
        Case c = [Select Id,Status,RootCause__c,Resolution__c,External_System_Type__c from Case where Subject = 'Techno case' limit 1];
        Test.setMock(WebServiceMock.class, new TST_WSC_CSM_BISMIncidentMgmt_WSMock());
        c.Status = CON_CSM.S_AWAITING;
        c.RootCause__c = 'Other';
        c.Resolution__c = 'Other';
        c.Root_Cause_Reason__c = 'Other Service';
        c.External_System_Type__c = CON_CSM.S_BISM;
        update c;
        WSC_CSM_CSMBISMCaseManager.messageHeaderType header = new WSC_CSM_CSMBISMCaseManager.messageHeaderType();
        WSC_CSM_CSMBISMCaseManager.systemAddressType sender = new WSC_CSM_CSMBISMCaseManager.systemAddressType();
        WSC_CSM_CSMBISMCaseManager.systemAddressType receiver = new WSC_CSM_CSMBISMCaseManager.systemAddressType();
        WSC_CSM_CSMBISMCaseManager.resolveTicketType resolveTicket = new WSC_CSM_CSMBISMCaseManager.resolveTicketType();
        Case cs =[Select Id,CaseNumber,description,Techno_Impact__c,Urgency__c,Priority,Status,Service_Now_Incident_Number__c,Service_Now_Type__c,Resolution__c From Case Limit 1];
        System.debug('resolveTicket cs.CaseNumber : '+cs.CaseNumber);
        header.transactionId = cs.Id;
        header.initiator = 'POLARIS';
        header.currentOwner = 'POLARIS';
        //callerid
        sender.id = '1234';
        sender.name = 'BISNOW';
        header.sender = sender;
        receiver.id = cs.CaseNumber;
        receiver.name = 'IQVIA';
        header.receiver = receiver;
        
        try { 
            resolveTicket.reason = 'access provied';
            resolveTicket.solution = 'access provied';
            resolveTicket.solvedDirectly = false;
            resolveTicket.resolveDate = System.now();
            resolveTicket.resolveStatus = 'Closed/Resolved by Caller';
            
            WSC_CSM_CSMBISMCaseManager.message_element resolve = WSC_CSM_CSMBISMCaseManager.ResolveTicket(header, resolveTicket);
            WSC_CSM_CSMBISMCaseManager.responseType rst = resolve.response; 
        
            
        } catch ( CalloutException ce) { 
            System.debug('Exce : '+ce.getCause());
            System.debug('Stack'+ ce.getStackTraceString());
            
        } catch ( Exception e) { 
            // Standard Exception Handling 
        }
        
    }
    
    @isTest static void closeTicket() {
        Test.setMock(WebServiceMock.class, new TST_WSC_CSM_BISMIncidentMgmt_WSMock());
        Case c = [Select Id,Status,RootCause__c,Resolution__c from Case where Subject = 'Techno case' limit 1];
        c.Status = CON_CSM.S_AWAITING;
        c.RootCause__c = 'Other';
        c.Resolution__c = 'Other';
        c.Root_Cause_Reason__c = 'Other Service';

        update c;

        WSC_CSM_CSMBISMCaseManager.messageHeaderType header = new WSC_CSM_CSMBISMCaseManager.messageHeaderType();
        WSC_CSM_CSMBISMCaseManager.systemAddressType sender = new WSC_CSM_CSMBISMCaseManager.systemAddressType();
        WSC_CSM_CSMBISMCaseManager.systemAddressType receiver = new WSC_CSM_CSMBISMCaseManager.systemAddressType();
        WSC_CSM_CSMBISMCaseManager.closeTicketType closeTicket = new WSC_CSM_CSMBISMCaseManager.closeTicketType();
        Case cs =[Select Id,CaseNumber,description,Techno_Impact__c,Urgency__c,Priority,Status,Service_Now_Incident_Number__c,Service_Now_Type__c,Resolution__c From Case Limit 1];
        System.debug('closeTicket cs.CaseNumber : '+cs.CaseNumber);
        header.transactionId = cs.Id;
        header.initiator = 'POLARIS';
        header.currentOwner = 'POLARIS';
        //callerid
        sender.id = '1234';
        sender.name = 'BISNOW';
        header.sender = sender;
        receiver.id = cs.CaseNumber;
        receiver.name = 'IQVIA';
        header.receiver = receiver;
        
        
        try { 
            closeTicket.closeDate = System.now();
            closeTicket.closeGroup = 'BI-ITINF-KM-MPS-SOFTWARE-ISSUE';
            
            WSC_CSM_CSMBISMCaseManager.message_element closed = WSC_CSM_CSMBISMCaseManager.CloseTicket(header, closeTicket);
            WSC_CSM_CSMBISMCaseManager.responseType rst = closed.response; 
            
        } catch ( CalloutException ce) { 
            System.debug('Exce : '+ce.getCause());
            System.debug('Stack'+ ce.getStackTraceString());
            
        } catch ( Exception e) { 
            // Standard Exception Handling 
        }
        
    } 
    
    @isTest static void closeTicketNull() {
        Test.setMock(WebServiceMock.class, new TST_WSC_CSM_BISMIncidentMgmt_WSMock());
        Case c = [Select Id,Status,SubStatus__c from Case where Subject = 'Techno case' limit 1];
        c.Status = CON_CSM.S_AWAITING;
        c.SubStatus__c = CON_CSM.S_SS_CI;
        update c;
        WSC_CSM_CSMBISMCaseManager.messageHeaderType header = new WSC_CSM_CSMBISMCaseManager.messageHeaderType();
        WSC_CSM_CSMBISMCaseManager.systemAddressType sender = new WSC_CSM_CSMBISMCaseManager.systemAddressType();
        WSC_CSM_CSMBISMCaseManager.systemAddressType receiver = new WSC_CSM_CSMBISMCaseManager.systemAddressType();
        WSC_CSM_CSMBISMCaseManager.closeTicketType closeTicket = new WSC_CSM_CSMBISMCaseManager.closeTicketType();
        Case cs =[Select Id,CaseNumber,description,Techno_Impact__c,Urgency__c,Priority,Status,Service_Now_Incident_Number__c,Service_Now_Type__c,Resolution__c From Case Limit 1];
        System.debug('closeTicket cs.CaseNumber : '+cs.CaseNumber);
        header.transactionId = cs.Id;
        header.initiator = 'POLARIS';
        header.currentOwner = 'POLARIS';
        //callerid
        sender.id = '1234';
        sender.name = 'BISNOW';
        header.sender = sender;
        receiver.id = cs.CaseNumber;
        receiver.name = 'IQVIA';
        header.receiver = receiver;
        
        
        try { 
            closeTicket.closeDate = System.now();
            closeTicket.closeGroup = 'BI-ITINF-KM-MPS-SOFTWARE-ISSUE';
            WSC_CSM_CSMBISMCaseManager.getConfirmResponseType(header.receiver.Id,header.transactionId,'activityUpdate',header.sender.Id,'200','Ok',header.sender.name);
            WSC_CSM_CSMBISMCaseManager.message_element closed = WSC_CSM_CSMBISMCaseManager.CloseTicket(header, closeTicket);
            WSC_CSM_CSMBISMCaseManager.responseType rst = closed.response; 
            
        } catch ( CalloutException ce) { 
            System.debug('Exce : '+ce.getCause());
            System.debug('Stack'+ ce.getStackTraceString());
            
        } catch ( Exception e) { 
            // Standard Exception Handling 
        }
        
    }
}