/*
 * Version       : 1.0
 * Description   : Test Class for SLT_Report_Drug
 */
@isTest
private class TST_SLT_Report_Drug {
    @testSetup static void setup() {
        UTL_PSA_TestData.createPermissionControls();

        Program__c program = new Program__c(Name = 'TestProgram');
        insert program;

        Service_Line__c serviceline = new Service_Line__c(
            Name = 'Aggregate Reporting',
            Active__c=true,
            Service_Line_Code__c = 'AR');
        insert serviceline;

        //service
        Service__c service = new Service__c(Name = 'Test Service');
        service.Service_Code__c = '12345678';
        service.Service_Line__c = serviceline.Id;
        insert service;

        //contacts
        RecordType contactRT = [SELECT Id from RecordType where Name='IQVIA User Contact'];
        Contact testResource = UTL_PSA_TestData.createResources(1,false)[0];
        testResource.RecordTypeId = contactRT.Id;
        testResource.pse__Salesforce_User__c = UserInfo.getUserId();
        testResource.Location_Code_text__c = 'USDUR1';
        insert testResource;


        // Parent Project
        pse__Proj__c parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Project_Status__c = 'Start-up';
        parentproject.Program__c = program.id;
        insert parentproject;

        pse__Proj__c project = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        project.recordTypeId = recTypeId;
        project.pse__Project_Status__c = 'Start-up';
        project.pse__Parent_Project__c = parentproject.Id;
        project.Service_Line__c = serviceline.Id;
        insert project;
        
        //milestone
        pse__Milestone__c milestone = UTL_PSA_TestData.createMilestones(1, false)[0];
        Id milestonerecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Milestone__c', CON_PSA.MILESTONE_REC_TYPE_SERVICE);
        milestone.RecordTypeId = milestonerecTypeId;
        milestone.Actual_Quantity__c = 10;
        milestone.Billed_Quantity__c = 15;
        milestone.pse__Project__c = project.Id;
        milestone.pse__Target_Date__c = system.today();
        milestone.Actual_Amount__c = 20;
        milestone.pse__Milestone_Amount__c = 100;
        milestone.Billed_Amount__c = 30;
        milestone.Include_Tasks_on_Deliverables__c = false;
        milestone.Service__c = service.id;
        milestone.Service_Line__c = serviceline.id;
        insert milestone;
        
        Drug__c drug = new Drug__c();
        drug.Name = 'Test Drug 1';
        drug.Service_Lines__c = 'Aggregate Reporting';
        drug.Program__c = program.Id;
        drug.Therapeutic_Area__c = 'Allergy';
        insert drug;
        
        List<pse__Assignment__c> assignments = UTL_PSA_TestData.createAssignments(new List<Contact> {testResource, testResource, testResource},project,false);
        assignments[0].pse__Bill_Rate__c = 200;
        assignments[0].Sub_role__c = 'IQVIA Primary GSO';
        assignments[1].pse__Bill_Rate__c = 200;
        assignments[1].Sub_role__c = 'IQVIA GSO LM';
        assignments[2].pse__Bill_Rate__c = 200;
        assignments[2].Sub_role__c = 'IQVIA TAH';
        system.debug('Assignments: ');
        system.debug(assignments);
        insert assignments;
        
        RecordType recordId = [SELECT Id from RecordType where Name='Sanofi GSO Report'];
        Aggregate_Report__c ar2 = new Aggregate_Report__c();
        //ar2.Name = 'Test GSO Report';
        ar2.Project__c = project.Id;
        ar2.Task_Type__c = 'ACO';
        ar2.Status__c = 'In Progress';
        ar2.Product_Priority__c = 'Standard Priority';
        ar2.Local_Product_Global_Product__c = 'Local Product';
        ar2.Activity_Type__c = 'Regulard';
        ar2.Global_Business_Unit_GBU__c = 'Pasteur';
        ar2.Offensive_Generic__c = 'Yes';
        ar2.Active_Marketing_Authorization__c = 'Yes';
        ar2.Activity_DetailsEvent_Name__c = 'Test details';
        ar2.IQVIA_Primary_GSO__c = testResource.Id;
        ar2.IQVIA_GSO_LM__c = testResource.Id;    
        ar2.IQVIA_TAH__c = testResource.Id;    
        ar2.RecordTypeId = recordId.Id;
        ar2.Service_Milestone__c = milestone.Id;
        insert ar2;
        
        Report_Drug__c reportDrug = new Report_Drug__c();
        reportDrug.Drug__c = drug.Id;
        reportDrug.Program__c =  program.id;  
        reportDrug.Aggregate_Report__c = ar2.Id;
        insert reportDrug;
    }
    
    /**
     * This method used to get a Report Drug.
     */    
    @IsTest
    static void testgetReportDrugList() {
        Test.startTest();
        list<Aggregate_Report__c> aggReportList= [select id from Aggregate_Report__c limit 1];
        Set<Id> aggIdSet = new Set<Id>();
        for(Aggregate_Report__c aggRec:aggReportList)
        {
            aggIdSet.add(aggRec.id);            
        }
        Set<String> fieldSet = new Set<String>{'Id', 'Name', 'Aggregate_Report__c', 'Drug__c','Drug__r.name', 'Indication__c', 'Therapeutic_Area__c', 'Program__c'};
        List<Report_Drug__c> rptDrugList = new SLT_Report_Drug().getReportDrugList(aggIdSet, fieldSet, 'Aggregate_Report__c' );
        List<Report_Drug__c> rptDrug = new SLT_Report_Drug(false).getReportDrugList(aggIdSet, fieldSet, 'Aggregate_Report__c' );
        Test.stopTest();
        System.assertEquals(rptDrugList.size(), 1);
    }

}
