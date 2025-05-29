@IsTest
public class TST_SCH_BCH_PSA_Mail_Updtd_LR_Metrics {

    static testmethod void testschedule(){
        Test.startTest();
        SCH_BCH_PSA_Mail_Updtd_LR_Metrics sch1 = new SCH_BCH_PSA_Mail_Updtd_LR_Metrics();
        String sch = '0 0 1 * * ?';
        system.Schedule('Test Check', sch, sch1);
        Test.stopTest();
        SCH_BCH_PSA_Mail_Updtd_LR_Metrics.scheduleJob('Test Batch Sharing Correction',sch);
    }
}
