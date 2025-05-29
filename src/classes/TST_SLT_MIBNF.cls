/**
* This class is used to test SLT_MIBNF 
*/ 
@isTest
public class TST_SLT_MIBNF {
    
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        Revenue_Analyst__c revenueAnalyst = UTL_TestData.createRevenueAnalyst();
        insert revenueAnalyst;
        MIBNF2__c mibnf2 = UTL_TestData.createMIBNF(opp, revenueAnalyst);
        insert mibnf2; 
    }
    
    @isTest
    public static void testSelectByFilter() {
        Set<ID> oppIdSet = new Set<Id>();
        Set<String> fieldSet = new Set<String>{'Name', 'Id'};
        String filterCondition = 'Opportunity__c in :oppIdSet';    
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        oppIdSet.add(opp.Id);
        Test.startTest();
        SLT_MIBNF mibnfSelector = new SLT_MIBNF();
        List<MIBNF2__c> mibnf2List = mibnfSelector.selectByFilter(oppIdSet, fieldSet, filterCondition);
        System.assertEquals(1, mibnf2List.size());
        Test.stopTest();
    }
    
    @isTest
    public static void testSelectMibnfByMibnfId() {
        Set<Id> idSet = new Set<Id>();
        Set<String> mibnffieldSet = new Set<String>{'Id', 'Name'};
        Set<String> mibnfCompfieldSet = new Set<String>{'Id', 'Name'};
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
		MIBNF2__c mibnf = [SELECT Id, Name From MIBNF2__c where Opportunity__c = :opp.Id];
        idset.add(mibnf.id);
        Test.startTest();
        SLT_MIBNF mibnfSelector = new SLT_MIBNF();
        List<MIBNF2__c> mibnfList = mibnfSelector.selectMibnfByMibnfId(idSet, mibnffieldSet, mibnfCompfieldSet);
        System.assertEquals(1, mibnfList.size());
        Test.stopTest();
    }
}