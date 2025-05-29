public class QBL_TPA_Merge_Doc implements Queueable, Database.AllowsCallouts {
    public string requestId = '';
    public void execute(QueueableContext context) {
        if(!Test.isRunningTest()){
        	SRV_TPA_DocusignEnvelope.mergeAddHocDocsWithTLLA(requestId,'');   
        }
    }
}