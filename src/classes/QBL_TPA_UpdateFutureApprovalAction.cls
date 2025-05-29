public class QBL_TPA_UpdateFutureApprovalAction implements Queueable,Database.AllowsCallouts { 
    public TPA_Request__c request; 
    public Set<String> commReviewKeys;
    public List<TPA_Additional_Term__c> addTermToUpdate;
    public String GUID = '';
    public boolean sendTLLAForSign;
    public void execute(QueueableContext context) {
            if(addTermToUpdate != null && addTermToUpdate.size()>0){
                update addTermToUpdate;
            }
            if(commReviewKeys != null && commReviewKeys.size()>0){
                CNT_TPA_CommercialReviewForm.createUpdateWatchList(request,commReviewKeys);
            }

            if(sendTLLAForSign){
                system.debug('request.id:' + request.id);
                QBL_TPA_AsyncSendDoc asyncSendDocCall= new QBL_TPA_AsyncSendDoc();
                asyncSendDocCall.requestId = request.id;
                if(!Test.isRunningTest()){
                    System.enqueueJob(asyncSendDocCall);
                }
            }
    }

}
