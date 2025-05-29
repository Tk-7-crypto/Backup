/*
* Version       : 1.0
* Description   : This test class is used to test TGR_CRM_BatchApexErrorEvent.
*/
@isTest
public class TST_TGR_CRM_BatchApexErrorEvent {
    
    
    // Method to set up test data
    @testSetup
    private static void setupTestData() {
        Account accounts = UTL_TestData.createAccount();
        accounts.Name = 'Test Class 1';
        insert accounts;
    }
    
    @isTest
    static void testBatchExceptionInsert(){
        try{
        Test.startTest();
        BatchExceptionThrow batch = new BatchExceptionThrow();
        Database.executeBatch(batch); 
        Test.stopTest();
    } catch(System.MathException e){}
       Test.getEventBus().deliver(); 
    }

}