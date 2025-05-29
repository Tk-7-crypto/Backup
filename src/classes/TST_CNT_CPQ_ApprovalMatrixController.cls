@isTest
public class TST_CNT_CPQ_ApprovalMatrixController {
    
    @TestSetup    
    static void dataSetup() {
        CPQ_Proposal_Create_Settings__c customTestSetting = new CPQ_Proposal_Create_Settings__c(Name = 'CPQ-TS-AMESA', Available_Pricing_Tools__c = 'AMESA', Permission_Set_Name__c = 'CPQ_TS_AMESA_Data_ReadWrite',
                                                                                               Proposal_Record_Type_Name__c = 'Test');
        insert customTestSetting;
        List<Approval_Matrix__c> appMatList = new List<Approval_Matrix__c>();
        
        Approval_Matrix__c appmat1 = new Approval_Matrix__c(Levels__c= 'Level 1', Country__c = 'All', 
                                                            Min_Amount__c = 0, Max_Amount__c = 50000, Min_Gross_Margin__c = 0, 
                                                            Max_Gross_Margin__c = 45, Min_Discount_Percent__c = -100, Max_Discount_Percent__c = 100, 
                                                            Min_Discount_Amount__c = -99999999, Max_Discount_Amount__c = 99999999, 
                                                            Approver_1__c = UserInfo.getUserId(), Track_Name__c = 'CPQ',
                                                            Pricing_Tool__c = 'AMESA', Process_Type__c = CON_CPQ.APPROVAL_PROCESS);
        appMatList.add(appmat1);
        Approval_Matrix__c appmat2 = new Approval_Matrix__c(Levels__c= 'Level 2', Country__c = 'India', 
                                                            Min_Amount__c = 0, Max_Amount__c = 50000, Min_Gross_Margin__c = 0, 
                                                            Max_Gross_Margin__c = 45, Min_Discount_Percent__c = -100, Max_Discount_Percent__c = 100, 
                                                            Min_Discount_Amount__c = -99999999, Max_Discount_Amount__c = 99999999, 
                                                            Approver_1__c = UserInfo.getUserId(), Track_Name__c = 'CPQ',
                                                            Pricing_Tool__c = 'AMESA', Process_Type__c = CON_CPQ.APPROVAL_PROCESS);
        appMatList.add(appmat2);
        insert appMatList;
    }
    
	@IsTest
    static void testfetchApprovalMatrix() {
        PermissionSet permissionSetObj = [SELECT Id FROM PermissionSet WHERE Name =: CON_CPQ.CPQ_AMESA_READ_WRITE_PERMISSION_SET];

        List<PermissionSetAssignment> permissionList = [SELECT Id from PermissionSetAssignment WHERE AssigneeId =: UserInfo.getUserId() AND PermissionSet.name =: CON_CPQ.CPQ_AMESA_READ_WRITE_PERMISSION_SET];
        if (permissionList.size() == 0) {
            PermissionSetAssignment permissionAssignmentObj = new PermissionSetAssignment();
            permissionAssignmentObj.AssigneeId = UserInfo.getUserId();
            permissionAssignmentObj.PermissionSetId = permissionSetObj.Id;
            insert permissionAssignmentObj;
        }

        CNT_CPQ_ApprovalMatrixController.WPR_CPQ_ApprovalMatrixWrapper approvalMatrixObj = CNT_CPQ_ApprovalMatrixController.fetchApprovalMatrix();
		System.assertNotEquals(null, approvalMatrixObj, 'Approval Matrix Detail Wrapper fetched successfully');
    }
}