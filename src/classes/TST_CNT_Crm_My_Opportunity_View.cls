@IsTest
public class TST_CNT_Crm_My_Opportunity_View {
    @IsTest
    public static void testGetOpportunity(){
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        CNT_Crm_My_Opportunity_View.OpportunityWrapper opportunityWrapper = CNT_Crm_My_Opportunity_View.getOpportunity();
        System.assertEquals(opportunityWrapper.opportunity.size() == 0, true);
    }

}