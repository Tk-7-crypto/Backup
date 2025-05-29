public class QBL_TPA_AsyncSendDoc implements Queueable, Database.AllowsCallouts {
    public string requestId = '';
    public string documentIds = ''; 
    public void execute(QueueableContext context) {
        SRV_TPA_DocusignEnvelope.createAndSendEnvelopeForAgreement(requestId, documentIds);   
    }
}