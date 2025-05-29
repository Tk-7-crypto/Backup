@isTest
public class TST_SLT_DrugProductName {
    
    @isTest
    public static void getOppDrugProductByOppId(){
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        Drug_Product__c dp = UTL_TestData.createDrugProducts();
        insert dp;
        Drug_Product_Name__c odp = UTL_TestData.createOpportunityDrugProduct(dp, opp);
        insert odp;
        
        Test.startTest();
        List<Drug_Product_Name__c> odpList = new SLT_DrugProductName().getOppDrugProductByOppId(new Set<Id>{opp.Id}, new Set<String>{'Id'});
        System.assertEquals(odpList.size() > 0, true);
        Test.stopTest();
    }
}