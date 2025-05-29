/*
 * Version       : 1.0
 * Description   : This test class is used for Select OpportunityTeamMember
 */
@isTest
private  class TST_SLT_OpportunityTeamMember {
    
    /**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Contact cnt = UTL_TestData.createContact(acc.Id);
        insert cnt;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        Product2 product = UTL_TestData.createProduct();
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        insert oppLineItem;
    }
    
    /**
     * This method used to Select Opportunity Team Member
     */    
    @IsTest
    static void testOpportunityTeamMember() {
        List<OpportunityTeamMember> oppTeamMemberList = null;
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Set<String> fieldSet = new Set<String>{'Id', 'TeamMemberRole'};
        Test.startTest();
            oppTeamMemberList = new SLT_OpportunityTeamMember().selectByOpportunityId(new Set<Id>{opp.Id}, fieldSet);
        Test.stopTest();
        System.assertEquals(1, oppTeamMemberList.size());
    }
}