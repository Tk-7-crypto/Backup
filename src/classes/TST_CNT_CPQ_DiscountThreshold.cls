@isTest
private class TST_CNT_CPQ_DiscountThreshold {

    @testSetup
    static void setUpTestData() {
        Approval_Matrix__c approvalMatrix = new Approval_Matrix__c(Min_Amount__c = 0, Max_Amount__c = 1000, Min_Discount_Amount__c = 100, Min_Discount_Percent__c = 10, Process_Type__c = 'Discount Validation', Pricing_Tool__c = 'AMESA');
        insert approvalMatrix;
        CNT_CPQ_DiscountThreshold.getDiscountThresholdRecords();
    } 
    @isTest
    static void tsetUpdateApprovalDiscountThresholdRecords(){
        List<Approval_Matrix__c> approvalMatrix = new SLT_ApprovalMatrix().getDiscountThresholdMatrix();
        Test.startTest();
        approvalMatrix[0].Min_Amount__c = 100;
        CNT_CPQ_DiscountThreshold.updateDiscountThresholdRecords(approvalMatrix);
        Test.stopTest();
        approvalMatrix = new SLT_ApprovalMatrix().getDiscountThresholdMatrix();
        System.assertEquals(100, approvalMatrix[0].Min_Amount__c);
    }
}