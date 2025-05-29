@isTest
public class TST_DAO_Budget {
    
    @IsTest
    static void dataSetup(){
        UTL_PSA_TestData.createPermissionControls();

        //program
        Program__c program = new Program__c(Name = 'TestProgram');
        insert program;

        //service line
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
        testResource.Email = 'test@email.com';
        insert testResource;
        
        // Parent Project
        pse__Proj__c parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Project_Status__c = 'Start-up';
        parentproject.Program__c = program.id;
        insert parentproject;

        //project
        pse__Proj__c project = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        project.recordTypeId = recTypeId;
        project.pse__Project_Status__c = 'Start-up';
        project.pse__Parent_Project__c = parentproject.Id;
        project.Service_Line__c = serviceline.Id;
        insert project;

        pse__Budget__c budgetRec = UTL_PSA_TestData.createBudgets(1,false)[0];
        budgetRec.pse__Project__c = project.id;
        budgetRec.pse__Status__c = 'Draft';
        budgetRec.pse__Type__c = 'Customer Purchase Order';
        budgetRec.pse__Effective_Date__c = system.today();
        insert budgetRec;
        Integer actual = [Select Id from pse__Budget__c].size();
        System.assertEquals(1, actual, 'Record Inserted');
    }
    
    @IsTest
    static void testSetFieldValue (){
        dataSetup();
        Test.startTest();
            pse__Budget__c budgetRec = [Select Id, pse__Status__c from pse__Budget__c limit 1];
            budgetRec.pse__Status__c = 'Open';
            update budgetRec;
        Test.stopTest();
        List<pse__Budget__c> budgetRecList = new List<pse__Budget__c>();
        budgetRecList = [SELECT Id FROM pse__Budget__c limit 1];
        System.assertEquals(1, budgetRecList.size(), 'Test budgetRec insertion');
    }
}
