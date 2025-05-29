@isTest
public class TST_PRP_FL01_CPQ_Proposal {
     /*
    * This method is used to setup data for all methods.
    */
    @testSetup
    static void dataSetup() { 
        Account acc = UTL_TestData.createAccount();
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'TestOpportunity';
        opp.stageName = CON_CRM.IDENTIFYING_OPP_STAGE;
        opp.AccountId = acc.Id;
        opp.CurrencyIsoCode = CON_CPQ.USD;
        opp.Is_this_IQVIA_Biotech__c = CON_CPQ.YES_TITLE_CASE;
        opp.Legacy_Quintiles_Opportunity_Number__c = CON_CPQ.TEST_OPPORTUNITY_NUMBER;
        opp.CloseDate = System.today();
        opp.Global_project_unit__c = 'AA/Japan';
        opp.Number_of_Potential_Regions__c = 0;
        opp.Executive_Sponsor__c = null;
        opp.Line_of_Business__c = 'Clinical';
        opp.Path_Probability__c ='Advance to Potential';
        insert opp;
        
        CPQ_Settings__c cpqSetting = new CPQ_Settings__c();
        cpqSetting.Name = 'Test CPQ Setting';
        cpqSetting.No_of_Installment_for_Schedule_Creation__c = 1;
        cpqSetting.Timeout_Delay__c = 0;
        insert cpqSetting;
        
        Bid_History__c clinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
        
        
        List<Apttus_Proposal__Proposal__c> proposalList = new List<Apttus_Proposal__Proposal__c>();
        
        Apttus_Proposal__Proposal__c initialQuote = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, clinicalBid.Id);
        initialQuote.Apttus_Proposal__Proposal_Category__c = CON_CPQ.INITIAL;
        initialQuote.Apttus_Proposal__Approval_Stage__c  = CON_CPQ.PRESENTED;
        initialQuote.Apttus_Proposal__Primary__c = false;
        initialQuote.XAE_Lock_Timestamp__c = Datetime.now() - 0.25 - 0.01041667;
        initialQuote.Budget_Checked_Out_By__c = UserInfo.getUserId();
        initialQuote.Pricing_Tool_Locked__c = true;
        proposalList.add(initialQuote);
        
        Apttus_Proposal__Proposal__c COQuote = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, clinicalBid.Id);
        COQuote.Apttus_Proposal__Proposal_Category__c = CON_CPQ.CHNAGE_ORDER;
        proposalList.add(COQuote); 
        update proposalList;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(), IsActive = true);
        update standardPricebook;
        
        Product2 testProduct = UTL_TestData.createProduct();
        testProduct.Billing_System__c = CON_CPQ.SAP;
        insert testProduct;
        
        PricebookEntry testPricebookEntry = UTL_TestData.createPricebookEntry(testProduct.Id);
        testPricebookEntry.CurrencyIsoCode = CON_CPQ.USD;
        insert testPricebookEntry;
                
        Apttus_Proposal__Proposal_Line_Item__c budgetLineItem = UTL_TestData.createProposalLineItem(initialQuote.Id, testProduct.Id);
        budgetLineItem.Sale_Type__c = CON_CPQ.SALE_TYPE_NEW;
        budgetLineItem.Revenue_Type__c = CON_CPQ.AD_HOC;
        budgetLineItem.IQVIA_Line_Type__c = CON_CPQ.CRM_Product;
        budgetLineItem.BidGrid_Country__c = 'Canada';
        budgetLineItem.Apttus_QPConfig__NetPrice__c = 2976070.05;
        insert budgetLineItem;
             
        Apttus_Proposal__Proposal_Line_Item__c budgetLineItem2 = UTL_TestData.createProposalLineItem(initialQuote.Id, testProduct.Id);
        budgetLineItem2.Sale_Type__c = CON_CPQ.SALE_TYPE_NEW;
        budgetLineItem2.Revenue_Type__c = CON_CPQ.AD_HOC;
        budgetLineItem2.IQVIA_Line_Type__c = CON_CPQ.CRM_Product;
        budgetLineItem2.BidGrid_Country__c = CON_CPQ.USA;
        budgetLineItem2.Apttus_QPConfig__NetPrice__c = 2976070.05;
        insert budgetLineItem2;  
    }
    
    @isTest
    static void testSendMailOnSyncFail() {
        Apttus_Proposal__Proposal__c testProposal = [SELECT Id,Record_Type_Name__c,Execution_Status__c FROM Apttus_Proposal__Proposal__c Where Apttus_Proposal__Proposal_Category__c = :CON_CPQ.INITIAL LIMIT 1];
        Opportunity testOpportunity = [Select Id, Executive_Sponsor__c from Opportunity Limit 1];
        
        testProposal.Apttus_Proposal__Primary__c = true;
        testProposal.Bid_Sent_Date__c = Date.newInstance(2023, 10, 13);
        testProposal.Number_of_Line_Items__c =2;
        testProposal.Apttus_QPConfig__ConfigurationFinalizedDate__c = Datetime.newInstance(2023, 10, 13, 0, 0, 0);
        testProposal.Bottom_Line_Discount_Amount_BLDA__c =100;
        testProposal.Total_Bid_Value_Labor_Direct_Discount__c =100;
        testProposal.Link_to_Budget_Files__c = 'test';
        testProposal.Bid_Sent__c =CON_CPQ.YES_TITLE_CASE;
        testProposal.Additional_Explanation__c ='test';
        testProposal.Pricing_Under_MSA__c =CON_CPQ.YES_TITLE_CASE;
        testProposal.RFP_Folder_Link__c ='https://iqviacpq.app.box.com//folder/193623868958';
        testProposal.Number_of_Scenarios__c = 2;
       
        Test.startTest();   
		    update testProposal;
        Test.stopTest();
        
        Apttus_Proposal__Proposal__c proposal = [SELECT Id,Record_Type_Name__c,Execution_Status__c FROM Apttus_Proposal__Proposal__c Where Id =:testProposal.Id];
        //System.assertEquals('Failed',proposal.Execution_Status__c,'Sync failed');
    }
    @isTest
    static void testSendMailOn_CO_Quote_Acceptance() {
        Apttus_Proposal__Proposal__c testProposal = [SELECT Id,Record_Type_Name__c FROM Apttus_Proposal__Proposal__c Where Apttus_Proposal__Proposal_Category__c = :CON_CPQ.CHNAGE_ORDER LIMIT 1];
        testProposal.Apttus_Proposal__Approval_Stage__c =CON_CPQ.ACCEPTED;
        Test.startTest();
            update testProposal;
        Test.stopTest();
        Apttus_Proposal__Proposal__c proposal = [SELECT Id, Apttus_Proposal__Approval_Stage__c FROM Apttus_Proposal__Proposal__c Where Apttus_Proposal__Proposal_Category__c = :CON_CPQ.CHNAGE_ORDER];
        System.assertEquals ('Accepted',proposal.Apttus_Proposal__Approval_Stage__c, 'Proposal Accepted');
    }
    
    @isTest
    static void testSendMailOnRDS_Budget_Creation() {
        Bid_History__c testBidHistory = [Select Id,Is_there_a_Client_Bid_Grid__c from Bid_History__c limit 1];
        testBidHistory.Is_there_a_Client_Bid_Grid__c = CON_CPQ.YES_TITLE_CASE;
        update testBidHistory;
        
        Opportunity testOpportunity = [Select Id from Opportunity Limit 1];

        Id recordTypeId =
            SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByDeveloperName().get(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET).getRecordTypeId();
        Apttus_Proposal__Proposal__c testProposal = new Apttus_Proposal__Proposal__c(Apttus_Proposal__Proposal_Name__c = 'test proposal');
        testProposal.Apttus_Proposal__Opportunity__c = testOpportunity.Id;
        testProposal.RecordTypeId = recordTypeId;
        testProposal.Select_Pricing_Tool__c = CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT;
        testProposal.Clinical_Bid__c = testBidHistory.Id;
        testProposal.Scenario_Number__c = 12;
        testProposal.DTE_Study__c = CON_CPQ.YES_TITLE_CASE;
        testProposal.Scenario_Description__c = CON_CPQ.OPPORTUNITY_BALLPARK;
        testProposal.Budget_Iteration__c = 1;
        testProposal.RFP_Scenario__c = 'Bid to Spec';
        testProposal.Apttus_Proposal__Primary__c = true;
        
        testProposal.Apttus_Proposal__Approval_Stage__c =CON_CPQ.DRAFT;
        testProposal.Apttus_Proposal__Proposal_Category__c = CON_CPQ.INITIAL;
        Test.startTest();
        insert testProposal;     
        Test.stopTest();
        Apttus_Proposal__Proposal__c proposal = [Select id,Apttus_Proposal__Proposal_Name__c from Apttus_Proposal__Proposal__c where Id=:testProposal.Id ];
        System.assertEquals('TestOpportunity-1-12',proposal.Apttus_Proposal__Proposal_Name__c,'Record Inserted');
    }
    @isTest
    static void testNotifyBudgetOwnerToUnlockQuoteAfter4Hours() {
        Apttus_Proposal__Proposal__c testProposal = [SELECT Id, XAE_Lock_Timestamp__c, Budget_Checked_Out_By__c, Pricing_Tool_Locked__c, Scenario_Description__c FROM Apttus_Proposal__Proposal__c Where Apttus_Proposal__Proposal_Category__c = :CON_CPQ.INITIAL LIMIT 1];
        testProposal.Scenario_Description__c = 'Test Record Unlock';
        testProposal.XAE_Lock_Timestamp__c = Datetime.now().addHours(-4);
        Test.startTest();
            update testProposal;
        Test.stopTest();
        Apttus_Proposal__Proposal__c proposal = [Select id,Pricing_Tool_Locked__c,XAE_Lock_Timestamp__c, XAE_Unlock_Timestamp__c from Apttus_Proposal__Proposal__c where Id=:testProposal.Id ];
        System.debug('!!'+proposal.XAE_Unlock_Timestamp__c);
        System.assertEquals(true ,proposal.Pricing_Tool_Locked__c,'Quote is Locked After 4Hrs');
    }  
}