@isTest
public class TST_UTL_TPA_RestApi {
    
    public class MockHttpResponseGeneratorForTPA implements HttpCalloutMock{
		public HTTPResponse respond(HTTPRequest req) {
        	// Create a fake response
        	HttpResponse res = new HttpResponse();
        	res.setHeader('Content-Type', 'application/json');
        	res.setBody('{"example":"test"}');
        	res.setStatusCode(200);
        	return res;
    	}
	}
    
    @isTest static void testAuth(){
        UTL_TPA_SetupTestData.createTPASettingData();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForTPA());
        
        UTL_TPA_RestApi requestArg = new UTL_TPA_RestApi();
        CNT_TPA_RequestSubmissionForm.tpaRequestDetails tpaReqDet =  new CNT_TPA_RequestSubmissionForm.tpaRequestDetails();
        tpaReqDet.tpaRequest = UTL_TPA_SetupTestData.getTestTPARequest();
        requestArg.requestObj = tpaReqDet; 
        requestArg.actionType = 'UpdateUseOffData';
        Test.startTest();
        UTL_TPA_RestApi returnResult = UTL_TPA_RestApi.callTpaRestApiHttpPost(requestArg, userInfo.getSessionId());
        Test.stopTest();
    }
    @isTest static void testAuthException(){
        UTL_TPA_SetupTestData.createTPASettingData();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorForTPA());
        
        UTL_TPA_RestApi requestArg = new UTL_TPA_RestApi();
        CNT_TPA_RequestSubmissionForm.tpaRequestDetails tpaReqDet =  new CNT_TPA_RequestSubmissionForm.tpaRequestDetails();
        tpaReqDet.tpaRequest = UTL_TPA_SetupTestData.getTestTPARequest();
        requestArg.requestObj = tpaReqDet; 
        requestArg.actionType = 'UpdateUseOffData';
        UTL_TPA_RestApi returnResult = UTL_TPA_RestApi.callTpaRestApiHttpPost(requestArg, userInfo.getSessionId());
    }
}