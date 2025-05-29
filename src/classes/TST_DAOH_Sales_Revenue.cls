@isTest
public class TST_DAOH_Sales_Revenue {
    
    @isTest
    public static void testSetSalesRevenueFields(){
        Product2 pro = UTL_TestData.createProduct();
        pro.ProductCode = 'T123';
        insert pro;
        
        Test.startTest();
        Sales_Revenue__c sr = new Sales_Revenue__c();
        sr.Product_Code__c = 'T123';
        sr.Scenario__c = 'Pipeline';
        insert sr;
        
        sr = [SELECT Id, Product__c FROM Sales_Revenue__c];
        System.assertEquals(Pro.Id, sr.Product__c);
        Test.stopTest();
    }
}