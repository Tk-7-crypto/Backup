public class WSC_CSM_OneKeyCaseVerification {
    @future (callout = true)
    public static void checkIfOneKeyISAvailable(List<Id> caseList)  {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        SLT_RecordType sltRecordType = new SLT_RecordType();
        OneKey_Config__c oneKeyConfig = OneKey_Config__c.getOrgDefaults();
        request.setEndpoint(oneKeyConfig.OneKey_ApiName__c+oneKeyConfig.OneKey_ApiCode__c+oneKeyConfig.OneKey_CisCode__c);
        String username = oneKeyConfig.OneKey_UserName__c;
        String password = oneKeyConfig.OneKey_Password__c;
        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = CON_CSM_OneKey.S_BASIC +EncodingUtil.base64Encode(headerValue);
        request.setHeader(CON_CSM_OneKey.S_CONTENT_TYPE,CON_CSM_OneKey.S_APPLICATION_JSON);
        request.setHeader(CON_CSM_OneKey.S_AUTHORIZATION, authorizationHeader);
        request.setMethod(CON_CSM_OneKey.S_POST);
        String oneKeyEId = '"';
        String name = '"';
        SLT_Case sltCase = new SLT_Case();
        List<Case> listOfCase = sltCase.getCaseByIdAndStatus(caseList, CON_CSM_OneKey.S_CLOSED);
        map<STring, Case> mapOfOneKeyId = new Map<String, Case>();
        if(!listOfCase.isEmpty()){
            for(Case newCase : listOfCase) {
                oneKeyEId += newCase.OneKeyID__c + '",';
                name += listOfCase[0].OneKey_FirstName__c+' '+listOfCase[0].OneKey_LastName__c+'",';
                mapOfOneKeyId.put(newCase.OneKeyID__c,newCase);  
            }   
        }
        if(!String.isEmpty(oneKeyEId) && oneKeyEId.length() > 4 && !String.isEmpty(name)) {
            oneKeyEId = oneKeyEId.substring(0, oneKeyEId.length()-1);
            name = name.substring(0, name.length()-1);
            List<Object> parameters = new List<Object> {oneKeyEId.substring(0, 4)};
            String requestPart = String.format(oneKeyConfig.OneKey_Request_2__c, parameters);
            String eidSearchString = oneKeyConfig.OneKey_Request_1__c + oneKeyEId +oneKeyConfig.Exact_Search_Method__c;
            String nameSearchString = oneKeyConfig.OneKey_Request_3__c + name + oneKeyConfig.Phonetic_Search_Method__c;
            String body = eidSearchString + nameSearchString + requestPart;
            request.setBody(body);
        }
        HTTPResponse res = http.send(request);
        OneKeyProcessClass rc = new OneKeyProcessClass();
        List<OneKeyProcessClass> listOfOneKey = new List<OneKeyProcessClass>();
        Set<Case> caseToUpdate = new Set<Case>();
        if(res.getStatusCode() == 200){
            JSONParser parser = JSON.createParser(res.getBody()); 
            while (parser.nextToken() != null) { 
                if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                    while (parser.nextToken() != null) { 
                        if (parser.getCurrentToken() == JSONToken.START_OBJECT) { 
                            rc = (OneKeyProcessClass)parser.readValueAs(OneKeyProcessClass.class);
                            parser.skipChildren();   
                            listOfOneKey.add(rc);
                        }
                    }
                }
            }
            map<String, OneKeyProcessClass> mapOfOneKey = new Map<String, OneKeyProcessClass>();
            if(!listOfOneKey.isEmpty()) {
                for(OneKeyProcessClass oneKey : listOfOneKey) {
                    if(!mapOfOneKey.containsKey(oneKey.individual.individualEid)) {
                        mapOfOneKey.put(oneKey.individual.individualEid, oneKey);
                    }
                }
            }
            listOfOneKey = new List<OneKeyProcessClass>();
            listOfOneKey.addAll(mapOfOneKey.values());
            if(!listOfOneKey.isEmpty() && !mapOfOneKeyId.isEmpty()) {
                for(OneKeyProcessClass oneKey : listOfOneKey) {
                    Case caseRecord = mapOfOneKeyId.get(oneKey.individual.individualEid);
                    caseRecord.OneKey_FirstName__c = oneKey.individual.firstName;
                    caseRecord.OneKey_LastName__c = oneKey.individual.lastName;
                    caseRecord.OneKey_Validation_Error__c = '';
                    caseRecord.Status = CON_CSM_OneKey.S_REQUEST_FOR_APPROVAL;
                    caseToUpdate.add(caseRecord);
                    WSC_CSM_OneKeyCaseVerification.submitForApproval(caseRecord);
                }
                
            } else {
                caseToUpdate = updateCaseWithError(listOfCase);
            }
        } else {
            caseToUpdate = updateCaseWithError(listOfCase);
        }
        if(!caseToUpdate.isEmpty()) {
            List<Case> newListCase = new List<Case>();
            newListCase.addAll(caseToUpdate);
            update  newListCase;
        }
        
    }
    
    public static void submitForApproval(Case newCase)
    {
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setObjectId(newCase.id);
        Approval.ProcessResult result = Approval.process(req1);
        
    }
    
    public static Set<Case> updateCaseWithError(List<Case> listOfCase) {
        Set<Case> setOfCase = new Set<Case>();
        for(Case newCase : listOfCase) {
            newCase.Status = CON_CSM_OneKey.S_ERROR;
            newCase.OneKey_Validation_Error__c = CON_CSM_OneKey.S_ONEKEYID_ERROR;
            setOfCase.add(newCase);
        } 
        return setOfCase;
    }
    
    public class OneKeyProcessClass {
        public String onekeyEid {get;set;}
        public individual individual {get; set;}
    }
    
    public class individual {
        public String individualEid {get; set;}
        public String firstName {get; set;}
        public String lastName{get; set;}
    }
}