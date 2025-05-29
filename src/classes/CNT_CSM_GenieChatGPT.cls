public class CNT_CSM_GenieChatGPT {

    public class GenieChatGPTWrapper{
        public string Mode;
        public string Language;
        public string Product_Name;
        public string Email_Id;
        public string Case_Number;
        public string Subject;
        public string Description;
        public string Account;
        public string Queue;
    }
    
    public class ResolutionResponseWrapper{
        @AuraEnabled
        public string Summary;
        @AuraEnabled
        public List<string> Resolution;
        @AuraEnabled
        public List<string> References;
    }
    
    @AuraEnabled
    public static CSM_Ticket_Genie__c getTicketGeniedata(String recordId){
        Id userId = UserInfo.getUserId();
        List<CSM_Ticket_Genie__c> ticketList = Database.query('Select Id,Case__c,SuggestedResolution__c,FeedBackScore__c,Comments__c from CSM_Ticket_Genie__c where Case__c = :recordId and CreatedById = :userId Order by LastModifiedDate DESC LIMIT 1');
        if(ticketList != null && !ticketList.isEmpty()){
            return ticketList[0];
        }else{
            return null;
        }
    }
    
    
    @AuraEnabled
    public static CSM_Ticket_Genie__c getGenieResolution(Case caseRecord, Boolean genieType, Boolean genieLanguage){
        CSM_Ticket_Genie__c tg = null;
        if(caseRecord != null){
            UserInfo.getUserEmail();
            List<Case> caseList =  new SLT_Case().selectByCaseIdList(new Set<ID>{caseRecord.Id},new Set<String>{'CaseNumber','ProductName__c','Account_Name_Article__c','CurrentQueue__r.Name','Subject','Description'});
            CSM_ExternalClient_info__c ec = CSM_ExternalClient_info__c.getValues('AskGenie');
            if(caseList != null && !caseList.isEmpty() && ec != null && ec.Client_Url__c != null){
                GenieChatGPTWrapper gpt = null;
                for(Case c : caseList){
                    gpt = new GenieChatGPTWrapper();
                    gpt.Mode = genieType ? 'advanced': 'basic';
                    gpt.Language = genieLanguage ? 'nen':'en';
                    gpt.Product_Name = c.ProductName__c;
                    gpt.Email_Id = UserInfo.getUserEmail();
                    gpt.Case_Number = c.CaseNumber;
                    gpt.Subject = c.Subject;
                    gpt.Description = c.Description;
                    gpt.Account = c.Account_Name_Article__c;
                    gpt.Queue = c.CurrentQueue__r.Name;
                }
                String jsonString = JSON.serialize(gpt);
                //String token = '';
                //String urlGet = 'http://test-internal-global-ticketgenie.iqvia.com';
                //String urlPost = 'http://test-internal-global-ticketgenie.iqvia.com/ticketgenie';
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                //req.setHeader('Authorization', 'Basic ' + token);
                req.setHeader('Content-Type', 'application/json');
                req.setHeader('Accept','application/json');
                req.setEndpoint(ec.Client_Url__c);
                req.setMethod(ec.Account_Id__c);
                req.setTimeout(120000); //GPT 4.0 turbo time latency
                req.setBody(jsonString);
                HttpResponse res = h.send(req);
                String response = res.getBody();
                tg = new CSM_Ticket_Genie__c(Case__c = caseRecord.Id, IsAdvanced__c = genieType, IsNativeLanguage__c = genieLanguage,SuggestedResolution__c = response); 
                insert tg;
                String tId = tg.Id;
                tg = Database.query('Select Id,Case__c,SuggestedResolution__c,FeedBackScore__c,Comments__c from CSM_Ticket_Genie__c where Id = : tId LIMIT 1');
            }
        }
        return tg;
    }
    
     @AuraEnabled
    public static CSM_Ticket_Genie__c saveFeedBackdata(CSM_Ticket_Genie__c ticketGenie){
        update ticketGenie;
        return ticketGenie;
    }

}
