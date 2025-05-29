@IsTest
public class TST_SCH_BCH_PSA_UPDT_ACCNT_ON_LR {
    
    static testmethod void testschedule(){
        Test.startTest();
        SCH_BCH_PSA_UPDT_ACCNT_ON_LR sch1 = new SCH_BCH_PSA_UPDT_ACCNT_ON_LR();
        String sch = '0 0 1 * * ?';
        system.Schedule('Test Check', sch, sch1);
        Test.stopTest();
        SCH_BCH_PSA_UPDT_ACCNT_ON_LR.scheduleJob('Test Batch Sharing Correction',sch);
    }

}