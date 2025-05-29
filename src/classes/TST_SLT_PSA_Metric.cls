/*
* TST_SLT_PSA_Metric
*
* Providing proofs for the SLT_PSA_Metric
* @see TST_CNT_PSA_ProjectMetric
*
* Revisions    2019-May  cld      Initial version
*/
/*
sfdx force:apex:test:run -t TST_SLT_PSA_Metric -c -r json
*/
@isTest(isParallel=false)
private class TST_SLT_PSA_Metric {
    // !! Common TST_CNT_PSA_ProjectMetric defined tests!
    @isTest static void itGetsActivePsaMetrics () {
        TST_CNT_PSA_ProjectMetric.verifyItGetsActivePsaMetrics();
    }

    @isTest static void itAllowsFLSBypass () {
        SLT_PSA_Metric ma = new SLT_PSA_Metric(false);
        system.assertNotEquals(null, ma);
        system.assertEquals(PSA_Metric__c.sObjectType, ma.getSObjectType());
    }
}