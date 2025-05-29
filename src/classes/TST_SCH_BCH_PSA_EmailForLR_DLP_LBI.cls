@IsTest
public class TST_SCH_BCH_PSA_EmailForLR_DLP_LBI {
    
    static testmethod void testschedule(){
        Test.startTest();
        SCH_BCH_PSA_EmailForLR_DLP_LBI sch1 = new SCH_BCH_PSA_EmailForLR_DLP_LBI();
        String sch = '0 0 1 * * ?';
        system.Schedule('Test Check', sch, sch1);
        Test.stopTest();
        SCH_BCH_PSA_EmailForLR_DLP_LBI.scheduleJob('Test Batch Sharing Correction',sch);
    }
}