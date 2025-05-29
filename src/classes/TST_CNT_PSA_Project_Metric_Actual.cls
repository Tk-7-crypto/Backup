@isTest
public class TST_CNT_PSA_Project_Metric_Actual {
    @testsetup
    static void dataSetup(){
        UTL_PSA_TestData.createPermissionControls();
        
        //Program
        Program__c program = UTL_PSA_TestData.createPrograms(1, true)[0];
        
        //Contact
        RecordType contactRT = [SELECT Id from RecordType where Name='IQVIA User Contact'];
        Contact testResource = UTL_PSA_TestData.createResources(1, false)[0];
        testResource.RecordTypeId = contactRT.Id;
        testResource.pse__Salesforce_User__c = UserInfo.getUserId();
        insert testResource;
        Contact contact = testResource;
        
        //RDS Project
        pse__Proj__c parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Project_Status__c = CON_PSA.PROJ_STAGE_STARTUP;
        parentproject.Program__c = program.id;
        insert parentproject;
        
        //Service Line
        Service_Line__c serviceline = UTL_PSA_TestData.createServiceLine(1, true)[0];
        
        //Service
        Service__c service = UTL_PSA_TestData.createService(1, serviceline, true)[0];
        
        //Service Line Project
        pse__Proj__c project = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        project.recordTypeId = recTypeId;
        project.pse__Project_Status__c = 'Start-up';
        project.pse__Parent_Project__c = parentproject.Id;
        project.Service_Line__c = serviceline.Id;
        project.pse__Start_Date__c = Date.newInstance(2020, 07, 25);
        project.pse__End_Date__c = Date.newInstance(System.Today().year()+1, 12, 31);
        insert project;
        
        //Psa Metric Monthly
        PSA_Metric__c psaMetricMonthly = UTL_PSA_TestData.createPSAmetric(service.Id, serviceline.Id);
        psaMetricMonthly.Frequency__c = CON_PSA.PSA_METRIC_Frequency_Monthly;
        insert psaMetricMonthly;
        
        //Project Metric linked to Monthly
        Project_Metric__c projectMetricForMonthly = UTL_PSA_TestData.createProjectMetric(psaMetricMonthly.id, parentproject.id);
        insert projectMetricForMonthly;
        
        //Project Metric Actual for Monthly 1
        Project_Metric_Actual__c projectMetricActualMonthly1 = UTL_PSA_TestData.createProjectMetricActual(parentproject.id, projectMetricForMonthly.id, psaMetricMonthly.id);
        projectMetricActualMonthly1.Date__c = Date.newInstance(2023, 01, 01);
        insert projectMetricActualMonthly1;
    }
    
    @istest
    static void testGetProjectMetricData(){
        pse__Proj__c proRec = [Select Id from pse__Proj__c where RecordType.Name ='RDS Project' limit 1];
        String recordId = proRec.id;
        List<Project_Metric_Actual__c> projectMetricList= new List<Project_Metric_Actual__c>();
        List<Project_Metric_Actual__c> projectMetricRecList= new List<Project_Metric_Actual__c>();
        Project_Metric_Actual__c projMetric = [Select Id from Project_Metric_Actual__c limit 1];
        PSA_Metric__c PSAMetricc = [Select Id,Name from PSA_Metric__c limit 1];
        List<String> projectMetricIdList = new List<String>();
        projectMetricIdList.add(projMetric.id);
        Test.startTest();
        projectMetricList = CNT_PSA_Project_Metric_Actual.getProjectMetricActualData(recordId);
        String Data = CNT_PSA_Project_Metric_Actual.getAllRecordsForListView(recordId, 10,10,0);
        projectMetricRecList = CNT_PSA_Project_Metric_Actual.delMetricRecords(projectMetricIdList,recordId);
        Test.stopTest();
    }
}
