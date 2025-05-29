/**
 * @Author  : Vikram Singh Fartyal (Created under CR-11525 on 05th Jan 2018)
 * @Purpose : Generate CDA Doc for Non-Apttus licensed user's request
 */
public class QUE_CDA_AsyncGenerateCDADoc implements Queueable {
    public CDA_Request__c cdaRequest = new CDA_Request__c();
    public void execute(QueueableContext context) {
        SRV_CDA_CDARequest.generateCDADocumentThroughBatch(JSON.serialize(cdaRequest));
    }
}