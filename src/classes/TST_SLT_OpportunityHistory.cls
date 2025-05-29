@isTest
public class TST_SLT_OpportunityHistory {

    @isTest
    public static void testOpportunityHistory(){
        Test.startTest();
        SLT_OpportunityHistory oppHistorySelector = new SLT_OpportunityHistory();
        new SLT_OpportunityHistory(false,false);
        oppHistorySelector.getSObjectFieldList();
        oppHistorySelector.getSObjectType();
        Test.stopTest();
    }
}