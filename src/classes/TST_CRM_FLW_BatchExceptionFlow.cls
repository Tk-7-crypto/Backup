/**
 * This test class is used to cover the record triggered flow on account in after context.
 * version : 1.0
 */
@isTest
public class TST_CRM_FLW_BatchExceptionFlow{
    
     @isTest
    static void testEmailFlowOnBatchException() {
        // Start the test
        Test.startTest();
        
        BatchExceptionThrow batch = new BatchExceptionThrow();
        Database.executeBatch(batch); 
        
        // Stop the test to allow Flow actions to complete
        Test.stopTest();
    }

}