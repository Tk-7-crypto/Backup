public class WSC_CSM_SNOWGenAICallOut {
    public class GenAIRequest{
        public String u_billing_type;
        public String u_communication;
    }
    
    public class GenAIResponse{ 
        public GenAIResult result;
    }
    public class GenAIGetResponse{ 
        public List<GenAIResult> result;
    }
    public class GenAIResult{
        public String sys_id;
        public String u_content;
        public String u_order;
        public String u_role;
    }
    public static GenAIResponse callSNOWGenAIPost(String chatData,String sysid){
        CSM_ExternalClient_info__c ecc = CSM_ExternalClient_info__c.getValues('InternalSnowGenAI');
        GenAIResponse re = null;
        if(ecc != null){
            GenAIRequest genAIReq = new GenAIRequest();
            genAIReq.u_billing_type = '05a6bb681b87ca10eec5ddb9ec4bcb46';
            genAIReq.u_communication = chatData;
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setHeader('Content-Type', 'application/json;charset=UTF-8');
            req.setHeader('Accept', 'application/json;charset=UTF-8');
            if(sysid != null){
                req.setMethod('PUT');
                req.setEndpoint(ecc.Client_Url__c+'/'+sysid);
            }else{
                req.setMethod('POST');
                req.setEndpoint(ecc.Client_Url__c);
            }
            Blob beforeblob = Blob.valueOf(ecc.UserName__c+':'+ecc.Password__c);
            req.setHeader('Authorization', 'Basic '+EncodingUtil.base64Encode(beforeblob));
            req.setBody(Json.serialize(genAIReq));
            req.setTimeout(120000);
            HttpResponse res = http.send(req);
            if(res != null){
                re = (GenAIResponse)JSON.deserialize(res.getBody(), GenAIResponse.class);
            }
        }
        return re;
    }
    
    public static GenAIGetResponse callSNOWGenAIGet(String sys_id){
        CSM_ExternalClient_info__c ecc = CSM_ExternalClient_info__c.getValues('InternalSnowGenAI');
        GenAIGetResponse re = null;
        if(ecc != null){
            GenAIRequest genAIReq = new GenAIRequest();
            genAIReq.u_billing_type = '05a6bb681b87ca10eec5ddb9ec4bcb46';
            // Case Summarizer : a5910cd2dbfb4610596acf5e13961940
            genAIReq.u_communication = '';
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            //req.setEndpoint('https://quintilestest.service-now.com/api/now/table/u_genai_conversation_log?sysparm_query=u_role%3Dassistant%5Eu_copilot_record%3D'+sys_id+'%5EORDERBYDESCu_order&sysparm_fields=u_content%2Cu_order%2Cu_role&sysparm_limit=10');
            req.setEndpoint(ecc.Q2_Get_URL1__c+sys_id+ecc.Q2_Get_URL2__c);
            req.setHeader('Content-Type', 'application/json;charset=UTF-8');
            req.setHeader('Accept', 'application/json;charset=UTF-8');
            req.setMethod('GET');
            Blob beforeblob = Blob.valueOf(ecc.UserName__c+':'+ecc.Password__c);
            req.setHeader('Authorization', 'Basic '+EncodingUtil.base64Encode(beforeblob));
            req.setTimeout(120000);
            HttpResponse res = http.send(req);
            if(res != null){
                re = (GenAIGetResponse)JSON.deserialize(res.getBody(), GenAIGetResponse.class);
            }
        }
        return re;
    }
    
    public static GenAIResponse callSNOWCaseSummary(String jsonString,String billingType,String sysid){
        CSM_ExternalClient_info__c ecc = CSM_ExternalClient_info__c.getValues('InternalSnowGenAI');
        GenAIResponse re = null;
        if(ecc != null && jsonString !=null && billingType !=null){
            GenAIRequest genAIReq = new GenAIRequest();
            genAIReq.u_billing_type = billingType;//'a5910cd2dbfb4610596acf5e13961940';
            genAIReq.u_communication = jsonString;
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            req.setHeader('Content-Type', 'application/json;charset=UTF-8');
            req.setHeader('Accept', 'application/json;charset=UTF-8');
            if(sysid != null){
                req.setMethod('PUT');
                req.setEndpoint(ecc.Client_Url__c+'/'+sysid);
            }else{
                req.setMethod('POST');
                req.setEndpoint(ecc.Client_Url__c);
            }
            Blob beforeblob = Blob.valueOf(ecc.UserName__c+':'+ecc.Password__c);
            req.setHeader('Authorization', 'Basic '+EncodingUtil.base64Encode(beforeblob));
            req.setBody(Json.serialize(genAIReq));
            req.setTimeout(120000);
            HttpResponse res = http.send(req);
            if(res != null && (res.getStatus() == 'Created' || res.getStatusCode() == 200 || res.getStatusCode() == 201)){
                re = (GenAIResponse)JSON.deserialize(res.getBody(), GenAIResponse.class);
            }else if(res != null && !(res.getStatus() == 'Created' || res.getStatusCode() == 200 || res.getStatusCode() == 201)){
                re = new GenAIResponse();
                GenAIResult result = new GenAIResult();
                result.sys_id = 'Failed';
                result.u_content = 'We are unable to connect to the service, please try again later';
                re.result = result;
            }
        }
        return re;
    }
    
    public static GenAIGetResponse callSNOWSummaryGet(String sys_id){
        CSM_ExternalClient_info__c ecc = CSM_ExternalClient_info__c.getValues('InternalSnowGenAI');
        GenAIGetResponse re = null;
        if(ecc != null){
            //https://quintilestest.service-now.com/api/now/table/u_genai_co_pilot
            Http http = new Http();
            HttpRequest req = new HttpRequest();
            //req.setEndpoint('https://quintilestest.service-now.com/api/now/table/u_genai_conversation_log?sysparm_query=u_role%3Dassistant%5Eu_copilot_record%3D'+sys_id+'%5EORDERBYDESCu_order&sysparm_fields=u_content%2Cu_order%2Cu_role&sysparm_limit=10');
            req.setEndpoint(ecc.Q2_Get_URL1__c+sys_id+ecc.Q2_Get_URL2__c);
            req.setHeader('Content-Type', 'application/json;charset=UTF-8');
            req.setHeader('Accept', 'application/json;charset=UTF-8');
            req.setMethod('GET');
            Blob beforeblob = Blob.valueOf(ecc.UserName__c+':'+ecc.Password__c);
            req.setHeader('Authorization', 'Basic '+EncodingUtil.base64Encode(beforeblob));
            req.setTimeout(120000);
            HttpResponse res = http.send(req);
            if(res != null && (res.getStatus() == 'Ok' || res.getStatusCode() == 200 || res.getStatusCode() == 201)){
                re = (GenAIGetResponse)JSON.deserialize(res.getBody(), GenAIGetResponse.class);
            }else if(res != null && !(res.getStatus() == 'Ok' || res.getStatusCode() == 200 || res.getStatusCode() == 201)){
                re = new GenAIGetResponse();
                List<GenAIResult> resultList = new List<GenAIResult>();
                GenAIResult result = new GenAIResult();
                result.sys_id = 'Failed';
                result.u_content = 'We are unable to connect to the service, please try again later';
                result.u_role = 'Assistant';
                resultList.add(result);
                re.result = resultList;
            }
        }
        return re;
    }
}