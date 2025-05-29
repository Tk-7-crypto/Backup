public class WSC_CSM_BISMSOAPCallout {
    @future (callout = true)
    public static void CreateTicketCSM2BISM(String jsonString) {
        WSC_CSM_BISMIncidentMgmt.ticketInformationType createTicket = new WSC_CSM_BISMIncidentMgmt.ticketInformationType();
        WSC_CSM_BISMIncidentMgmt.configItem configItem = new WSC_CSM_BISMIncidentMgmt.configItem();
        WSC_CSM_BISMIncidentMgmt.person customer = new WSC_CSM_BISMIncidentMgmt.person();
        WSC_CSM_BISMIncidentMgmt.person contact = new WSC_CSM_BISMIncidentMgmt.person();
        Case c = (Case)JSON.deserialize(jsonString, Case.class);
        List<Contact> conList = new SLT_Contact().selectByContactIdList(new Set<Id>{c.ContactId}, new Set<String>{'Email','UniqueID__c','FirstName','LastName','Phone','MobilePhone','Country__c'});
        createTicket.contact = getContact((conList != null && !conList.isEmpty()) ? conList[0] : null);
        createTicket.configItem = getConfigItem();
        
        createTicket.description = c.description;
        createTicket.location = '';
        createTicket.serviceClassification = '';
        createTicket.ticketType = '';
        createTicket.impact = CON_CSM.PL_TECHNO_IMPACT.get(c.Techno_Impact__c); //<!-- 3:low | 2:medium | 1:high -->
        createTicket.urgency = CON_CSM.PL_TECHNO_URGENCY.get(c.Urgency__c); // <!-- 3:low | 2:medium | 1:high -->
        createTicket.priority = c.Priority.remove('Priority ');
        createTicket.ticketCreationDate = System.now();
        createTicket.slaTargetDate = System.now();
        createTicket.issueDate = System.now();
        createTicket.currentGroup = 'ITB-IAS';
        //createTicket.assignGroup = 'DS.ISD.HU.7X24.BUD';
        createTicket.assignGroup = 'BI-ITINF-KM-MPS-SOFTWARE-ISSUE';
        createTicket.category = 'Business Administration';
        createTicket.subcategory = 'Manage Ratings definition';
        createTicket.majorIncident = false;
        createTicket.medium= 'External Service';
        createTicket.ticketStatus = CON_CSM.PL_TECHNO_S2B_STATUS.get(c.Status);
        Map<String,String> head = new Map<String,String>();
        CSM_ExternalClient_info__c cc = CSM_ExternalClient_info__c.getValues('BISM');
        head.put('KeyId', cc.Password__c);
        WSC_CSM_BISMIncidentMgmt.HTTPS_Port_DEV dev = new WSC_CSM_BISMIncidentMgmt.HTTPS_Port_DEV();
        dev.inputHttpHeaders_x = head;
        try { 
            string currentdate = System.now().formatGmt('YYYYMMddhhmmss') + c.CaseNumber;
            WSC_CSM_BISMIncidentMgmt.message_element res = dev.CreateTicket(getHeader(c,currentdate), createTicket); 
            WSC_CSM_BISMIncidentMgmt.responseType rt = res.response; 
            c.Service_Now_Incident_Number__c = res.header.sender.id;
            c.Service_Now_Type__c = 'Incident';
            update c;
            
        } catch ( CalloutException ce) { 
            System.debug('Exce : '+ce.getCause());
            System.debug('Stack'+ ce.getStackTraceString());
            
        } catch ( Exception e) { 
            // Standard Exception Handling 
        }
        
        
    }
    
    @future (callout = true)
    public static void updateTicketCSM2BISM(String jsonString, String assign,String current) {
        Set<String> sngroup = new Set<String>{assign,current};
        boolean ownership = false;
        WSC_CSM_BISMIncidentMgmt.ticketInformationType updateTicket = new WSC_CSM_BISMIncidentMgmt.ticketInformationType();
        WSC_CSM_BISMIncidentMgmt.configItem configItem = new WSC_CSM_BISMIncidentMgmt.configItem();
        WSC_CSM_BISMIncidentMgmt.person customer = new WSC_CSM_BISMIncidentMgmt.person();
        WSC_CSM_BISMIncidentMgmt.person contact = new WSC_CSM_BISMIncidentMgmt.person();
        WSC_CSM_BISMIncidentMgmt.attachments_element attachments = new WSC_CSM_BISMIncidentMgmt.attachments_element();
        WSC_CSM_BISMIncidentMgmt.attachment_element attachment = null;
        Case c = (Case)JSON.deserialize(jsonString, Case.class);
        List<Contact> conList = new SLT_Contact().selectByContactIdList(new Set<Id>{c.ContactId}, new Set<String>{'Email','UniqueID__c','FirstName','LastName','Phone','MobilePhone','Country__c'});
        updateTicket.contact = getContact((conList != null && !conList.isEmpty()) ? conList[0] : null);
        //updateTicket.configItem = getConfigItem();
        updateTicket.shortdescription = c.subject;
        updateTicket.location = '';
        updateTicket.serviceClassification = '';
        updateTicket.ticketType = '';
        if(c.Priority != null && CON_CSM.PL_TECHNO_UI_PRIORITY.get(c.Priority+'~'+c.Urgency__c+'~'+c.Techno_Impact__c) != null){
            List<String> pList = CON_CSM.PL_TECHNO_UI_PRIORITY.get(c.Priority+'~'+c.Urgency__c+'~'+c.Techno_Impact__c).split('~');
            if(pList != null && !pList.isEmpty()){
                updateTicket.priority = pList[0];
                updateTicket.urgency = pList[1];
                updateTicket.impact = pList[2];
            }
        }else{
            updateTicket.impact = CON_CSM.PL_TECHNO_IMPACT.get(c.Techno_Impact__c); //<!-- 2:low | 2:medium | 1:high -->
            updateTicket.urgency = CON_CSM.PL_TECHNO_URGENCY.get(c.Urgency__c); // <!-- 3:low | 2:medium | 1:high -->    
        }
        
        updateTicket.priority = c.Priority.remove('Priority ');
        updateTicket.ticketCreationDate = c.CreatedDate;
        updateTicket.slaTargetDate = c.CreatedDate;
        updateTicket.issueDate = c.CreatedDate;
        String Queue = c.InitialQueue__c;
        List<ServiceNow_Group__c>  sngList = Database.query('select Id,Name,SystemType__c,Group_ID__c from ServiceNow_Group__c where SystemType__c in :sngroup and Queue__c = :Queue');
        for(ServiceNow_Group__c sg : sngList){
            if(sg.SystemType__c == current){
                updateTicket.currentGroup = sg.Group_ID__c;        
            }else if(sg.SystemType__c == assign && sg.Id == c.ServiceNow_Group__c){
                updateTicket.assignGroup = sg.Group_ID__c;
            }
        }
        if(current != assign){
            ownership = true;
        }
        updateTicket.category = 'Business Administration';
        updateTicket.subcategory = 'Manage Ratings definition';
        updateTicket.majorIncident = false;
        updateTicket.medium = c.Origin;
        updateTicket.ticketStatus = c.Status;
        Map<String,String> head = new Map<String,String>();
        CSM_ExternalClient_info__c cc = CSM_ExternalClient_info__c.getValues('BISM');
        head.put('KeyId', cc.Password__c);
        WSC_CSM_BISMIncidentMgmt.HTTPS_Port_DEV dev = new WSC_CSM_BISMIncidentMgmt.HTTPS_Port_DEV();
        dev.inputHttpHeaders_x = head;
        try { 
            string currentdate = System.now().formatGmt('YYYYMMddhhmmss') + c.CaseNumber;
            WSC_CSM_BISMIncidentMgmt.message_element res = dev.updateTicket(getHeader(c,currentdate), updateTicket); 
            WSC_CSM_BISMIncidentMgmt.responseType rt = res.response; 
            insertIntegrationLog(c.CaseNumber, c.Id,c.Service_Now_Incident_Number__c,rt.message,rt.status,currentdate,'updateTicket',false,ownership,false);
            System.debug('message : '+ rt.message + ' status : ' + rt.status + ' type :' + rt.type_x);
            System.debug('header.sender.id : '+ res.header.sender.id + ' sender.name : ' + res.header.sender.name);
            System.debug('header.receiver.id : '+ res.header.receiver.id + ' receiver.name : ' + res.header.receiver.name);
            
        } catch ( CalloutException ce) { 
            System.debug('Exce : '+ce.getCause());
            System.debug('Stack'+ ce.getStackTraceString());
            
        } catch ( Exception e) { 
            // Standard Exception Handling 
        }
        
        
    }
    
    @future (callout = true)
    public static void UpdateTicketCSM2BISMAttachment(String jsonString) {
        WSC_CSM_BISMIncidentMgmt.ticketInformationType updateTicket = new WSC_CSM_BISMIncidentMgmt.ticketInformationType();
        WSC_CSM_BISMIncidentMgmt.historyEntry_element historyEntry = new WSC_CSM_BISMIncidentMgmt.historyEntry_element();
        WSC_CSM_BISMIncidentMgmt.attachments_element attachments = new WSC_CSM_BISMIncidentMgmt.attachments_element();
        WSC_CSM_BISMIncidentMgmt.extensionFields_element extensionFields = new WSC_CSM_BISMIncidentMgmt.extensionFields_element();
        WSC_CSM_BISMIncidentMgmt.attachment_element attachment = null;
        Map<String, Object> metaCase = (Map<String, Object>) JSON.deserialize(JsonString,Map<String, SObject>.class);
        Set<String> docIdSet = metaCase.keySet();
        List<ContentVersion> cvL = Database.query('SELECT Id, VersionData,CreatedDate,ContentModifiedDate,Title,ContentDocumentId,PathOnClient,ContentSize FROM ContentVersion WHERE ContentDocumentId in :docIdSet');
        for(ContentVersion cv : cvL){
            Case c = (Case)metaCase.get(cv.ContentDocumentId);
            if(cv.ContentSize < 6000001 && metaCase.containsKey(cv.ContentDocumentId)){
                String caseId = c.Id;
                WSC_CSM_BISMIncidentMgmt.attachment_element[] attachmentarr = new List<WSC_CSM_BISMIncidentMgmt.attachment_element>();
                attachment = new WSC_CSM_BISMIncidentMgmt.attachment_element();
                attachment.reference = cv.Id;
                attachment.filename = cv.PathOnClient;
                attachment.description = cv.Title;
                attachment.created = cv.CreatedDate;
                attachment.updated = cv.ContentModifiedDate;
                attachment.size = cv.ContentSize;
                attachment.data = EncodingUtil.base64Encode(cv.VersionData);
                attachmentarr.add(attachment);    
                
                attachments.attachment = attachmentarr;
                updateTicket.attachments = attachments;
                Map<String,String> head = new Map<String,String>();
                CSM_ExternalClient_info__c cc = CSM_ExternalClient_info__c.getValues('BISM');
                head.put('KeyId', cc.Password__c);
                WSC_CSM_BISMIncidentMgmt.HTTPS_Port_DEV dev = new WSC_CSM_BISMIncidentMgmt.HTTPS_Port_DEV();
                dev.inputHttpHeaders_x = head;
                try { 
                    string currentdate = System.now().formatGmt('YYYYMMddhhmmss') + c.CaseNumber;
                    WSC_CSM_BISMIncidentMgmt.message_element res = dev.updateTicket(getHeader(c,currentdate), updateTicket); 
                    WSC_CSM_BISMIncidentMgmt.responseType rt = res.response; 
                    sleep(20000);
                    insertIntegrationLog(c.CaseNumber, c.Id,c.Service_Now_Incident_Number__c,rt.message,rt.status,currentdate,'updateTicket',false,false,true);
                } catch ( CalloutException ce) { 
                    System.debug('Exce : '+ce.getCause());
                    System.debug('Stack'+ ce.getStackTraceString());
                    
                } catch ( Exception e) { 
                    // Standard Exception Handling 
                }    
            }else{
                String filecomment = 'The public attachment '+ cv.PathOnClient +' which you have uploaded is larger than 5 mb and therefore will not be sent to the client.'+
                    'Please ensure you only upload file(s) that have an individual file size which is less than 5 mb. Kindly change the attachment visibility back to Internal.';
                CaseComment cc = new CaseComment(ParentId = c.Id,CommentBody = filecomment, IsPublished = false);
                insert cc;
            }
        }
    }
    
    @future (callout = true)
    public static void ActivityUpdateCSM2BISMComments(String jsonString,String jsonComment) {
        WSC_CSM_BISMIncidentMgmt.activityUpdateType activityUpdate = new WSC_CSM_BISMIncidentMgmt.activityUpdateType();
        WSC_CSM_BISMIncidentMgmt.historyEntries_element historyEntries = null;
        WSC_CSM_BISMIncidentMgmt.historyEntry_element historyEntry = null;
        WSC_CSM_BISMIncidentMgmt.attachments_element attachments = new WSC_CSM_BISMIncidentMgmt.attachments_element();
        WSC_CSM_BISMIncidentMgmt.extensionFields_element extensionFields = new WSC_CSM_BISMIncidentMgmt.extensionFields_element();
        Map<String, Object> caseMap = (Map<String, Object>) JSON.deserialize(JsonString,Map<String, SObject>.class);
        Set<String> caseSet = caseMap.keySet();
        Map<String, Object>  ccMap = (Map<String, Object>) JSON.deserialize(jsonComment,Map<String, SObject>.class);
        for(String i : caseSet){
            Case c = (Case)caseMap.get(i);
            CaseComment cc = (CaseComment)ccMap.get(i);
            
            historyEntry = new WSC_CSM_BISMIncidentMgmt.historyEntry_element();
            historyEntry.orderNumber  = 1;
            historyEntry.activityInformation = cc.CommentBody;
            historyEntry.date_x = cc.CreatedDate;
            historyEntry.creator = cc.CreatedBy.Name;  
            activityUpdate.historyEntry = historyEntry;
            Map<String,String> head = new Map<String,String>();
            CSM_ExternalClient_info__c ecc = CSM_ExternalClient_info__c.getValues('BISM');
            head.put('KeyId', ecc.Password__c);
            WSC_CSM_BISMIncidentMgmt.HTTPS_Port_DEV dev = new WSC_CSM_BISMIncidentMgmt.HTTPS_Port_DEV();
            dev.inputHttpHeaders_x = head;
            try { 
                string currentdate = System.now().formatGmt('YYYYMMddhhmmss') + c.CaseNumber;
                WSC_CSM_BISMIncidentMgmt.message_element res = dev.activityUpdate(getHeader(c,currentdate), activityUpdate); 
                WSC_CSM_BISMIncidentMgmt.responseType rt = res.response;
                insertIntegrationLog(c.CaseNumber, c.Id,c.Service_Now_Incident_Number__c,rt.message,rt.status,currentdate,'activityUpdate',false,false,false);
                
            } catch ( CalloutException ce) { 
                System.debug('Exce : '+ce.getCause());
                System.debug('Stack'+ ce.getStackTraceString());
                
            } catch ( Exception e) { 
                // Standard Exception Handling 
            }    
        }
    }
    
    @future (callout = true)
    public static void ActivityUpdateCSM2BISMCommentsSendEmail(String jsonString,String jsonEmail) {
        WSC_CSM_BISMIncidentMgmt.activityUpdateType activityUpdate = new WSC_CSM_BISMIncidentMgmt.activityUpdateType();
        WSC_CSM_BISMIncidentMgmt.historyEntries_element historyEntries = null;
        WSC_CSM_BISMIncidentMgmt.historyEntry_element historyEntry = null;
        WSC_CSM_BISMIncidentMgmt.attachments_element attachments = new WSC_CSM_BISMIncidentMgmt.attachments_element();
        WSC_CSM_BISMIncidentMgmt.extensionFields_element extensionFields = new WSC_CSM_BISMIncidentMgmt.extensionFields_element();
        Map<String, Object> caseMap = (Map<String, Object>) JSON.deserialize(JsonString,Map<String, SObject>.class);
        Set<String> caseSet = caseMap.keySet();
        Map<String, String>  ccMap = (Map<String, String>) JSON.deserialize(jsonEmail,Map<String, String>.class);
        for(String i : caseSet){
            Case c = (Case)caseMap.get(i);
            String cc = (String)ccMap.get(i);
            
            historyEntry = new WSC_CSM_BISMIncidentMgmt.historyEntry_element();
            historyEntry.orderNumber  = 1;
            historyEntry.activityInformation = cc;
            historyEntry.date_x = System.now();
            historyEntry.creator = UserInfo.getName();  
            activityUpdate.historyEntry = historyEntry;
            Map<String,String> head = new Map<String,String>();
            CSM_ExternalClient_info__c ecc = CSM_ExternalClient_info__c.getValues('BISM');
            head.put('KeyId', ecc.Password__c);
            WSC_CSM_BISMIncidentMgmt.HTTPS_Port_DEV dev = new WSC_CSM_BISMIncidentMgmt.HTTPS_Port_DEV();
            dev.inputHttpHeaders_x = head;
            try { 
                string currentdate = System.now().formatGmt('YYYYMMddhhmmss') + c.CaseNumber;
                WSC_CSM_BISMIncidentMgmt.message_element res = dev.activityUpdate(getHeader(c,currentdate), activityUpdate); 
                WSC_CSM_BISMIncidentMgmt.responseType rt = res.response;
                insertIntegrationLog(c.CaseNumber, c.Id,c.Service_Now_Incident_Number__c,rt.message,rt.status,currentdate,'activityUpdate',false,false,false);
                
            } catch ( CalloutException ce) { 
                System.debug('Exce : '+ce.getCause());
                System.debug('Stack'+ ce.getStackTraceString());
                
            } catch ( Exception e) { 
                // Standard Exception Handling 
            }    
        }
    }
    
    @future (callout = true)
    public static void resolveTicketCSM2BISM(String jsonString,String current) {
        WSC_CSM_BISMIncidentMgmt.resolveTicketType resolveTicket = new WSC_CSM_BISMIncidentMgmt.resolveTicketType();
        WSC_CSM_BISMIncidentMgmt.configItem configItem = new WSC_CSM_BISMIncidentMgmt.configItem();
        Case c = (Case)JSON.deserialize(jsonString, Case.class);
        resolveTicket.reason = c.Resolution__c;
        if(c.Resolution__c != null){
            resolveTicket.solution = c.Resolution__c;
        }else{
            resolveTicket.solution = 'Solved (Permanently)';
        }
        String Queue = c.InitialQueue__c;
        List<ServiceNow_Group__c>  sngList = Database.query('select Id,Name,SystemType__c from ServiceNow_Group__c where SystemType__c = :current and Queue__c = :Queue');
        for(ServiceNow_Group__c sg : sngList){
            resolveTicket.assignGroup = sg.Name;        
        }
        
        resolveTicket.solvedDirectly = false;
        resolveTicket.resolveDate = System.now();
        resolveTicket.resolveStatus = 'Solved (Permanently)';
        //resolveTicket.offendingConfigItem = getConfigItem();
        Map<String,String> head = new Map<String,String>();
        CSM_ExternalClient_info__c cc = CSM_ExternalClient_info__c.getValues('BISM');
        head.put('KeyId', cc.Password__c);
        WSC_CSM_BISMIncidentMgmt.HTTPS_Port_DEV dev = new WSC_CSM_BISMIncidentMgmt.HTTPS_Port_DEV();
        dev.inputHttpHeaders_x = head;
        try { 
            string currentdate = System.now().formatGmt('YYYYMMddhhmmss') + c.CaseNumber;
            WSC_CSM_BISMIncidentMgmt.message_element res = dev.ResolveTicket(getHeader(c,currentdate), resolveTicket); 
            String aString = JSON.serialize(resolveTicket);
            System.debug('aString :'+aString);
            WSC_CSM_BISMIncidentMgmt.responseType rt = res.response; 
            insertIntegrationLog(c.CaseNumber, c.Id,c.Service_Now_Incident_Number__c,rt.message,rt.status,currentdate,'resolveTicket',false,false,false);
        } catch ( CalloutException ce) { 
            System.debug('Exce : '+ce.getCause());
            System.debug('Stack'+ ce.getStackTraceString());
            
        } catch ( Exception e) { 
            // Standard Exception Handling 
        }
        
        
    }
    
    @future (callout = true)
    public static void closeTicketCSM2BISM(String jsonString,String current) {
        
        WSC_CSM_BISMIncidentMgmt.closeTicketType closeTicket = new WSC_CSM_BISMIncidentMgmt.closeTicketType();
        Case c = (Case)JSON.deserialize(jsonString, Case.class);
        closeTicket.closeDate = System.now();
        String Queue = c.InitialQueue__c;
        List<ServiceNow_Group__c>  sngList = Database.query('select Id,Name,SystemType__c from ServiceNow_Group__c where SystemType__c = :current and Queue__c = :Queue');
        for(ServiceNow_Group__c sg : sngList){
            closeTicket.closeGroup = sg.Name;        
        }
        Map<String,String> head = new Map<String,String>();
        CSM_ExternalClient_info__c cc = CSM_ExternalClient_info__c.getValues('BISM');
        head.put('KeyId', cc.Password__c);
        WSC_CSM_BISMIncidentMgmt.HTTPS_Port_DEV dev = new WSC_CSM_BISMIncidentMgmt.HTTPS_Port_DEV();
        dev.inputHttpHeaders_x = head;
        try { 
            string currentdate = System.now().formatGmt('YYYYMMddhhmmss') + c.CaseNumber;
            WSC_CSM_BISMIncidentMgmt.message_element res = dev.closeTicket(getHeader(c,currentdate), closeTicket); 
            WSC_CSM_BISMIncidentMgmt.responseType rt = res.response;
            insertIntegrationLog(c.CaseNumber, c.Id,c.Service_Now_Incident_Number__c,rt.message,rt.status,currentdate,'closeTicket',false,false,false);
        } catch ( CalloutException ce) { 
            System.debug('Exce : '+ce.getCause());
            System.debug('Stack'+ ce.getStackTraceString());
            
        } catch ( Exception e) { 
            // Standard Exception Handling 
        }
        
        
    }
    
    @future (callout = true)
    public static void confirmTicketCSM2BISM(String jsonString) {
        WSC_CSM_BISMIncidentMgmt.message_element response_x = (WSC_CSM_BISMIncidentMgmt.message_element)JSON.deserialize(jsonString, WSC_CSM_BISMIncidentMgmt.message_element.class);
        Map<String,String> head = new Map<String,String>();
        sleep(30000);
        CSM_ExternalClient_info__c cc = CSM_ExternalClient_info__c.getValues('BISM');
        head.put('KeyId', cc.Password__c);
        WSC_CSM_BISMIncidentMgmt.HTTPS_Port_DEV dev = new WSC_CSM_BISMIncidentMgmt.HTTPS_Port_DEV();
        dev.inputHttpHeaders_x = head;
        try { 
            WSC_CSM_BISMIncidentMgmt.message_element res = dev.ConfirmTicket(response_x.header, response_x.response); 
            WSC_CSM_BISMIncidentMgmt.responseType rt = res.response; 
        } catch ( CalloutException ce) { 
            System.debug('Exce : '+ce.getCause());
            System.debug('Stack'+ ce.getStackTraceString());
        } catch ( Exception e) { 
            // Standard Exception Handling 
        }
    }
    
    public static void sleep(Long milliSeconds)
    {
        Long timeDiff = 0;
        DateTime firstTime = System.now();
        do
        {
            timeDiff = System.now().getTime() - firstTime.getTime();
        }
        while(timeDiff <= milliSeconds);
    }
    
    private static WSC_CSM_BISMIncidentMgmt.messageHeaderType getHeader(Case c,String transId){
        WSC_CSM_BISMIncidentMgmt.messageHeaderType header = new WSC_CSM_BISMIncidentMgmt.messageHeaderType();
        WSC_CSM_BISMIncidentMgmt.systemAddressType sender = new WSC_CSM_BISMIncidentMgmt.systemAddressType();
        WSC_CSM_BISMIncidentMgmt.systemAddressType receiver = new WSC_CSM_BISMIncidentMgmt.systemAddressType();
        header.transactionId = transId;
        header.initiator = '';
        header.currentOwner = '';
        //callerid
        sender.id = c.CaseNumber;
        sender.name = 'IQVIA';
        header.sender = sender;
        receiver.id = c.Service_Now_Incident_Number__c;
        receiver.name = 'BISNOW';
        header.receiver = receiver;
        return header;
    }
    
    private static WSC_CSM_BISMIncidentMgmt.person getContact(Contact con){
        WSC_CSM_BISMIncidentMgmt.person contact = new WSC_CSM_BISMIncidentMgmt.person();
        if(con != null){
            contact.reference = con.Email;
            contact.globalId = con.UniqueID__c;
            //contact.userId = 'x2acdepolaris';
            contact.eMail =con.Email;
            contact.firstName =con.FirstName;
            contact.surname =con.LastName;
            contact.telephoneNumber = con.Phone;
            contact.mobileNumber = con.MobilePhone;
            //contact.facsimileNumber ='+49 (7351) 54-2653';
            //contact.location = 'Biberach';
            contact.country = con.Country__c;
        }
        return contact;
    }
    
    private static WSC_CSM_BISMIncidentMgmt.configItem getConfigItem(){
        WSC_CSM_BISMIncidentMgmt.configItem configItem = new WSC_CSM_BISMIncidentMgmt.configItem();
        configItem.reference  = 'BOEHRINGER_EPB_ACCEPTANCE (APPL259517)';
        configItem.title = 'BI-PAAS-SAP-EPB';
        configItem.description = 'Cloud System for all SAP Hosting';
        configItem.type_x = 'Cloud Service';
        configItem.status = 'In Production';
        configItem.physicalLocation = '';
        configItem.location = 'Unspecified';
        configItem.country = '';
        configItem.serialNumber = '';
        return configItem;
    }
    public static void insertIntegrationLog(String CaseNumber, String CaseId,String serviceNowId,String messageR,String statusR,String transId,String ticketType,boolean incoming,boolean transferOwner,boolean attach){
        CSM_QI_Integration_Log__c cil = new CSM_QI_Integration_Log__c();
        cil.Case_Number__c  = CaseNumber;
        cil.Case_Id__c = CaseId;
        cil.ExternalSystemType__c = 'BISM';
        cil.ExternalTicket_Id__c = serviceNowId;
        cil.Message__c = messageR;
        cil.MessageStatus__c = statusR;
        cil.ConfirmStatus__c = 'Created';
        cil.Transaction_Id__c = transId;
        cil.TicketType__c = ticketType;
        cil.IsIncoming__c = incoming;
        cil.Transfer_Ownership__c = transferOwner;
        cil.Attachment_Added__c = attach;
        insert cil;    
    }

    public static void insertIntegrationLog(String CaseNumber, String CaseId,String serviceNowId,String messageR,String statusR,String transId,String ticketType,boolean incoming,boolean transferOwner,boolean attach,String SystemType){
        CSM_QI_Integration_Log__c cil = new CSM_QI_Integration_Log__c();
        cil.Case_Number__c  = CaseNumber;
        cil.Case_Id__c = CaseId;
        cil.ExternalSystemType__c = 'BISM';
        cil.ExternalTicket_Id__c = serviceNowId;
        cil.Message__c = messageR;
        cil.MessageStatus__c = statusR;
        cil.ConfirmStatus__c = 'Created';
        cil.Transaction_Id__c = transId;
        cil.TicketType__c = ticketType;
        cil.IsIncoming__c = incoming;
        cil.Transfer_Ownership__c = transferOwner;
        cil.Attachment_Added__c = attach;
        insert cil;    
    }

    

}