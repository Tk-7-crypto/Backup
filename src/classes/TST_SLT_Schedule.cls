/**
 * This test class is used to test all methods in SLT_Schedule class
 * version : 1.0
 */
@isTest
private class TST_SLT_Schedule {

    /**
     * This test method used to cover basic methods
     */ 
    static testMethod void testSelectScheduleById(){
        pse__Schedule__c scheduleInstance = UTL_OWF_TestData.createSchedule();
        insert scheduleInstance;
        SLT_Schedule sltSchedule = new SLT_Schedule();
        Test.startTest();
        Map<Id, pse__Schedule__c> scheduleMap = 
            sltSchedule.selectScheduleById(new Set<Id> {scheduleInstance.Id}, new Set<String> {'Id'});
        Test.stopTest();
    }
}