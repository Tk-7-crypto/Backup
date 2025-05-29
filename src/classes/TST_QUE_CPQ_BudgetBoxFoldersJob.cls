@isTest
private class TST_QUE_CPQ_BudgetBoxFoldersJob {
    
    /**
    * This method is used to setup data for all methods.
    */
    @testSetup
    static void dataSetup() { 
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity Opp = UTL_TestData.createOpportunity(acc.Id);
        insert Opp;
        Apttus_Proposal__Proposal__c budget = new Apttus_Proposal__Proposal__c();
        budget.Apttus_Proposal__Proposal_Name__c = 'Test Budget 1';
        budget.Apttus_Proposal__Account__c = acc.Id;
        budget.Apttus_Proposal__Opportunity__c = Opp.Id;
        budget.Apttus_Proposal__Proposal_Category__c = CON_CPQ.INITIAL;
        budget.Select_Pricing_Tool__c = CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT;
        insert budget; 
        
        Apttus_Proposal__Proposal__c budget2 = new Apttus_Proposal__Proposal__c();
        budget2.Apttus_Proposal__Proposal_Name__c = 'Test Budget 2';
        budget2.Apttus_Proposal__Account__c = acc.Id;
        budget2.Apttus_Proposal__Opportunity__c = Opp.Id;
        budget2.Select_Pricing_Tool__c = CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT;
        insert budget2; 
    }

    @isTest 
    static void TestBudgetBoxFoldersJob() {
        List<Apttus_Proposal__Proposal__c> budgetList = [SELECT Id FROM Apttus_Proposal__Proposal__c];
        Test.startTest();
            System.enqueueJob(new QUE_CPQ_BudgetBoxFoldersJob(budgetList));
        Test.stopTest();
    }
}