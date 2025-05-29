public class DAOH_FeedItem {
    public static void updateOLAonCase(List<FeedItem> newList){
        List<Id> caseIds = new List<Id>();
        Map<Id,Case> JsonCases = new Map<Id,Case>();
        Map<Id,String> jsonEmail = new Map<Id,String>();
        List<Case> caseList = new List<Case>();
        for(FeedItem c : newList) {
            if(c.ParentId != null && String.valueOf(c.ParentId).startsWith('500') && c.Body != null && c.Type == 'TextPost' ){
                caseIds.add(c.ParentId);
                if(c.Visibility == 'AllUsers'){
                    jsonEmail.put(c.ParentId,c.Body);
                }
            }
        }
        if(!caseIds.isEmpty()){
            DAOH_CaseComment.completeOLA(caseIds);
            UTL_CSM_SendMail.updatePostMail(newList,caseIds);
        }
        if(!jsonEmail.isEmpty()){
            caseList = new SLT_Case().selectById(jsonEmail.keySet()); 
            for(Case cs : caseList){
                CSM_ExternalClient_info__c ecc = CSM_ExternalClient_info__c.getValues(cs.External_System_Type__c);
                if(ecc != null && UserInfo.getUserId() != ecc.Profile_Id__c && cs.External_System_Type__c == CON_CSM.S_ROCHE_SN && cs.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && cs.Service_Now_Incident_Number__c != null){
                    JsonCases.put(cs.Id,cs);
                }
            }
            if(!JsonCases.isEmpty() && !jsonEmail.isEmpty() && !System.isBatch() && !System.isFuture()){
                WSC_CSM_ROCHERestCallout.addIncidentComment(Json.serialize(JsonCases),Json.serialize(jsonEmail),'Email');    
            }
            
        }
    }
    public static void updateCaseonAttachment(List<FeedItem> newList){
        List<Id> caseIds = new List<Id>();
        for(FeedItem c : newList) {
            if(c.ParentId != null && String.valueOf(c.ParentId).startsWith('500') && (c.Type == 'TextPost' || c.Type == 'ContentPost') ){
                caseIds.add(c.ParentId);
            }
        }
        if(!caseIds.isEmpty()){
            DAOH_Case.updateCaseLastModifiedDateOnPostInsert(caseIds);
        }
    }
}