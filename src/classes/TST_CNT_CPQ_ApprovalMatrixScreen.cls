@isTest
private class TST_CNT_CPQ_ApprovalMatrixScreen {
    
    @testSetup
    static void setUpTestData() {
        Approver_Group__c approverGroup = UTL_TestData.createApproverGroup(CON_CPQ.APPROVER_GROUP_PL, CON_CPQ.GENERAL);
        insert approverGroup;
        
        Approval_Matrix__c approvalMatrix = UTL_TestData.createApprovalMatrix(approverGroup, CON_CPQ.OPPORTUNITY_RFP,
            CON_CPQ.REGION_EMEA, CON_CPQ.ONCOLOGY, CON_CPQ.SALES_USER, '', '', '', '', CON_CPQ.APPROVER_SALES_LOCAL_PHARMA,
            CON_CPQ.MD, CON_CPQ.Role_PRIMARY1, CON_CPQ.ONCOLOGY, CON_CPQ.CUSTOMER_NAME);
        insert approvalMatrix;
    }    
    
    @isTest
    static void testGetApproverGroups() {
        
        Test.startTest();
            List<CNT_CPQ_ApprovalMatrixScreen.ApprovalMatrixWithKeyWrapper> approvalMatrixWrapperList = CNT_CPQ_ApprovalMatrixScreen.getApproverGroups();
        Test.stopTest();
        
        System.assertEquals(true, approvalMatrixWrapperList.size()>0, 'Should return approval Matrix Wrapper List');
    }
    
    @isTest
    static void testUpdateApprovalMatrix() {
        Approval_Matrix__c approvalMatrix = [SELECT Id, Name, Opportunity_Type__c FROM Approval_Matrix__c LIMIT 1];
        Approver_Group__c testApproverGroup = [SELECT Id, Name FROM Approver_Group__c LIMIT 1];
        approvalMatrix.Opportunity_Type__c = CON_CPQ.OPPORTUNITY_BALLPARK;
        
        CNT_CPQ_ApprovalMatrixScreen.ApprovalMatrixWrapper approvalMatrixWrapper = 
            new CNT_CPQ_ApprovalMatrixScreen.ApprovalMatrixWrapper(approvalMatrix, true);
        List<CNT_CPQ_ApprovalMatrixScreen.ApprovalMatrixWrapper> approvalMatrixWrapperList = new List<CNT_CPQ_ApprovalMatrixScreen.ApprovalMatrixWrapper>();
        approvalMatrixWrapperList.add(approvalMatrixWrapper);
        CNT_CPQ_ApprovalMatrixScreen.ApprovalMatrixWithKeyWrapper approvalMatrixWithKeyWrapper = 
            new CNT_CPQ_ApprovalMatrixScreen.ApprovalMatrixWithKeyWrapper(testApproverGroup, approvalMatrixWrapperList);
        String approvalMatrixData = JSON.serialize(approvalMatrixWithKeyWrapper);
        approvalMatrixData = '[' +approvalMatrixData +']';
        
        Test.startTest();
            CNT_CPQ_ApprovalMatrixScreen.updateApprovalMatrix(approvalMatrixData);
        Test.stopTest();
        
        Approval_Matrix__c actualApprovalMatrix = [SELECT Id, Name, Opportunity_Type__c FROM Approval_Matrix__c LIMIT 1];
        System.assertEquals(CON_CPQ.OPPORTUNITY_BALLPARK, actualApprovalMatrix.Opportunity_Type__c, 'should update approval matrix');
    }

}