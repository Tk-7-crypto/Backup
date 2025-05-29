/*
* Version       : 1.0
* Description   : This test class is used to test all methods of SLT_FieldHistory.
*/
@isTest
private class TST_SLT_FieldHistory {
    
    /*
      * This method used to test method getFieldHistory()
     */  
    @isTest
    static void testGetFieldHistory(){
        Account acc = UTL_TestData.createAccount();
        insert acc;
        
        List<User> userList = UTL_TestData.createUser('Standard User', 1);
        userList[0].IsActive = true;
        insert userList;
        Set<String> fieldSet = new Set<String> {'New_Value__c', 'Old_Value__c', 'Tracked_Field_API__c', 'Tracked_Object__c',  'Action_User__c', 'Action_Date_Time__c'};
        
        List<Field_History__c> accountFieldHistoryList = new List<Field_History__c>();
        Field_History__c accountFieldHistoryRecord = new Field_History__c( New_Value__c = acc.Name, Tracked_Field_API__c = 'Name', Tracked_Object__c = 'Account', Action_User__c = userList[0].Id  , Action_Date_Time__c = System.Today());
        accountFieldHistoryList.add(accountFieldHistoryRecord);
        
        Field_History__c accountFieldHistoryRecord1 = new Field_History__c( Old_Value__c = acc.Name,New_Value__c = 'Test Acc',  Tracked_Field_API__c = 'Name', Tracked_Object__c = 'Account', Action_User__c = userList[0].Id  , Action_Date_Time__c = System.Today());
        accountFieldHistoryList.add(accountFieldHistoryRecord1);
        insert accountFieldHistoryList; 
        
        Test.startTest();
        List<Field_History__c> FieldHistoryRecord = new SLT_FieldHistory().getFieldHistory(fieldSet, acc.Id);
        Test.StopTest();
    }
}