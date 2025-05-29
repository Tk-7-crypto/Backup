@isTest
private class TST_SLT_ApprovalMatrix {

    static Approval_Matrix__c setApprovalMatrixData(){
        Approver_Group__c approverGroup = UTL_TestData.createApproverGroup(CON_CPQ.APPROVER_GROUP_PL, CON_CPQ.GENERAL);
        insert approverGroup;
        Approval_Matrix__c approvalMatrix = UTL_TestData.createApprovalMatrix(approverGroup, CON_CPQ.OPPORTUNITY_RFP,
            CON_CPQ.JAPAN, CON_CPQ.ONCOLOGY, CON_CPQ.SALES_USER, '', '', '', '', CON_CPQ.APPROVER_SALES_LOCAL_PHARMA,
            CON_CPQ.MD, CON_CPQ.Role_TSSU1, CON_CPQ.ONCOLOGY, CON_CPQ.CUSTOMER_NAME);
        insert approvalMatrix;
        return approvalMatrix;
    }
    
    @isTest
    static void testSelectApprovalMatrixById(){
        Approval_Matrix__c testApprovalMatrix  = setApprovalMatrixData();
        
        Test.startTest();
        	List<Approval_Matrix__c> approvalMatrixList = new SLT_ApprovalMatrix().selectById(new Set<Id>{testApprovalMatrix.Id});
        Test.stopTest();
    }
    
    @isTest
    static void testSelectApprovalMatrixCondition(){
        setApprovalMatrixData();
        
        Test.startTest();
        	List<Approval_Matrix__c> testApprovalMatrixList = new SLT_ApprovalMatrix().selectApprovalMatrixCondition(CON_CPQ.OPPORTUNITY_RFP, CON_CPQ.JAPAN);
        Test.stopTest();
    }
    
    @isTest
    static void testSelectApprovalMatrixByOpportunityType(){
        setApprovalMatrixData();
        
        Test.startTest();
        	List<Approval_Matrix__c> testApprovalMatrixList = new SLT_ApprovalMatrix().selectApprovalMatrixByOpportunityType(CON_CPQ.OPPORTUNITY_RFP);
        Test.stopTest();
    }
    
    @isTest
    static void testgetApprover(){
        Account account = UTL_OCE_TestData.createaccount();
        insert account;
        Opportunity opportunity = UTL_OCE_TestData.createOpportunity(account.Id);
        insert opportunity;
        Apttus_Proposal__Proposal__c thisProposal = UTL_TestData.setTSProposalData(false, CON_CPQ.TECH_SOLUTION, opportunity.Id, CON_CPQ.OCE);
        thisProposal.Approver_Level__c = 1;
        thisProposal.Total_Amount__c = 40000;
        thisProposal.CountryCode__c = 'India';
        thisProposal.Min_Gross_Margin__c = 40;
        thisProposal.Apttus_Proposal__Discount_Percent__c = 0;
        thisProposal.Actual_Discount_Value__c = 0;
        insert thisProposal;
        Approval_Matrix__c approvalMatrix = new Approval_Matrix__c(Levels__c= 'Level 1', Country__c = 'India', Min_Amount__c = 0, Max_Amount__c = 50000, Min_Gross_Margin__c = 0, Max_Gross_Margin__c = 45, Min_Discount_Percent__c = -100, Max_Discount_Percent__c = 100, Min_Discount_Amount__c = -99999999, Max_Discount_Amount__c = 99999999, Approver_1__c = UserInfo.getUserId(), Track_Name__c = 'CPQ', Pricing_Tool__c = 'OCE', Auto_Approve__c = FALSE );
        insert approvalMatrix;
        Set<String> fieldSet = new Set<String> {CON_CPQ.ID , CON_CPQ.LEVELS, CON_CPQ.PRIORITY,CON_CPQ.COUNTRY, CON_CPQ.MIN_AMOUNT, CON_CPQ.MAX_AMOUNT, CON_CPQ.MIN_GORSS_MARGIN, CON_CPQ.MAX_GORSS_MARGIN, CON_CPQ.MIN_DISCOUNT_PERCENT, CON_CPQ.MAX_DISCOUNT_PERCENT, CON_CPQ.MIN_DISCOUNT_AMOUNT, CON_CPQ.MAX_DISCOUNT_AMOUNT, CON_CPQ.APPROVER1, CON_CPQ.APPROVER2, CON_CPQ.APPROVER3, CON_CPQ.APPROVER4, CON_CPQ.APPROVER5, CON_CPQ.OBJECT_NAME, CON_CPQ.TRACK_NAME, CON_CPQ.PRICING_TOOL, CON_CPQ.AUTO_APPROVE};
        String condition = 'Min_Amount__c <= ' + thisProposal.Total_Amount__c +
				   ' AND Max_Amount__c > ' + thisProposal.Total_Amount__c +
				   ' AND Min_Gross_Margin__c <= ' + (thisProposal.Min_Gross_Margin__c == null? 0 : thisProposal.Min_Gross_Margin__c) +
				   ' AND Max_Gross_Margin__c > ' + (thisProposal.Min_Gross_Margin__c == null? 0 : thisProposal.Min_Gross_Margin__c) +
                   ' AND Min_Discount_Percent__c <= ' + (thisProposal.Apttus_Proposal__Discount_Percent__c == null? 0 : thisProposal.Apttus_Proposal__Discount_Percent__c) +
				   ' AND Max_Discount_Percent__c > ' + (thisProposal.Apttus_Proposal__Discount_Percent__c == null? 0 : thisProposal.Apttus_Proposal__Discount_Percent__c) +
				   ' AND Min_Discount_Amount__c <= ' + (thisProposal.Actual_Discount_Value__c == null? 0 : thisProposal.Actual_Discount_Value__c) +
				   ' AND Max_Discount_Amount__c > ' + (thisProposal.Actual_Discount_Value__c == null? 0 : thisProposal.Actual_Discount_Value__c) +
				   ' AND Country__c = ' + '\''+thisProposal.CountryCode__c + '\''+
				   ' AND Pricing_Tool__c = ' + '\'' + thisProposal.Select_Pricing_Tool__c + '\''+
				   ' AND Track_Name__c = ' + '\''+CON_CPQ.CPQ + '\'';
        
        Test.startTest();
        	List<Approval_Matrix__c> testApprovalMatrixList = new SLT_ApprovalMatrix().getApprover(fieldSet, condition);
        Test.stopTest();
    }
    @isTest
    static void testgetDiscountMatrix(){
        Approval_Matrix__c approvalMatrix = new Approval_Matrix__c(Levels__c= 'Level 1', Country__c = 'India', Min_Amount__c = 0, Max_Amount__c = 50000, Min_Gross_Margin__c = 0, Max_Gross_Margin__c = 45, Min_Discount_Percent__c = -100, Max_Discount_Percent__c = 100, Min_Discount_Amount__c = -99999999, Max_Discount_Amount__c = 99999999, Approver_1__c = UserInfo.getUserId(), Track_Name__c = 'CPQ', Pricing_Tool__c = 'OCE', Auto_Approve__c = FALSE );
        insert approvalMatrix;
        Set<String> approvalMatrixFieldSet = new Set<String> {CON_CPQ.MIN_AMOUNT, CON_CPQ.MAX_AMOUNT,  CON_CPQ.MIN_DISCOUNT_PERCENT, CON_CPQ.MAX_DISCOUNT_PERCENT, CON_CPQ.MIN_DISCOUNT_AMOUNT, CON_CPQ.MAX_DISCOUNT_AMOUNT};
        String condition = 'Process_Type__c = ' + '\'' + CON_CPQ.DISCOUNT_VALIDATION + '\'' +
                           ' AND Min_Amount__c < ' + approvalMatrix.Min_Amount__c +
                           ' AND Max_Amount__c >= ' + approvalMatrix.Max_Amount__c +
                           ' AND (Min_Discount_Percent__c <= ' + approvalMatrix.Min_Discount_Percent__c +
                           ' OR Min_Discount_Amount__c <= ' + approvalMatrix.Min_Discount_Amount__c +')';
        Test.startTest();
        	List<Approval_Matrix__c> testApprovalMatrixList = new SLT_ApprovalMatrix().getDiscountMatrix(approvalMatrixFieldSet, condition);
        Test.stopTest();
    }

    @isTest
    static void testGetApproverByPricingTool(){
        Approval_Matrix__c approvalMatrix = new Approval_Matrix__c(Levels__c= 'Level 1', Process_Type__c = CON_CPQ.APPROVAL_PROCESS, Country__c = 'India', Min_Amount__c = 0, Max_Amount__c = 50000, Min_Gross_Margin__c = 0, Max_Gross_Margin__c = 45, Min_Discount_Percent__c = -100, Max_Discount_Percent__c = 100, Min_Discount_Amount__c = -99999999, Max_Discount_Amount__c = 99999999, Approver_1__c = UserInfo.getUserId(), Track_Name__c = 'CPQ', Pricing_Tool__c = 'AMESA', Auto_Approve__c = FALSE );
        insert approvalMatrix;
        Set<String> approvalMatrixFieldSet = new Set<String> {CON_CPQ.MIN_AMOUNT, CON_CPQ.MAX_AMOUNT,  CON_CPQ.MIN_DISCOUNT_PERCENT, CON_CPQ.MAX_DISCOUNT_PERCENT, CON_CPQ.MIN_DISCOUNT_AMOUNT, CON_CPQ.MAX_DISCOUNT_AMOUNT};
        String condition = 'Process_Type__c = ' + '\'' + CON_CPQ.APPROVAL_PROCESS + '\'';
        List<String> assignedPricingTools = new List<String> {CON_CPQ.AMESA};
        Test.startTest();
        	List<Approval_Matrix__c> testApprovalMatrixList = new SLT_ApprovalMatrix().getApproverByPricingTool(approvalMatrixFieldSet, condition, assignedPricingTools);
        Test.stopTest();
    }
}