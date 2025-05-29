/*
 * Version       : 1.0
 * Description   : Test Class for SLT_Competitor
 */ 
@isTest
private class TST_SLT_Competitor {
    
    /**
     * Method to test getObjectType method of competitor selector.
     */
    @isTest static void testGetSObjectType(){
          SLT_Competitor compSelector =  new SLT_Competitor();
          Test.startTest();
          System.assertEquals( compSelector.getSObjectType(), Competitor__c.sObjectType);
          Test.stopTest();
    }
    
    /**
     * Method to test getSObjectFieldList method of competitor selector.
     */
    @isTest static void testGetSObjectFieldList(){
         SLT_Competitor compSelector =  new SLT_Competitor();
         Test.startTest();
         System.assert(compSelector.getSObjectFieldList().size() == 3, 'method return 3 fields');
         Test.stopTest();
    }
    
    @isTest
    public static void testSelectSalesSpotCompetitorById() {
        Competitor__c competitorRecord = UTL_TestData.createCompetitor();
        competitorRecord.SalesSpot_Enabled__c = true;
        insert competitorRecord;
        SLT_Competitor compSelector = new SLT_Competitor();
        Test.startTest();
        Map<Id, Competitor__c> compMap = compSelector.selectSalesSpotCompetitorById(new Set<Id>{competitorRecord.Id}, new Set<String>{'Id','Name'});
        Test.stopTest();
        System.assertEquals(compMap.size(), 1);
    }
}