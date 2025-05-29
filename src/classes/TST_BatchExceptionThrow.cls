/*
* Version       : 1.0
* Description   : This test class is used to test batch Class BatchExceptionThrow.
*/
@isTest
public class TST_BatchExceptionThrow {
    
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
    }
}