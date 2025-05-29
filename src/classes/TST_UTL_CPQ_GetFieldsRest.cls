@isTest
public class TST_UTL_CPQ_GetFieldsRest {
    @isTest
    public static void testGetObjectFields(){

        RestRequest request = new RestRequest();
        request.requestUri = URL.getOrgDomainUrl().toExternalForm() + CON_CPQ.URL_SERVICE_FIELDS + CON_CPQ.APTTUS_PROPOSAL_PROPOSAL;
        request.httpMethod = CON_CPQ.GET;
		
        RestContext.request = request;

        Test.startTest();
        	List<UTL_CPQ_GetFieldsRest.FieldsList> fieldList = UTL_CPQ_GetFieldsRest.getObjectFields();
        Test.stopTest();
  
        system.assertNotEquals(null, fieldList, 'Should return object fields');
    }
}