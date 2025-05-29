@isTest
public class TST_SLT_Opportunity_Extension {
    
    @isTest
    public static void getOpportunityExtensionByOppId(){
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        Test.startTest();
        List<Opportunity_Extension__c> oppExtList = new SLT_Opportunity_Extension().getOpportunityExtensionByOppId(new Set<id>{opp.Id});
        System.assertEquals(Opp.Id, oppExtList[0].Opportunity__c);
        Test.stopTest();
        
    }
}