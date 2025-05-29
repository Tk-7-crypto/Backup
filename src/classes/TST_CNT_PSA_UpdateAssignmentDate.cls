/*
 * TST_CNT_PSA_UpdateAssignmentDate
 *
 * Providing proofs for the CNT PSA Update Assignment's Date page
 *
 *
 */
@isTest(isParallel=false)
private class TST_CNT_PSA_UpdateAssignmentDate {

    @testSetup
    static void dataSetup() 
    {
        pse__Schedule__c schedule = new pse__Schedule__c();
        schedule.pse__Start_Date__c = system.today();
        schedule.pse__End_Date__c = schedule.pse__Start_Date__c.addDays(30);
        insert schedule;  
    }
    
    @IsTest
    static void testUpdateAssignmentSchedules() {
        pse__Schedule__c schedule = [Select Id, pse__Start_Date__c,pse__End_Date__c from pse__Schedule__c limit 1];
        Test.startTest();
        String startDateString = string.valueof(schedule.pse__Start_Date__c);
        String endDateString = string.valueof(schedule.pse__End_Date__c);
        String assignmentSchedules = CNT_PSA_UpdateAssignmentDate.updateAssignmentScheduleDates(schedule.Id, startDateString, endDateString );
        Test.stopTest();
        String expected = 'success';
        String actual = assignmentSchedules;
        System.assertEquals(expected, actual);
    }

}