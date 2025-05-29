/**
 * @Author  : Vikram Singh Fartyal (Created under CR-11525 on 05th Jan 2018)
 * @Purpose : Submits the CDA request with recently generated CDA Doc for Non-Apttus licensed user's request
 */
public class QUE_CDA_AsyncSendCDADoc implements Queueable {
    public CDA_Request__c cdaRequest = new CDA_Request__c();
    public void execute(QueueableContext context) {
        ApexPages.StandardController sc = new ApexPages.StandardController(cdaRequest);
        EXT_CDA_RequestViewController rvc = new EXT_CDA_RequestViewController(sc);
        system.debug('####QUE_CDA_AsyncSendCDADoc cdaRequest: '+cdaRequest);
        rvc.submitRequest();
    }
}