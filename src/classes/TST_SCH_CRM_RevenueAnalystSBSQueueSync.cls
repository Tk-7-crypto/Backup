/**
* This test class is used to test SCH_CRM_RevenueAnalystSBSQueueSync
* version : 1.0
*/
@isTest
public class TST_SCH_CRM_RevenueAnalystSBSQueueSync {
    static testmethod void testm1(){
        SCH_CRM_RevenueAnalystSBSQueueSync m = new SCH_CRM_RevenueAnalystSBSQueueSync();
        String sch = '0 0 * * * ?';
        Test.startTest();
        String jobID = system.schedule('Run revenue anyalyst batch2', sch, m);
        Test.stopTest();
    }
}