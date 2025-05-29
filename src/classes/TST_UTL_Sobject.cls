/*
 * Version       : 1.0
 * Description   : Test Class for UTL_Sobject
 */
@isTest
private class TST_UTL_Sobject {

    /**
     * test method to crate different constructor of OLIWrapper
     */    
    static testmethod void testGetSobjectFieldDetails() {
        String objectName = 'Product2';
        UTL_Sobject sobjectRec = new UTL_Sobject(objectName);
        List<String> fieldApiList = new List<String>{'Id', 'Name', 'ProductCode', 'CurrencyIsoCode' ,'Territory__c'};
        Test.startTest();
            List<ObjectFieldsWrapper> fieldsWrapper = sobjectRec.getSobjectFieldDetails(fieldApiList);
            sobjectRec.getSobjectFieldsDetailMap(fieldApiList);
            sobjectRec.getFieldDataTypeByFieldAPIName();
            Integer expected = 5;
            Integer actual = fieldsWrapper.size();
        Test.stopTest();
        System.assertEquals(expected, actual);
    }
    
    static testmethod void testGetCustomFieldByIds() {
        Map<String, String> customFieldsByIdMap = new Map<String, String>();
        Test.startTest();
        	customFieldsByIdMap = UTL_Sobject.getCustomFieldByIds('BNF2');
        Test.stopTest();
        System.assertNotEquals(customFieldsByIdMap.size(), 0);
    }
}