@isTest
public class TST_SRV_CBEX_PriceModularCallOuts {
    
    @isTest
    private static void testCallout() {
        CBEX_Price_Modular_Cred__c pmc = UTL_TestData.createCBEXPriceModularCred();
        upsert pmc;
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockResponseGenerator());
        String payload = '{"total_sites":2,"total_patients":2,"therapeutic_area":"Oncology","regions":{"global":true,"japan":false,"latin_america":false,"asia_pacific":false,"emea":false,"usa_canada":false},"phase":"1"}';
        SRV_CBEX_PriceModularCallOuts.getCostPriceModuleAPICall(payload);
        
        Test.stopTest();
    }
    
    public class MockResponseGenerator implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"getBody": {"cost": 12838354.866263704}}');
            res.setStatusCode(200);
            return res;
        }
    }
}