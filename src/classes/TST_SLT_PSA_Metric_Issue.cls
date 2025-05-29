/*
* TST_SLT_PSA_Metric_Issue
*
* Providing proofs for the SLT_PSA_Metric_Issue
*/
@isTest
private class TST_SLT_PSA_Metric_Issue 
{
    
    @testSetup
    static void setupTestData(){
        Service_Line__c serviceLine = new Service_Line__c(
            Name='Test Service Line',
            Service_Line_Code__c='87654321');
        insert serviceLine;

        Service__c service = new Service__c(
            Name = 'Test Service',
            Service_Code__c = '12345678',
            Service_Line__c = serviceLine.Id);
        insert service;

        PSA_Metric__c metric = new PSA_Metric__c(
            Name='Test Metric',
            //PSA_Metric_Unique_ID__c='1111',
            External_ID__c='1111',
            Service_Line__c=serviceLine.Id
        );
        insert metric;
	
        PSA_Metric_Issue__c issue1 = new PSA_Metric_Issue__c(
            Service__c=service.Id,
            PSA_Metric__c=metric.Id);
        insert issue1;

        PSA_Metric_Issue__c issue2 = new PSA_Metric_Issue__c(
            PSA_Metric__c=metric.Id);
        insert issue2;
    }
    
    
    @isTest
    static void testGetSObjectFieldList() {
        Test.startTest();
        List<Schema.SObjectFIeld> fields = new SLT_PSA_Metric_Issue(true).getSObjectFieldList();
        Test.stopTest();
        System.assertNotEquals(0,fields.size());
    }

    @isTest
    static void testSelectByServiceLine(){
        //setupTestData();
        Service_Line__c serviceLine =  [Select Id, Name from Service_Line__c where Name ='Test Service Line'];
        Test.startTest();
        List<PSA_Metric_Issue__c> issues = new SLT_PSA_Metric_Issue(false).selectByServiceLine(serviceLine.Id, new Set<String>{'Id'});
        Test.stopTest();
        System.assertEquals(1,issues.size());
    }

    @isTest
    static void testSelectByService(){
        //setupTestData();
        Service__c service = [Select Id, Name from Service__c where Name ='Test Service'];
        Test.startTest();
        List<PSA_Metric_Issue__c> issues = new SLT_PSA_Metric_Issue().selectByService(service.Id, new Set<String>{'Id'});
        Test.stopTest();
        System.assertEquals(1,issues.size());
    }

    /*
    static Service_Line__c serviceLine;
    static Service__c service;
    static void setupTestData(){

        serviceLine = new Service_Line__c(
            Name='Test Service Line',
            Service_Line_Code__c='87654321');
        insert serviceLine;

        service = new Service__c(
            Name = 'Test Service',
            Service_Code__c = '12345678',
            Service_Line__c = serviceLine.Id);
        insert service;

        PSA_Metric__c metric = new PSA_Metric__c(
            Name='Test Metric',
            //PSA_Metric_Unique_ID__c='1111',
            External_ID__c='1111',
            Service_Line__c=serviceLine.Id
        );
        insert metric;

        PSA_Metric_Issue__c issue1 = new PSA_Metric_Issue__c(
            Service__c=service.Id,
            PSA_Metric__c=metric.Id);
        insert issue1;

        PSA_Metric_Issue__c issue2 = new PSA_Metric_Issue__c(
            PSA_Metric__c=metric.Id);
        insert issue2;
    }
	*/
}