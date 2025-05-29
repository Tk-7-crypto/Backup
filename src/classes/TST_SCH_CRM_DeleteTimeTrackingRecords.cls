@isTest
public class TST_SCH_CRM_DeleteTimeTrackingRecords {
    @isTest
    static void testschedule() {
        Test.StartTest();
        SCH_CRM_DeleteTimeTrackingRecords testsche = new SCH_CRM_DeleteTimeTrackingRecords();
        String sch = '0 15 23 08 04 ?';
        System.schedule('Test  delete status Check', sch, testsche );
        Test.stopTest();
    }
}