public with sharing class DAOH_CSM_ContentDocument {
	public static void updateCountForAttachmentOnRDCaseActivities(List<ContentDocument> newRecords){
        Set<Id> contentIds = new Set<Id>();
        for(ContentDocument cdRecord : newRecords){
            contentIds.add(cdRecord.Id);
        }
        if(contentIds != null && !contentIds.isEmpty()){
            List<ContentDocumentLink> contentLinkList = new SLT_ContentDocumentLink().getContentDocumentBasedOnLinkedEntityids(contentIds);
            Map<Id,Integer> linkedIdEntityMap = new Map<Id,Integer>();
            if(contentLinkList != null && !contentLinkList.isEmpty()){
                Boolean flag = false;
                for(ContentDocumentLink cdlRecord : contentLinkList){
                    String linkid = String.valueof(cdlRecord.LinkedEntityId);
                    if(linkid.startsWith('a00')){
                        flag = true;
                        linkedIdEntityMap.put(cdlRecord.LinkedEntityId, 0);
                    }
                    if(flag){
                        Integer count = linkedIdEntityMap.get(cdlRecord.LinkedEntityId);
                        count = count+1;
                        linkedIdEntityMap.remove(cdlRecord.LinkedEntityId);
                        linkedIdEntityMap.put(cdlRecord.LinkedEntityId, count);    
                        flag= false;
                    }
                }
            }
            if(linkedIdEntityMap.keySet().size() > 0){
                Set<id> ids = linkedIdEntityMap.keySet();
                List<Activity__c> actList = new SLT_ActivityC().getActivityById(ids);
                for(Activity__c actRecord : actList){
                    if(linkedIdEntityMap.containsKey(actRecord.Id)){
                        actRecord.Attachments__c =actRecord.Attachments__c-linkedIdEntityMap.get(actRecord.Id);
                    }
                }
                if(actList != null && actList.size()>0){
                    update actList;
                }    
            }
           
        }
    }
}