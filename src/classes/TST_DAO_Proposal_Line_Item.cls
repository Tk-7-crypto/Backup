@isTest
public class TST_DAO_Proposal_Line_Item {
    @testSetup
    static void dataSetup() {
        Account testAccount = UTL_TestData.createAccount();
        insert testAccount;
        
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        OWF_Config__c owfConfig = UTL_OWF_TestData.createOWFConfig(grp.Id);
        insert owfConfig;
        
        Opportunity testOpportunity= UTL_TestData.createOpportunity(testAccount.id);
        testOpportunity.Line_of_Business__c = CON_CPQ.SAMPLE_LINE_OF_BUSINESS;
        testOpportunity.Is_this_IQVIA_Biotech__c = CON_CPQ.YES_TITLE_CASE;
        testOpportunity.CurrencyIsoCode = CON_CPQ.USD;
        testOpportunity.Legacy_Quintiles_Opportunity_Number__c = 'MVP123';
        insert testOpportunity;
        Product2 testProduct = UTL_TestData.createProduct();
        insert testProduct;
        PricebookEntry testPricebookEntry = UTL_TestData.createPricebookEntry(testProduct.id);
        testPricebookEntry.CurrencyIsoCode = CON_CPQ.USD;
        testPricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
        insert testPricebookEntry;
        
        Bid_History__c testClinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
        
        Apttus_Proposal__Proposal__c budget = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, testClinicalBid.Id);  
    }
    @isTest
    static void onBeforeInsert(){
        Apttus_Proposal__Proposal__c proposal = [SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1];
        Apttus_Proposal__Proposal_Line_Item__c budgetLineItem = UTL_TestData.createQuoteLineItem(proposal.Id);
        budgetLineItem.IQVIA_Line_Type__c = CON_CPQ.CRM_Product;
        
        Test.startTest();
            insert budgetLineItem;
        Test.stopTest();
        
        Integer expected = 1;
        Integer actual = [Select Id From Apttus_Proposal__Proposal_Line_Item__c].size();
        system.assertEquals(expected, actual);
    }
}