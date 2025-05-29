@isTest
public class TST_UTL_GetTemplateDataRest {
    @isTest
    public static void testGetTemplateData(){

        RestRequest request = new RestRequest();
        request.requestUri = URL.getOrgDomainUrl().toExternalForm() + CON_CPQ.URL_SERVICE_TEMPLATE_DATA + CON_CPQ.USER;
        request.httpMethod = CON_CPQ.GET;
		
        RestContext.request = request;

        Test.startTest();
            List<UTL_GetTemplateDataRest.TemplateData> templateData = UTL_GetTemplateDataRest.getTemplateData();
        Test.stopTest();
  
        system.assertNotEquals(null, templateData, 'Should return Template');
    }
}