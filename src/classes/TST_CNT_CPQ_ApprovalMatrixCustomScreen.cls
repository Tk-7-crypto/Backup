@isTest
private class TST_CNT_CPQ_ApprovalMatrixCustomScreen {
    
    @testSetup
    static void setUpTestData() {
    
        Approver_Group__c approverGroup = UTL_TestData.createApproverGroup(CON_CPQ.APPROVER_GROUP_TSSU, CON_CPQ.GENERAL);
        insert approverGroup;
        
        Approval_Matrix__c approvalMatrix = UTL_TestData.createApprovalMatrix(approverGroup, CON_CPQ.OPPORTUNITY_RFP,
        	CON_CPQ.REGION_EMEA, CON_CPQ.ONCOLOGY, CON_CPQ.SALES_USER, '', '', '', '', CON_CPQ.APPROVER_SALES_LOCAL_PHARMA,
        	CON_CPQ.MD, CON_CPQ.Role_PRIMARY1, CON_CPQ.ONCOLOGY, CON_CPQ.CUSTOMER_NAME);
        insert approvalMatrix;
        
        Account account = UTL_TestData.createAccount();
        insert account;
        
        Account_Directory__c accountDirectory = UTL_TestData.createAccountDirectoryData(CON_CPQ.ROLE_ADDITIONAL, account, CON_CPQ.CUSTOMER_NAME);
        insert accountDirectory;
        
        Country_Sales_Head__c countrySalesHead = UTL_TestData.createCountrySalesHeadData(CON_CPQ.SALE_TYPE_LARGE,CON_CPQ.COUNTRY,CON_CPQ.CUSTOMER_NAME);
        insert countrySalesHead;
    }    
    	
    @isTest
    static void testGetApproverGroups() {
        
        Test.startTest();
            List<CNT_CPQ_ApprovalMatrixCustomScreen.ApprovalMatrixWithKeyWrapper> approvalMatrixWrapperList = CNT_CPQ_ApprovalMatrixCustomScreen.getApproverGroups(
                CON_CPQ.APPROVER_GROUP_TSSU, CON_CPQ.OPPORTUNITY_RFP, CON_CPQ.X_0_5M_USD, CON_CPQ.ONCOLOGY, CON_CPQ.REGION_EMEA, CON_CPQ.Role_TSSU1, CON_CPQ.APPROVER_SALES_LOCAL_PHARMA,
                '', CON_CPQ.X_0_5M_USD_EMAIL, CON_CPQ.ONCOLOGY, CON_CPQ.CUSTOMER_NAME);
        Test.stopTest();
        
        System.assertEquals(true, approvalMatrixWrapperList.size() > 0, 'Should return approval Matrix Wrapper List');
    }
    
    @isTest
    static void testUpdateApprovalMatrix() {
    
        Approval_Matrix__c approvalMatrix = [SELECT Id, Name, Opportunity_Type__c FROM Approval_Matrix__c LIMIT 1];
        Approver_Group__c testApproverGroup = [SELECT Id, Name FROM Approver_Group__c LIMIT 1];
        approvalMatrix.Opportunity_Type__c = CON_CPQ.OPPORTUNITY_BALLPARK;
        
        CNT_CPQ_ApprovalMatrixCustomScreen.ApprovalMatrixWrapper approvalMatrixWrapper = 
            new CNT_CPQ_ApprovalMatrixCustomScreen.ApprovalMatrixWrapper(approvalMatrix, true, false);
        List<CNT_CPQ_ApprovalMatrixCustomScreen.ApprovalMatrixWrapper> approvalMatrixWrapperList = new List<CNT_CPQ_ApprovalMatrixCustomScreen.ApprovalMatrixWrapper>();
        approvalMatrixWrapperList.add(approvalMatrixWrapper);
        CNT_CPQ_ApprovalMatrixCustomScreen.ApprovalMatrixWithKeyWrapper approvalMatrixWithKeyWrapper = 
            new CNT_CPQ_ApprovalMatrixCustomScreen.ApprovalMatrixWithKeyWrapper(testApproverGroup, approvalMatrixWrapperList);
        String approvalMatrixData = JSON.serialize(approvalMatrixWithKeyWrapper);
        approvalMatrixData = '[' + approvalMatrixData + ']';
        
        Test.startTest();
            CNT_CPQ_ApprovalMatrixCustomScreen.updateApprovalMatrix(approvalMatrixData);
        Test.stopTest(); 
        
        Approval_Matrix__c actualApprovalMatrix = [SELECT Id, Name, Opportunity_Type__c FROM Approval_Matrix__c LIMIT 1];
        System.assertEquals(CON_CPQ.OPPORTUNITY_BALLPARK, actualApprovalMatrix.Opportunity_Type__c, 'should update approval matrix');
    }
    
    @isTest
    static void testDeleteApprovalMatrix() {
    
        Approval_Matrix__c approvalMatrix = [SELECT Id, Name, Opportunity_Type__c FROM Approval_Matrix__c LIMIT 1];
        Approver_Group__c testApproverGroup = [SELECT Id, Name FROM Approver_Group__c LIMIT 1];
        approvalMatrix.Opportunity_Type__c = CON_CPQ.OPPORTUNITY_BALLPARK;
        
        CNT_CPQ_ApprovalMatrixCustomScreen.ApprovalMatrixWrapper approvalMatrixWrapper = 
            new CNT_CPQ_ApprovalMatrixCustomScreen.ApprovalMatrixWrapper(approvalMatrix, false, true);
        List<CNT_CPQ_ApprovalMatrixCustomScreen.ApprovalMatrixWrapper> approvalMatrixWrapperList = new List<CNT_CPQ_ApprovalMatrixCustomScreen.ApprovalMatrixWrapper>();
        approvalMatrixWrapperList.add(approvalMatrixWrapper);
        CNT_CPQ_ApprovalMatrixCustomScreen.ApprovalMatrixWithKeyWrapper approvalMatrixWithKeyWrapper = 
            new CNT_CPQ_ApprovalMatrixCustomScreen.ApprovalMatrixWithKeyWrapper(testApproverGroup, approvalMatrixWrapperList);
        String approvalMatrixData = JSON.serialize(approvalMatrixWithKeyWrapper);
        approvalMatrixData = '[' + approvalMatrixData + ']';
        
        Test.startTest();
            CNT_CPQ_ApprovalMatrixCustomScreen.deleteApprovalMatrix(approvalMatrixData);
        Test.stopTest(); 
        
        List<Approval_Matrix__c> actualApprovalMatrixList = [SELECT Id, Name, Opportunity_Type__c FROM Approval_Matrix__c LIMIT 1];
        System.assertEquals(actualApprovalMatrixList.size(), 0, 'Approval Matrix Data deleted successfully');
    }
        
    @isTest
    static void testGetselectOptions() { 
        
        List<String> optionsList = new List<String> ();
        
        Test.startTest();
            optionsList = CNT_CPQ_ApprovalMatrixCustomScreen.getSelectOptions(new Approval_Matrix__c(), CON_CPQ.AGREEMENT_OPPORTUNITY_TYPE);
        Test.stopTest(); 
        
        System.assertEquals(optionsList.size() > 0, true, 'Picklist field value fetched successfully');
    }

    @isTest
    static void testCreateApprovalMatrix() { 
        
        Approver_Group__c approverGroup = UTL_TestData.createApproverGroup(CON_CPQ.APPROVER_GROUP_PL, CON_CPQ.GENERAL);
        insert approverGroup;
        
        Approval_Matrix__c approvalMatrix = UTL_TestData.createApprovalMatrix(approverGroup, CON_CPQ.OPPORTUNITY_RFP,
        	CON_CPQ.REGION_EMEA, CON_CPQ.ONCOLOGY, CON_CPQ.SALES_USER, '', '', '', '', CON_CPQ.APPROVER_SALES_LOCAL_PHARMA,
        	CON_CPQ.MD, CON_CPQ.Role_PRIMARY1, CON_CPQ.ONCOLOGY, CON_CPQ.CUSTOMER_NAME);
        
        Test.startTest();
            Approval_Matrix__c approvalRecord = CNT_CPQ_ApprovalMatrixCustomScreen.createApprovalMatrix(approvalMatrix, approverGroup.Id,
                CON_CPQ.Role_PRIMARY1);
        Test.stopTest();  
        
        List<Approval_Matrix__c> actualApprovalMatrixList = [SELECT Id, Name, Opportunity_Type__c FROM Approval_Matrix__c LIMIT 1];
        System.assertEquals(actualApprovalMatrixList.size()>0, true, 'Data entered successfully');
    }

	@isTest
    static void testGetValueSetForSalesType() { 
        
        List<String> optionsList = new List<String> ();
        
        Test.startTest();
        optionsList = CNT_CPQ_ApprovalMatrixCustomScreen.getValueSet(CON_CPQ.SALE_LARGE,CON_CPQ.ROLE_SALES_TYPE);
        Test.stopTest(); 
        
        System.assertEquals(optionsList.size() > 0, true, 'Picklist field option value fetched successfully');
    }

	@isTest
    static void testGetValueSetForAccountDirectory() { 
        
        List<String> optionsList = new List<String> ();
        Account account = [select id ,name From Account limit 1];
        Test.startTest();
        optionsList = CNT_CPQ_ApprovalMatrixCustomScreen.getValueSet(CON_CPQ.NONE, CON_CPQ.ROLE_ADDITIONAL);
        Test.stopTest(); 
        
        System.assertEquals(optionsList.size() > 0, true, 'Picklist field option value fetched successfully');
    }

	@isTest
    static void testGetCustomerValuesForSalesType() { 
        
        List<String> customerNameAndEmail;
        
        Test.startTest();
        customerNameAndEmail = CNT_CPQ_ApprovalMatrixCustomScreen.getCustomerValues(CON_CPQ.SALE_LARGE, CON_CPQ.ROLE_SALES_TYPE, CON_CPQ.COUNTRY);
        Test.stopTest(); 
        
        System.assertEquals(customerNameAndEmail.size() > 0, true, 'Customer Name fetched successfully');
    }

	@isTest
    static void testGetCustomerValuesAccountDirectory() { 
        List<String> customerNameAndEmail;
        Account account = [SELECT Id, Name FROM Account LIMIT 1];
        Test.startTest();
        customerNameAndEmail = CNT_CPQ_ApprovalMatrixCustomScreen.getCustomerValues(CON_CPQ.NONE, CON_CPQ.ROLE_ADDITIONAL, account.name);
        Test.stopTest();
        
        System.assertEquals(customerNameAndEmail.size() > 0, true, 'Customer Name fetched successfully');
    }
}