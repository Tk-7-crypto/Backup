@IsTest
public class TST_SCH_BCH_PSA_ANNUAL_SS_EMAILS {
    
    static testmethod void testschedule(){
        Test.startTest();
        SCH_BCH_PSA_ANNUAL_SS_EMAILS sch1 = new SCH_BCH_PSA_ANNUAL_SS_EMAILS();
        String sch = '0 0 1 * * ?';
        system.Schedule('Test Check', sch, sch1);
        Test.stopTest();
        SCH_BCH_PSA_ANNUAL_SS_EMAILS.scheduleJob('Test Batch Sharing Correction',sch);
    }
}