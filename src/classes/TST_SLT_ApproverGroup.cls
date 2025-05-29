@isTest
private class TST_SLT_ApproverGroup {

    @testSetup
    static void setApproverGroupData() {
        Approver_Group__c approverGroup = UTL_TestData.createApproverGroup(CON_CPQ.APPROVER_GROUP_PL, CON_CPQ.GENERAL);
        insert approverGroup;
    }
    
    public static void setUpApprovalMatrixData(String approverGroupName, String role) {
    
        Approver_Group__c approverGroup = UTL_TestData.createApproverGroup(approverGroupName, CON_CPQ.GENERAL);
        insert approverGroup;
        
        Approval_Matrix__c approvalMatrix = UTL_TestData.createApprovalMatrix(approverGroup, CON_CPQ.OPPORTUNITY_RFP,
            CON_CPQ.REGION_EMEA, CON_CPQ.ONCOLOGY, CON_CPQ.SALES_USER,'', '', '', '', CON_CPQ.APPROVER_SALES_LOCAL_PHARMA,
            CON_CPQ.MD, role, CON_CPQ.ONCOLOGY, CON_CPQ.CUSTOMER_NAME);        
        insert approvalMatrix; 
    } 
    
    @isTest
    static void testSelectById(){
        Approver_Group__c testApproverGroup  = [SELECT Id FROM Approver_Group__c LIMIT 1];
        
        Test.startTest();
            List<Approver_Group__c> approverGroupList = new SLT_ApproverGroup().selectById(new Set<Id>{testApproverGroup.Id});
        Test.stopTest();
        
        System.assertEquals(true, approverGroupList.size() > 0, 'Should return Approver Group List');
    }
    
    @isTest
    static void testGetApproverGroupWithApprovalMatrixList() {
        
        Test.startTest();
            List<Approver_Group__c> approverGroupList = new SLT_ApproverGroup().getApproverGroupWithApprovalMatrixList();
        Test.stopTest();
        
        System.assertEquals(true, approverGroupList.size() > 0, 'Should return Approver Group List');
    }
    
    @isTest
    static void testGetApproverGroupWithApprovalMatrixListWithApproverGroupFilterForPL() {
        
        setUpApprovalMatrixData(CON_CPQ.APPROVER_GROUP_PL, CON_CPQ.Role_PRIMARY1);
            
        Test.startTest();
            List<Approver_Group__c> approverGroupList = new SLT_ApproverGroup().getApproverGroupWithApprovalMatrixListWithApproverGroupFilter(
                CON_CPQ.APPROVER_GROUP_PL, CON_CPQ.OPPORTUNITY_RFP, CON_CPQ.X_0_5M_USD, CON_CPQ.ONCOLOGY, '', CON_CPQ.Role_PRIMARY1, '', '',
                CON_CPQ.X_0_5M_USD_EMAIL, CON_CPQ.ONCOLOGY, CON_CPQ.CUSTOMER_NAME);
        Test.stopTest();
        
        System.assertEquals(true, approverGroupList.size() > 0, 'Should return Approver Group List');
    }
    
    @isTest
    static void testGetApproverGroupWithApprovalMatrixListWithApproverGroupFilterForTSSU() {
        
        setUpApprovalMatrixData(CON_CPQ.APPROVER_GROUP_TSSU, CON_CPQ.Role_TSSU1);
        
        Test.startTest();
            List<Approver_Group__c> approverGroupList = new SLT_ApproverGroup().getApproverGroupWithApprovalMatrixListWithApproverGroupFilter(
                CON_CPQ.APPROVER_GROUP_TSSU, CON_CPQ.OPPORTUNITY_RFP, CON_CPQ.X_0_5M_USD, CON_CPQ.ONCOLOGY, CON_CPQ.REGION_EMEA, CON_CPQ.Role_TSSU1,
                '', '', CON_CPQ.X_0_5M_USD_EMAIL, CON_CPQ.ONCOLOGY, CON_CPQ.CUSTOMER_NAME);
        Test.stopTest();
        
        System.assertEquals(true, approverGroupList.size() > 0, 'Should return Approver Group List');
    }
    
    @isTest
    static void testGetApproverGroupWithApprovalMatrixListWithApproverGroupFilterForSales() {
        
        setUpApprovalMatrixData(CON_CPQ.APPROVER_GROUP_SALES_AND_ACCOUNT_MANAGEMENT, CON_CPQ.Role_INCOPY1);
        
        Test.startTest();
            List<Approver_Group__c> approverGroupList = new SLT_ApproverGroup().getApproverGroupWithApprovalMatrixListWithApproverGroupFilter(
                CON_CPQ.APPROVER_GROUP_SALES_AND_ACCOUNT_MANAGEMENT, CON_CPQ.OPPORTUNITY_RFP,CON_CPQ.X_0_5M_USD, '', CON_CPQ.REGION_EMEA,
                CON_CPQ.Role_INCOPY1, CON_CPQ.APPROVER_SALES_LOCAL_PHARMA, CON_CPQ.MD, CON_CPQ.X_0_5M_USD_EMAIL, CON_CPQ.ONCOLOGY, CON_CPQ.CUSTOMER_NAME);
        Test.stopTest();
        
        System.assertEquals(true, approverGroupList.size() > 0, 'Should return Approver Group List');
    }
    
    @isTest
    static void testGetApproverGroupWithApprovalMatrixListWithApproverGroupFilterForPLCustomer() {
        
        setUpApprovalMatrixData(CON_CPQ.APPROVER_GROUP_PL, CON_CPQ.Role_PRIMARY1);
        
        Test.startTest();
            List<Approver_Group__c> approverGroupList = new SLT_ApproverGroup().getApproverGroupWithApprovalMatrixListWithApproverGroupFilter(
                CON_CPQ.APPROVER_GROUP_PL_CUSTOMER, CON_CPQ.OPPORTUNITY_RFP, CON_CPQ.X_0_5M_USD, CON_CPQ.ONCOLOGY, CON_CPQ.REGION_EMEA,
                CON_CPQ.Role_PRIMARY1, '', '', CON_CPQ.X_0_5M_USD_EMAIL, CON_CPQ.ONCOLOGY, CON_CPQ.CUSTOMER_NAME);
        Test.stopTest();
        
        System.assertEquals(true, approverGroupList.size() > 0, 'Should return Approver Group List');
    }
}