public class WSC_CSM_ROCHERestCallout {

    public class message {
        public header_element header;
        public content_element content;
        public List<attachment_element> attachment;
    }
    public class header_element {
        public String transactionid;
        public String sourcesystemid;
        public String targetsystemid;
        public header_element(){
            
        }
        public header_element(String sourcesystemid,String targetsystemid){
            this.sourcesystemid = sourcesystemid;
            this.targetsystemid = targetsystemid;
        }
        
    }
    
    public class content_element {
        public String number_x;
        public String caller_id;
        public String category;
        public String subcategory;
        public String u_affected_user;
        public String business_service;
        public String ci_name;
        public String ci_sysid;
        public String impact;
        public String urgency;
        public String assignment_group;
        public String assigned_to;
        public String short_description;
        public String work_notes;
        public String comments;
        public String state;
        public String close_code;
        public String close_notes;
    }
    
    public class attachment_element {
        public String file_name;
        public String mime_type;
        public String base64string;
    }
    
    public class result_element {
        public String number_x;
        public String response_code;
        public String response_message;
    }
    
    public class response_element {
        public result_element result;
    }
    
    @future (callout = true)
    public static void updateIncident(String jsonString, String assign,String current){
        Set<String> sngroup = new Set<String>{assign,current};
        boolean ownership = false;
        message message = new message();
        header_element header = new header_element('IQVIA','SNOW');
        content_element content = new content_element();
        Case c = (Case)JSON.deserialize(jsonString, Case.class);
        CSM_ExternalClient_info__c cc = CSM_ExternalClient_info__c.getValues(c.External_System_Type__c);
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        if(cc.Client_Certificate__c != null) req.setClientCertificateName (cc.Client_Certificate__c);
        req.setHeader(CON_CSM_OneKey.S_CONTENT_TYPE, CON_CSM_OneKey.S_APPLICATION_JSON);
        req.setMethod(CON_CSM_OneKey.S_POST);
        req.setHeader('Accept', '*/*');
        req.setEndpoint(cc.Client_Url__c+'/incident/updateIncidentMethod');
        req.setHeader('client_id', cc.client_id__c);
        req.setHeader('client_secret', cc.client_secret__c);
        Blob beforeblob = Blob.valueOf(cc.UserName__c+':'+cc.Password__c);
        req.setHeader(CON_CSM_OneKey.S_AUTHORIZATION, CON_CSM_OneKey.S_BASIC+EncodingUtil.base64Encode(beforeblob));
        System.debug('Impact : '+CON_CSM.PL_TECHNO_URGENCY.get(c.Techno_Impact__c));
        System.debug('Urgency__c : '+CON_CSM.PL_TECHNO_URGENCY.get(c.Urgency__c));
        if(CON_CSM.PL_TECHNO_URGENCY.get(c.Urgency__c) != null && CON_CSM.PL_TECHNO_IMPACT.get(c.Techno_Impact__c) != null){
            content.impact = CON_CSM.PL_TECHNO_IMPACT.get(c.Techno_Impact__c); //<!-- 2:low | 2:medium | 1:high -->
            content.urgency = CON_CSM.PL_TECHNO_URGENCY.get(c.Urgency__c); // <!-- 3:low | 2:medium | 1:high -->    
        }
        content.comments = 'Updated from IQVIA';
        String Queue = c.InitialQueue__c;
        List<ServiceNow_Group__c>  sngList = Database.query('select Id,Name,SystemType__c,Group_ID__c from ServiceNow_Group__c where SystemType__c in :sngroup and Queue__c = :Queue');
        for(ServiceNow_Group__c sg : sngList){
            if(sg.SystemType__c == assign){
                content.assignment_group = sg.Group_ID__c;
            }
        }
        if(current != assign){
            ownership = true;
            if(assign == CON_CSM.S_ROCHE_SN){
                content.state = '2';
            }else{
                content.state = '3';
            }
        }
        try { 
            string currentdate = System.now().formatGmt('YYYYMMddhhmmss') + c.CaseNumber;
            header.transactionid = currentdate;
            content.number_x = c.Service_Now_Incident_Number__c;
            message.header = header;
            message.content = content;
            req.setBody(JSON.serialize(message,true).remove('_x'));
            System.debug('message JSON : '+JSON.serialize(message,true).remove('_x'));
            // Call the Rest api
            HttpResponse res = h.send(req);
            response_element re = (response_element)JSON.deserialize(res.getBody(), response_element.class);
            System.debug('result : '+ re);
            WSC_CSM_BISMSOAPCallout.insertIntegrationLog(c.CaseNumber, c.Id,c.Service_Now_Incident_Number__c,re.result.response_message,re.result.response_code,currentdate,'updateIncident',false,false,true,'ROCHESNOW');
            
            
        } catch ( CalloutException ce) { 
            System.debug('Exce : '+ce.getCause());
            System.debug('Stack'+ ce.getStackTraceString());
            
        } catch ( Exception e) { 
            // Standard Exception Handling 
        }
        
    }
    
    @future (callout = true)
    public static void resolveIncident(String jCase){
     
        Case c = (Case)JSON.deserialize(jCase, Case.class);
        message message = new message();
        header_element header = new header_element('IQVIA','SNOW');
        content_element content = new content_element();
        CSM_ExternalClient_info__c cc = CSM_ExternalClient_info__c.getValues(c.External_System_Type__c);
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        if(cc.Client_Certificate__c != null) req.setClientCertificateName (cc.Client_Certificate__c);
        req.setHeader(CON_CSM_OneKey.S_CONTENT_TYPE, CON_CSM_OneKey.S_APPLICATION_JSON);
        req.setMethod(CON_CSM_OneKey.S_POST);
        req.setHeader('Accept', '*/*');
        req.setEndpoint(cc.Client_Url__c+'/incident/resolveIncidentMethod');
        req.setHeader('client_id', cc.client_id__c);
        req.setHeader('client_secret', cc.client_secret__c);
        Blob beforeblob = Blob.valueOf(cc.UserName__c+':'+cc.Password__c);
        req.setHeader(CON_CSM_OneKey.S_AUTHORIZATION, CON_CSM_OneKey.S_BASIC+EncodingUtil.base64Encode(beforeblob));
        try { 
            string currentdate = System.now().formatGmt('YYYYMMddhhmmss') + c.CaseNumber;
            header.transactionid = currentdate;
            content.number_x = c.Service_Now_Incident_Number__c;
            content.state = '6';
            content.close_code = 'Solved (Permanently)';
            if(c.Resolution__c != null){
                content.close_notes = c.Resolution__c;
            }else{
                content.close_notes = 'Solved (Permanently)';
            }
            content.comments = 'Ticket Resolved from IQVIA';
            message.header = header;
            message.content = content;
            System.debug('message JSON : '+JSON.serialize(message,true).remove('_x'));
            req.setBody(JSON.serialize(message,true).remove('_x'));
            HttpResponse res = h.send(req);
            response_element re = (response_element)JSON.deserialize(res.getBody(), response_element.class);
            System.debug('result : '+ re);
            WSC_CSM_BISMSOAPCallout.insertIntegrationLog(c.CaseNumber, c.Id,c.Service_Now_Incident_Number__c,re.result.response_message,re.result.response_code,currentdate,'resolveIncident',false,false,true,'ROCHESNOW');
        } catch ( CalloutException ce) { 
            System.debug('Exce : '+ce.getCause());
            System.debug('Stack'+ ce.getStackTraceString());
            
        } catch ( Exception e) { 
            // Standard Exception Handling 
        }
    }
    
    @future (callout = true)
    public static void addIncidentComment(String JsonString,String jsonComment,String fromUpdate){
        Map<String, Object> caseMap = (Map<String, Object>) JSON.deserialize(JsonString,Map<String, SObject>.class);
        Set<String> caseSet = caseMap.keySet();
        Map<String, Object>  ccMap = null;
        Map<String, Object>  strMap = null;
        CaseComment cc = null;
        String body = null;
        if(fromUpdate == 'CaseComment'){
            ccMap = (Map<String, Object>) JSON.deserialize(jsonComment,Map<String, SObject>.class);
        }else if(fromUpdate == 'Email'){
            strMap = (Map<String, String>) JSON.deserialize(jsonComment,Map<String, String>.class);
        }
        message message = new message();
        header_element header = new header_element('IQVIA','SNOW');
        content_element content = new content_element();
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        for(String i : caseSet){
            Case c = (Case)caseMap.get(i);
            if(fromUpdate == 'CaseComment'){
                cc = (CaseComment)ccMap.get(i);
                body = cc.CommentBody;
            }else if(fromUpdate == 'Email'){
                body = (String)strMap.get(i);
                if(body != null) body = body.stripHtmlTags();
            }
            CSM_ExternalClient_info__c ecc = CSM_ExternalClient_info__c.getValues(c.External_System_Type__c);
            
            try {
                if(ecc.Client_Certificate__c != null) req.setClientCertificateName (ecc.Client_Certificate__c);
                req.setHeader(CON_CSM_OneKey.S_CONTENT_TYPE, CON_CSM_OneKey.S_APPLICATION_JSON);
                req.setMethod(CON_CSM_OneKey.S_POST);
                req.setHeader('Accept', '*/*');
                req.setEndpoint(ecc.Client_Url__c+'/incident/updateIncidentMethod');
                req.setHeader('client_id', ecc.client_id__c);
                req.setHeader('client_secret', ecc.client_secret__c);
                Blob beforeblob = Blob.valueOf(ecc.UserName__c+':'+ecc.Password__c);
                req.setHeader(CON_CSM_OneKey.S_AUTHORIZATION, CON_CSM_OneKey.S_BASIC+EncodingUtil.base64Encode(beforeblob));
                string currentdate = System.now().formatGmt('YYYYMMddhhmmss') + c.CaseNumber;
                //header.transactionid = currentdate;
                content.number_x = c.Service_Now_Incident_Number__c;
                content.work_notes = body;
                message.header = header;
                message.content = content;
                System.debug('message JSON : '+JSON.serialize(message,true).remove('_x'));
                req.setBody(JSON.serialize(message,true).remove('_x'));
                
                System.debug('req : '+ req);
                // Call the Rest api
                HttpResponse res = h.send(req);
                response_element re = (response_element)JSON.deserialize(res.getBody(), response_element.class);
                System.debug('result : '+ re);
                WSC_CSM_BISMSOAPCallout.insertIntegrationLog(c.CaseNumber, c.Id,c.Service_Now_Incident_Number__c,re.result.response_message ,re.result.response_code ,currentdate,'addIncidentComment',false,false,true,'ROCHESNOW');
                
            } catch ( CalloutException ce) { 
                System.debug('Exce : '+ce.getCause());
                System.debug('Stack'+ ce.getStackTraceString());
                
            } catch ( Exception e) { 
                // Standard Exception Handling 
            }    
        }
    }
    
    @future (callout = true)
    public static void addIncidentAttachment(String jsonString){
        Map<String, Object> metaCase = (Map<String, Object>) JSON.deserialize(JsonString,Map<String, SObject>.class);
        Set<String> docIdSet = metaCase.keySet();
        List<ContentVersion> cvL = Database.query('SELECT Id, VersionData,CreatedDate,ContentModifiedDate,Title,ContentDocumentId,PathOnClient,ContentSize FROM ContentVersion WHERE ContentDocumentId in :docIdSet');
        message message = new message();
        header_element header = new header_element('IQVIA','SNOW');
        content_element content = new content_element();
        List<attachment_element> attachment = new List<attachment_element>();
        attachment_element att = null;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        for(ContentVersion cv : cvL){
            Case c = (Case)metaCase.get(cv.ContentDocumentId);
            if(cv.ContentSize < 6000001 && metaCase.containsKey(cv.ContentDocumentId)){
                String caseId = c.Id;
                att = new attachment_element();
                att.file_name = cv.PathOnClient;
                att.base64string = EncodingUtil.base64Encode(cv.VersionData);
                att.mime_type = 'text/plain';
                attachment.add(att);    
                CSM_ExternalClient_info__c ecc = CSM_ExternalClient_info__c.getValues(c.External_System_Type__c);
                if(ecc.Client_Certificate__c != null)  req.setClientCertificateName (ecc.Client_Certificate__c);
                req.setHeader(CON_CSM_OneKey.S_CONTENT_TYPE, CON_CSM_OneKey.S_APPLICATION_JSON);
                req.setMethod(CON_CSM_OneKey.S_POST);
                req.setHeader('Accept', '*/*');
                req.setEndpoint(ecc.Client_Url__c+'/incident/addIncidentAttachmentMethod');
                req.setHeader('client_id', ecc.client_id__c);
                req.setHeader('client_secret', ecc.client_secret__c);
                Blob beforeblob = Blob.valueOf(ecc.UserName__c+':'+ecc.Password__c);
                req.setHeader(CON_CSM_OneKey.S_AUTHORIZATION, CON_CSM_OneKey.S_BASIC+EncodingUtil.base64Encode(beforeblob));
                try {
                    string currentdate = System.now().formatGmt('YYYYMMddhhmmss') + c.CaseNumber;
                    header.transactionid = currentdate;
                    content.number_x = c.Service_Now_Incident_Number__c;
                    message.header = header;
                    message.content = content;
                    message.attachment = attachment;
                    req.setBody(JSON.serialize(message,true).remove('_x'));
                    System.debug('message JSON : '+JSON.serialize(message,true).remove('_x'));
                    // Call the Rest api
                    HttpResponse res = h.send(req);
                    WSC_CSM_BISMSOAPCallout.sleep(20000);
                    response_element re = (response_element)JSON.deserialize(res.getBody(), response_element.class);
                    System.debug('result : '+ re);
                    WSC_CSM_BISMSOAPCallout.insertIntegrationLog(c.CaseNumber, c.Id,c.Service_Now_Incident_Number__c,re.result.response_message ,re.result.response_code ,currentdate,'addIncidentAtt',false,false,true,'ROCHESNOW');                    WSC_CSM_BISMSOAPCallout.insertIntegrationLog(c.CaseNumber, c.Id,c.Service_Now_Incident_Number__c,res.getStatus(),res.getStatusCode()+'',currentdate,'addIncidentAtt',false,false,true,'ROCHESNOW');
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
    
}