@isTest
public class TST_SRV_CBEX_UnitySync {
    
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        CBEX_Unity_Flag_Outbound__c uf = UTL_TestData.createCBEXUnityFlag();
        upsert uf;
    }
    
    @isTest
    private static void testCallout() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Intake_Unity_Flag_Sync__c iuf = UTL_TestData.createIntakeUnityFlag(opp.Id, CON_CBEx.OPPORTUNITY_OBJECT);
        insert iuf;
        
        Test.startTest();
        List<id> iufs = new list<id>{[Select id from Intake_Unity_Flag_Sync__c limit 1].id};
        Test.setMock(HttpCalloutMock.class, new MockResponseGenerator());
        SRV_CBEX_UnitySync.getCostUnityFlagAPICall(iufs);
        
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