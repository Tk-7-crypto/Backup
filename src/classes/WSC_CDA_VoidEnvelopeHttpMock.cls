/**
 * @author 		: Babita Dadarwal
 * HTTP Callout Mock class for BCH_CDA_VoidEnvelope
 */
@isTest(seeAllData=false)
public class WSC_CDA_VoidEnvelopeHttpMock implements HttpCalloutMock {
    // Implement this interface method
    public HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        
        //Void the Docusign Status
        List<dsfs__DocuSign_Status__c> dsStatusList = [SELECT id, dsfs__Envelope_Status__c FROM dsfs__DocuSign_Status__c];
        if(dsStatusList.size() > 0) {
            dsStatusList[0].dsfs__Envelope_Status__c = 'voided';
            update dsStatusList;
        }

        response.setStatusCode(200);
        return response;
    }
}