/**
 * This test class is used to test all methods in opportunity trigger.
 * version : 1.0
 */
@isTest
private class TST_TGR_Opportunity {
    
    /**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() {
   		Account acc = UTL_TestData.createAccount();
    	insert acc;
    }
    
    /**
     * This test method used for insert opportunity record
     */
    @isTest
    static void testOpportunityInsert() {   
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        Test.startTest();
        	insert opp;
        Test.stopTest();
        List<Opportunity> oppList = [SELECT id FROM Opportunity WHERE name = 'TestOpportunity'];
        Integer expected = 1;
        Integer actual = oppList.size();
        System.assertEquals(expected, actual);
    }
}