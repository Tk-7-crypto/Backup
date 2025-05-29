@isTest
private class TST_WSC_CSM_SNOWGenAICallOut {
    @isTest
    private static void testCallSNOWGenAIPost(){
        CSM_ExternalClient_info__c ecc = new CSM_ExternalClient_info__c(Name = 'InternalSnowGenAI', Client_Url__c = 'http://test.com', UserName__c = 'User', Password__c='Pwd');
        insert ecc;
        Test.setMock(HttpCalloutMock.class, new TST_Mock_CSM_GenericCallOut('{"sys_id":"13242435","u_content":"Case Summary","u_order":"3","u_role":"Assistant"}'));
        Test.startTest();
        WSC_CSM_SNOWGenAICallOut.callSNOWGenAIPost('What is IQVIA?','13242435');
        WSC_CSM_SNOWGenAICallOut.callSNOWGenAIGet('13242435');
        WSC_CSM_SNOWGenAICallOut.callSNOWCaseSummary('{Test}','13242435',null);
        WSC_CSM_SNOWGenAICallOut.callSNOWSummaryGet('13242435');
        Test.stopTest();
    }

}