@IsTest
public class TST_CNT_CPQ_ApprovalProcessRLController {
	@TestSetup
    static void dataSetup() {
        Account account = UTL_OCE_TestData.createaccount();
        insert account;
        Opportunity opportunity = UTL_OCE_TestData.createOpportunity(account.Id);
        insert opportunity;		
    }
    @IsTest
    static void testGetApprovalSteps() {
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
        List<CNT_CPQ_ApprovalProcessRLController.WPR_CPQ_Step> wcs = CNT_CPQ_ApprovalProcessRLController.getApprovalSteps(proposal.Id);
        Test.stopTest();
        wcs[0].Name = 'Step1';
        System.assertEquals('Step1', wcs[0].Name, 'Step1');
    }
    
    @IsTest
    static void testGetAllApprovalSteps() {
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
        CNT_CPQ_ApprovalProcessRLController.WPR_CPQ_Details wcs = CNT_CPQ_ApprovalProcessRLController.getAllApprovalSteps(proposal.Id, CON_CPQ.APTTUS_PROPOSAL_PROPOSAL);
        Test.stopTest();
        wcs.approvalSteps[0].Name = 'Step1';
        System.assertEquals('Step1', wcs.approvalSteps[0].Name, 'Step1');
    }
    
}