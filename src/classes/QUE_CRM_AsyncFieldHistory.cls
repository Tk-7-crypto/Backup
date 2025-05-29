/**
 * This is Queueable Class for Custom field history tracking solution.
 * version : 1.0
**/
public class QUE_CRM_AsyncFieldHistory implements Queueable,Database.AllowsCallouts{
    
    String reqPayload;
    public QUE_CRM_AsyncFieldHistory(String payLoad){
        this.reqPayload = payLoad;
    }

    public void execute(QueueableContext qc){
         asyncSaveFieldHistories(reqPayload);
    }
    
    /** 
     * This method is used to save field history records.
     * @params  reqPayload
     * @return  void
    **/
    public static void asyncSaveFieldHistories(String reqPayload) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint ('callout:Field_History_Tracking_Named_Credentials/services/apexrest/createHistoryTrackingRecords');
        request.setHeader('Content-Type','application/json');
        request.setMethod('POST');
        request.setBody(reqPayload);
        Http http = new Http();
        HttpResponse response = http.send(request);
        system.debug('TestR: '+response.getStatusCode());
        while (response.getStatusCode() == 302) {
            request.setEndpoint(response.getHeader('Location'));
            response = new Http().send(request);
        }
    }
}