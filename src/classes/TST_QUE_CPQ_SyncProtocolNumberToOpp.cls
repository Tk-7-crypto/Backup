@isTest
private class TST_QUE_CPQ_SyncProtocolNumberToOpp {
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

        Bid_History__c testClinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
        
        Apttus_Proposal__Proposal__c quote = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, testClinicalBid.Id);
        quote.CurrencyIsoCode = CON_CPQ.USD;
        quote.Protocol_Number__c = 'test11222';
        update quote;  
    }

    @isTest 
    static void testSyncProtocolNoUpdate() {
        Apttus_Proposal__Proposal__c proposal =[Select Id from Apttus_Proposal__Proposal__c Limit 1];

        Test.startTest();
        QUE_CPQ_SyncProtocolNumberToOpp syncJob = new QUE_CPQ_SyncProtocolNumberToOpp(proposal.Id, false);
        System.enqueueJob(syncJob);
        Test.stopTest();

        Opportunity testOpp = [SELECT Protocol_Number__c FROM Opportunity LIMIT 1];
        System.assertEquals('test11222', testOpp.Protocol_Number__c, 'result should be test11222');
    }
    
    @isTest 
    static void testSyncProtocolNoUpdate_Negative() {
        try {
            Test.startTest();
                QUE_CPQ_SyncProtocolNumberToOpp syncJob = new QUE_CPQ_SyncProtocolNumberToOpp(null, true);
                System.enqueueJob(syncJob);
            Test.stopTest();
        } catch(Exception e) {
            System.assertEquals(e.getMessage(), 'Record Id not found.', 'result should be Record Id not found.');
        }
    }
}