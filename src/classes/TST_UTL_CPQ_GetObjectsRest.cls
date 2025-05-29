@isTest
public class TST_UTL_CPQ_GetObjectsRest {
    @isTest
    public static void testGetObjectList(){
    
        Test.setMock(HttpCalloutMock.class, new Mock());
        Test.startTest();
            Map<String, List<UTL_CPQ_GetObjectsRest.Objects>> objectList = UTL_CPQ_GetObjectsRest.getObjectList();
        Test.stopTest();

        system.assertNotEquals(null, objectList, 'Should return objects');
    }
    
    private static final String FAKE_RESPONSE_JSON = '{"sobjects":[{"triggerable":true,"custom":false,"name":"CPQ_Agreement","label":"Change Event: CPQ Agreement"},{"triggerable":true,"custom":true,"name":"Agreement__c","label":"Change Event: Agreement"}]}';

    private class Mock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest request) {
            HTTPResponse response = new HTTPResponse();
            response.setBody(FAKE_RESPONSE_JSON);
            response.setStatusCode(200);
            return response;
        }
    }
}