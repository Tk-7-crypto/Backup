/**
 * This test class is used to test DAO_Sd_Run.cls.
 *
 */
@isTest
private class TST_DAO_Sd_Run {
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
    
    testmethod static void testUpdateAuditLog(){
        Test.startTest();
        list<SD_Runs__c> sdRunRec = [SELECT id, Frequency__c from SD_Runs__c limit 1];
        sdRunRec[0].Frequency__c = 'Monthly';
        update sdRunRec;
        Test.stopTest();
    }
    
    testmethod static void testDeleteAuditLog(){
        Test.startTest();
        list<SD_Runs__c> sdRunRec = [SELECT id, Frequency__c from SD_Runs__c limit 1];
        delete sdRunRec;
        Test.stopTest();
    }
      
}
