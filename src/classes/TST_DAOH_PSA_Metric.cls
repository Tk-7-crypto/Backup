/**
 * This test class is used to test DAOH_PSA_Metric.cls. It is copied over from TST_DAOH_PSA_Metric.cls
 * 
 */
@isTest
private class TST_DAOH_PSA_Metric{
    @IsTest
    static void testPSAMetricMethod() {
        
        //Service Line
        Service_Line__c serviceline = UTL_PSA_TestData.createServiceLine(1, true)[0];
        
        //Service
        Service__c service = UTL_PSA_TestData.createService(1, serviceline, true)[0];
        
        //Psa Metric Monthly
        PSA_Metric__c psaMetricMonthly = UTL_PSA_TestData.createPSAmetric(service.Id, serviceline.Id);
        psaMetricMonthly.Frequency__c = CON_PSA.PSA_METRIC_Frequency_Monthly;
        insert psaMetricMonthly;
        
        System.assertEquals(psaMetricMonthly.Non_Standard__c, TRUE );
    }
}
