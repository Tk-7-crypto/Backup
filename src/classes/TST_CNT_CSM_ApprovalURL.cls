/*
* Version       : 1.0
* Description   : This test class is used CSM Approval URL class
*/
@isTest
private class TST_CNT_CSM_ApprovalURL {
    /**
    * This method used to set up testdata
    */ 
    @testSetup
    static void setup() {
        UTL_TestData.createOneKeyConfig();
        Test.setMock(HttpCalloutMock.class, new TST_Mock_WSC_CSM_OneKeyCaseVerification());
        List<Case> listOfCase = new List<Case>();
        listOfCase.add(UTL_TestData.createCase());
        insert listOfCase;
    }
    
    /**
    * This method used to test approval URL
    */ 
    @IsTest
    private static void testGenerateApprovalURLShouldReturnResult() {
        Case resultCase = [SELECT Id, caseNumber FROM case where OneKeyID__c = 'WFRD00890450' limit 1];
        Test.startTest();
            CNT_CSM_ApprovalURL cntCsmApprovalUrlInstance= new CNT_CSM_ApprovalURL();
            cntCsmApprovalUrlInstance.recID = resultCase.Id;
            String result = cntCsmApprovalUrlInstance.urlStr;
        Test.stopTest();
    }
}