/**
 * Test class for Date Offset service
 */
@isTest
private class TST_SRV_PSA_Date_Offset 
{
	@testSetup
    static void setupTestData(){
        UTL_PSA_TestData.createPermissionControls();
        
        Program__c program = new Program__c(Name = 'TestProgram');
        insert program;

        Service_Line__c serviceline = new Service_Line__c(
            Name = 'Aggregate Reporting',
            Active__c=true,
            Service_Line_Code__c = 'AR');
        insert serviceline;

        Service__c service = new Service__c(Name = 'Test Service');
        service.Service_Code__c = '12345678';
        service.Service_Line__c = serviceline.Id;
        insert service;
        
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
        project.pse__End_Date__c = system.today().addYears(2);
        insert project;
        
        List<PSA_Date_Offset__c> offsets = new List<PSA_Date_Offset__c>();
        PSA_Date_Offset__c offset = new PSA_Date_Offset__c();
        offset.Object__c = 'Aggregate_Report__c';
        offset.Type_Field__c = 'Report_Type__c';
        offset.Type_Value__c = 'DSUR';
        offset.Source_Date_Field__c = 'Data_Lock_Point__c';
        offset.Target_Date_Field__c = 'Client_First_Due__c';
        offset.Offset__c = -2;
        offset.Unit_Type__c = 'Weekday';
        offsets.add(offset);

        PSA_Date_Offset__c offset1 = new PSA_Date_Offset__c();
        offset1.Object__c = 'Aggregate_Report__c';
        offset1.Type_Field__c = 'Report_Type__c';
        offset1.Type_Value__c = 'DSUR';
        offset1.Source_Date_Field__c = 'Data_Lock_Point__c';
        offset1.Target_Date_Field__c = 'Client_Final_Due__c';
        offset1.Offset__c = 5;
        offset1.Unit_Type__c = 'Months';
        offsets.add(offset1);

        PSA_Date_Offset__c offset2 = new PSA_Date_Offset__c();
        offset2.Object__c = 'Aggregate_Report__c';
        offset2.Type_Field__c = 'Report_Type__c';
        offset2.Type_Value__c = 'DSUR';
        offset2.Source_Date_Field__c = 'Data_Lock_Point__c';
        offset2.Target_Date_Field__c = 'First_RTR_Planned_Date__c';
        offset2.Offset__c = 1;
        offset2.Unit_Type__c = 'Years';
        offsets.add(offset2);
        insert offsets;
        
        RecordType contactRT = [SELECT Id from RecordType where Name='IQVIA User Contact'];
        UTL_PSA_TestData.createResources(1,false);
        Contact testResource = [Select id,FirstName,LastName,Email from Contact limit 1];
        testResource.RecordTypeId = contactRT.Id;
        testResource.pse__Salesforce_User__c = UserInfo.getUserId();
        update testResource;
        
        pse__Assignment__c assignment = UTL_PSA_TestData.createAssignments(new List<Contact> {testResource},project,false)[0];
        assignment.pse__Bill_Rate__c = 200;
        insert assignment;

        RecordType recordId = [SELECT Id from RecordType where Name='General Report'];
        Aggregate_Report__c ar = new Aggregate_Report__c();
        ar.Data_Lock_Point__c = Date.today();
        ar.Primary_Author__c = testResource.Id;
        ar.RecordTypeId = recordId.Id;
        ar.Report_Type__c = 'DSUR';
        ar.Project_Files_SMP__c = 'http://salesforce.com';
        ar.Client_Final_Report__c = 'http://salesforce.com';
        ar.Project__c = project.Id;
        insert ar;
    }
    
    @isTest
    static void testApplyDateOffsetsToObjects(){
        //setupTestData();
        Test.startTest();
			Aggregate_Report__c ar = [Select Id from Aggregate_Report__c limit 1];       	
        Test.stopTest();

    }

    /*
    static Aggregate_Report__c ar; 
    
    static void setupTestData () {
        
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
        project.pse__End_Date__c = system.today().addYears(2);
        insert project;
        
        List<PSA_Date_Offset__c> offsets = new List<PSA_Date_Offset__c>();
        PSA_Date_Offset__c offset = new PSA_Date_Offset__c();
        offset.Object__c = 'Aggregate_Report__c';
        offset.Type_Field__c = 'Report_Type__c';
        offset.Type_Value__c = 'DSUR';
        offset.Source_Date_Field__c = 'Data_Lock_Point__c';
        offset.Target_Date_Field__c = 'Client_First_Due__c';
        offset.Offset__c = -2;
        offset.Unit_Type__c = 'Weekday';
        offsets.add(offset);

        offset = new PSA_Date_Offset__c();
        offset.Object__c = 'Aggregate_Report__c';
        offset.Type_Field__c = 'Report_Type__c';
        offset.Type_Value__c = 'DSUR';
        offset.Source_Date_Field__c = 'Data_Lock_Point__c';
        offset.Target_Date_Field__c = 'Client_Final_Due__c';
        offset.Offset__c = 5;
        offset.Unit_Type__c = 'Months';
        offsets.add(offset);

        offset = new PSA_Date_Offset__c();
        offset.Object__c = 'Aggregate_Report__c';
        offset.Type_Field__c = 'Report_Type__c';
        offset.Type_Value__c = 'DSUR';
        offset.Source_Date_Field__c = 'Data_Lock_Point__c';
        offset.Target_Date_Field__c = 'First_RTR_Planned_Date__c';
        offset.Offset__c = 1;
        offset.Unit_Type__c = 'Years';
        offsets.add(offset);
        insert offsets;
        
        RecordType contactRT = [SELECT Id from RecordType where Name='IQVIA User Contact'];
        Contact testResource = UTL_PSA_TestData.createResources(1,false)[0];
        testResource.RecordTypeId = contactRT.Id;
        testResource.pse__Salesforce_User__c = UserInfo.getUserId();
        insert testResource;
        
        pse__Assignment__c assignment = UTL_PSA_TestData.createAssignments(new List<Contact> {testResource},project,false)[0];
        assignment.pse__Bill_Rate__c = 200;
        insert assignment;

        RecordType recordId = [SELECT Id from RecordType where Name='General Report'];
        ar = new Aggregate_Report__c();
        ar.Data_Lock_Point__c = Date.today();
        ar.Primary_Author__c = testResource.Id;
        ar.RecordTypeId = recordId.Id;
        ar.Report_Type__c = 'DSUR';
        ar.Project_Files_SMP__c = 'http://salesforce.com';
        ar.Client_Final_Report__c = 'http://salesforce.com';
        ar.Project__c = project.Id;

    }
	*/
}
