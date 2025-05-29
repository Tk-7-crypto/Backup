public class DAOH_ContentVersion {

    public static void callOutContentVersiontoBISMSN(List<ContentVersion> newList){
        Map<Id, Case> cvCaseMap = new Map<Id, Case>();
        Map<Id, Case> caseMap = new Map<Id, Case>();
        Set<Id> caseIds = new Set<Id>();
        Set<Id> conDocIds = new Set<Id>();
        Map<Id,String> conDocVis = new Map<Id,String>();
        List<Case> caseList = new List<Case>();
        for(ContentVersion cv : newList){
            if(cv.FirstPublishLocationId != null && String.valueOf(cv.FirstPublishLocationId).startsWith('500')){
                caseIds.add(cv.FirstPublishLocationId);
                conDocIds.add(cv.ContentDocumentId);
            }
        }
        
        if(!caseIds.isEmpty()){
            String strExtType = null;
            caseList = new SLT_Case().selectById(caseIds);
            for(Case c : caseList){
                if(c.RecordTypeName__c == CON_CSM.S_TECHNOLOGY_R_T && c.Service_Now_Incident_Number__c != null && c.External_System_Type__c != null && (c.External_System_Type__c == CON_CSM.S_BISM || c.External_System_Type__c == CON_CSM.S_ROCHE_SN)){
                    caseMap.put(c.Id, c);
                    strExtType = c.External_System_Type__c;
                }
                
            }
            if(strExtType != null){
                if(!conDocIds.isEmpty()){
                    List<ContentDocumentLink> cdls = Database.query('SELECT ContentDocumentId,ContentDocument.Title, ContentDocument.LastModifiedDate, ContentDocument.CreatedBy.Id, ContentDocument.CreatedBy.Name, ContentDocument.FileExtension, ContentDocument.ContentSize, LinkedEntityId, Visibility , LinkedEntity.Name , LinkedEntity.Type FROM ContentDocumentLink WHERE ContentDocumentId in :conDocIds and LinkedEntityId in :caseIds');
                    for(ContentDocumentLink cdl : cdls){
                        if(cdl.Visibility == CON_CSM.S_ALL_USERS && cdl.LinkedEntity.Type == CON_CSM.S_CASE) conDocVis.put(cdl.ContentDocumentId , cdl.Visibility);
                    }
                }
                for(ContentVersion cv : newList){
                    if(caseMap.containsKey(cv.FirstPublishLocationId) && conDocVis.containsKey(cv.ContentDocumentId)){
                        cvCaseMap.put(cv.ContentDocumentId , caseMap.get(cv.FirstPublishLocationId)); 
                    }
                }
                CSM_ExternalClient_info__c ecc = CSM_ExternalClient_info__c.getValues(strExtType);
                System.debug(' Issue 1: '+(ecc != null && UserInfo.getUserId() != ecc.Profile_Id__c && !cvCaseMap.isEmpty() && !System.isFuture() && !System.isBatch()));
                System.debug(' Issue 2: '+(!System.isFuture() && !System.isBatch()));
                if(ecc != null && UserInfo.getUserId() != ecc.Profile_Id__c && !cvCaseMap.isEmpty() && !System.isFuture() && !System.isBatch()){
                    if(strExtType == CON_CSM.S_BISM){
                        WSC_CSM_BISMSOAPCallout.UpdateTicketCSM2BISMAttachment(JSON.serialize(cvCaseMap));
                    }else if(strExtType == CON_CSM.S_ROCHE_SN){
                        WSC_CSM_ROCHERestCallout.addIncidentAttachment(JSON.serialize(caseMap));
                    }
                }
                
            }
        }
    }
}