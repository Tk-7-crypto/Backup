/*
* Version       : 1.0
* Description   : This test class is used to test all methods of TGRH_CRM_BatchApexErrorEvent.
*/
@isTest
public class TST_TGRH_CRM_BatchApexErrorEvent {
    // Method to set up test data
    @testSetup
    private static void setupTestData() {
        Account accounts = UTL_TestData.createAccount();
        accounts.Name = 'Test Class 1';
        insert accounts;
    }
    
    @isTest
    static void testBatch() {
        try{
            Test.startTest();
            BatchExceptionThrow batch = new BatchExceptionThrow();
            Database.executeBatch(batch); 
            Test.stopTest();
        } catch(System.MathException e){}
        Test.getEventBus().deliver(); 
        List<BatchException__c> BchExp = [Select id from BatchException__c];
        System.assertEquals(1,BchExp.size());
    }
}