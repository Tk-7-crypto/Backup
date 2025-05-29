@IsTest
public class TST_SCH_BCH_PSA_Monthly_LR_Metric_Mails {

    static testmethod void testschedule(){
        Test.startTest();
        SCH_BCH_PSA_Send_Monthly_LR_Metric_Mails sch1 = new SCH_BCH_PSA_Send_Monthly_LR_Metric_Mails();
        String sch = '0 0 1 * * ?';
        system.Schedule('Test Check', sch, sch1);
        Test.stopTest();
        SCH_BCH_PSA_Send_Monthly_LR_Metric_Mails.scheduleJob('Test Batch Sharing Correction',sch);
    }
}