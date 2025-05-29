@isTest
private class TST_CNT_CPQ_CountrySalesHeadDetails {

    @testSetup
    static void setUpTestData() {
        Country_Sales_Head__c countrySalesHead = UTL_TestData.createCountrySalesHeadData(CON_CPQ.SALE_TYPE_LARGE,CON_CPQ.COUNTRY,CON_CPQ.CUSTOMER_NAME);
        insert countrySalesHead;
    }
    
    @isTest
    static void testGetSelectOptions() { 
        List<String> optionsList = new List<String> ();
        
        Test.startTest();
            optionsList = CNT_CPQ_CountrySalesHeadDetails.getSelectOptions(new Country_Sales_Head__c(),CON_CPQ.SALE_TYPE_FIELD);
        Test.stopTest(); 
        
        System.assertEquals(optionsList.size() > 0, true, 'Picklist field value fetched successfully');
    }

    @isTest
    static void testGetValueSet() {
        List<String> optionsList1 = new List<String> ();
        List<String> optionsList2 = new List<String> ();
        
        Test.startTest();
            optionsList1 = CNT_CPQ_CountrySalesHeadDetails.getValueSet(new Country_Sales_Head__c(),CON_CPQ.CUSTOMER_NAME_FIELD);
            optionsList2 = CNT_CPQ_CountrySalesHeadDetails.getValueSet(new Country_Sales_Head__c(),CON_CPQ.COUNTRY_SALES_FIELD);
        Test.stopTest();
        System.assertEquals(optionsList1.size() > 0, true, 'Picklist field value fetched successfully');
        System.assertEquals(optionsList2.size() > 0, true, 'Picklist field value fetched successfully');
    }

    @isTest
    static void testGetCountrySalesHeadData() {
        
        Test.startTest();
            List<CNT_CPQ_CountrySalesHeadDetails.CountrySalesHeadWrapper> countrySalesHeadWrapperList = CNT_CPQ_CountrySalesHeadDetails.getCountrySalesHeadData(
                CON_CPQ.SALE_TYPE_LARGE,CON_CPQ.COUNTRY,CON_CPQ.CUSTOMER_NAME);
        Test.stopTest();
        
        System.assertEquals(true, countrySalesHeadWrapperList.size() > 0, 'Should return country Sales Head Wrapper List');
    }
    
    @isTest
    static void testUpdateCountrySalesHead() {
    
        Country_Sales_Head__c countrySalesHead = [SELECT Id, Name FROM Country_Sales_Head__c LIMIT 1];
        List<CNT_CPQ_CountrySalesHeadDetails.CountrySalesHeadCustomerWrapper> countrySalesHeadCustomerWrapper = new List<CNT_CPQ_CountrySalesHeadDetails.CountrySalesHeadCustomerWrapper>();
        countrySalesHeadCustomerWrapper.add(new CNT_CPQ_CountrySalesHeadDetails.CountrySalesHeadCustomerWrapper(countrySalesHead));
        List<CNT_CPQ_CountrySalesHeadDetails.CountrySalesHeadWrapper> countrySalesHeadWrapperList = new List<CNT_CPQ_CountrySalesHeadDetails.CountrySalesHeadWrapper>();
        countrySalesHeadWrapperList.add(new CNT_CPQ_CountrySalesHeadDetails.CountrySalesHeadWrapper(CON_CPQ.COUNTRY,countrySalesHeadCustomerWrapper,true,true));

        Test.startTest();            
            CNT_CPQ_CountrySalesHeadDetails.updateCountrySalesHead(JSON.serialize(countrySalesHeadWrapperList));
        Test.stopTest();
    }
    
    @isTest
    static void testDeleteCountrySalesHead() {
    
        Country_Sales_Head__c countrySalesHead = [SELECT Id, Name FROM Country_Sales_Head__c LIMIT 1];
        List<CNT_CPQ_CountrySalesHeadDetails.CountrySalesHeadCustomerWrapper> countrySalesHeadCustomerWrapper = new List<CNT_CPQ_CountrySalesHeadDetails.CountrySalesHeadCustomerWrapper>();
        countrySalesHeadCustomerWrapper.add(new CNT_CPQ_CountrySalesHeadDetails.CountrySalesHeadCustomerWrapper(countrySalesHead));
        List<CNT_CPQ_CountrySalesHeadDetails.CountrySalesHeadWrapper> countrySalesHeadWrapperList = new List<CNT_CPQ_CountrySalesHeadDetails.CountrySalesHeadWrapper>();
        countrySalesHeadWrapperList.add(new CNT_CPQ_CountrySalesHeadDetails.CountrySalesHeadWrapper(CON_CPQ.COUNTRY,countrySalesHeadCustomerWrapper,true,true));

        Test.startTest();
            CNT_CPQ_CountrySalesHeadDetails.deleteCountrySalesHead(JSON.serialize(countrySalesHeadWrapperList));
        Test.stopTest();
    }

}