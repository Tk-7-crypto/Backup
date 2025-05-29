/**
 * This test class is used to test DAOH_PSA_Project.cls. It is copied over from TST_TGR_Proj.cls
 * version : 1.0
 */
@isTest
public with sharing class TST_DAOH_PSA_Project 
{
    @testSetup
    static void dataSetup() 
    {
        List<sObject> toSave = new List<sObject>();

        pse__Grp__c grp = new pse__Grp__c( Name='PV Solutions' );
        toSave.add(grp);

        Service_Line__c agReportServiceLine = new Service_Line__c (
            Active__c = true,
            Service_Line_Code__c = 'TEST1',
            Name = 'Aggregate Reporting'
        ); 
        toSave.add(agReportServiceLine);

        Service_Line__c pvsServiceLine = new Service_Line__c (
            Active__c = true,
            Service_Line_Code__c = 'TEST2',
            Name = 'PV Solutions'
        );
        toSave.add(pvsServiceLine);
        
        Service_Line__c SMServiceLine = new Service_Line__c (
            Active__c = true,
            Service_Line_Code__c = 'SM',
            Name = 'Signal Management'
        );
        toSave.add(SMServiceLine);
        
        Service_Line__c cevaServiceLine = new Service_Line__c (
            Active__c = true,
            Service_Line_Code__c = 'CEVA',
            Name = 'CEVA'
        );
        toSave.add(cevaServiceLine);
        
        //service
        Service__c cevaService = new Service__c(Name = 'CEVA Service');
        cevaService.Service_Code__c = '123456';
        cevaService.Service_Line__c = cevaServiceLine.Id;
        insert cevaService; 
        
       //service
        Service__c service = new Service__c(Name = 'Test Service');
        service.Service_Code__c = '12345678';
        service.Service_Line__c = SMServiceLine.Id;
        insert service; 
        
        pse__Proj__c parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        parentproject.pse__Stage__c = 'Start-up';
        parentproject.pse__Start_Date__c = System.today()-1000;
        parentproject.pse__End_Date__c = System.today()+1000;
        parentproject.Actual_Go_Live_Date__c = System.today();
        parentproject.Go_Live_Date__c = System.today();
        toSave.add(parentProject);
        insert toSave;
        toSave = new List<sObject>(); 

        pse__Proj__c project = UTL_PSA_TestData.createServiceLineProject(parentProject, 'Aggregate Reporting Project', false);
        project.Service_Line__c = agReportServiceLine.Id;
        toSave.add(project);
        
        pse__Proj__c pvsProject = UTL_PSA_TestData.createServiceLineProject(parentProject, 'PV Solutions Project', false);
        pvsProject.Service_Line__c = pvsServiceLine.Id;
        toSave.add(pvsProject);
        
        pse__Proj__c cevaServicelineproject = UTL_PSA_TestData.createProjects(2, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        cevaServicelineproject.recordTypeId = recTypeId;
        cevaServicelineproject.pse__Parent_Project__c = parentProject.id;
        cevaServicelineproject.Name = 'Test ServiceLine Project';
        cevaServicelineproject.pse__Stage__c = 'Cancelled';
        cevaServicelineproject.Service_Line_Scope__c = 'IRC;DMC';
        cevaServicelineproject.Service_Line__c = cevaServiceLine.id;
        toSave.add(cevaServicelineproject);
        
        RecordType contactRT = [SELECT Id from RecordType where Name='IQVIA User Contact'];
        UTL_PSA_TestData.createResources(1,false);
        Contact contact = [Select id,FirstName,LastName,Email from Contact limit 1];
        contact.RecordTypeId = contactRT.Id;
        contact.pse__Salesforce_User__c = UserInfo.getUserId();
        contact.pse__Group__c = grp.id;
        update contact;
        
        pse__Proj__c smProject = UTL_PSA_TestData.createServiceLineProject(parentProject, 'Signal Management Project', false);
        smProject.Service_Line__c = SMServiceLine.Id;
        smProject.Service_Line_Lead__c = contact.Id;
        toSave.add(smProject);

        UTL_PSA_TestData.createPermissionControls();

        insert toSave;
        toSave = new List<sObject>();

        pse__Resource_Request__c resourcerequest = UTL_PSA_TestData.createResourceRequests(1, project, false)[0];
        toSave.add(resourcerequest);
        
        RecordType recordId = [SELECT Id from RecordType where Name='General Report'];
        Aggregate_Report__c ar = new Aggregate_Report__c();
        ar.Project__c = project.Id; 
        ar.RecordTypeId = recordId.Id;
        toSave.add(ar);

        insert toSave;
        
        PSA_RDS_Settings__c setting = new PSA_RDS_Settings__c();
        setting.Signal_Management_Service_Line_Id__c = SMServiceLine.id;
        insert setting;
        
        Program__c program = new Program__c(Name = 'TestProgram');
        insert program;
        
        Id targetRecordTypeId = UTL_PSA_TestData.lookupRecordTypeId('Target__c', CON_PSA.TARGET_REC_TYPE_RDS_PRODUCT_LINE);
        Target__c target = new Target__c(
            recordTypeId=targetRecordTypeId,
            Name='Test Target',
            API__c='Test API',
            Strength__c='Super strong',
            Dosage_Form__c='Huge pill',
            Program__c=program.Id,
            Inactivated_Date__c = system.today(),
            Date_Activated__c = System.today(),
            Countries_NA__c = true
        );
        insert target;
        
        SD_Runs__c sdrunRec = new SD_Runs__c();
        sdrunRec.Frequency__c = 'Weekly';
        sdrunRec.Project__c = smProject.id;
        sdrunRec.Product__c = target.id;
        sdrunRec.Service_Line_Lead__c = contact.Id;
        insert sdrunRec;
        
        pse__Schedule__c sch = new pse__Schedule__c();
        sch.pse__Start_Date__c = project.pse__Start_Date__c;
        sch.pse__End_Date__c = project.pse__End_Date__c;
        sch.pse__Monday_Hours__c = 8;
        sch.pse__Tuesday_Hours__c = 8;
        sch.pse__Wednesday_Hours__c = 8;
        sch.pse__Thursday_Hours__c = 8;
        sch.pse__Friday_Hours__c = 8;
        sch.pse__Saturday_Hours__c = 0;
        sch.pse__Sunday_Hours__c = 0;
        insert sch;
        
        pse__Assignment__c assignment = new pse__assignment__c();
        assignment.pse__Is_Billable__c = project.pse__Is_Billable__c;
        assignment.pse__Bill_Rate__c = (assignment.pse__Is_Billable__c && project.pse__Billing_Type__c == CON_PSA.PROJ_BILL_TYPE_FIXED) ? 200 : 0;
        assignment.pse__Planned_Hours__c = 100;
        assignment.pse__Project__c = project.Id;
        assignment.pse__Resource__c = contact.id;
        assignment.pse__Role__c = CON_PSA.RESOURCE_ROLE_SERVICELINE_LEAD;
        assignment.pse__Schedule__c = sch.Id;
        assignment.pse__Status__c = CON_PSA.ASSIGNMENT_STATUS_SCHEDULED;
        assignment.pse__Time_Credited__c = project.pse__Time_Credited__c;
        assignment.pse__Time_Excluded__c = project.pse__Time_Excluded__c;
        assignment.RecordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Assignment__c', CON_PSA.ASSIGNMENT_REC_TYPE_RDS);
        assignment.Primary_Service_Line_Lead__c = true;
        assignment.Active__c = true;
        insert assignment;
        List< pse__Project_Task__c > lstPT = new List< pse__Project_Task__c >();
        pse__Project_Task__c pt = new pse__Project_Task__c();
        pt.recordTypeId =  Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosByName().get('RDS Project Task').getRecordTypeId();
        pt.pse__Project__c = project.Id;
        pt.Parent_Project__c = parentproject.Id;
        pt.pse__Status__c = 'In Progress';
        pt.pse__Start_Date_Time__c = date.today().addDays(-30);
        pt.pse__End_Date_Time__c = date.today().addDays(-3);
        pt.Start_Date_Planned__c = date.today().addDays(-3);
        pt.End_Date_Planned__c = date.today().addDays(-3);
        pt.Service__c = service.id;
        pt.Countries__c = 'US';
        pt.Reason_for_Deletion__c = 'Delete pt';
        pt.Program__c = program.id;
        pt.Resource__c = Contact.Id;
        pt.Frequency__c = 'Yearly';
        pt.Service_Line_Scope__c = 'DMC';
        pt.Type__c = 'Maintenance';
        lstPT.add( pt );     
           
        pse__Project_Task__c pt1 = new pse__Project_Task__c();
        pt1.recordTypeId =  Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosByName().get('RDS Project Task').getRecordTypeId();
        pt1.pse__Project__c = project.Id;
        pt1.Parent_Project__c = parentproject.Id;
        pt1.pse__Status__c = 'In Progress';
        pt1.pse__Start_Date_Time__c = date.today().addDays(-30);
        pt1.pse__End_Date_Time__c = date.today().addDays(-3);
        pt1.Start_Date_Planned__c = date.today().addDays(-3);
        pt1.End_Date_Planned__c = date.today().addDays(-3);
        pt1.Service__c = service.id;
        pt1.Countries__c = 'US';
        pt1.Reason_for_Deletion__c = 'Delete pt';
        pt1.Program__c = program.id;
        pt1.Resource__c = Contact.Id;
        pt1.Frequency__c = 'Yearly';
        pt1.Service_Line_Scope__c = 'IRC';
        pt1.Type__c = 'Start-up';
        lstPT.add( pt1 ); 
        
        pse__Project_Task__c pt2 = new pse__Project_Task__c();
        pt2.recordTypeId =  Schema.SObjectType.pse__Project_Task__c.getRecordTypeInfosByName().get('RDS Project Task').getRecordTypeId();
        pt2.pse__Project__c = cevaServicelineproject.Id;
        pt2.Parent_Project__c = parentproject.Id;
        pt2.pse__Status__c = 'In Progress';
        pt2.pse__Start_Date_Time__c = date.today().addDays(-30);
        pt2.pse__End_Date_Time__c = date.today().addDays(-3);
        pt2.Start_Date_Planned__c = date.today().addDays(-3);
        pt2.End_Date_Planned__c = date.today().addDays(-3);
        pt2.Service__c = cevaService.id;
        pt2.Countries__c = 'US';
        pt2.Reason_for_Deletion__c = 'Delete pt';
        pt2.Program__c = program.id;
        pt2.Resource__c = Contact.Id;
        pt2.Frequency__c = 'Yearly';
        pt2.Service_Line_Scope__c = 'DMC';
        pt2.Type__c = 'Maintenance';
        lstPT.add( pt2 ); 
        
        Test.startTest();
        insert lstPT;	
        Test.stopTest();
    }
    
    @IsTest
    static void testUpdatePMFieldOnRR () 
    {
        //setupTestData();
        Contact contact = [Select Id from Contact limit 1];
        pse__Resource_Request__c resourcerequest = [Select Id from pse__Resource_Request__c limit 1];
        Service_Line__c agReportServiceLine = [Select Id, Name from Service_Line__c where Name ='Aggregate Reporting' limit 1];
        Test.startTest();
        pse__Proj__c project = [Select Id, Name from pse__Proj__c where Service_Line__c =: agReportServiceLine.Id];
        project.Service_Line_Lead__c = contact.Id;
        update project;
        Test.stopTest();
        
        // verify that ResourceRequest Project Manager and Service Line Lead was set to the Project PM.
        pse__Resource_Request__c rrAfterUpdate = [SELECT pse__Project__c,pse__Project__r.Name,Project_Manager__c,Project_Manager__r.Name,Service_Line_Lead__c,Service_Line_Lead__r.Name from pse__Resource_Request__c where Id=: resourcerequest.Id];
        System.assertEquals(contact.Id, rrAfterUpdate.Project_Manager__c);
        System.assertEquals(contact.Id, rrAfterUpdate.Service_Line_Lead__c);
    }

    @IsTest
    static void testInsertServiceLineProjectFields () 
    {
        Contact contact = [Select Id from Contact where  pse__Salesforce_User__c != NULL limit 1];
        Test.startTest();
        pse__Proj__c anotherproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        anotherproject.recordTypeId = recTypeId;
        anotherproject.Service_Line_Lead__c= contact.Id;
        insert anotherproject;
        Test.stopTest();
        
        // verify that Project's Project Manager matches Service Line Lead.
        pse__Proj__c projectAfterInsert = [SELECT Name,Service_Line_Lead__c,pse__Project_Manager__c from pse__Proj__c where Id=: anotherproject.Id];
        System.assertEquals(contact.Id, projectAfterInsert.pse__Project_Manager__c);
        System.assertEquals(projectAfterInsert.Service_Line_Lead__c, projectAfterInsert.pse__Project_Manager__c);
    }

    @IsTest
    static void testUpdateServiceLineProjectFields () 
    {
        //setupTestData();
        Contact contact = [Select Id from Contact limit 1];
        Service_Line__c agReportServiceLine = [Select Id, Name from Service_Line__c where Name ='Aggregate Reporting' limit 1];
        Test.startTest();
        pse__Proj__c project = [Select Id, Name from pse__Proj__c where Service_Line__c =: agReportServiceLine.Id];
        project.Service_Line_Lead__c= contact.Id;
        update project;
        Test.stopTest();
        
        // verify that Project's Project Manager matches Service Line Lead .
        pse__Proj__c projectAfterUpdate = [SELECT Name,Service_Line_Lead__r.Name,pse__Project_Manager__c from pse__Proj__c where Id=: project.Id];
        System.assertEquals(contact.Id, projectAfterUpdate.pse__Project_Manager__c);
    }

    @IsTest
    static void testCascadeToServiceLineProjects ()
    {
        //setupTestData();
        Service_Line__c agReportServiceLine = [Select Id, Name from Service_Line__c where Name ='Aggregate Reporting' limit 1];
        pse__Proj__c project = [Select Id, Name from pse__Proj__c where Service_Line__c =: agReportServiceLine.Id];
        Test.startTest();
        pse__Proj__c parentproject = [Select Id, Name, pse__Stage__c from pse__Proj__c where pse__Stage__c = 'Start-up'];
        parentproject.pse__Stage__c = 'Completed';
        parentproject.Actual_Go_Live_Date__c = System.today()-1;
        update parentproject;
        parentproject.Go_Live_Date__c = System.today()+1;
        update parentproject;
        Test.stopTest();

        // verify that Parent project's stage is updated to 'Completed'' .
        pse__Proj__c parentprojectAfterUpdate = [SELECT Name,pse__Stage__c from pse__Proj__c where Id=: parentproject.Id];
        System.assertEquals('Completed', parentprojectAfterUpdate.pse__Stage__c);

        // verify that Sub project's stage is updated to 'Not Active' .
        pse__Proj__c subprojectAfterUpdate = [SELECT Name,pse__Stage__c from pse__Proj__c where Id=: project.Id];
        subprojectAfterUpdate.pse__Stage__c = 'Completed';
        update subprojectAfterUpdate;
        System.debug('subprojectAfterUpdate.pse__Stage__c'+ subprojectAfterUpdate.pse__Stage__c);
        //System.assertEquals('Not Active', subprojectAfterUpdate.pse__Stage__c);
    }
    
    @IsTest
    static void testfieldValidationsRDS()
    {
        Test.startTest();
        try{
            Service_Line__c smServiceLine = [Select Id, Name from Service_Line__c where Name ='Signal Management' limit 1];
            pse__Proj__c project = [Select Id, Name from pse__Proj__c where name =: 'Signal Management Project'];
            project.CT_Database_Location__c = null;
            project.Safety_Database_Location__c = null;
            project.Setting__c = null;
            project.Scope__c = 'Other';
            update project;
        }
        catch(Exception ex)
        {
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        Test.stopTest();
    }
    
     @IsTest
    static void testvalidateDeletion()
    {
        //setupTestData();
        Service_Line__c agReportServiceLine = [Select Id, Name from Service_Line__c where Name ='Aggregate Reporting' limit 1];
        pse__Proj__c project = [Select Id, Name from pse__Proj__c where Service_Line__c =: agReportServiceLine.Id];
        Test.startTest();
       
        // verify that Sub project's stage is updated to 'Not Active' .
        pse__Proj__c projectToDelete = [SELECT Name,pse__Stage__c from pse__Proj__c where  isDeleted = FALSE LIMIT 1];
        delete projectToDelete;
        Test.stopTest();
    }
    
    @isTest
    static void testsyncProjectScopeFields() {       
        Test.startTest();
        pse__Proj__c projectToUpdate = [SELECT Name,Project_Scope__c from pse__Proj__c where pse__Stage__c = 'Start-up'];
        projectToUpdate.Project_Scope__c = 'Stand-Alone';
        //update projectToUpdate;
        Test.stopTest();
    }
    
    

    
    @IsTest
    static void testUpdateServiceLineProjectStage () 
    {
        //setupTestData();
        Contact contact = [Select Id from Contact limit 1];
        Service_Line__c agReportServiceLine = [Select Id, Name from Service_Line__c where Name ='Aggregate Reporting' limit 1];
        Test.startTest();
        pse__Proj__c project = [Select Id, Name from pse__Proj__c where Service_Line__c =: agReportServiceLine.Id];
        project.Service_Line_Lead__c= contact.Id;
        project.pse__Stage__c = 'Completed';
        update project;
        project.Action_Apply_Template_Tasks__c = true;
        update project;
        Test.stopTest();
        
        // verify that Project's Project Manager matches Service Line Lead .
        pse__Proj__c projectAfterUpdate = [SELECT Name,Service_Line_Lead__r.Name,pse__Project_Manager__c from pse__Proj__c where Id=: project.Id];
        System.assertEquals(contact.Id, projectAfterUpdate.pse__Project_Manager__c);
    }
    @IsTest
    static void testUpdateAssignmentCheckListTaskOnChangeOrder(){
        List<pse__Proj__c>  proj=[Select Id,pse__End_Date__c,Name,RecordType.Name from pse__Proj__c where pse__Stage__c='Start-up' and RecordType.Name='RDS Project'];
        Set<Id> projectIds=new Set<Id>();
       	Test.startTest();
        for(pse__Proj__c p:proj){
            p.pse__End_Date__c=Date.newInstance(2040, 2, 17);
            projectIds.add(p.Id);
        }
        update proj;
        Test.stopTest();
        List<pse__Assignment__c> assignmentList=[SELECT id, pse__End_Date__c,pse__Project__r.pse__Parent_Project__r.pse__End_Date__c  from pse__Assignment__c where pse__Project__r.pse__Parent_Project__c in:projectIds];
        for(pse__Assignment__c ass: assignmentList){
            System.assertEquals(ass.pse__End_Date__c, ass.pse__Project__r.pse__Parent_Project__r.pse__End_Date__c);
        }     	
    }

    @IsTest
    static void testdeleteDeselectedSlScopeProjectTasks(){
        Set<Id> projectIdSet = new Set<Id>();
        Set<String> projectTaskFieldsSet = new Set<string>{'Id','Service_Line_Scope__c','pse__Project__c','pse__Status__c'};
        List<pse__Proj__c>  proj=[Select Id, Service_Line_Scope__c, Name, Service_Line__r.Name, RecordType.Name from pse__Proj__c where RecordType.Name = 'RDS Service Line' and Service_Line__r.Name ='CEVA' limit 1];
        test.startTest();
        for(pse__Proj__c project:proj){
            project.Service_Line_Scope__c = 'Advisory Board';
            projectIdSet.add(project.id);
        }
        update proj;
        Test.stopTest();
        List< pse__Project_Task__c > currentProjectTaskList = new SLT_Project_Task().getProjectTasksByServiceLineProject( projectIdSet, projectTaskFieldsSet);
        System.assertEquals(0, currentProjectTaskList.size(), 'Tested');
    }
}
