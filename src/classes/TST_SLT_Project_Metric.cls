/*
* TST_SLT_Project_Metric
*
* Providing proofs for the SLT_Project_Metric
* @see TST_CNT_PSA_ProjectMetric
*
* Revisions    2019-May  cld      Initial version
*/
/*
sfdx force:apex:test:run -t TST_SLT_Project_Metric -c -r json
*/
@isTest(isParallel=false)
private class TST_SLT_Project_Metric {

    // !! Common TST_CNT_PSA_ProjectMetric defined tests!
    @isTest static void itGetActiveMetrics() {
        TST_CNT_PSA_ProjectMetric.verifyItGetsMetrics();
    }
    // Common TST_CNT_PSA_ProjectMetric defined tests
    @isTest static void itGetsManualMetrics () {
        TST_CNT_PSA_ProjectMetric.verifyItGetsManualMetrics();
    }
    // Common TST_CNT_PSA_ProjectMetric defined tests
    @isTest static void itClonesProjectMetrics () {
        TST_CNT_PSA_ProjectMetric.verifyItClonesProjectMetrics();
    }
    
    // Common TST_CNT_PSA_ProjectMetric defined tests
    @isTest static void hasRDSAdminPermission () {
        test.startTest();
		SLT_Project_Metric svc = new SLT_Project_Metric(false);    
        svc.hasRDSAdminPermmission();
        test.stopTest();
    } 
    // --------

    // !! cover selecting by project ids
    @isTest static void itSelectsByProjectIds() {
        TST_CNT_PSA_ProjectMetric.setupTestData(); // reuse setup from TST_CNT_PSA_ProjectMetrics
        test.startTest();
        
        Id testProjectId = TST_CNT_PSA_ProjectMetric.parentproject.Id;

        SLT_Project_Metric svc = new SLT_Project_Metric(false); // bypass FLS!

        Project_Metric__c[] metrics = svc.selectByProject(new Set<Id>{testProjectId}, new Set<String>{'Id', 'Name', 'Project__c'});
        system.assert(metrics != null && metrics.size() > 0, 'did not retrieve expected metrics');
        system.assert(metrics[0].Project__c == testProjectId);
        test.stopTest();
    }
}