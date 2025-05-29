@isTest
private class TST_CNT_CPQ_SendEmailOnCOQuoteAcceptance {
    /**
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
        insert opp;
        
        Bid_History__c clinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
        List<Apttus_Proposal__Proposal__c> proposalList = new List<Apttus_Proposal__Proposal__c>();
        
        Apttus_Proposal__Proposal__c quote1 = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, clinicalBid.Id);
        quote1.Apttus_Proposal__Proposal_Category__c = CON_CPQ.CHNAGE_ORDER;
        quote1.CurrencyIsoCode = CON_CPQ.USD;
        update quote1;
        
        Apttus_Proposal__Proposal__c quote2 = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, clinicalBid.Id);
        quote2.Apttus_Proposal__Proposal_Category__c = CON_CPQ.CNF;
        quote2.CurrencyIsoCode = CON_CPQ.USD;
        proposalList.add(quote2);
        
        Apttus_Proposal__Proposal__c quote3 = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, clinicalBid.Id);
        quote3.Apttus_Proposal__Proposal_Category__c = CON_CPQ.CNF;
        quote3.CurrencyIsoCode = CON_CPQ.USD;
        proposalList.add(quote3);
        
        Apttus_Proposal__Proposal__c quote4 = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, clinicalBid.Id);
        quote4.Apttus_Proposal__Proposal_Category__c = CON_CPQ.CNF;
        quote4.Related_Change_Order__c = quote1.Id;
        quote4.CurrencyIsoCode = CON_CPQ.USD;
        proposalList.add(quote4);
        update proposalList;  
    }

    @isTest 
    static void testGetAllCNFProposal() {
        Opportunity opp =[SELECT Id FROM Opportunity LIMIT 1];
        Test.startTest();
        	CNT_CPQ_SendEmailOnCOQuoteAcceptance.getAllCNFProposal();
        Test.stopTest();
        
        List<Apttus_Proposal__Proposal__c> cnfProposalList =[SELECT Id FROM Apttus_Proposal__Proposal__c WHERE Apttus_Proposal__Proposal_Category__c =: CON_CPQ.CNF AND Apttus_Proposal__Opportunity__c =: opp.Id];
        System.assertEquals(3, cnfProposalList.size(), 'CNF Record retrieved Successfully');
        
    }
    
    @isTest 
    static void testGetNonAssociatedCNF() {
        Opportunity opp =[SELECT Id FROM Opportunity LIMIT 1];
        CNT_CPQ_SendEmailOnCOQuoteAcceptance.coOpportunityId =opp.Id;
        
        Apttus_Proposal__Proposal__c coProposal = [SELECT Id, Name FROM Apttus_Proposal__Proposal__c WHERE Apttus_Proposal__Proposal_Category__c =: CON_CPQ.CHNAGE_ORDER LIMIT 1];
        CNT_CPQ_SendEmailOnCOQuoteAcceptance.recordID =coProposal.Id;
        
        Test.startTest();
        	List<Apttus_Proposal__Proposal__c> nonAssociatedCNF = CNT_CPQ_SendEmailOnCOQuoteAcceptance.getNonAssociatedCNF();
        Test.stopTest();
        System.assertEquals(2, nonAssociatedCNF.size(), 'Non-associated CNF Record retrieved Successfully');
        
    }
    
    @isTest 
    static void testGetAssociatedCNF() {
        Opportunity opp =[SELECT Id FROM Opportunity LIMIT 1];
        CNT_CPQ_SendEmailOnCOQuoteAcceptance.coOpportunityId =opp.Id;
        
        Apttus_Proposal__Proposal__c coProposal = [SELECT Id, Name FROM Apttus_Proposal__Proposal__c WHERE Apttus_Proposal__Proposal_Category__c =: CON_CPQ.CHNAGE_ORDER LIMIT 1];
        CNT_CPQ_SendEmailOnCOQuoteAcceptance.recordID =coProposal.Id;
        
        Test.startTest();
        	List<Apttus_Proposal__Proposal__c> associatedCNF = CNT_CPQ_SendEmailOnCOQuoteAcceptance.getAssociatedCNF();
        Test.stopTest();
        System.assertEquals(1, associatedCNF.size(), 'Associated CNF Record retrieved Successfully'); 
    }
     
}