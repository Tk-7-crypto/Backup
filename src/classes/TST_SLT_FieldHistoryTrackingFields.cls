/*
* Version       : 1.0
* Description   : This test class is used to test all methods of SLT_FieldHistoryTrackingFields.
*/
@isTest
private class TST_SLT_FieldHistoryTrackingFields {
    
   Static list<Field_History_Tracking_Field__mdt> testdata;
       
   static void setupTestData () {
        testdata = [select id,field__c,Is_Active__c from Field_History_Tracking_Field__mdt where Is_Active__c=true];
        Account abc = UTL_TestData.createAccount();
        insert abc; 
    }
    
     /*
      * This method used to get sObjectFieldlist
     */    
    @IsTest
    static void testGetSObjectFieldList() {
        setupTestData();
        Test.startTest();
        List<Schema.SObjectField> fieldNames = new SLT_FieldHistoryTrackingFields(false).getSObjectFieldList();
        Test.stopTest();
    }
    /*
      * This method used to test method TrackingFields()
     */
    @IsTest
    static void testTrackingFields() {
        setupTestData();
        Test.startTest();
        List<Field_History_Tracking_Field__mdt> actualData = new SLT_FieldHistoryTrackingFields().TrackingFields(new Set<String>{'Id','Field__c','Is_Active__c'},'Is_Active__c=true',null);
        System.assertEquals(testdata,actualData);
        Test.stopTest();
    }
    /*
      * This method used to test method GetRecordName()
     */
    @isTest
    static void testGetRecordName() {
        setupTestData();
        Account abc = [Select Id, Name From Account LIMIT 1];
        Test.startTest();
        String recordName = new SLT_FieldHistoryTrackingFields().getRecordIdName(abc.Id);
        Test.stopTest(); 
        System.assertEquals(abc.Name, recordName);
    }
}