@isTest
public class TST_ObjectFieldsWrapper {
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
        // System.assertEquals(expected, actual);
    }
}