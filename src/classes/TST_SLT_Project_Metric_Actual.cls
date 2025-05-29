/*
* TST_SLT_Project_Metric_Actual
*
* Providing proofs for the SLT_Project_Metric_Actual
* @see TST_CNT_PSA_ProjectMetric
*
* Revisions    2019-May  cld      Initial version
*/
/*
sfdx force:apex:test:run -t TST_SLT_Project_Metric_Actual -c -r json
*/
@isTest(isParallel=false)
private class TST_SLT_Project_Metric_Actual {
    
    @isTest static void itAllowsFLSBypass () {
        SLT_Project_Metric_Actual ma = new SLT_Project_Metric_Actual(false);
        system.assertNotEquals(null, ma,'Expected Result');
        system.assertEquals(Project_Metric_Actual__c.sObjectType, ma.getSObjectType(),'Expected Result');
    }
    
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
        Project_Metric_Actual__c projMetric = [Select Id from Project_Metric_Actual__c limit 1];
        Set<Id> projectMetricIdList = new Set<Id>();
        projectMetricIdList.add(projMetric.id);
        Set<String> PMAFieldSet = new Set<String>();
        Set<String> fields = new Set<String>();
        PMAFieldSet = new Set<String>{'id','name','PSA_Metric__c.Name','Project_Metric__c.Name','Date__c','Quantity__c','Comments__c'};
        List<String> PMARecordsForDeletion = new List<String>();
        PMARecordsForDeletion.add(projMetric.id);
        List<Integer> sizeList = new List<Integer>();
        Test.startTest();
        fields = new SLT_Project_Metric_Actual(true).getSObjectFieldSet();
        List<Project_Metric_Actual__c> ProjectMetricRecordsForPagination = new SLT_Project_Metric_Actual().getProjectMetricByIdsForPagination(projectMetricIdList, PMAFieldSet,1,1);
        List<Project_Metric_Actual__c> ProjectMetricRecordsForDeletion = new SLT_Project_Metric_Actual().getSelectedRecordsForDeletion(PMARecordsForDeletion, PMAFieldSet);
        sizeList.add(ProjectMetricRecordsForPagination.size());
        sizeList.add(ProjectMetricRecordsForDeletion.size());
        Test.stopTest();
        system.assertNotEquals(0, sizeList.size(),'Expected Result');
    }
}
