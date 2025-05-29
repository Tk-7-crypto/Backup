/*
* @Author :  Vikram Singh Fartyal (Created under CR-11525 on 05th Jan 2018)
* @Purpose : Batch class to process all the requests in 'Submitted for processing' status.
*/
global class BCH_CDA_ProcessRequests implements Database.Batchable<sObject> {

    String query;
    global BCH_CDA_ProcessRequests() {

    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        query = 'SELECT Id FROM CDA_Request__c WHERE Status__c = \'' + UTL_CDAUtility.STATUS_SUBMITTEDFORPROCESSING + '\' AND Awaiting_Requestor_Submission_Date__c != null';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        Set<Id> cdaIdSet = new Set<Id>();
        for(CDA_Request__c cdaRequest : (List<CDA_Request__c>)scope){
            cdaIdSet.add(cdaRequest.Id);
        }
        String fieldStr = UTL_CDAUtility.getObjectFieldStr('CDA_Request__c');
        fieldStr += ', (SELECT id, name, description, CreatedDate FROM Attachments ORDER BY createdDate DESC)';
        query = 'SELECT ' + fieldStr + ' FROM CDA_Request__c WHERE Id In :cdaIdSet';
        //Filter such request those have already generated the CDA doc but status is still not updated
        List<CDA_Request__c> requestToProcessList = new List<CDA_Request__c>();
        for(CDA_Request__c cdaRequest : (List<CDA_Request__c>)Database.query(query)) {
            Boolean isAttachmentGeneratedAlready = false;
            for(Attachment attach : cdaRequest.Attachments) {
                //checks whether attachment is required for this request or already generated so that we won't process this
                if(attach.Name.contains(UTL_CDAUtility.GENERATED_DOCUMENT_KEYWORD) && attach.Name.contains(cdaRequest.Name) && cdaRequest.Awaiting_Requestor_Submission_Date__c != null && cdaRequest.Awaiting_Requestor_Submission_Date__c < attach.CreatedDate) {
                    isAttachmentGeneratedAlready = true;
                    break;
                }
            }
            if(!isAttachmentGeneratedAlready) {
                requestToProcessList.add(cdaRequest);
            }
        }
        System.debug('####BCH_CDA_ProcessRequests.execute requestToProcessList: '+requestToProcessList);
        for(CDA_Request__c rtp : requestToProcessList) {
            //Assigning all the appropriate requests in the Queue
            QUE_CDA_AsyncGenerateCDADoc asyncGenDocQue = new QUE_CDA_AsyncGenerateCDADoc();
            asyncGenDocQue.cdaRequest = rtp;
            System.enqueueJob(asyncGenDocQue);            
        }
    }

    global void finish(Database.BatchableContext BC) {

    }
}