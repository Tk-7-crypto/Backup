@isTest
private class TST_DAO_CountrySalesHead {
    @testSetup
    static void setUpTestData() {
        Country_Sales_Head__c countrySalesHead = UTL_TestData.createCountrySalesHeadData(CON_CPQ.SALE_TYPE_LARGE,CON_CPQ.COUNTRY,CON_CPQ.CUSTOMER_NAME);
        insert countrySalesHead;
    }
    
    @isTest
    static void testInActiveOldRecord() {
        try{
            Country_Sales_Head__c countrySalesHead = UTL_TestData.createCountrySalesHeadData(CON_CPQ.SALE_TYPE_LARGE,CON_CPQ.COUNTRY,CON_CPQ.CUSTOMER_NAME);
            insert countrySalesHead;
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains(CON_CPQ.COUNTRY_SALES_HEAD_ERROR) ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);            
        } 
    }
}