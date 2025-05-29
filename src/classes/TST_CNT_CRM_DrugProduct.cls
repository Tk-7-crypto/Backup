@isTest
public class TST_CNT_CRM_DrugProduct {
    
    @isTest
    public static void testSaveDrugProductRecords(){
        Account acc = UTL_TestData.createAccount();
        insert acc;
        
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        
        List<Drug_Product__c> DrugProductList = new List<Drug_Product__c>();
        DrugProductList.add(UTL_TestData.createDrugProducts());
        DrugProductList.add(UTL_TestData.createDrugProducts());
        insert DrugProductList;
        String DrugProductIds = '';
        for(Drug_Product__c dp: DrugProductList){
            DrugProductIds += dp.Id +',';
        }
        DrugProductIds.removeEnd(',');
        
        Test.startTest();
        Boolean result = CNT_CRM_DrugProduct.saveDrugProductRecords(DrugProductIds, opp.Id);
        String oldValue = CNT_CRM_DrugProduct.getOldDrugProductValue(opp.Id);
        System.assertEquals(true, result);
        Test.stopTest();
    }
}