@IsTest
private class TST_TGR_ProductConfiguration {

    /**
    * This method used to set up testdata
    */
    @TestSetup
    static void dataSetup() {
        Account account = UTL_OCE_TestData.createaccount();
        insert account;
        Opportunity opportunity = UTL_OCE_TestData.createOpportunity(account.Id);
        insert opportunity;
    }

    
    @IsTest
    static void testUpdateProposalConfig() {
        Account account = [SELECT Id FROM Account Limit 1];
        
        Opportunity opportunity = [SELECT Id FROM Opportunity LIMIT 1];
        
        RecordType recordType  = [SELECT Id FROM RecordType WHERE DeveloperName = :CON_CPQ.TECH_SOLUTION 
                                  AND SobjectType = 'Apttus_Proposal__Proposal__c' LIMIT 1];
        
        Apttus_Proposal__Proposal__c proposal = UTL_TestData.setTSProposalData(false, CON_CPQ.TECH_SOLUTION, opportunity.Id, CON_CPQ.OCE);
        proposal.Apttus_Proposal__Account__c = account.Id;
        insert proposal;
        
        Apttus_Config2__ProductConfiguration__c configuration = UTL_TestData.createProductConfiguration(proposal.Id, CON_CPQ.FINALIZED);
        insert configuration;
        
        Test.startTest();
        configuration.Name = 'Proposal Configuration';
        update configuration;
        Test.stopTest();
    }
}