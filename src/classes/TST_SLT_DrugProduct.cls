@isTest
public class TST_SLT_DrugProduct {

     @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        
        Drug_product__c dp = new Drug_product__c();
        dp.International_Drug_Name__c = 'ASSET AGNOSTIC (OTHERS)';
        dp.Status__c=  'Active';
        insert dp;
    }
    
    @isTest
    public static void getAvacareDrugProductTestMethod(){
        Test.StartTest();
	        List<Drug_Product__c> dp = new SLT_DrugProduct().getAvacareDrugProduct();
        Test.StopTest();
    }
}