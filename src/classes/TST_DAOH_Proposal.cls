@isTest
public class TST_DAOH_Proposal {
    
    @testSetup
    static void setUpTestData() {        
        List<SObject_Sharing__c> socsList = new List<SObject_Sharing__c>();
        SObject_Sharing__c sObjectParentSharing = UTL_TestData.createSObjectSharingParentData('Apttus_Proposal__Proposal__c', 'Apttus_Proposal__Proposal__share','Proposal_Territory__c','Agreement_Team__c', 'Derived', 'Agreement__c', 'Account_Country__c', 'Record_Type_Developer_Name__c', '', '');
        socsList.add(sObjectParentSharing);
        insert socsList;
        List<Group> groupList = [Select Id FROM Group LIMIT 1];
        Territory_Sharing__c territorySharing = UTL_TestData.createTerritorySharingData(groupList[0].Id, 'Apttus_Proposal__Proposal__c');
        insert territorySharing;
        Account acc = UTL_TestData.createAccount();
        acc.AccountCountry__c = 'AL';
        insert acc;
        
        SObject_Sharing_Settings__c sharingSetting = new SObject_Sharing_Settings__c();
        sharingSetting.Sharing_Daily_Correction_Batch_Name__c = 'BCH_GBL_Sharing_Daily_Correction';
        sharingSetting.Sharing_Failure_Correction_Batch_Name__c = 'BCH_GBL_Sharing_Failure_Correction';
        sharingSetting.Sharing_Maintenance_Job_Batch_Name__c = 'BCH_GBL_Sharing_Maintenance_Job';
        sharingSetting.Parent_Sharing_FieldSet_Name__c = 'SHR_Parent_FieldSet';
        sharingSetting.Child_Sharing_FieldSet_Name__c = 'SHR_Child_FieldSet';
        sharingSetting.Last_Sharing_Calculation_Timestamp__c = System.Now().addMinutes(-100);
        insert sharingSetting;
    }
    
    @isTest
    static void testSetSharing(){
        Test.startTest();
        Account acc = [SELECT Id,AccountCountry__c FROM Account Limit 1];
        Opportunity opp = setOpportunityData(acc.Id);
        Bid_History__c testClinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);

        Apttus_Proposal__Proposal__c proposal = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, testClinicalBid.Id);
        proposal.Apttus_Proposal__Account__c = acc.Id;
        update proposal;
        Test.stopTest();
    }
    
    @isTest
    static void testSetAccountCountry(){
        Account acc = [SELECT Id,AccountCountry__c FROM Account Limit 1];
        Opportunity opp = setOpportunityData(acc.Id);
        Bid_History__c testClinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
        Test.startTest();
        Apttus_Proposal__Proposal__c proposal = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, testClinicalBid.Id);
        proposal.Apttus_Proposal__Account__c = acc.Id;
        update proposal;

        Test.stopTest();
        Apttus_Proposal__Proposal__c quote = [SELECT Id,Account_Country__c FROM Apttus_Proposal__Proposal__c WHERE Id = :proposal.Id Limit 1];
        System.assertEquals(acc.AccountCountry__c, quote.Account_Country__c);
    }
    
    @isTest
    static void testSetLastSharingCalculationTimestamp(){
        Account acc = [SELECT Id,AccountCountry__c FROM Account Limit 1];
        Opportunity opp = setOpportunityData(acc.Id);
        Bid_History__c testClinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);

        Apttus_Proposal__Proposal__c proposal = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, testClinicalBid.Id);
        proposal.Apttus_Proposal__Account__c = acc.Id;
        update proposal;
        
        Test.startTest();
        proposal.Apttus_Proposal__Account__c = null;
        update proposal;
        Test.stopTest();
        
        Apttus_Proposal__Proposal__c agr = [SELECT Id, Last_Sharing_Calculation_Timestamp__c FROM Apttus_Proposal__Proposal__c WHERE Id = :proposal.Id Limit 1];
        Date expected = Date.today(); 
        DateTime dT = agr.Last_Sharing_Calculation_Timestamp__c;
        Date actual = date.newinstance(dT.year(), dT.month(), dT.day());
        System.assertEquals(expected,actual);
    }
    
    @isTest
    static void testSetLastManualSharingFieldUpdate(){
        Account acc = [SELECT Id,AccountCountry__c FROM Account Limit 1];
        Opportunity opp = setOpportunityData(acc.Id);
        Bid_History__c testClinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);

        Apttus_Proposal__Proposal__c proposal = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, testClinicalBid.Id);
        proposal.Apttus_Proposal__Account__c = acc.Id;
        update proposal;
        Test.startTest();
        proposal.Run_Sharing__c = true;
        update proposal;
        Test.stopTest();
        Apttus_Proposal__Proposal__c agr = [SELECT Id, Last_Manual_Sharing_Execution__c FROM Apttus_Proposal__Proposal__c WHERE Id = :proposal.Id Limit 1];
        Date expected = Date.today(); 
        DateTime dT = agr.Last_Manual_Sharing_Execution__c;
        Date actual = date.newinstance(dT.year(), dT.month(), dT.day());
        System.assertEquals(expected,actual);
    }
    
	private static Opportunity setOpportunityData(Id accountId){
        
        Opportunity testOpportunity = UTL_TestData.createOpportunity(accountId);
        testOpportunity.Line_of_Business__c = CON_CPQ.SAMPLE_LINE_OF_BUSINESS;
        testOpportunity.Legacy_Quintiles_Opportunity_Number__c = CON_CPQ.TEST_OPPORTUNITY_NUMBER;
        insert testOpportunity;
        return testOpportunity;
    }
    
    private static Account setAccountData() {
        
        Account testAccount = UTL_TestData.createAccount();
        insert testAccount;
        return testAccount;
    }
    
    @isTest
    public static void testProposalBeforeUpdate() {
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        
        Bid_History__c testClinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);

        Contract testContract = UTL_TestData.createContract(testOpportunity, 'Generic_Contract');
        testContract.Contract_Ranking__c = '1.1'; 
        insert testContract;

        Apttus_Config2__PriceList__c pl = TST_TestGeneratorClass.buildTestPriceList(CON_CPQ.MIDDLE_EAST_PRICE_LIST_EGP);
        
        Apttus_Proposal__Proposal__c budget = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, testClinicalBid.Id);
        
        // AMESA budget
        Apttus_Proposal__Proposal__c amesaBudget = UTL_TestData.setTSProposalData(false, CON_CPQ.TECH_SOLUTION, testOpportunity.Id, CON_CPQ.AMESA);
        amesaBudget.Apttus_Proposal__Approval_Stage__c = CON_CPQ.APPROVED;
        amesaBudget.CurrencyIsoCode = 'EGP';
        amesaBudget.Apttus_QPConfig__PriceListId__c = pl.Id;
        insert amesaBudget;
        
        Test.startTest();
        	budget.Contract__c = testContract.Id;
            budget.Pricing_Tool_Locked__c = true;
            budget.Budget_Checked_Out_By__c = UserInfo.getUserId();
        
            amesaBudget.Apttus_Proposal__Proposal_Name__c = 'Test Proposal';
            amesaBudget.Apttus_Proposal__Approval_Stage__c = CON_CPQ.GENERATED;
            List<Apttus_Proposal__Proposal__c> updateProposalList = new List<Apttus_Proposal__Proposal__c>();
            updateProposalList.add(budget);
            updateProposalList.add(amesaBudget);
            update updateProposalList;
            
        Test.stopTest();
        
        List<Apttus_Proposal__Proposal__c> budgetList = [SELECT Id, XAE_Lock_Timestamp__c FROM Apttus_Proposal__Proposal__c WHERE Id = :budget.Id Limit 1];
        System.assertNotEquals(null, budgetList[0].XAE_Lock_Timestamp__c);          
    }
    
    @isTest
    public static void testMoveToPresentedStage() 
    {
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        
        Bid_History__c clinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
        
        Apttus_Proposal__Proposal__c budget = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, clinicalBid.Id);
        budget.Apttus_Proposal__Primary__c = true;
        budget.Bottom_Line_Discount_Amount_BLDA__c = 1.0;
        budget.Total_Bid_Value_Labor_Direct_Discount__c = 1;
        budget.Link_to_Budget_Files__c = 'TST';
        budget.Bid_Sent__c = 'Yes';
        budget.Number_of_Scenarios__c = 10;
        budget.Additional_Explanation__c = 'TST';
        budget.Pricing_Under_MSA__c = 'Yes';
        budget.Select_Pricing_Tool__c = CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_LCS_UPT;
        budget.Apttus_Proposal__Approval_Stage__c = CON_CPQ.GENERATED;
        budget.Apttus_QPConfig__ConfigurationFinalizedDate__c = System.today();
        budget.Bottom_Line_Discount_Amount_BLDA__c = 1.0;
        budget.Apttus_Proposal__Proposal_Category__c = CON_CPQ.INITIAL;
        budget.Contribution_Margin__c = 10;

        
        Apttus_Proposal__Proposal_Line_Item__c budgetLineItem = UTL_TestData.createQuoteLineItem(budget.Id);
        budgetLineItem.IQVIA_Line_Type__c = CON_CPQ.CRM_Product;
        insert budgetLineItem;
        
        Test.startTest();
            budget.Bid_Sent_Date__c = System.today();
            budget.Number_of_Line_Items__c = 1;
            update budget;
        Test.stopTest();
        
        List<Apttus_Proposal__Proposal__c> budgetList = [SELECT Id, Apttus_Proposal__Approval_Stage__c FROM Apttus_Proposal__Proposal__c WHERE Id = :budget.Id Limit 1];
        System.assertEquals(CON_CPQ.PRESENTED, budgetList[0].Apttus_Proposal__Approval_Stage__c);          
    }
    
    @isTest
    public static void testCreateAdminTimeEntryData() 
    {
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        
        Bid_History__c testClinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);

        Apttus_Proposal__Proposal__c budget = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, testClinicalBid.Id);
        budget.Apttus_Proposal__Proposal_Category__c = CON_CPQ.INITIAL;
        budget.Apttus_Proposal__Approval_Stage__c = CON_CPQ.PRESENTED;
        
        Test.startTest();
            budget.Apttus_Proposal__Approval_Stage__c = CON_CPQ.ACCEPTED;
            update budget;
        Test.stopTest();
    }
    
    @isTest
    public static void testRemoveInitialOrRebidRelatedAgreement() 
    {
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        
        List<RecordType> recordType  = [SELECT Id FROM RecordType WHERE DeveloperName = 'Preliminary_Agreement' AND SobjectType = 'Apttus__APTS_Agreement__c' LIMIT 1];
        Apttus__APTS_Agreement__c agreement = UTL_TestData.createAgreement();
        agreement.Apttus__Related_Opportunity__c = testOpportunity.id;
        insert agreement;
        
        Bid_History__c testClinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);

        Apttus_Proposal__Proposal__c budget = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, testClinicalBid.Id);
        budget.Apttus_Proposal__Proposal_Category__c = CON_CPQ.INITIAL;
        budget.Apttus_QPComply__MasterAgreementId__c = agreement.Id;
        update budget;
        
        
        Test.startTest();
        	Apttus_Proposal__Proposal__c newBudget = UTL_TestData.createQuote();
            newBudget.Apttus_Proposal__Opportunity__c = testOpportunity.Id;
            newBudget.Clinical_Bid__c = testClinicalBid.Id;
        	newBudget.Select_Pricing_Tool__c = CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT;
            newBudget.Apttus_Proposal__Proposal_Category__c = CON_CPQ.PROJECT_SPECIFIC;
            insert newBudget;
        Test.stopTest(); 
        Apttus_Proposal__Proposal__c proposal = new SLT_Proposal().getProposalDetails(budget.Id, new Set<String> {CON_CPQ.ID, CON_CPQ.REALTED_AGREEMENT});
        System.assertEquals(proposal.Apttus_QPComply__MasterAgreementId__c, null, 'Related agreement field should be blank');
    }
    
    @isTest
    public static void testValidateLineItemCount() 
    {
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        
        Bid_History__c testClinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);

        Apttus_Proposal__Proposal__c budget = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, testClinicalBid.Id);
        
        Apttus_Proposal__Proposal_Line_Item__c budgetLineItem = UTL_TestData.createQuoteLineItem(budget.Id);
        budgetLineItem.IQVIA_Line_Type__c = CON_CPQ.CRM_Product;
        insert budgetLineItem;
        
        Test.startTest();
            budget.Apttus_QPConfig__ConfigurationFinalizedDate__c = System.today();
            budget.Number_of_Line_Items__c = 1;
            update budget;
        Test.stopTest();      
    }
    
    @isTest
    public static void testCreateTeamMemberForPL() 
    {
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        
        Bid_History__c testClinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
        
        Contact testContact = UTL_TestData.createContact(testAccount.Id);
        testContact.recordTypeId = CON_CLM.IQVIA_USER_CONTACT_RECORDTYPEID;
        testContact.EmployeeNumber__c = '1112222';
        insert testContact;
        
        Apttus__APTS_Agreement__c testAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        testAgreement.Name = CON_CPQ.TEST_BODY;
        testAgreement.IQVIA_Project_Manager_Con__c = testContact.Id;
        insert testAgreement;

        Test.startTest();
            Apttus_Proposal__Proposal__c budget = UTL_TestData.createQuote();
        	Id recordTypeId = SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByDeveloperName().get(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET).getRecordTypeId();
        	budget.Apttus_Proposal__Opportunity__c = testOpportunity.Id;
        	budget.RecordTypeId = recordTypeId;
        	budget.Select_Pricing_Tool__c = CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT;
        	budget.Clinical_Bid__c = testClinicalBid.Id;
        	budget.Scenario_Number__c = 123.0;
        	budget.DTE_Study__c = CON_CPQ.YES_TITLE_CASE;
        	budget.Scenario_Description__c = CON_CPQ.OPPORTUNITY_BALLPARK;
        	budget.Budget_Iteration__c = 1;
        	budget.RFP_Scenario__c = CON_CPQ.OPPORTUNITY_BALLPARK;
        	budget.Apttus_Proposal__Primary__c = true;
            budget.Apttus_QPComply__MasterAgreementId__c = testAgreement.Id;
            budget.Apttus_Proposal__Proposal_Category__c = CON_CPQ.PROJECT_SPECIFIC;
            insert budget;
        Test.stopTest();
        
        List<Team_Member__c> teamMemberList = new SLT_TeamMember().getTeamMemberByProposalIdANDMemberRole(new Set<Id> {budget.Id}, new Set<String> {CON_CPQ.ID, CON_CPQ.MEMBER_ROLE}, new List<String> {CON_CPQ.APPROVER});
        System.assertEquals(teamMemberList.size(), 1, 'Team member record created for PL');
    }
    @isTest
    static void testSetBudgetAmountFields(){
        Account acc = [SELECT Id,AccountCountry__c FROM Account Limit 1];
        Opportunity opp = setOpportunityData(acc.Id);
        
        Bid_History__c testClinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
        Test.startTest();
        Apttus_Proposal__Proposal__c proposal = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, testClinicalBid.Id);
        proposal.Apttus_Proposal__Account__c = acc.Id;
        proposal.Apttus_Proposal__Proposal_Category__c = CON_CPQ.INITIAL;
        proposal.Total_IQVIA_Fees_Bottom_Line_Discount__c = 20;
        proposal.Total_IQVIA_Fees__c = 10;
        proposal.Professional_Fees_Variance__c = 10;
        proposal.Q2_Sol_Prof_Fees__c = 10;
        proposal.Total_INV_Grants__c = 10;
        proposal.Total_Expenses_Other__c = 10;
        proposal.Expenses_Variance__c = 10;
        proposal.Q2_Sol_Expenses__c = 10;
        update proposal;
        Test.stopTest();
        Apttus_Proposal__Proposal__c budget = [SELECT Id,Account_Country__c,Actual_Quote_Amount__c,Project_Expense__c FROM Apttus_Proposal__Proposal__c WHERE Id = :proposal.Id Limit 1];
        System.assertEquals(30,budget.Actual_Quote_Amount__c,'Actual Quote Amount is not as expected');
        System.assertEquals(20,budget.Project_Expense__c,'Project Expense is not as expected');
    }
    @isTest
    public static void testResetCNFBudgetStatus() 
    {
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        
        Bid_History__c testClinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);

        Apttus_Proposal__Proposal__c budget = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, testClinicalBid.Id);
        budget.Apttus_Proposal__Proposal_Category__c = CON_CPQ.CNF;
        budget.Apttus_Proposal__Approval_Stage__c = CON_CPQ.PRESENTED;
        update budget;
        Test.startTest();
            budget.CNF_Status__c = CON_CPQ.REJECTED;
        	budget.CNF_Approval_Date__c = Date.today();
            update budget;
        Test.stopTest();
        Apttus_Proposal__Proposal__c proposal = [SELECT Id, Apttus_Proposal__Approval_Stage__c
                                               FROM Apttus_Proposal__Proposal__c WHERE Id = :budget.Id Limit 1];
        System.assertEquals(CON_CPQ.DRAFT, proposal.Apttus_Proposal__Approval_Stage__c);
    }
    @isTest
    public static void testSetBudgetLink() 
    {
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
		
        CPQ_Settings__c cpqSetting = new CPQ_Settings__c();
        cpqSetting.Name = 'Test CPQ Setting';
        cpqSetting.SFC_Template_Date__c = Date.today();
		cpqSetting.Box_Path__c = 'Test URL';
        insert cpqSetting;
        
        Bid_History__c testClinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
        
        List<RecordType> recordType  = [SELECT Id FROM RecordType WHERE DeveloperName = 'RDS_Budget' AND SobjectType = 'Apttus_Proposal__Proposal__c' LIMIT 1];

        Apttus_Proposal__Proposal__c proposal = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, testClinicalBid.Id);
        proposal.Apttus_Proposal__Account__c = testAccount.Id;
        proposal.Apttus_Proposal__Proposal_Category__c = CON_CPQ.CNF;
		
        Test.startTest();
            proposal.Budget_Tool_Version_Date__c = Date.today().addDays(2);
            update proposal;
        Test.stopTest();
        
        System.assertNotEquals('', proposal.External_Link__c, 'External_Link__c is populated with Box Path link');
    }
    
    @isTest
    public static void testResetCOLinkingFromRejectedCNF() 
    {
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        
        Bid_History__c testClinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);

        // Create CO budget
        Apttus_Proposal__Proposal__c COBudget = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, testClinicalBid.Id);
        COBudget.Apttus_Proposal__Proposal_Category__c = CON_CPQ.CHNAGE_ORDER;
        update COBudget;
        
        // Create CNF budget and link it with CO
        Apttus_Proposal__Proposal__c CNFBudget = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, testClinicalBid.Id);
        CNFBudget.Apttus_Proposal__Proposal_Category__c = CON_CPQ.CNF;
        CNFBudget.Apttus_Proposal__Approval_Stage__c = CON_CPQ.PRESENTED;
        update CNFBudget;
        Test.startTest();
            CNFBudget.CNF_Status__c = CON_CPQ.REJECTED_STATUS;
            CNFBudget.CNF_Approval_Date__c = Date.today();
            CNFBudget.Related_Change_Order__c = COBudget.Id;
            update CNFBudget;
        Test.stopTest();
        
        // Verify CO linking is removed from rejected CNF record
        Apttus_Proposal__Proposal__c proposal = [SELECT CNF_Status__c, Related_Change_Order__c FROM Apttus_Proposal__Proposal__c WHERE Id = :CNFBudget.Id];
        System.assertEquals(null, proposal.Related_Change_Order__c, 'Related change order mis-match');
        System.assertEquals(CON_CPQ.REJECTED_STATUS, proposal.CNF_Status__c, 'Status mis-match');
    }
    
    @isTest
    public static void testSetAmount() 
    {
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        Apttus_Config2__PriceList__c pl = TST_TestGeneratorClass.buildTestPriceList('Test PriceList');
        // Create budget
        Apttus_Proposal__Proposal__c budget = UTL_TestData.setTSProposalData(false, CON_CPQ.TECH_SOLUTION, testOpportunity.Id, CON_CPQ.OCE);
        budget.Apttus_Proposal__Approval_Stage__c = CON_CPQ.DRAFT;
        budget.Apttus_QPConfig__PriceListId__c = pl.Id;
        insert budget;
        
        Apttus_Proposal__Proposal_Line_Item__c lineItem1 = UTL_TestData.createQuoteLineItem(budget.Id);
        lineItem1.Apttus_QPConfig__LineType__c = CON_CPQ.OPTION;
        lineItem1.Apttus_QPConfig__NetPrice__c = 100;
        lineItem1.Apttus_QPConfig__ExtendedPrice__c = 120;
        Apttus_Proposal__Proposal_Line_Item__c lineItem2 = UTL_TestData.createQuoteLineItem(budget.Id);
        lineItem2.Apttus_QPConfig__LineType__c = CON_CPQ.OPTION;
        lineItem2.Apttus_QPConfig__NetPrice__c = 200;
        lineItem2.Apttus_QPConfig__ExtendedPrice__c = 140;
        Apttus_Proposal__Proposal_Line_Item__c lineItem3 = UTL_TestData.createQuoteLineItem(budget.Id);
        lineItem3.Apttus_QPConfig__LineType__c = 'Product/Service';
        lineItem3.Apttus_QPConfig__NetPrice__c = 300;
        lineItem3.Apttus_QPConfig__ExtendedPrice__c = 260;
        insert lineItem1;
        insert lineItem2;
        insert lineItem3;
        Test.startTest();
        budget.Apttus_Proposal__Approval_Stage__c = CON_CPQ.FINALIZED;
        update budget;
        Test.stopTest();
        
        // Verify Amount is updated on Budget
        Apttus_Proposal__Proposal__c proposal = [SELECT Total_Amount__c, Total_Amount_USD__c FROM Apttus_Proposal__Proposal__c WHERE Id = :budget.Id];
        System.assertNotEquals(0, proposal.Total_Amount__c);
        System.assertNotEquals(0, proposal.Total_Amount_USD__c);
    }
    @isTest
    public static void testSetStageGeneratedToApproved() 
    {
        Test.startTest();
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);

        Apttus_Config2__PriceList__c pl = TST_TestGeneratorClass.buildTestPriceList(CON_CPQ.MIDDLE_EAST_PRICE_LIST_EGP);
        // Create budget
        Apttus_Proposal__Proposal__c budget = UTL_TestData.setTSProposalData(false, CON_CPQ.TECH_SOLUTION, testOpportunity.Id, CON_CPQ.AMESA);
        budget.Apttus_Proposal__Approval_Stage__c = CON_CPQ.Approved;
        insert budget;
        
        budget.Apttus_Proposal__Approval_Stage__c = CON_CPQ.GENERATED;
        budget.Apttus_QPConfig__PriceListId__c = pl.Id;
        update budget;
        Test.stopTest();
    }
    
    @isTest
    public static void testSetAcceptedDate() 
    {
        Test.startTest();
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        Apttus_Config2__PriceList__c pl = TST_TestGeneratorClass.buildTestPriceList('Test PriceList');
        // Create budget
        Apttus_Proposal__Proposal__c budget = UTL_TestData.setTSProposalData(false, CON_CPQ.TECH_SOLUTION, testOpportunity.Id, CON_CPQ.OCE);
        budget.Apttus_Proposal__Approval_Stage__c = CON_CPQ.Draft;
        insert budget;
        budget.Apttus_Proposal__Approval_Stage__c = CON_CPQ.ACCEPTED;
        budget.Apttus_QPConfig__PriceListId__c = pl.Id;
        update budget;
        Test.stopTest();
        
        Apttus_Proposal__Proposal__c proposal = [SELECT Accepted_Date__c FROM Apttus_Proposal__Proposal__c WHERE Id = :budget.Id];
        System.assertNotEquals(null, proposal.Accepted_Date__c);
    }
    
    @isTest
    static void testSetBudgetFields() {
        Account acc = [SELECT Id,AccountCountry__c FROM Account Limit 1];
        Opportunity opp = setOpportunityData(acc.Id);
        Bid_History__c testClinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);

        Test.startTest();
        Apttus_Proposal__Proposal__c proposal = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, testClinicalBid.Id);
        proposal.Apttus_Proposal__Account__c = acc.Id;
        proposal.Apttus_Proposal__Proposal_Category__c = CON_CPQ.INITIAL;
        update proposal;
        Test.stopTest();
        Apttus_Proposal__Proposal__c quote = [SELECT Id, Approval_Status__c FROM Apttus_Proposal__Proposal__c WHERE Id = :proposal.Id Limit 1];
        System.assertEquals('None', quote.Approval_Status__c,'Approval Stage updated');
    }
    
    @isTest
    public static void testSetPriceList() 
    {
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        
        List<RecordType> recordType  = [SELECT Id FROM RecordType WHERE DeveloperName = 'Tech_Solution' AND SobjectType = 'Apttus_Proposal__Proposal__c' LIMIT 1];
        Apttus_Config2__PriceList__c pl = TST_TestGeneratorClass.buildTestPriceList('OCE Price List-CHF');
        insert pl;
        Apttus_Config2__PriceList__c pl2 = TST_TestGeneratorClass.buildTestPriceList('OCE Price List-EGP');
        pl2.Migration_Id__c = 'PL-13';
        insert pl2;
        // Create budget
        Apttus_Proposal__Proposal__c budget = UTL_TestData.setTSProposalData(false, CON_CPQ.TECH_SOLUTION, testOpportunity.Id, CON_CPQ.OCE);
        budget.Apttus_Proposal__Approval_Stage__c = CON_CPQ.DRAFT;
        budget.CurrencyIsoCode = 'CHF';
        budget.Apttus_QPConfig__PriceListId__c = pl.Id;
        insert budget;
        
        Test.startTest();
        budget.CurrencyIsoCode = 'EGP';
        update budget;
        Test.stopTest();
        
        Apttus_Proposal__Proposal__c proposal = [SELECT Apttus_QPConfig__PriceListId__c FROM Apttus_Proposal__Proposal__c WHERE Id = :budget.Id];
        System.assertEquals(pl2.Id, proposal.Apttus_QPConfig__PriceListId__c);
    }
    
    @isTest
    public static void testSetBudgetname() {
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        
        Bid_History__c testClinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.CONTRACT_POST_AWARD, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
        testClinicalBid.Contract_Ranking__c = '2.1';
        testClinicalBid.Project_Leader_Region__c = CON_CPQ.REGION_EMEA;
        testClinicalBid.Created_by_FormAssembly__c = true;
        update testClinicalBid;
        
        Test.startTest();
            Id recordTypeId =
                SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByDeveloperName().get(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET).getRecordTypeId();
            Apttus_Proposal__Proposal__c testProposal = UTL_TestData.createQuote();
            testProposal.Apttus_Proposal__Opportunity__c = testOpportunity.ID;
            testProposal.RecordTypeId = recordTypeId;
            testProposal.Select_Pricing_Tool__c = CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT;
            testProposal.Clinical_Bid__c = testClinicalBid.ID;
            testProposal.Scenario_Number__c = 12;
            testProposal.Scenario_Description__c = CON_CPQ.OPPORTUNITY_BALLPARK;
            testProposal.Budget_Iteration__c = 1;
            testProposal.RFP_Scenario__c = CON_CPQ.OPPORTUNITY_BALLPARK;
            testProposal.Apttus_Proposal__Primary__c = true;
            testProposal.Apttus_Proposal__Proposal_Category__c = CON_CPQ.BALLPARK;
            insert testProposal;
        Test.stopTest();
        
        List<Apttus_Proposal__Proposal__c> budgetList = [SELECT Id, Contract_Ranking__c FROM Apttus_Proposal__Proposal__c WHERE Id = :testProposal.Id Limit 1];
        Assert.areEqual('2.1', budgetList[0].Contract_Ranking__c,'Contract Ranking Updated');
    }

    @isTest
    public static void testSetPriceListOnCartAndLineItems() 
    {
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        
        List<RecordType> recordType  = [SELECT Id FROM RecordType WHERE DeveloperName = 'Tech_Solution' AND SobjectType = 'Apttus_Proposal__Proposal__c' LIMIT 1];
        Apttus_Config2__PriceList__c pl = TST_TestGeneratorClass.buildTestPriceList('DPS - USD');
        insert pl;
        Apttus_Config2__PriceList__c pl2 = TST_TestGeneratorClass.buildTestPriceList('DPS - EUR');
        pl2.Migration_Id__c = 'PL-13';
        insert pl2;
        
        Apttus_Proposal__Proposal__c budget = UTL_TestData.setTSProposalData(false, CON_CPQ.TECH_SOLUTION, testOpportunity.Id, CON_CPQ.COMPLETE_CONSENT);
        budget.Apttus_Proposal__Approval_Stage__c = CON_CPQ.DRAFT;
        budget.CurrencyIsoCode = 'USD';
        budget.Apttus_QPConfig__PriceListId__c = pl.Id;
        insert budget;
        
        List<Product2> prodList = new List<Product2>();
        Product2 prod = TST_TestGeneratorClass.buildTestProduct('LC9', 'Bundle', CON_CPQ.CPQ_TS_AMESA_Data_PI, 'US', 'Go Blue');       
        prod.CanUseRevenueSchedule = true;
        prodList.add(prod);
        Product2 prod1 = TST_TestGeneratorClass.buildTestProduct('LC9', 'Option', CON_CPQ.CPQ_TS_AMESA_Data_STD, 'US', 'Go Blue');
        prod1.CanUseRevenueSchedule = true;
        prodList.add(prod1);
        Product2 prod2 = TST_TestGeneratorClass.buildTestProduct('LC1', 'Option', CON_CPQ.CPQ_TS_AMESA_Data_SL_SF, 'US', 'Go Blue');
        prod2.CanUseRevenueSchedule = true;
        prodList.add(prod2);
        insert prodList;
        
        Apttus_Config2__ProductConfiguration__c prodConfig = new Apttus_Config2__ProductConfiguration__c();
        prodConfig.Apttus_QPConfig__Proposald__c = budget.Id;
        insert prodConfig;
        
        List<Apttus_Config2__LineItem__c> lineItemList = new List<Apttus_Config2__LineItem__c>();
        Apttus_Config2__LineItem__c lineItem = TST_TestGeneratorClass.createOptionConfigLineItem(prodConfig.Id, 1, 1, prod.id, prod1.Id, 1, 100);
        lineItemList.add(lineItem);
        Apttus_Config2__LineItem__c lineItem1 = TST_TestGeneratorClass.createOptionConfigLineItem(prodConfig.Id, 1, 1, prod.Id, prod2.Id, 1, 200);
        lineItemList.add(lineItem1);
        insert lineItemList;
        
        Test.startTest();
        budget.CurrencyIsoCode = 'EUR';
        update budget;
        Test.stopTest();
        
        Apttus_Proposal__Proposal__c proposal = [SELECT Apttus_QPConfig__PriceListId__c FROM Apttus_Proposal__Proposal__c WHERE Id = :budget.Id];
        System.assertEquals(pl2.Id, proposal.Apttus_QPConfig__PriceListId__c);
    }

    @isTest
    public static void testHandleCNFLinking() {

        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        
        Bid_History__c testClinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);

        Apttus_Proposal__Proposal__c COBudget = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, testClinicalBid.Id);
        COBudget.Apttus_Proposal__Proposal_Category__c = CON_CPQ.CHNAGE_ORDER;
        update COBudget;
        
        Apttus_Proposal__Proposal__c CNFBudget = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, testClinicalBid.Id);
        CNFBudget.Apttus_Proposal__Proposal_Category__c = CON_CPQ.CNF;
        CNFBudget.Apttus_Proposal__Approval_Stage__c = CON_CPQ.PRESENTED;
        CNFBudget.Change_Order_Number__c = '02';
        update CNFBudget;

        Test.startTest();
            CNFBudget.Change_Order_Number__c = '01';
            update CNFBudget;
        Test.stopTest();
        
        Apttus_Proposal__Proposal__c proposal = [SELECT CNF_Status__c, Related_Change_Order__c FROM Apttus_Proposal__Proposal__c WHERE Id = :CNFBudget.Id];
        System.assertEquals(null, proposal.Related_Change_Order__c, 'Related change order mis-match');
    }
    
    @isTest
    public static void testUpdateContractPostAwardBidDate() {
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        
        Bid_History__c testClinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.CONTRACT_POST_AWARD, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);

        Apttus_Proposal__Proposal__c CNFBudget = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, testClinicalBid.Id);
        CNFBudget.Apttus_Proposal__Proposal_Category__c = CON_CPQ.CNF;
        CNFBudget.CNF_Approval_Date__c = Date.today().addDays(2);
        CNFBudget.CNF_Status__c = CON_CPQ.REJECTED_STATUS;
        update CNFBudget;
        
        Test.startTest();
            CNFBudget.CNF_Approval_Date__c = Date.today();
            update CNFBudget;
        Test.stopTest();
        
        Apttus_Proposal__Proposal__c proposal = [SELECT CNF_Approval_Date__c, Clinical_Bid__r.Bid_Due_Date__c FROM Apttus_Proposal__Proposal__c WHERE Id = :CNFBudget.Id];
        System.assertEquals(proposal.CNF_Approval_Date__c, proposal.Clinical_Bid__r.Bid_Due_Date__c, 'Bid due date is updated');
    }
}