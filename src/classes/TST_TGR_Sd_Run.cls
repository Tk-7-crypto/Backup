/**
 * This test class is used to test TGR_Sd_Run.cls.
 *
 */
@isTest
private class TST_TGR_Sd_Run {
    @testSetup static void setup() {
         UTL_PSA_TestData.createSdRun();
    }
    
    testmethod static void testPopulateSdRunIdField(){
        Test.startTest();
        // Validate if a record was inserted in QC Tracker Result 
        list<SD_Runs__c> sdRunRec = [SELECT id from SD_Runs__c];
        System.assertEquals(2, sdRunRec.size());
        Test.stopTest();
    }
    
}