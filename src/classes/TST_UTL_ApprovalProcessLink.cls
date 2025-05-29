/*
* Version       : 1.0
* Description   : This test class is used for UTIl Approval link
*/
@isTest
private class TST_UTL_ApprovalProcessLink {
    /**
    * This method used to set up testdata
    */ 
    @testSetup
    static void setup() {
        UTL_TestData.createOneKeyConfig();
        Test.setMock(HttpCalloutMock.class, new TST_Mock_WSC_CSM_OneKeyCaseVerification());
        Case newCase = UTL_TestData.createCase();
        insert newCase;
    }
    
    @IsTest
    private static void testGenerateApprovalURLShouldReturnResult() {
        Case resultCase = [SELECT Id, caseNumber FROM case where OneKeyID__c = 'WFRD00890450' limit 1];
        Test.startTest();
            String result = UTL_ApprovalProcessLink.generateApprovalURL(resultCase.Id);
        Test.stopTest();        
    }
    
    @IsTest
    private static void testGenerateURLShouldReturnResult() {
        List<ProcessInstanceWorkitem> workItemLst = new List<ProcessInstanceWorkitem>();
        ProcessInstanceWorkitem newProcess = new ProcessInstanceWorkitem();
        workItemLst.add(newProcess);
        
        Test.startTest();
            String result = UTL_ApprovalProcessLink.generateUrl(workItemLst);
        Test.stopTest();

    }
}