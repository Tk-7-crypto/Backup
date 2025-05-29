/**
 * This test class is used to test UTL_ExecutionControl class.
 * version : 1.0
 */
@isTest
private class TST_UTL_ExecutionControl {
    
    /**
     * This test method used for insert opportunity record
     */
    @isTest
    static void testExecutionControlFlags() {   
        Test.startTest();
            system.assertEquals(false, UTL_ExecutionControl.stopTriggerExecution);
            system.assertEquals(false, UTL_ExecutionControl.isCurrencyIsoCodeChangeAllowed);
            system.assertEquals(false, UTL_ExecutionControl.olisTriggerAlreadyRun);
            UTL_ExecutionControl.stopTriggerExecution = true; 
            UTL_ExecutionControl.olisTriggerAlreadyRun = true;
            UTL_ExecutionControl.stopTriggerExecution_OWF = true; 
            system.assertEquals(true, UTL_ExecutionControl.stopTriggerExecution);
            system.assertEquals(true, UTL_ExecutionControl.olisTriggerAlreadyRun);
            system.assertEquals(true, UTL_ExecutionControl.stopTriggerExecution_OWF);
        Test.stopTest();
    }
}