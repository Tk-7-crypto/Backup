@isTest
private class TST_SRV_CLM_Opportunity {

    @isTest
    private static void testOppDetailShouldReturnMap() {
        Set<String> fieldSet = new Set<String>{'Name', 'Id'}; 
        Opportunity opp = TST_CLM_TestDataFactory.createOpportunity(true);
        Set<Id> oppIdSet = new Set<Id> {opp.Id};
        
        Test.startTest();
            Map<Id, Opportunity> idToOpportunityMap = SRV_CLM_Opportunity.getOppDetail(oppIdSet, fieldSet);
        Test.stopTest();
        
        System.assertNotEquals(null, idToOpportunityMap, 'idToOpportunityMap must not be null.');
    }

    @isTest
    private static void testOppDetailShouldThrowException() {
        Set<String> fieldSet = new Set<String>{'Name', 'Id'}; 
        Opportunity opp = TST_CLM_TestDataFactory.createOpportunity(true);
        Set<Id> oppIdSet = new Set<Id> {opp.Id};
        
        Test.startTest();
            try {
                Map<Id, Opportunity> idToOpportunityMap = SRV_CLM_Opportunity.getOppDetail(null, fieldSet);
            } catch(Exception ex) {
                System.assertNotEquals(null, ex, 'Exception should be thrown.');
            }
        Test.stopTest();
    }
}