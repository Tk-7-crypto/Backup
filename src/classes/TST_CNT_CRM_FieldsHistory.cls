/*
* Version       : 1.0
* Description   : This test class is used to test all methods of CNT_CRM_FieldsHistory.
*/
@isTest
private class TST_CNT_CRM_FieldsHistory {
    
    /*
    Method for Data Setup for Test Class
    */
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        List<Field_History__c> accountFieldHistoryList =UTL_TestData.createFieldHistoryRecord('Account',acc.id);
        insert accountFieldHistoryList;
    }
    
    /*
     * This method used to test method getFieldHistory()
    */
    @isTest
    static void TestGetFieldHistoryRecords(){
        Account Acc = [SELECT Id FROM Account LIMIT 1];
        Test.startTest();
        List<CNT_CRM_FieldsHistory.FieldHistoryWrapper> FieldHistoryRecord = CNT_CRM_FieldsHistory.getFieldHistoryRecords(acc.Id);
        system.assertEquals(8,FieldHistoryRecord.size(),'');
        Test.stopTest();
    }
    /*
     * This method used to test method getObjectName()
    */
    @isTest
    static void testGetObjectName() {
        Account Acc = [SELECT Id FROM Account LIMIT 1];
        String objectName = CNT_CRM_FieldsHistory.getObjectName(acc.id);
        System.assertEquals('Account', objectName, 'Object name should be Account');
    }
}