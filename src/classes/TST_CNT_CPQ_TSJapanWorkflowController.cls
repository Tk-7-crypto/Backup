/**
 * Controller class of CNT_CPQ_TSJapanWorkflowController
 */
@IsTest
private class TST_CNT_CPQ_TSJapanWorkflowController {

    /**
    * This method used to set up testdata
    */
    @TestSetup
    static void dataSetup() {
        Account account = UTL_OCE_TestData.createaccount();
        insert account;
        Opportunity opportunity = UTL_OCE_TestData.createOpportunity(account.Id);
        insert opportunity;
        User currentUser = [Select Profile.Name From User Where Id = :UserInfo.getUserId()];
        CPQ_TS_Admin_Profiles__c adminProfiles = new CPQ_TS_Admin_Profiles__c(Name = currentUser.Profile.Name);
        insert adminProfiles;    

        Currency_Exchange_Rates__c currencyRate = UTL_TestData.getCurrencyExchangeRate(false);
        insert currencyRate;
    }
    
    @isTest
    static void testsyncPLIWithOpportunity() { 
        Account account = [SELECT Id FROM Account Limit 1];
        
        Opportunity opportunity = [SELECT Id FROM Opportunity LIMIT 1];
        
        RecordType recordType  = [SELECT Id FROM RecordType WHERE DeveloperName = :CON_CPQ.TECH_SOLUTION 
                                  AND SobjectType = 'Apttus_Proposal__Proposal__c' LIMIT 1];
        
        Apttus_Proposal__Proposal__c proposal = UTL_TestData.setTSProposalData(false, CON_CPQ.TECH_SOLUTION, opportunity.Id, CON_CPQ.OCE);
        proposal.Apttus_Proposal__Account__c = account.Id;
        proposal.Average_Gross_Margin__c = 15;
        proposal.Approver_Level__c = 1; 
        proposal.Total_Amount__c = 40000; 
        proposal.CountryCode__c = 'India'; 
        proposal.Average_Gross_Margin__c = 40; 
        proposal.Apttus_Proposal__Discount_Percent__c = 0; 
        proposal.Actual_Discount_Value__c = 0;
        proposal.Apttus_Proposal__Approval_Stage__c = 'Finalized'; 
        proposal.Approval_Status__c = 'None';
        insert proposal;
        
        Test.startTest();
        Id jobId = CNT_CPQ_TSJapanWorkflowController.syncPLIWithOpportunity(proposal.Id, 'OCE', proposal.Apttus_Proposal__Approval_Stage__c);
        Test.stopTest();

       	System.assert(jobId != Null);
    }

    @IsTest
    static void testGetProposalDetails() {
        Account account = [SELECT Id FROM Account Limit 1];
        
        Opportunity opportunity = [SELECT Id FROM Opportunity LIMIT 1];
        
        CPQ_Proposal_Create_Settings__c proposalCreateSetting = UTL_TestData.cpqProposalCreateSettings();
        insert proposalCreateSetting;
        
        Apttus_Proposal__Proposal__c proposal = UTL_TestData.setTSProposalData(false, CON_CPQ.TECH_SOLUTION, opportunity.Id, CON_CPQ.TS_JAPAN);
        proposal.Apttus_Proposal__Account__c = account.Id;
        proposal.Min_Gross_Margin__c = 15;
        proposal.Vendor_Use__c = true;
        insert proposal;
        
        // Create Proposal Line Items
        Product2 product = UTL_TestData.createProduct();
        Apttus_Proposal__Proposal_Line_Item__c lineItem = UTL_TestData.createProposalLineItem(proposal.Id, product.Id);
        insert lineItem;
        
        UTL_TestData.createContentDocument(CON_CPQ.CSS_FILE + ' File', proposal.id);
        
        Test.startTest();
        CNT_CPQ_TSJapanWorkflowController.WPR_CPQ_ProposalDetails proposalObj = CNT_CPQ_TSJapanWorkflowController.getProposalDetails(proposal.Id);
        Test.stopTest();
        
        System.assertEquals(proposal.Id, proposalObj.recordId, 'Record Id mis-match');
        System.assertEquals(proposal.Id, proposalObj.proposalSObject.Id, 'proposalSObject mis-match');
        System.assertEquals(null, proposalObj.error, 'error mis-match');
        System.assertEquals(true, proposalObj.isPrimary, 'isPrimary mis-match');
        System.assertEquals(true, proposalObj.isrecordTypeNameTechSolution, 'isrecordTypeNameTechSolution mis-match');
        System.assertEquals(null, CNT_CPQ_TSJapanWorkflowController.isoCodeTocurrencyTypeMap, 'currency map');
        System.assertEquals(true, proposalObj.cssFileAttached, 'cssFileAttached mis-match');
        System.assertEquals('TSJapan', proposalObj.flowName, 'Flow Name Matched');
    }
    
    @IsTest
    static void testGetOCEProposalDetails() {
        Account account = [SELECT Id FROM Account Limit 1];
        
        Opportunity opportunity = [SELECT Id FROM Opportunity LIMIT 1];
        
        CPQ_Proposal_Create_Settings__c proposalCreateSetting = UTL_TestData.cpqProposalCreateSettings();
        insert proposalCreateSetting;
		
        Apttus_Proposal__Proposal__c proposal = UTL_TestData.setTSProposalData(false, CON_CPQ.TECH_SOLUTION, opportunity.Id, CON_CPQ.OCE);
        proposal.Apttus_Proposal__Account__c = account.Id;
        proposal.Average_Gross_Margin__c = 15;
        proposal.Approver_Level__c = 1; 
        proposal.Total_Amount__c = 40000; 
        proposal.CountryCode__c = 'India'; 
        proposal.Average_Gross_Margin__c = 40; 
        proposal.Apttus_Proposal__Discount_Percent__c = 0; 
        proposal.Actual_Discount_Value__c = 0;
        proposal.Apttus_Proposal__Approval_Stage__c = 'Finalized'; 
        proposal.Approval_Status__c = 'None';
        insert proposal;
        
        Test.startTest();
        CNT_CPQ_TSJapanWorkflowController.WPR_CPQ_ProposalDetails proposalObj = CNT_CPQ_TSJapanWorkflowController.getProposalDetails(proposal.Id);
        Test.stopTest();
        
        System.assertEquals(proposal.Id, proposalObj.recordId, 'Record Id mis-match');
        System.assertEquals(proposal.Id, proposalObj.proposalSObject.Id, 'proposalSObject mis-match');
    }
	
    @IsTest
    static void testSubmitForApproval() {
        Account account = [SELECT Id FROM Account Limit 1];
        
        Opportunity opportunity = [SELECT Id FROM Opportunity LIMIT 1];
        
        CPQ_Proposal_Create_Settings__c proposalCreateSetting = UTL_TestData.cpqProposalCreateSettings();
        insert proposalCreateSetting;
        
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        List<User> userList = new List<User>();
        for(Integer i=0;i<5;i++){
            Blob b = Crypto.GenerateAESKey(128);
            String h = EncodingUtil.ConvertTohex(b);
            String uid = h.SubString(0,8);
            User u = new User(Alias = uid, Email= 'standarduser'+i+'@accenture.com', 
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p.Id, Audit_Employee_Number_Reason__c = 'REASON'+i,
                Change_Request_Ticket_Number__c = '1'+i, Change_Request_Description__c = '2'+i,
                TimeZoneSidKey='America/New_York', UserName= uniqueUserName+i); 
            userList.add(u);
        }
        
        insert userList;
        
        Approval_Matrix__c appmat2 = new Approval_Matrix__c(Levels__c= 'Level 1', Country__c = 'India', 
                                                            Min_Amount__c = 0, Max_Amount__c = 50000, Min_Gross_Margin__c = 0, 
                                                            Max_Gross_Margin__c = 45, Min_Discount_Percent__c = -100, Max_Discount_Percent__c = 100, 
                                                            Min_Discount_Amount__c = -99999999, Max_Discount_Amount__c = 99999999, 
                                                            Approver_1__c = UserInfo.getUserId(), Approver_2__c = userList[0].Id, Track_Name__c = 'CPQ',
                                                            Pricing_Tool__c = 'OCE', Process_Type__c = CON_CPQ.APPROVAL_PROCESS);
        insert appmat2;
        Apttus_Proposal__Proposal__c proposal = UTL_TestData.setTSProposalData(false, CON_CPQ.TECH_SOLUTION, opportunity.Id, CON_CPQ.OCE);
        proposal.Apttus_Proposal__Account__c = account.Id;
        proposal.Average_Gross_Margin__c = 15;
        proposal.Approver_Level__c = 1; 
        proposal.Total_Amount__c = 40000; 
        proposal.CountryCode__c = 'India'; 
        proposal.Average_Gross_Margin__c = 40; 
        proposal.Apttus_Proposal__Discount_Percent__c = 0; 
        proposal.Actual_Discount_Value__c = 0;
        proposal.Apttus_Proposal__Approval_Stage__c = 'Finalized'; 
        proposal.Approval_Status__c = 'None';
        insert proposal;
        
        Test.startTest();
        CNT_CPQ_TSJapanWorkflowController.submitForApprovalProcess(proposal.Id);
        List<CNT_CPQ_TSJapanWorkflowController.WPR_CPQ_Approvers> approverList = CNT_CPQ_TSJapanWorkflowController.getActorProcessInstanceWorkItems(proposal.Id);
        String result = CNT_CPQ_TSJapanWorkflowController.updateOldApproverWithNew(JSON.serialize(approverList), proposal.Id);
        CNT_CPQ_TSJapanWorkflowController.createWorkItemOnReject(proposal.Id, 'Reject');
        Test.stopTest();
        
        System.assertEquals(result, 'Success', 'Reassign is successful');
        List<Apttus_Proposal__Proposal__c> updatedProposal = [Select Apttus_Proposal__Approval_Stage__c From Apttus_Proposal__Proposal__c Where Id =: proposal.Id];
        //System.assertEquals('Rejected', updatedProposal[0].Apttus_Proposal__Approval_Stage__c, 'Approval Stage mis-match');
    }
    
    @IsTest
    static void testSubmitForApprovalAutoApprove() {
        Account account = [SELECT Id FROM Account Limit 1];
        
        Opportunity opportunity = [SELECT Id FROM Opportunity LIMIT 1];
        
        CPQ_Proposal_Create_Settings__c proposalCreateSetting = UTL_TestData.cpqProposalCreateSettings();
        insert proposalCreateSetting;
        
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        List<User> userList = new List<User>();
        for(Integer i=0;i<5;i++){
            Blob b = Crypto.GenerateAESKey(128);
            String h = EncodingUtil.ConvertTohex(b);
            String uid = h.SubString(0,8);
            User u = new User(Alias = uid, Email= 'standarduser'+i+'@accenture.com', 
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p.Id, Audit_Employee_Number_Reason__c = 'REASON'+i,
                Change_Request_Ticket_Number__c = '1'+i, Change_Request_Description__c = '2'+i,
                TimeZoneSidKey='America/New_York', UserName= uniqueUserName+i); 
            userList.add(u);
        }
        
        insert userList;
        
        Approval_Matrix__c appmat = new Approval_Matrix__c(Levels__c= 'Level 1', Country__c = 'India', 
                                                            Min_Amount__c = 0, Max_Amount__c = 50000, Min_Gross_Margin__c = 0, 
                                                            Max_Gross_Margin__c = 45, Min_Discount_Percent__c = -100, Max_Discount_Percent__c = 100, 
                                                            Min_Discount_Amount__c = -99999999, Max_Discount_Amount__c = 99999999, 
                                                            Track_Name__c = 'CPQ',
                                                            Pricing_Tool__c = 'OCE', Auto_Approve__c = TRUE, Process_Type__c = CON_CPQ.APPROVAL_PROCESS);
        insert appmat;
        
        Apttus_Proposal__Proposal__c proposal = UTL_TestData.setTSProposalData(false, CON_CPQ.TECH_SOLUTION, opportunity.Id, CON_CPQ.OCE);
        proposal.Apttus_Proposal__Account__c = account.Id;
        proposal.Average_Gross_Margin__c = 15;
        proposal.Approver_Level__c = 1; 
        proposal.Total_Amount__c = 40000; 
        proposal.CountryCode__c = 'India'; 
        proposal.Average_Gross_Margin__c = 40; 
        proposal.Apttus_Proposal__Discount_Percent__c = 0; 
        proposal.Actual_Discount_Value__c = 0;
        proposal.Apttus_Proposal__Approval_Stage__c = 'Finalized'; 
        proposal.Approval_Status__c = 'None';
        insert proposal;
        
        Test.startTest();
        CNT_CPQ_TSJapanWorkflowController.submitForApprovalProcess(proposal.Id);
  		Test.stopTest();
        List<Apttus_Proposal__Proposal__c> updatedProposal = [Select Apttus_Proposal__Approval_Stage__c From Apttus_Proposal__Proposal__c Where Id =: proposal.Id];
    }
    /*
    @IsTest
    static void testApprove() {
        Account account = [SELECT Id FROM Account Limit 1];
        
        Opportunity opportunity = [SELECT Id FROM Opportunity LIMIT 1];
        
        CPQ_Proposal_Create_Settings__c proposalCreateSetting = UTL_TestData.cpqProposalCreateSettings();
        insert proposalCreateSetting;
        
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        List<User> userList = new List<User>();
        for(Integer i=0;i<5;i++){
            Blob b = Crypto.GenerateAESKey(128);
            String h = EncodingUtil.ConvertTohex(b);
            String uid = h.SubString(0,8);
            User u = new User(Alias = uid, Email= 'standarduser'+i+'@accenture.com', 
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                LocaleSidKey='en_US', ProfileId = p.Id, Audit_Employee_Number_Reason__c = 'REASON'+i,
                Change_Request_Ticket_Number__c = '1'+i, Change_Request_Description__c = '2'+i,
                TimeZoneSidKey='America/New_York', UserName= uniqueUserName+i); 
            userList.add(u);
        }
        
        insert userList;
        
        Approval_Matrix__c appmat1 = new Approval_Matrix__c(Levels__c= 'Level 1', Country__c = 'India', 
                                                            Min_Amount__c = 0, Max_Amount__c = 50000, Min_Gross_Margin__c = 0, 
                                                            Max_Gross_Margin__c = 45, Min_Discount_Percent__c = -100, Max_Discount_Percent__c = 100, 
                                                            Min_Discount_Amount__c = -99999999, Max_Discount_Amount__c = 99999999, 
                                                            Approver_1__c = UserInfo.getUserId(), Track_Name__c = 'CPQ',
                                                            Pricing_Tool__c = 'OCE', Approve_On_First_Response__c = false, Process_Type__c = CON_CPQ.APPROVAL_PROCESS);
        insert appmat1;
        Approval_Matrix__c appmat2 = new Approval_Matrix__c(Levels__c= 'Level 2', Country__c = 'India', 
                                                            Min_Amount__c = 0, Max_Amount__c = 50000, Min_Gross_Margin__c = 0, 
                                                            Max_Gross_Margin__c = 45, Min_Discount_Percent__c = -100, Max_Discount_Percent__c = 100, 
                                                            Min_Discount_Amount__c = -99999999, Max_Discount_Amount__c = 99999999, 
                                                            Approver_1__c = UserInfo.getUserId(), Track_Name__c = 'CPQ',
                                                            Pricing_Tool__c = 'OCE', Approve_On_First_Response__c = true, Process_Type__c = CON_CPQ.APPROVAL_PROCESS);
        insert appmat2;
        Apttus_Proposal__Proposal__c proposal = UTL_TestData.setTSProposalData(false, CON_CPQ.TECH_SOLUTION, opportunity.Id, CON_CPQ.OCE);
        proposal.Apttus_Proposal__Account__c = account.Id;
        proposal.Average_Gross_Margin__c = 15;
        proposal.Approver_Level__c = 1; 
        proposal.Total_Amount__c = 40000; 
        proposal.CountryCode__c = 'India'; 
        proposal.Average_Gross_Margin__c = 40; 
        proposal.Apttus_Proposal__Discount_Percent__c = 0; 
        proposal.Actual_Discount_Value__c = 0;
        proposal.Apttus_Proposal__Approval_Stage__c = 'Finalized'; 
        proposal.Approval_Status__c = 'None';
        insert proposal;
        
        Test.startTest();
        CNT_CPQ_TSJapanWorkflowController.submitForApprovalProcess(proposal.Id);
        CNT_CPQ_TSJapanWorkflowController.createWorkItemOnApprove(proposal.Id, 'Approver 1');
        Test.stopTest();
        List<Apttus_Proposal__Proposal__c> updatedProposal = [Select Apttus_Proposal__Approval_Stage__c From Apttus_Proposal__Proposal__c Where Id =: proposal.Id];
    }*/
    
    @IsTest
    static void testRecallAction() {
        Account account = [SELECT Id FROM Account Limit 1];
        
        Opportunity opportunity = [SELECT Id FROM Opportunity LIMIT 1];
        
        RecordType recordType  = [SELECT Id FROM RecordType WHERE DeveloperName = :CON_CPQ.TECH_SOLUTION 
                                  AND SobjectType = 'Apttus_Proposal__Proposal__c' LIMIT 1];
        
        Apttus_Proposal__Proposal__c proposal = UTL_TestData.setTSProposalData(false, CON_CPQ.TECH_SOLUTION, opportunity.Id, CON_CPQ.TS_JAPAN);
        proposal.Apttus_Proposal__Account__c = account.Id;
        proposal.Min_Gross_Margin__c = 15;
        proposal.Vendor_Use__c = true;
        proposal.Apttus_Proposal__Approval_Stage__c = CON_CPQ.PENDING_APPROVAL;
        proposal.CurrencyIsoCode = CON_CPQ.CURRENCY_JPY;
        insert proposal;
        
        // Create Proposal Line Items
        Product2 product = UTL_TestData.createProduct();
        Apttus_Proposal__Proposal_Line_Item__c lineItem = UTL_TestData.createProposalLineItem(proposal.Id, product.Id);
        insert lineItem;
        
        // Recall Action
        Test.startTest();
        CNT_CPQ_TSJapanWorkflowController.recallProposal(proposal.Id);
        Test.stopTest();
        
        // Verify updated value of Proposal
        List<Apttus_Proposal__Proposal__c> updatedProposal = [Select Apttus_Proposal__Approval_Stage__c From Apttus_Proposal__Proposal__c Where Id =: proposal.Id];
        System.assertEquals(CON_CPQ.IN_PROGRESS_STATUS, updatedProposal[0].Apttus_Proposal__Approval_Stage__c, 'Approval Stage mis-match');
    }
    
    @IsTest
    static void testAcceptAction() {
        Account account = [SELECT Id FROM Account Limit 1];
        
        Opportunity opportunity = [SELECT Id FROM Opportunity LIMIT 1];
        Apttus_Proposal__Proposal__c proposal = UTL_TestData.setTSProposalData(false, CON_CPQ.TECH_SOLUTION, opportunity.Id, CON_CPQ.TS_JAPAN);
        proposal.Apttus_Proposal__Account__c = account.Id;
        proposal.Min_Gross_Margin__c = 15;
        proposal.Vendor_Use__c = true;
        proposal.Apttus_Proposal__Approval_Stage__c = CON_CPQ.PENDING_APPROVAL;
        proposal.CurrencyIsoCode = CON_CPQ.CURRENCY_JPY;
        insert proposal;
        
        // Create Proposal Line Items
        Product2 product = UTL_TestData.createProduct();
        Apttus_Proposal__Proposal_Line_Item__c lineItem = UTL_TestData.createProposalLineItem(proposal.Id, product.Id);
        insert lineItem;
        
        // Recall Action
        Test.startTest();
        CNT_CPQ_TSJapanWorkflowController.updateQuoteStatus(proposal.Id, 'Accepted');
        Test.stopTest();
        
        // Verify updated value of Proposal
        List<Apttus_Proposal__Proposal__c> updatedProposal = [Select Apttus_Proposal__Approval_Stage__c From Apttus_Proposal__Proposal__c Where Id =: proposal.Id];
        System.assertEquals(CON_CPQ.ACCEPTED, updatedProposal[0].Apttus_Proposal__Approval_Stage__c, 'Approval Stage mis-match');
    }
    
    @isTest
    static void testupdateQuoteStatusOCE() {
        Account account = [SELECT Id FROM Account Limit 1];
        
        Opportunity opportunity = [SELECT Id FROM Opportunity LIMIT 1];
        
        RecordType recordType  = [SELECT Id FROM RecordType WHERE DeveloperName = :CON_CPQ.TECH_SOLUTION 
                                  AND SobjectType = 'Apttus_Proposal__Proposal__c' LIMIT 1];
        
        Apttus_Proposal__Proposal__c proposal = UTL_TestData.setTSProposalData(false, CON_CPQ.TECH_SOLUTION, opportunity.Id, CON_CPQ.TS_JAPAN);
        proposal.Apttus_Proposal__Account__c = account.Id;
        proposal.Apttus_Proposal__Approval_Stage__c = CON_CPQ.DRAFT;
        proposal.CurrencyIsoCode = CON_CPQ.CURRENCY_JPY;
        insert proposal;
        
        Test.startTest();
        	CNT_CPQ_TSJapanWorkflowController.updateQuoteStatusOCE(proposal.Id, CON_CPQ.APPROVED, CON_CPQ.APPROVED);
        Test.stopTest();
        
    }
    @isTest
    static void testCheckForAutoApprove() {
        Account account = [SELECT Id FROM Account Limit 1];
        
        Opportunity opportunity = [SELECT Id FROM Opportunity LIMIT 1];
		
        Apttus_Proposal__Proposal__c proposal = UTL_TestData.setTSProposalData(false, CON_CPQ.TECH_SOLUTION, opportunity.Id, CON_CPQ.OCE);
        proposal.Apttus_Proposal__Account__c = account.Id;
        proposal.Average_Gross_Margin__c = 15;
        proposal.Approver_Level__c = 1; 
        proposal.Total_Amount__c = 40000; 
        proposal.CountryCode__c = 'India'; 
        proposal.Average_Gross_Margin__c = 40; 
        proposal.Apttus_Proposal__Discount_Percent__c = 0; 
        proposal.Actual_Discount_Value__c = 0;
        proposal.Apttus_Proposal__Approval_Stage__c = 'Finalized'; 
        proposal.Approval_Status__c = 'None';
        insert proposal;

        Approval_Matrix__c appmat1 = new Approval_Matrix__c(Levels__c= 'Level 1', Country__c = 'India', 
                                                            Min_Amount__c = 0, Max_Amount__c = 50000, Min_Gross_Margin__c = 0, 
                                                            Max_Gross_Margin__c = 45, Min_Discount_Percent__c = -100, Max_Discount_Percent__c = 100, 
                                                            Min_Discount_Amount__c = -99999999, Max_Discount_Amount__c = 99999999, 
                                                            Auto_Approve__c = true, Track_Name__c = 'CPQ',
                                                            Pricing_Tool__c = 'OCE', Notifier_1__c = UserInfo.getUserEmail(), Notifier_2__c = UserInfo.getUserEmail(),
                                                            Notifier_3__c = UserInfo.getUserEmail(), Notifier_4__c = UserInfo.getUserEmail(), Notifier_5__c = UserInfo.getUserEmail(), Process_Type__c = CON_CPQ.APPROVAL_PROCESS);
        insert appmat1;
        Approval_Matrix__c appmat2 = new Approval_Matrix__c(Levels__c= 'Level 2', Country__c = 'India', 
                                                            Min_Amount__c = 0, Max_Amount__c = 50000, Min_Gross_Margin__c = 0, 
                                                            Max_Gross_Margin__c = 45, Min_Discount_Percent__c = -100, Max_Discount_Percent__c = 100, 
                                                            Min_Discount_Amount__c = -99999999, Max_Discount_Amount__c = 99999999, 
                                                            Approver_1__c = UserInfo.getUserId(), Auto_Approve__c = false, Track_Name__c = 'CPQ',
                                                            Pricing_Tool__c = 'OCE', Process_Type__c = CON_CPQ.APPROVAL_PROCESS);
        insert appmat2;
		test.startTest();
        CNT_CPQ_TSJapanWorkflowController.submitForApprovalProcess(proposal.Id);
        CNT_CPQ_TSJapanWorkflowController.createWorkItemOnApprove(proposal.Id, 'Approver 1');
        String result1 = CNT_CPQ_TSJapanWorkflowController.checkForAutoApprove(1, CNT_CPQ_TSJapanWorkflowController.approversMap.get('Level 1'), proposal, null, 'Auto Approve');
        String result2 = CNT_CPQ_TSJapanWorkflowController.checkForAutoApprove(1, CNT_CPQ_TSJapanWorkflowController.approversMap.get('Level 2'), proposal, null, 'Approve');
        String result3 = CNT_CPQ_TSJapanWorkflowController.checkForAutoApprove(2, CNT_CPQ_TSJapanWorkflowController.approversMap.get('Level 2'), proposal, null, 'Approve');
        test.stopTest();
        System.assertEquals('SUCCESS', result2, 'Auto Approved');
    }

    @isTest
    static void testGetCollaborationConfigCartURL() { 
        CPQ_Proposal_Create_Settings__c cpcs = new CPQ_Proposal_Create_Settings__c(Name = 'CPQ TS AMESA', Available_Pricing_Tools__c = 'AMESA', Flow_Name__c = 'AMESA', Permission_Set_Name__c = 'CPQ_TS_AMESA_Data_ReadWrite', Proposal_Record_Type_Name__c = 'Tech_Solution', Price_List__c = 'AMESA Price List - CHF');
        insert cpcs;
        
        Account account = [SELECT Id FROM Account Limit 1];
        
        Opportunity opportunity = [SELECT Id FROM Opportunity LIMIT 1];
        
        RecordType recordType  = [SELECT Id FROM RecordType WHERE DeveloperName = :CON_CPQ.TECH_SOLUTION 
                                  AND SobjectType = 'Apttus_Proposal__Proposal__c' LIMIT 1];
        
        Apttus_Proposal__Proposal__c proposal = UTL_TestData.setTSProposalData(false, CON_CPQ.TECH_SOLUTION, opportunity.Id, CON_CPQ.AMESA);
        proposal.Apttus_Proposal__Account__c = account.Id;
        insert proposal;
        Apttus_Config2__ProductConfiguration__c pc = new Apttus_Config2__ProductConfiguration__c(Name = 'test', Apttus_QPConfig__Proposald__c = proposal.Id);
        insert pc;
        
        Apttus_Config2__CollaborationRequest__c collabRequest = new Apttus_Config2__CollaborationRequest__c(OwnerId = UserInfo.getUserId(), Apttus_Config2__Status__c = 'Submitted', Apttus_Config2__ParentConfigurationId__c = pc.Id);
        insert collabRequest; 
        
        Test.startTest();
        String result = CNT_CPQ_TSJapanWorkflowController.getCollaborationConfigCartURL(collabRequest.Id);
        Test.stopTest();
		
        System.assertEquals('AMESA&true', result, 'amesa');
    }
}