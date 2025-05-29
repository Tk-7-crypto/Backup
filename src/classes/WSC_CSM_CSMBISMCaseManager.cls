global with sharing class WSC_CSM_CSMBISMCaseManager {
    global class extensionField_element {
        webservice String name;
        webservice String value;
    }
    global class serviceItem {
        webservice String reference;
        webservice String title;
        webservice String description;
        webservice String type_x;
        webservice String status;
        webservice WSC_CSM_CSMBISMCaseManager.extensionFields_element extensionFields;
    }
    global class extensionFields_element {
        webservice WSC_CSM_CSMBISMCaseManager.extensionField_element[] extensionField;
    }
    global class systemAddressType {
        webservice String id;
        webservice String name;
    }
    global class historyEntry_element {
        webservice Integer orderNumber;
        webservice String activityInformation;
        webservice DateTime date_x;
        webservice String creator;
    }
    global class historyEntries_element {
        webservice WSC_CSM_CSMBISMCaseManager.historyEntry_element[] historyEntry;
    }
    global class outageInformation {
        webservice String reference;
        webservice WSC_CSM_CSMBISMCaseManager.configItem configItem;
        webservice DateTime startDate;
        webservice DateTime endDate;
        webservice String description;
        webservice String type_x;
        webservice String linkedEntityReference;
    }
    global class typeHierarchy_element {
        webservice String[] type_x;
    }
    global class messageHeaderType {
        webservice String transactionId;
        webservice String initiator;
        webservice String currentOwner;
        webservice WSC_CSM_CSMBISMCaseManager.systemAddressType sender;
        webservice WSC_CSM_CSMBISMCaseManager.systemAddressType receiver;
    }
    global class responseType {
        webservice String type_x;
        webservice String status;
        webservice Boolean ownershipTransferred;
        webservice String message;
    }
    global class person {
        webservice String reference;
        webservice String globalId;
        webservice String userId;
        webservice String eMail;
        webservice String firstName;
        webservice String surname;
        webservice String title;
        webservice String telephoneNumber;
        webservice String mobileNumber;
        webservice String facsimileNumber;
        webservice String location;
        webservice String country;
        webservice WSC_CSM_CSMBISMCaseManager.extensionFields_element extensionFields;
    }
    global class message_element {
        webservice WSC_CSM_CSMBISMCaseManager.messageHeaderType header;
        webservice WSC_CSM_CSMBISMCaseManager.ticketInformationType createTicket;
        webservice WSC_CSM_CSMBISMCaseManager.ticketInformationType updateTicket;
        webservice WSC_CSM_CSMBISMCaseManager.activityUpdateType activityUpdate;
        webservice WSC_CSM_CSMBISMCaseManager.resolveTicketType resolveTicket;
        webservice WSC_CSM_CSMBISMCaseManager.closeTicketType closeTicket;
        webservice WSC_CSM_CSMBISMCaseManager.outageInformation outageInformation;
        webservice WSC_CSM_CSMBISMCaseManager.responseType response;
    }
    global class message_element_response {
        webservice WSC_CSM_CSMBISMCaseManager.messageHeaderType header;
        webservice WSC_CSM_CSMBISMCaseManager.responseType response;
    }
    global class attachments_element {
        webservice WSC_CSM_CSMBISMCaseManager.attachment_element[] attachment;
    }
    global class attachment_element {
        webservice String reference;
        webservice String filename;
        webservice String description;
        webservice DateTime created;
        webservice DateTime updated;
        webservice Integer size;
        webservice String data;
    }
    global class type_element {
        webservice Integer level;
        webservice String name;
    }
    global class closeTicketType {
        webservice DateTime closeDate;
        webservice String closeGroup;
    }
    global class configItem {
        webservice String reference;
        webservice String title;
        webservice String description;
        webservice String type_x;
        webservice String status;
        webservice String physicalLocation;
        webservice String location;
        webservice String country;
        webservice String serialNumber;
        webservice WSC_CSM_CSMBISMCaseManager.extensionFields_element extensionFields;
    }
    global class activityUpdateType {
        webservice WSC_CSM_CSMBISMCaseManager.historyEntry_element historyEntry;
        webservice WSC_CSM_CSMBISMCaseManager.attachments_element attachments;
        webservice WSC_CSM_CSMBISMCaseManager.extensionFields_element extensionFields;
    }
    global class ticketInformationType {
        webservice WSC_CSM_CSMBISMCaseManager.person customer;
        webservice WSC_CSM_CSMBISMCaseManager.person contact;
        webservice String description;
        webservice String shortdescription;
        webservice String category;
        webservice String subcategory;
        webservice String location;
        webservice WSC_CSM_CSMBISMCaseManager.configItem configItem;
        webservice WSC_CSM_CSMBISMCaseManager.serviceItem service;
        webservice String serviceClassification;
        webservice String ticketType;
        webservice String serviceOffering;
        webservice WSC_CSM_CSMBISMCaseManager.typeHierarchy_element typeHierarchy;
        webservice String impact;
        webservice String urgency;
        webservice String priority;
        webservice DateTime ticketCreationDate;
        webservice DateTime slaTargetDate;
        webservice DateTime issueDate;
        webservice String currentGroup;
        webservice String assignGroup;
        webservice String workaround;
        webservice Boolean datalossOrCorruptionPossible;
        webservice Boolean majorIncident;
        webservice String medium;
        webservice String ticketStatus;
        webservice String lastActivityInformation;
        webservice WSC_CSM_CSMBISMCaseManager.historyEntries_element historyEntries;
        webservice WSC_CSM_CSMBISMCaseManager.attachments_element attachments;
        webservice WSC_CSM_CSMBISMCaseManager.extensionFields_element extensionFields;
    }
    global class resolveTicketType {
        webservice String solution;
        webservice WSC_CSM_CSMBISMCaseManager.configItem offendingConfigItem;
        webservice Boolean solvedDirectly;
        webservice DateTime resolveDate;
        webservice String resolveStatus;
        webservice String reason;
        webservice String assignGroup;
    }
    
    webservice static WSC_CSM_CSMBISMCaseManager.message_element createTicket(WSC_CSM_CSMBISMCaseManager.messageHeaderType header,WSC_CSM_CSMBISMCaseManager.ticketInformationType ticketInformation) {
        String messageR;
        String statusR;
        boolean attach = false;
        boolean iscaseCreated = false;
        Case cs = new Case();
        if(ticketInformation.shortdescription != null){
            cs.Subject = ticketInformation.shortdescription;    
        }else{
            cs.Subject = header.sender.Id + ' - ' + header.sender.Name; 
        }
        cs.Status = 'New';
        cs.Description = ticketInformation.description;
        cs.Service_Now_Incident_Number__c = header.sender.Id;
        cs.Case_Type__c = 'Incident';
        cs.ServiceNowSystemType__c = 'IQVIA';
        cs.Service_Now_Type__c = 'Incident';
        cs.Device__c = 'Others';
        cs.CaseSource__c = 'Customer';
        cs.EnvironmentType__c = 'Production';
        cs.Requested_Date__c = System.today();
        if(header.sender.Id != null && header.sender.Id.startsWithIgnoreCase('SR')){
            cs.Service_Now_Type__c = 'Service Request';
        }
        cs.Customer_Requested_Date__c = ticketInformation.ticketCreationDate != null ? ticketInformation.ticketCreationDate.dateGmt() : System.today();
        cs.Priority = 'Priority ' + ticketInformation.priority;
        if(cs.Priority != null && CON_CSM.PL_TECHNO_UI_PRIORITY.get(ticketInformation.priority+'~'+ticketInformation.urgency +'~'+ticketInformation.impact) != null){
            List<String> pList = CON_CSM.PL_TECHNO_UI_PRIORITY.get(ticketInformation.priority+'~'+ticketInformation.urgency +'~'+ticketInformation.impact).split('~');
            if(pList != null && !pList.isEmpty()){
                cs.Urgency__c = pList[1];
                cs.Techno_Impact__c = pList[2];
            }
        }else if(ticketInformation.impact != null && ticketInformation.urgency != null && CON_CSM.PL_R_I_URGENCY.containsKey(ticketInformation.urgency) && CON_CSM.PL_R_I_IMPACT.containsKey(ticketInformation.impact)){
            cs.Urgency__c = CON_CSM.PL_R_I_URGENCY.get(ticketInformation.urgency);
            cs.Techno_Impact__c = CON_CSM.PL_R_I_IMPACT.get(ticketInformation.impact);
            cs.Priority = CON_CSM.PL_TECHNO_PRIORITY.get(cs.Urgency__c+'~'+cs.Techno_Impact__c);
        }else if(cs.Priority != null && CON_CSM.PL_TECHNO_UI_CASE_PRIORITY.get(cs.Priority) != null){
            List<String> pList = CON_CSM.PL_TECHNO_UI_CASE_PRIORITY.get(cs.Priority).split('~');
            if(pList != null && !pList.isEmpty()){
                cs.Urgency__c = pList[0];
                cs.Techno_Impact__c = pList[1];
            }
        }
        String AccountId;
        List<String> accountIds = null;
        CSM_ExternalClient_info__c ecc = null;
       if(header.sender.Name == 'BISNOW'){
           ecc = CSM_ExternalClient_info__c.getValues(CON_CSM.S_BISM);
           cs.External_System_Type__c = CON_CSM.S_BISM;
           cs.Origin = 'External Service';
        }else{
            ecc = CSM_ExternalClient_info__c.getValues(header.sender.Name);
            cs.External_System_Type__c = header.sender.Name;
            cs.Origin = CON_CSM.S_CUSTOMER_PORTAL;
        }
        if(ecc != null && ecc.Email_CC__c != null){
            cs.Mail_CC_List__c = ecc.Email_CC__c;
        }
        String assignGroup = ticketInformation.assignGroup;
        List<ServiceNow_Group__c>  sngList = Database.query('select Id,Name,Account_Id__c,Queue__c,Group_ID__c from ServiceNow_Group__c where (Name = :assignGroup OR Group_ID__c = :assignGroup) and SystemType__c = \'IQVIA\' and Queue__c != null LIMIT 1');
        for(ServiceNow_Group__c sg : sngList){
            cs.ServiceNow_Group__c =   sg.Id;
            if(sg.Account_Id__c != null){
                cs.AccountId = sg.Account_Id__c;
                AccountId = sg.Account_Id__c;
            }
        }
        if(ecc.Account_Id__c.contains(';')){
            accountIds = ecc.Account_Id__c.split(';');
        }else{
            accountIds = new List<String>();
            accountIds.add(ecc.Account_Id__c);
        }
        cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('TechnologyCase').getRecordTypeId();
        if(ticketInformation.contact != null && ticketInformation.contact.eMail != null){
            String email = ticketInformation.contact.eMail;
            cs.SuppliedEmail = email;
            List<Contact> conList = Database.query('Select Id, AccountId,Account.AccountCountry__c From Contact where Email = :email and AccountId in :accountIds limit 1');
            if(conList != null && !conList.isEmpty()){
                if(conList[0].Account.AccountCountry__c == 'US')
                {
                    cs.PhoneVerification__c = true;
                }
                cs.ContactId = conList[0].Id;
                cs.AccountId = conList[0].AccountId;
                AccountId = conList[0].AccountId;
            }else{
                cs.NoContactKnown__c = true;
            }
        }else{
            cs.NoContactKnown__c = true;
        }
        String Queue = null;
        if(AccountId != null){
            String product = CON_CSM.PL_TECHNO_B2S_PRODUCT.get(ticketInformation.serviceClassification);
            if(header.sender.Name == CON_CSM.S_ROCHE_SN){
                cs.ProductName__c = ticketInformation.serviceClassification;
                product = ticketInformation.serviceClassification;
                if(ticketInformation.contact != null && ticketInformation.contact.country != null){
                    List<EXT_CSM_CheckboxDetails> countryList = CNT_CSM_PortalCreateCase.getPickListOptionValues('Country_of_the_requester2__c');
                    if(countryList != null){
                        for(EXT_CSM_CheckboxDetails cn : countryList){
                            if(cn.label != null && cn.label != 'United States Minor Outlying Islands' && cn.label.containsIgnoreCase(ticketInformation.contact.country)){
                                cs.Country_of_the_requester2__c = cn.value;
                                break;
                            }
                        }
                    }    
                }
            }
            if(product != null){
                List<Asset>  aList = Database.query('select Id,Name,AccountId from Asset where Name = :product and AccountId = :AccountId LIMIT 1');
                for(Asset a : aList){
                    cs.AssetId = a.Id;
                    cs.ProductName__c = a.Name;
                }
            }
            
            List<CSM_QI_Data_Portal_Queue_User_details__c> outputDataList = Database.query('select Id, ClientContact__c, Queue_User_Relationship__c,Queue_User_Relationship__r.Name,Queue_User_Relationship__r.Group_Id__c, ContactUser__c, Account__c, Order__c, IQVIA_User__c, CaseRecordType__c  From CSM_QI_Data_Portal_Queue_User_details__c where CaseRecordType__c = \'TechnologyCase\' and (Account__c =:AccountId and Order__c = 20) order by Order__c DESC'); 
            for(CSM_QI_Data_Portal_Queue_User_details__c dp : outputDataList){
                cs.OwnerId = dp.Queue_User_Relationship__r.Group_Id__c;
                cs.CurrentQueue__c = dp.Queue_User_Relationship__c;
                Queue = dp.Queue_User_Relationship__r.Name;
            }
            
        }
        
        try{
            insert cs;
            statusR = 'ok';
            messageR = 'Ticket CSM_TicketNumber has been created with the IQVIA Support Team.';
            iscaseCreated = true;
        }catch(Exception e){
            statusR = 'error';
            messageR = 'Case insertion failure.';
        }
        List<ContentDocumentLink> cdl = new List<ContentDocumentLink>();
        List<String> newfiles = new List<String>();
        list<ContentVersion> docToInsert = new list<ContentVersion>();
        if(ticketInformation.attachments != null)
        {
            String caseId = cs.Id;
            for(WSC_CSM_CSMBISMCaseManager.attachment_element att : ticketInformation.attachments.attachment) {
                List<String> parts = new List<String>();
                if(att.filename != null && att.filename.length()>0){
                    if(att.filename != null)
                        parts = att.filename.split('\\.');
                    ContentVersion conVI = new ContentVersion(FirstPublishLocationId = cs.Id, Title = parts.size() > 0 ? parts[0] : att.filename,
                                                              PathOnClient = att.filename, VersionData = EncodingUtil.base64Decode(att.data),IsMajorVersion = false);
                    docToInsert.add(conVI);
                    newfiles.add(parts.size() > 0 ? parts[0] : att.filename);
                    attach = true;    
                }
                
            }
            try{
                if(docToInsert != null && !docToInsert.isEmpty()){
                    insert docToInsert;
                    cdl = Database.query('SELECT ContentDocumentId,ContentDocument.Title, ContentDocument.LastModifiedDate, ContentDocument.CreatedBy.Id, ContentDocument.CreatedBy.Name, ContentDocument.FileExtension, ContentDocument.ContentSize, LinkedEntityId, Visibility , LinkedEntity.Name , LinkedEntity.Type FROM ContentDocumentLink where LinkedEntityId =: caseId and ContentDocument.Title in :newfiles and Visibility = \'InternalUsers\'');
                    for(ContentDocumentLink cd : cdl){
                        cd.Visibility = CON_CSM.S_ALL_USERS;
                    }
                    if(cdl != null && !cdl.isEmpty()){
                        update cdl;
                    }
                    statusR = 'ok';  
                }
            }catch(Exception e){
                messageR = 'Attachment insertion failure.';
                statusR = 'error';
            }
        }
        
        list<CaseComment> commentsToInsert = new list<CaseComment>();
        if(ticketInformation.historyEntries!=null)
        {
            for (WSC_CSM_CSMBISMCaseManager.historyEntry_element he :ticketInformation.historyEntries.historyEntry) {
                if(he.activityinformation != null && he.activityinformation.length() > 0) {
                    CaseComment cc = new CaseComment(ParentId = cs.Id,CommentBody = he.activityinformation, IsPublished = true);
                    commentsToInsert.add(cc);
                }
            }
            try{   
                if(!commentsToInsert.isEmpty()){
                    insert commentsToInsert;
                    statusR = 'ok';
                }
            }catch(Exception e){
                messageR = 'Case Comment insertion failure.';
                statusR = 'error';
            }
            
        }
        WSC_CSM_BISMIncidentMgmt.message_element_confirm response_x = new WSC_CSM_BISMIncidentMgmt.message_element_confirm();
        if(iscaseCreated){
            cs = [Select Id, CaseNumber,ContactId,AccountId,Service_Now_Incident_Number__c From Case where id=:cs.Id limit 1];
            messageR = 'Ticket '+cs.CaseNumber+' has been created with the IQVIA Support Team.'+messageR;
            WSC_CSM_BISMSOAPCallout.insertIntegrationLog(cs.CaseNumber, cs.Id,cs.Service_Now_Incident_Number__c,messageR,statusR,header.transactionId,'createTicket',true,false,attach);
            response_x = getConfirmResponseType(cs.CaseNumber,header.transactionId,'createTicket',cs.Service_Now_Incident_Number__c,statusR,messageR);
        }else{
            WSC_CSM_BISMSOAPCallout.insertIntegrationLog('', '',header.sender.Id,messageR,statusR,header.transactionId,'createTicket',true,false,attach);
            response_x = getConfirmResponseType('',header.transactionId,'createTicket',header.sender.Id,statusR,messageR);
        }
        if(header.sender.Name != 'ROCHESNOW' && !System.isFuture() && !System.isBatch()){
            string json = JSON.serialize(response_x);
            WSC_CSM_BISMSOAPCallout.confirmTicketCSM2BISM(json);
            return null;
        }else{
            return getConfirmResponseType(cs.CaseNumber,header.transactionId,'createTicket',cs.Service_Now_Incident_Number__c,statusR,messageR,header.sender.name);
        }
        
    }
    
    webservice static WSC_CSM_CSMBISMCaseManager.message_element UpdateTicket(WSC_CSM_CSMBISMCaseManager.messageHeaderType header,WSC_CSM_CSMBISMCaseManager.ticketInformationType ticketInformation) {
        String messageR;
        String statusR;
        Case cs;
        boolean transferOwner = false;
        List<Case> csList = null;
        try{
            csList = new SLT_Case().getBISMCaseDetails(header.receiver.Id);
        }catch(Exception e){
            messageR = e.getMessage();
            statusR = 'error';
        }
        if(csList != null && !csList.isEmpty()){
            cs = csList[0];
            String caseId = cs.Id;
            if((cs.Status == CON_CSM.S_NEW || cs.Status == CON_CSM.S_IN_PROGRESS) && header.sender.Name != 'ROCHESNOW' && (ticketInformation.ticketStatus == '6' || ticketInformation.ticketStatus == '7')){
                CaseComment cc = new CaseComment(ParentId = cs.Id,CommentBody = CON_CSM.S_BISM_CC, IsPublished = false);
                insert cc;
                messageR = 'Success';
                statusR = 'ok';
            }else if(cs.Status != CON_CSM.S_CLOSED && (cs.Status == CON_CSM.S_IN_PROGRESS || cs.Status == CON_CSM.S_AWAITING || cs.Status == CON_CSM.S_RESOLVED_WITH_C)){
                if(ticketInformation.shortdescription != null){
                    cs.Subject = ticketInformation.shortdescription;
                }
                if(header.sender.Name != 'ROCHESNOW' && ticketInformation.priority != null && ticketInformation.priority != 'undefined'){
                    cs.Priority = 'Priority ' + ticketInformation.priority;
                }
                if(cs.External_System_Type__c == CON_CSM.S_ROCHE_SN && cs.Status != CON_CSM.S_IN_PROGRESS && ticketInformation.ticketStatus == '2'){
                    cs.Status = CON_CSM.S_AWAITING;
                    cs.SubStatus__c = CON_CSM.S_SS_CI;
                }
                String Queue = cs.InitialQueue__c;
                String assignGroup = ticketInformation.assignGroup;
                if(header.sender.Name != 'ROCHESNOW'){
                    List<ServiceNow_Group__c>  sngList = Database.query('select Id,Name,SystemType__c,Group_ID__c from ServiceNow_Group__c where Group_ID__c = :assignGroup and Queue__c = :Queue LIMIT 1');
                    for(ServiceNow_Group__c sg : sngList){
                        if(cs.Status != CON_CSM.S_IN_PROGRESS && cs.ServiceNowSystemType__c != sg.SystemType__c && sg.SystemType__c == CON_CSM.S_IQVIA){
                            cs.Status = CON_CSM.S_IN_PROGRESS;
                            cs.SubStatus__c = CON_CSM.S_RESPONSE_RECEIVED;
                            transferOwner = true;
                        }else if(cs.ServiceNowSystemType__c != sg.SystemType__c && sg.SystemType__c == CON_CSM.S_BISM){
                            cs.Status = CON_CSM.S_AWAITING;
                            cs.SubStatus__c = CON_CSM.S_SS_CI;
                            transferOwner = true;
                        }
                        cs.ServiceNowSystemType__c = sg.SystemType__c;
                        cs.ServiceNow_Group__c = sg.Id;
                    }

                    if(ticketInformation.priority != null && CON_CSM.PL_TECHNO_UI_PRIORITY.get(ticketInformation.priority+'~'+ticketInformation.urgency +'~'+ticketInformation.impact) != null){
                        List<String> pList = CON_CSM.PL_TECHNO_UI_PRIORITY.get(ticketInformation.priority+'~'+ticketInformation.urgency +'~'+ticketInformation.impact).split('~');
                        if(pList != null && !pList.isEmpty()){
                            cs.Urgency__c = pList[1];
                            cs.Techno_Impact__c = pList[2];
                        }
                    }else if(ticketInformation.impact != null && ticketInformation.urgency != null && CON_CSM.PL_R_I_URGENCY.containsKey(ticketInformation.urgency) && CON_CSM.PL_R_I_IMPACT.containsKey(ticketInformation.impact)){
                        cs.Urgency__c = CON_CSM.PL_R_I_URGENCY.get(ticketInformation.urgency);
                        cs.Techno_Impact__c = CON_CSM.PL_R_I_IMPACT.get(ticketInformation.impact);
                        cs.Priority = CON_CSM.PL_TECHNO_PRIORITY.get(cs.Urgency__c+'~'+cs.Techno_Impact__c);
                    }else if(ticketInformation.priority != null && CON_CSM.PL_TECHNO_UI_CASE_PRIORITY.get(cs.Priority) != null){
                        List<String> pList = CON_CSM.PL_TECHNO_UI_CASE_PRIORITY.get(cs.Priority).split('~');
                        if(pList != null && !pList.isEmpty()){
                            cs.Urgency__c = pList[0];
                            cs.Techno_Impact__c = pList[1];
                        }
                    }
                }
                list<CaseComment> commentsToInsert = new list<CaseComment>();
                if(ticketInformation.historyEntries != null){
                    Integer size = ticketInformation.historyEntries.historyEntry.size();
                    for(Integer i = 0; i < ticketInformation.historyEntries.historyEntry.size(); i++){
                        WSC_CSM_CSMBISMCaseManager.historyEntry_element he = ticketInformation.historyEntries.historyEntry[i];
                        if(he.orderNumber == ticketInformation.historyEntries.historyEntry.size()){
                            CaseComment cc = new CaseComment(ParentId = cs.Id,CommentBody = he.activityinformation, IsPublished = true);
                            commentsToInsert.add(cc);
                            break;
                        }
                        
                    }
                    
                    if(!commentsToInsert.isEmpty()){
                        insert commentsToInsert;    
                    }
                }
                
                try{
                    update cs;
                    messageR = 'Success';
                    statusR = 'ok';
                }catch(Exception e){
                    messageR = 'Case Comment insertion failure';
                    statusR = 'error';
                }
                
            }else if((cs.Status == CON_CSM.S_CLOSED || cs.Status == CON_CSM.S_CASE_ABANDONED)){
                messageR = CON_CSM.S_BISM_PUB_CC;
                messageR = messageR.replace('closed', cs.Status);
                statusR = 'ok';

                if(header.sender.Name != 'ROCHESNOW'){
                    CaseComment cc = new CaseComment(ParentId = cs.Id,CommentBody = messageR, IsPublished = true);
				    insert cc;
                }
            }
            list<ContentVersion> docToInsert = new list<ContentVersion>();
            if(ticketInformation.attachments != null){
                List<ContentDocumentLink> cdl = new List<ContentDocumentLink>();
                Set<String> fileList = new Set<String>();
                List<String> newfiles = new List<String>();
                cdl = Database.query('SELECT ContentDocumentId,ContentDocument.Title, ContentDocument.LastModifiedDate, ContentDocument.CreatedBy.Id, ContentDocument.CreatedBy.Name, ContentDocument.FileExtension, ContentDocument.ContentSize, LinkedEntityId, Visibility , LinkedEntity.Name , LinkedEntity.Type FROM ContentDocumentLink where LinkedEntityId =: caseId and Visibility = \'AllUsers\'');
                for(ContentDocumentLink cd : cdl){
                    fileList.add(cd.ContentDocument.Title);
                    fileList.add(cd.ContentDocument.Title +'.'+ cd.ContentDocument.FileExtension);
                }
                for(WSC_CSM_CSMBISMCaseManager.attachment_element att : ticketInformation.attachments.attachment) {
                    if(att.filename != null && att.filename.length() > 0){
                        List<String> parts = new List<String>();
                        if (att.filename != null)
                            parts = att.filename.split('\\.');
                        if(!((fileList.contains(att.filename) || (parts.size() > 0 && fileList.contains(parts[0]))))){
                            ContentVersion conVI = new ContentVersion(FirstPublishLocationId = cs.Id,Title = parts.size() > 0 ? parts[0] : att.filename, PathOnClient = att.filename,VersionData = EncodingUtil.base64Decode(att.data),IsMajorVersion = false);
                            docToInsert.add(conVI);
                            newfiles.add(parts.size() > 0 ? parts[0] : att.filename);
                        }    
                    }
                }
                if(!docToInsert.isEmpty()){
                    insert docToInsert;    
                }
                if(!newfiles.isEmpty()){
                    cdl.clear();
                    cdl = Database.query('SELECT ContentDocumentId,ContentDocument.Title, ContentDocument.LastModifiedDate, ContentDocument.CreatedBy.Id, ContentDocument.CreatedBy.Name, ContentDocument.FileExtension, ContentDocument.ContentSize, LinkedEntityId, Visibility , LinkedEntity.Name , LinkedEntity.Type FROM ContentDocumentLink where LinkedEntityId =: caseId and ContentDocument.Title in :newfiles and Visibility = \'InternalUsers\'');
                    for(ContentDocumentLink cd : cdl){
                        cd.Visibility = CON_CSM.S_ALL_USERS;
                    }
                    if(cdl != null && !cdl.isEmpty()){
                        update cdl;
                    }    
                }
            }
        }else{
            messageR = 'Not find the ticket in CSM';
            statusR = 'error';
        }
        
        WSC_CSM_BISMSOAPCallout.insertIntegrationLog(header.receiver.Id, cs !=null ? cs.Id : null ,header.sender.Id,messageR,statusR,header.transactionId,'updateTicket',true,transferOwner,false);
        if(header.sender.Name != 'ROCHESNOW' && !System.isFuture() && !System.isBatch()){
            WSC_CSM_BISMIncidentMgmt.message_element_confirm response_x = new WSC_CSM_BISMIncidentMgmt.message_element_confirm();
            response_x = getConfirmResponseType(header.receiver.Id,header.transactionId,'updateTicket',header.sender.Id,statusR,messageR);
            string json = JSON.serialize(response_x);
            WSC_CSM_BISMSOAPCallout.confirmTicketCSM2BISM(json);
            return null;
        }else{
            return getConfirmResponseType(header.receiver.Id,header.transactionId,'updateTicket',header.sender.Id,statusR,messageR,header.sender.name);
        }
        
        
    }
    
    webservice static WSC_CSM_CSMBISMCaseManager.message_element ResolveTicket(WSC_CSM_CSMBISMCaseManager.messageHeaderType header,WSC_CSM_CSMBISMCaseManager.resolveTicketType ticketInformation) {
        
        String messageR;
        String statusR;
        boolean checkClosed = false,checkRocheRes = false;
        Case cs = null;
        CaseComment cc = null;
        List<Case> csList = null;
        csList = new SLT_Case().getBISMCaseDetails(header.receiver.Id);
        if(csList != null && !csList.isEmpty()){
            cs = csList[0];
            if(CON_CSM.S_CLOSED != cs.Status){
                cs.ResolvedDatetime__c = System.now();
                if(cs.External_System_Type__c == 'ROCHESNOW'){
                    Datetime gmtDate = System.now();
                    if(ticketInformation.solution != null && cs.Resolution__c == null){
                        //String strConvertedDate = gmtDate.format('dd/MM/yyyy HH:mm:ss ZZZ', 'Europe/Paris');
                        cs.Resolution__c = '--- RocheSN Update on '+ gmtDate.format('dd/MM/yyyy HH:mm:ss ZZZ', 'Europe/Paris') +'--- \r\n'
                                           + ticketInformation.solution + '\r\n--- End of RocheSN Update ----\r\n';
                    }else if(ticketInformation.solution != null && cs.Resolution__c != null){
                        cs.Resolution__c = cs.Resolution__c + '\r\n--- RocheSN Update on '+ gmtDate.format('dd/MM/yyyy HH:mm:ss ZZZ', 'Europe/Paris') +'--- \r\n'
                                           + ticketInformation.solution + '\r\n--- End of RocheSN Update ----\r\n';
                    }
                }else if(ticketInformation.solution != null && cs.Resolution__c == null){
                        cs.Resolution__c = ticketInformation.solution;    
                }
                if(cs.RootCause__c == null) cs.RootCause__c = 'Other';
                cs.Root_Cause_Reason__c = 'API User updated';
                if(cs.ServiceNowSystemType__c == CON_CSM.S_BISM){
                    if(cs.RootCause__c != null && cs.Resolution__c != null && (cs.Status == CON_CSM.S_RESOLVED_WITH_C || cs.Status == CON_CSM.S_AWAITING || cs.Status == CON_CSM.S_SP_S)){
                        cs.Status = CON_CSM.S_CLOSED;
                        checkClosed = true;
                    }else if(!(cs.RootCause__c != null && cs.Resolution__c != null)){ 
                        if((cs.Status == CON_CSM.S_RESOLVED_WITH_C || (cs.Status == CON_CSM.S_AWAITING && cs.SubStatus__c == CON_CSM.S_SS_CI) || cs.Status == CON_CSM.S_SP_S)){
                            cs.Status = CON_CSM.S_IN_PROGRESS;
                            checkClosed = true;
                            if(cs.SubStatus__c == CON_CSM.S_SS_CI){
                              cs.SubStatus__c = CON_CSM.S_RESPONSE_RECEIVED;  
                            }else if(cs.SubStatus__c != null){
                                cs.SubStatus__c = null;
                            } 
                            
                        }
                    }
                }else if(cs.External_System_Type__c == 'ROCHESNOW'){
                    if(ticketInformation.resolveStatus != null){
                        cs.Status = ticketInformation.resolveStatus;    
                    }else{
                        cs.Status = CON_CSM.S_RESOLVED_WITH_C; 
                    }
                    checkRocheRes = true;
                }
                try{
                    if(checkClosed || checkRocheRes){
                        update cs;
                    }
                    messageR = 'Success';
                    statusR = 'ok';
                }catch(Exception e){
                    messageR = 'Case update failure';
                    statusR = 'error';
                }
                try{
                    if(checkClosed && statusR == 'error') {
                        cs.Status = CON_CSM.S_IN_PROGRESS;
                        update cs;
                    }
                    messageR = 'Success';
                    statusR = 'ok';
                }catch(Exception e){
                    
                }
                if(header.sender.Name != 'ROCHESNOW' && (cs.Status == CON_CSM.S_CLOSED || cs.Status == CON_CSM.S_CASE_ABANDONED)){
                    cc = new CaseComment(ParentId = cs.Id,CommentBody = ((cs.Status == CON_CSM.S_CLOSED || cs.Status == CON_CSM.S_CASE_ABANDONED) ? CON_CSM.S_BISM_CLCC : CON_CSM.S_BISM_CC), IsPublished = false);
                    insert cc;
                }
            }else if((cs.Status == CON_CSM.S_CLOSED || cs.Status == CON_CSM.S_CASE_ABANDONED)){
                messageR = CON_CSM.S_BISM_PUB_CC;
                messageR = messageR.replace('closed', cs.Status);
                statusR = 'ok';
                if(header.sender.Name != 'ROCHESNOW'){
                    cc = new CaseComment(ParentId = cs.Id,CommentBody = messageR, IsPublished = true);
                    insert cc;
                }
            }
            
        }else{
            messageR = 'Not find the ticket in CSM';
            statusR = 'error';
        }
        WSC_CSM_BISMSOAPCallout.insertIntegrationLog(header.receiver.Id, cs !=null ? cs.Id : null ,header.sender.Id,messageR,statusR,header.transactionId,'resolveTicket',true,false,false);
        if(header.sender.Name != 'ROCHESNOW' && !System.isFuture() && !System.isBatch()){
            WSC_CSM_BISMIncidentMgmt.message_element_confirm response_x = new WSC_CSM_BISMIncidentMgmt.message_element_confirm();
            response_x = getConfirmResponseType(header.receiver.Id,header.transactionId,'resolveTicket',header.sender.Id,statusR,messageR);
            string json = JSON.serialize(response_x);
            WSC_CSM_BISMSOAPCallout.confirmTicketCSM2BISM(json);
            return null;
        }else{
            return getConfirmResponseType(header.receiver.Id,header.transactionId,'resolveTicket',header.sender.Id,statusR,messageR,header.sender.name);
        }
        
    }
    
    webservice static WSC_CSM_CSMBISMCaseManager.message_element CloseTicket(WSC_CSM_CSMBISMCaseManager.messageHeaderType header,WSC_CSM_CSMBISMCaseManager.closeTicketType ticketInformation) {
        String messageR;
        String statusR;
        boolean checkClosed = false;
        Case cs;
        List<Case> csList = null;
        csList = new SLT_Case().getBISMCaseDetails(header.receiver.Id);
        String comment = null;
        if(csList != null && !csList.isEmpty()){
            cs = csList[0];
            CaseComment cc = null;
            if(cs.ServiceNowSystemType__c == CON_CSM.S_BISM){
                if(cs.RootCause__c != null && cs.Resolution__c != null && (cs.Status == CON_CSM.S_IN_PROGRESS || cs.Status == CON_CSM.S_RESOLVED_WITH_C || cs.Status == CON_CSM.S_AWAITING || cs.Status == CON_CSM.S_SP_S)){
                    cs.Status = CON_CSM.S_CLOSED;
                    checkClosed = true;
                    //cc = new CaseComment(ParentId = cs.Id,CommentBody = CON_CSM.S_BISM_CLCC, IsPublished = false);
                }else if(!(cs.RootCause__c != null && cs.Resolution__c != null)){ 
                    if((cs.Status == CON_CSM.S_RESOLVED_WITH_C || (cs.Status == CON_CSM.S_AWAITING && cs.SubStatus__c == CON_CSM.S_SS_CI) || cs.Status == CON_CSM.S_SP_S)){
                        cs.Status = CON_CSM.S_IN_PROGRESS;
                        checkClosed = true;
                        if(cs.SubStatus__c == CON_CSM.S_SS_CI){
                            cs.SubStatus__c = CON_CSM.S_RESPONSE_RECEIVED;  
                        }else if(cs.SubStatus__c != null){
                            cs.SubStatus__c = null;
                        }
                        
                    }
                }   
            }
            
            
            try{
                if(checkClosed) {
                    update cs;
                }
                messageR = 'Success';
                statusR = 'ok';
            }catch(Exception e){
                messageR = 'Case update failure';
                statusR = 'error';
            }
            try{
                if(statusR == 'error') {
                    cs.Status = CON_CSM.S_IN_PROGRESS;
                    update cs;
                }
                messageR = 'Success';
                statusR = 'ok';
            }catch(Exception e){
                
            }
            if(header.sender.Name != 'ROCHESNOW'){
                cc = new CaseComment(ParentId = cs.Id,CommentBody = ((cs.Status == CON_CSM.S_CLOSED || cs.Status == CON_CSM.S_CASE_ABANDONED) ? CON_CSM.S_BISM_CLCC : CON_CSM.S_BISM_CC), IsPublished = false);
                insert cc;
            }
        }else{
            messageR = 'Not find the ticket in CSM';
            statusR = 'error';
        }
        WSC_CSM_BISMSOAPCallout.insertIntegrationLog(header.receiver.Id, cs !=null ? cs.Id : null ,header.sender.Id,messageR,statusR,header.transactionId,'closeTicket',true,false,false);
        if(header.sender.Name != 'ROCHESNOW' && !System.isFuture() && !System.isBatch()){
            WSC_CSM_BISMIncidentMgmt.message_element_confirm response_x = new WSC_CSM_BISMIncidentMgmt.message_element_confirm();
            response_x = getConfirmResponseType(header.receiver.Id,header.transactionId,'closeTicket',header.sender.Id,statusR,messageR);
            string json = JSON.serialize(response_x);
            WSC_CSM_BISMSOAPCallout.confirmTicketCSM2BISM(json);
            return null;
        }else{
            return getConfirmResponseType(header.receiver.Id,header.transactionId,'closeTicket',header.sender.Id,statusR,messageR,header.sender.name);    
        }
        
    }
        
    webservice static WSC_CSM_CSMBISMCaseManager.message_element ActivityUpdate(WSC_CSM_CSMBISMCaseManager.messageHeaderType header,WSC_CSM_CSMBISMCaseManager.activityUpdateType ticketInformation) {
        String messageR;
        String statusR;
        Case cs;
        List<Case> csList = new SLT_Case().getBISMCaseDetails(header.receiver.Id);
        if(csList != null && !csList.isEmpty()){
            cs = csList[0];
            list<ContentVersion> docToInsert = new list<ContentVersion>();
            if(ticketInformation.attachments != null){
                for(WSC_CSM_CSMBISMCaseManager.attachment_element att : ticketInformation.attachments.attachment) {
                    if(att.filename != null && att.filename.length() > 0){
                        List<String> parts = new List<String>();
                        if (att.filename != null)
                            parts = att.filename.split('\\.');
                        ContentVersion conVI = new ContentVersion(FirstPublishLocationId = cs.Id, Title = parts.size() > 0 ? parts[0] : att.filename,PathOnClient = att.filename,VersionData = EncodingUtil.base64Decode(att.data),IsMajorVersion = false);
                        docToInsert.add(conVI);    
                    }
                    
                }
                try{
                    insert docToInsert;
                    messageR = 'Success';
                    statusR = 'ok';
                }catch(Exception e){
                    messageR = 'Attachment insertion failure';
                    statusR = 'error';
                }
            }
            list<CaseComment> commentsToInsert = new list<CaseComment>();
            if(ticketInformation.historyEntry != null && ticketInformation.historyEntry.activityinformation != null && ticketInformation.historyEntry.activityinformation.length() > 0){
                WSC_CSM_CSMBISMCaseManager.historyEntry_element he = ticketInformation.historyEntry;
                CaseComment cc = new CaseComment(ParentId = cs.Id,CommentBody = he.activityinformation, IsPublished = true);
                commentsToInsert.add(cc);
                try{
                    insert commentsToInsert;
                    messageR = 'Success';
                    statusR = 'ok';
                }catch(Exception e){
                    messageR = 'Case Comment insertion failure';
                    statusR = 'error';
                }
            }
        }else{
            messageR = 'Not find the ticket in CSM';
            statusR = 'error';
        }
        WSC_CSM_BISMSOAPCallout.insertIntegrationLog(header.receiver.Id, cs !=null ? cs.Id : null ,header.sender.Id,messageR,statusR,header.transactionId,'activityUpdate',true,false,false);
        if(header.sender.Name != 'ROCHESNOW' && !System.isFuture() && !System.isBatch()){
            WSC_CSM_BISMIncidentMgmt.message_element_confirm response_x = new WSC_CSM_BISMIncidentMgmt.message_element_confirm();
            response_x = getConfirmResponseType(header.receiver.Id,header.transactionId,'activityUpdate',header.sender.Id,statusR,messageR);
            string json = JSON.serialize(response_x);
            WSC_CSM_BISMSOAPCallout.confirmTicketCSM2BISM(json);
            return null;
        }else{
            return getConfirmResponseType(header.receiver.Id,header.transactionId,'activityUpdate',header.sender.Id,statusR,messageR,header.sender.name);
        }
        
    }
    
    static WSC_CSM_BISMIncidentMgmt.message_element_confirm getConfirmResponseType(String caseNumber,String transactionId,String type_x,String snId,String status,String message){
        WSC_CSM_BISMIncidentMgmt.message_element_confirm response_x = new WSC_CSM_BISMIncidentMgmt.message_element_confirm();
        WSC_CSM_BISMIncidentMgmt.messageHeaderType headerR = new WSC_CSM_BISMIncidentMgmt.messageHeaderType();
        WSC_CSM_BISMIncidentMgmt.systemAddressType sender = new WSC_CSM_BISMIncidentMgmt.systemAddressType();
        WSC_CSM_BISMIncidentMgmt.systemAddressType receiver = new WSC_CSM_BISMIncidentMgmt.systemAddressType();
        WSC_CSM_BISMIncidentMgmt.responseType response = new WSC_CSM_BISMIncidentMgmt.responseType();
        sender.id = caseNumber;
        sender.name = 'IQVIA';
        headerR.sender = sender;
        receiver.id = snId;
        receiver.name = 'BISNOW';
        headerR.receiver = receiver;
        headerR.transactionId = transactionId;
        response_x.header = headerR;
        response.type_x = type_x;
        response.ownershipTransferred = false;
        response.status = status; // ok or error
        response.message = message;
        response_x.response = response;
        return response_x;
    }
    
    public static WSC_CSM_CSMBISMCaseManager.message_element getConfirmResponseType(String caseNumber,String transactionId,String type_x,String snId,String status,String message,String name){
        WSC_CSM_CSMBISMCaseManager.message_element response_x = new WSC_CSM_CSMBISMCaseManager.message_element();
        WSC_CSM_CSMBISMCaseManager.messageHeaderType headerR = new WSC_CSM_CSMBISMCaseManager.messageHeaderType();
        WSC_CSM_CSMBISMCaseManager.systemAddressType sender = new WSC_CSM_CSMBISMCaseManager.systemAddressType();
        WSC_CSM_CSMBISMCaseManager.systemAddressType receiver = new WSC_CSM_CSMBISMCaseManager.systemAddressType();
        WSC_CSM_CSMBISMCaseManager.responseType response = new WSC_CSM_CSMBISMCaseManager.responseType();
        sender.id = caseNumber;
        sender.name = 'IQVIA';
        headerR.sender = sender;
        receiver.id = snId;
        receiver.name = name;
        headerR.receiver = receiver;
        headerR.transactionId = transactionId;
        response_x.header = headerR;
        response.type_x = type_x;
        response.ownershipTransferred = false;
        response.status = status; // ok or error
        response.message = message;
        response_x.response = response;
        return response_x;
    }
}