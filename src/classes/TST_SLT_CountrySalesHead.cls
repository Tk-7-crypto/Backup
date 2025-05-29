@isTest
public class TST_SLT_CountrySalesHead {
    
    @testSetup
    static void dataSetup() {
        Country_Sales_Head__c countrySalesHead = UTL_TestData.createCountrySalesHeadData(CON_CPQ.SALE_TYPE_LARGE,CON_CPQ.COUNTRY,CON_CPQ.CUSTOMER_NAME);
        insert countrySalesHead;
    }
    
    @IsTest
    static void testSelectById() {
        Country_Sales_Head__c countrySalesHead = [SELECT Id,Country_Sales__c,Approver_Name__c,Sale_Type__c FROM Country_Sales_Head__c limit 1];	
        List<Country_Sales_Head__c> countrySalesHeadList1 = new SLT_CountrySalesHead().selectById(new Set<Id> {countrySalesHead.Id});
        List<Country_Sales_Head__c> countrySalesHeadList2 = SLT_CountrySalesHead.selectCountrySalesHeadByFilter(countrySalesHead.Sale_Type__c, countrySalesHead.Country_Sales__c, countrySalesHead.Approver_Name__c);
        System.assertEquals(countrySalesHeadList1.size() > 0, true);
        System.assertEquals(countrySalesHeadList2.size() > 0, true);
    }
}