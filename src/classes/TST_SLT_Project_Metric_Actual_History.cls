/*
* TST_SLT_Project_Metric_Actual_History
*
* Providing proofs for the SLT_Project_Metric_Actual_History
* @see TST_CNT_PSA_ProjectMetric
*
* Revisions    2019-May  cld      Initial version
*/
/*
sfdx force:apex:test:run -t TST_SLT_Project_Metric_Actual_History -c -r json
*/
@isTest(isParallel=false)
private class TST_SLT_Project_Metric_Actual_History {
    // !! Common TST_CNT_PSA_ProjectMetric defined tests!
    @isTest static void itGetsManualMetrics () {
        TST_CNT_PSA_ProjectMetric.verifyItGetsManualMetrics();
    }

    @isTest static void itAllowsFLSBypass () {
        SLT_Project_Metric_Actual_History ma = new SLT_Project_Metric_Actual_History(false);
        system.assertNotEquals(null, ma);
        system.assertEquals(Project_Metric_Actual__History.sObjectType, ma.getSObjectType());
    }
}