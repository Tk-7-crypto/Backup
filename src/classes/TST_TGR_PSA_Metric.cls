/**
* This test class is used to test PSA_Metric Trigger.
* This is the main Test class for PSA_Metric Trigger and is copied over to dependant Trigger handler Test classes TST_PSA_Metric.cls as well as TST_DAOH_Target.cls.
* Any change to the main test class needs to be reflected in their dependant test classes
* version : 1.0
*/
@isTest
private class TST_TGR_PSA_Metric {
    @IsTest
    static void testPSAMetricMethod() {
        
        //Service Line
        Service_Line__c serviceline = UTL_PSA_TestData.createServiceLine(1, true)[0];
        
        //Service
        Service__c service = UTL_PSA_TestData.createService(1, serviceline, true)[0];
        
        //Psa Metric Monthly
        PSA_Metric__c psaMetricMonthly = UTL_PSA_TestData.createPSAmetric(service.Id, serviceline.Id);
        psaMetricMonthly.Frequency__c = CON_PSA.PSA_METRIC_Frequency_Monthly;
        Test.startTest();
        insert psaMetricMonthly;
        Test.stopTest();  
        
        System.assertEquals(psaMetricMonthly.Non_Standard__c, TRUE );
    }
}
