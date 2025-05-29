public class QBL_TPA_AsyncGenerateDoc implements Queueable, Database.AllowsCallouts {

    public string requestId = ''; 
    public string GUID = '';
    public Boolean generateAMADoc = false;
    public void execute(QueueableContext context) {
        if(generateAMADoc){
            SRV_TPA_DocusignEnvelope.generateAmaDocForSign(requestId, GUID); 
        }else{
        SRV_TPA_DocusignEnvelope.generateDocForSign(requestId, GUID); 
        }

        //SRV_TPA_TPARequest.generateHelpfulHintsAddendumDoc(requestId);
        // SRV_TPA_TPARequest.useDefinationAttachment(requestId);
    }
}
