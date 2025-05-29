public with sharing class QBL_TPA_MergeAdHocDocs implements Queueable, Database.AllowsCallouts {
    public string requestId = '';
    public void execute(QueueableContext context) {
        List<Id> attachsToMerge = new List<Id>();
        String reqName = '';
        for(TPA_Additional_Term__c addHoc :[Select Id,TPA_Request__r.Name,Parent_Additional_Terms__c,(Select Id From Attachments order by CreatedDate DESC Limit 1) From TPA_Additional_Term__c where Exhibit_Attached__c = true and TPA_Request__c =: requestId]){
            reqName = addHoc.TPA_Request__r.Name;
            if(addHoc.Attachments != null && addHoc.Attachments.size() > 0 && addHoc.Parent_Additional_Terms__c == null){
            	attachsToMerge.add(addHoc.Attachments[0].Id);   
            }
        }
        if(!Test.isRunningTest()){
        	SRV_TPA_DocusignEnvelope.mergeAddHocDocs(requestId, attachsToMerge,reqName,'');   
        }
    }
}