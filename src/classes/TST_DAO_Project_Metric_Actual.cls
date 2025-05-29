/**
* This test class is used to test DAO_Project_Metric_Actual Trigger.
* The test code is copied from its parent TST_TGR_Project_Metric_Actual Trigger.
* version : 1.0
*/
@isTest
public class TST_DAO_Project_Metric_Actual {
    
    @testSetup
    static void dataSetup() {
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
        project.pse__Start_Date__c = Date.newInstance(System.Today().year() - 1, 07, 25);
        project.pse__End_Date__c = Date.newInstance(System.Today().year() + 3, 12, 31);
        insert project;
        
        //Psa Metric Monthly
        PSA_Metric__c psaMetricMonthly = UTL_PSA_TestData.createPSAmetric(service.Id, serviceline.Id);
        psaMetricMonthly.Frequency__c = CON_PSA.PSA_METRIC_Frequency_Monthly;
        insert psaMetricMonthly;
        
        //Project Metric linked to Monthly
        Project_Metric__c projectMetricForMonthly = UTL_PSA_TestData.createProjectMetric(psaMetricMonthly.id, parentproject.id);
        insert projectMetricForMonthly;
        
        //Psa Metric Quarterly
        PSA_Metric__c psaMetricQuarterly = UTL_PSA_TestData.createPSAmetric(service.Id, serviceline.Id);
        psaMetricQuarterly.Frequency__c = CON_PSA.PSA_METRIC_Frequency_Quarterly;
        insert psaMetricQuarterly;
        
        //Project Metric linked to Quarterly
        Project_Metric__c projectMetricForQuarterly = UTL_PSA_TestData.createProjectMetric(psaMetricQuarterly.id, parentproject.id);
        insert projectMetricForQuarterly;
        
        //Psa Metric Semi_Annual
        PSA_Metric__c psaMetricSemi_Annual = UTL_PSA_TestData.createPSAmetric(service.Id, serviceline.Id);
        psaMetricSemi_Annual.Frequency__c = CON_PSA.PSA_METRIC_Frequency_Semi_Annual;
        insert psaMetricSemi_Annual;
        
        //Project Metric linked to Semi_Annual
        Project_Metric__c projectMetricForSemi_Annual = UTL_PSA_TestData.createProjectMetric(psaMetricSemi_Annual.id, parentproject.id);
        insert projectMetricForSemi_Annual;
        
        //Psa Metric Rolling_12
        PSA_Metric__c psaMetricRolling_12 = UTL_PSA_TestData.createPSAmetric(service.Id, serviceline.Id);
        psaMetricRolling_12.Frequency__c = CON_PSA.PSA_METRIC_Frequency_Rolling_12;
        insert psaMetricRolling_12;
        
        //Project Metric linked to Rolling_12
        Project_Metric__c projectMetricForRolling_12 = UTL_PSA_TestData.createProjectMetric(psaMetricRolling_12.id, parentproject.id);
        insert projectMetricForRolling_12;
        
        //Psa Metric EmptyServiceLine
        PSA_Metric__c psaMetricEmptyServiceLine = UTL_PSA_TestData.createPSAmetric();
        insert psaMetricEmptyServiceLine;
        
        //Project Metric linked to EmptyServiceLine
        Project_Metric__c projectMetricForEmptyServiceLine = UTL_PSA_TestData.createProjectMetric(psaMetricEmptyServiceLine.id, parentproject.id);
        insert projectMetricForEmptyServiceLine;
    }
    
    @IsTest
    static void testValidateProjectMetricActualByServiceLine () {
        
        pse__Proj__c parentproj = [Select Id, Name, RecordType.Name from pse__Proj__c where RecordType.Name=: CON_PSA.PROJ_REC_TYPE_RDS_PROJECT limit 1];        
        PSA_Metric__c psaMetricMonthly = [Select Id from PSA_Metric__c where Frequency__c =: CON_PSA.PSA_METRIC_Frequency_Monthly limit 1];
        Project_Metric__c projectMetricForMonthly = [Select Id, PSA_Metric__c from Project_Metric__c where PSA_Metric__c=:psaMetricMonthly.Id limit 1];
        
        PSA_Metric__c psaMetricQuarterly = [Select Id from PSA_Metric__c where Frequency__c =: CON_PSA.PSA_METRIC_Frequency_Quarterly limit 1];
        Project_Metric__c projectMetricForQuarterly = [Select Id, PSA_Metric__c from Project_Metric__c where PSA_Metric__c=:psaMetricQuarterly.Id limit 1];
        
        PSA_Metric__c psaMetricSemi_Annual = [Select Id from PSA_Metric__c where Frequency__c =: CON_PSA.PSA_METRIC_Frequency_Semi_Annual limit 1];
        Project_Metric__c projectMetricForSemi_Annual = [Select Id, PSA_Metric__c from Project_Metric__c where PSA_Metric__c=:psaMetricSemi_Annual.Id limit 1];
        
        PSA_Metric__c psaMetricRolling_12 = [Select Id from PSA_Metric__c where Frequency__c =: CON_PSA.PSA_METRIC_Frequency_Rolling_12 limit 1];
        Project_Metric__c projectMetricForRolling_12 = [Select Id, PSA_Metric__c from Project_Metric__c where PSA_Metric__c=:psaMetricRolling_12.Id limit 1];
        
        PSA_Metric__c psaMetricEmptyServiceLine = [Select Id, Service_Line__r.Name from PSA_Metric__c where Service_Line__r.Name = null limit 1];
        Project_Metric__c projectMetricForEmptyServiceLine = [Select Id, PSA_Metric__c from Project_Metric__c where PSA_Metric__c=:psaMetricEmptyServiceLine.Id limit 1];
        
        //Project Metric Actual for Monthly 1
        Project_Metric_Actual__c projectMetricActualMonthly1 = UTL_PSA_TestData.createProjectMetricActual(parentproj.id, projectMetricForMonthly.id, psaMetricMonthly.id);
        projectMetricActualMonthly1.Date__c = Date.newInstance(System.Today().year(), 01, 01);
        
        //Project Metric Actual for Monthly 2
        Project_Metric_Actual__c projectMetricActualMonthly2 = UTL_PSA_TestData.createProjectMetricActual(parentproj.id, projectMetricForMonthly.id, psaMetricMonthly.id);
        projectMetricActualMonthly2.Date__c = Date.newInstance(System.Today().year(), 11, 22);
        
        //Project Metric Actual for Quarterly 1
        Project_Metric_Actual__c projectMetricActualQuarterly1 = UTL_PSA_TestData.createProjectMetricActual(parentproj.id, projectMetricForQuarterly.id, psaMetricQuarterly.id);
        projectMetricActualQuarterly1.Date__c = Date.newInstance(System.Today().year(), 01, 01);
        
        //Project Metric Actual for Quarterly 2
        Project_Metric_Actual__c projectMetricActualQuarterly2 = UTL_PSA_TestData.createProjectMetricActual(parentproj.id, projectMetricForQuarterly.id, psaMetricQuarterly.id);
        projectMetricActualQuarterly2.Date__c = Date.newInstance(System.Today().year(), 11, 22);
        
        //Project Metric Actual for Semi_Annual 1
        Project_Metric_Actual__c projectMetricActualSemi_Annual1 = UTL_PSA_TestData.createProjectMetricActual(parentproj.id, projectMetricForSemi_Annual.id, psaMetricSemi_Annual.id);
        projectMetricActualSemi_Annual1.Date__c = Date.newInstance(System.Today().year(), 01, 01);
        
        //Project Metric Actual for Semi_Annual 2
        Project_Metric_Actual__c projectMetricActualSemi_Annual2 = UTL_PSA_TestData.createProjectMetricActual(parentproj.id, projectMetricForSemi_Annual.id, psaMetricSemi_Annual.id);
        projectMetricActualSemi_Annual2.Date__c = Date.newInstance(System.Today().year() + 1, 11, 22);
        
        //Project Metric Actual for Rolling_12 1
        Project_Metric_Actual__c projectMetricActualRolling_121 = UTL_PSA_TestData.createProjectMetricActual(parentproj.id, projectMetricForRolling_12.id, psaMetricRolling_12.id);
        projectMetricActualRolling_121.Date__c = Date.newInstance(System.Today().year() + 1, 01, 01);
        
        //Project Metric Actual for Rolling_12 2
        Project_Metric_Actual__c projectMetricActualRolling_122 = UTL_PSA_TestData.createProjectMetricActual(parentproj.id, projectMetricForRolling_12.id, psaMetricRolling_12.id);
        projectMetricActualRolling_122.Date__c = Date.newInstance(System.Today().year() + 1, 11, 22);
        
        //Project Metric Actual for EmptyServiceLine Validation
        Project_Metric_Actual__c projectMetricActualEmptyServiceLine = UTL_PSA_TestData.createProjectMetricActual(parentproj.id, projectMetricForEmptyServiceLine.id, psaMetricEmptyServiceLine.id);
        projectMetricActualEmptyServiceLine.Date__c = Date.newInstance(System.Today().year(), 11, 22);
        
        Test.startTest();
        List<Project_Metric_Actual__c> pmaRecords = new List<Project_Metric_Actual__c>();
        
        //(Monthly) Project_Metric_Actual record added with failure
        try{
            insert projectMetricActualMonthly2;
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Service line project \'End Date\' is in the past. Please update the service line project \'End Date\' and try again.') ? true : false;
            System.assertEquals(expectedExceptionThrown, true, 'Tested');
        }
        //(Monthly)Project_Metric_Actual record added with success
        insert projectMetricActualMonthly1;
        pmaRecords = [Select Id from Project_Metric_Actual__c LIMIT 50];
        System.assertEquals(2, pmaRecords.size(), 'Tested');
        
        //(Quarterly) Project_Metric_Actual record added with failure
        try{
            insert projectMetricActualQuarterly2;
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Service line project \'End Date\' is in the past. Please update the service line project \'End Date\' and try again.') ? true : false;
            System.assertEquals(expectedExceptionThrown, true, 'Tested');
        }
        //(Quarterly) Project_Metric_Actual record added with success
        insert projectMetricActualQuarterly1;
        pmaRecords = [Select Id from Project_Metric_Actual__c LIMIT 50];
        System.assertEquals(4, pmaRecords.size(), 'Tested');
        
        //(Semi_Annual) Project_Metric_Actual record added with failure
        try{
            insert projectMetricActualSemi_Annual2;
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Service line project \'End Date\' is in the past. Please update the service line project \'End Date\' and try again.') ? true : false;
            System.assertEquals(expectedExceptionThrown, true, 'Tested');
        }
        //(Semi_Annual) Project_Metric_Actual record added with success
        insert projectMetricActualSemi_Annual1;
        pmaRecords = [Select Id from Project_Metric_Actual__c LIMIT 50];
        System.assertEquals(6, pmaRecords.size(), 'Tested');
        
        //(Rolling_12) Project_Metric_Actual record added with failure
        try{
            insert projectMetricActualRolling_122;
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Service line project \'End Date\' is in the past. Please update the service line project \'End Date\' and try again.') ? true : false;
            System.assertEquals(expectedExceptionThrown, true, 'Tested');
        }
        //(Rolling_12) Project_Metric_Actual record added with success
        insert projectMetricActualRolling_121;
        pmaRecords = [Select Id from Project_Metric_Actual__c LIMIT 50];
        System.assertEquals(8, pmaRecords.size(), 'Tested');
        
        //(EmptyServiceLine Validation) Project_Metric_Actual record added with failure
        try{
            insert projectMetricActualEmptyServiceLine;
        }
        catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('There is no service line on this metrics, please link with a service line.') ? true : false;
            System.assertEquals(expectedExceptionThrown, true, 'Tested');
        }
        Test.stopTest();
    }
}
