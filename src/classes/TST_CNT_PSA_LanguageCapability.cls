@isTest
public without sharing class TST_CNT_PSA_LanguageCapability {
    @isTest
    public static void testGetResourceInfo(){
        List<CNT_PSA_LanguageCapability.WPR_PSA_LanguageSkillSet> responseList = new List<CNT_PSA_LanguageCapability.WPR_PSA_LanguageSkillSet>();
        //Service Line Project
        pse__Proj__c project = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);  
        project.recordTypeId = recTypeId;
        project.pse__Stage__c = CON_PSA.PROJ_STAGE_STARTUP;
        insert project;
        
        //Program
        Program__c program = new Program__c(Name = 'TestProgram');
        insert program;
        
        //Service Line [Literature]
        Service_Line__c serviceline = UTL_PSA_TestData.createServiceLine(1, false)[0];
        serviceline.Name = CON_PSA.MEDICAL_INFORMATION_SERVICE_LINE;
        serviceline.Service_Line_Code__c = CON_PSA.MEDICAL_INFORMATION_SERVICE_LINE_CODE;
        insert serviceline;
        
        //Parent Project
        pse__Proj__c parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Stage__c = CON_PSA.PROJ_STAGE_STARTUP;
        parentproject.Program__c = program.id;
        insert parentproject;
        
        //Service Line Project [Literature]
        pse__Proj__c literatureProject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeIdServiceLineProject = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        literatureProject.recordTypeId = recTypeIdServiceLineProject;
        literatureProject.pse__Stage__c = CON_PSA.PROJ_STAGE_STARTUP;
        literatureProject.pse__Parent_Project__c = parentproject.Id;
        literatureProject.Service_Line__c = serviceline.Id;
        literatureProject.Program__c = program.id;
        insert literatureProject;
        
        //Permission Control
        pse__Permission_Control__c pc = new pse__Permission_Control__c();
        pc.CurrencyIsoCode = project.CurrencyIsoCode;
        pc.pse__User__c = UserInfo.getUserId();
        pc.pse__Region__c = project.pse__region__c;
        pc.pse__Cascading_Permission__c = true;
        pc.Unit_Entry_Ops_Edit__c = true;
        pc.pse__Billing__c = true;
        pc.pse__Expense_Entry__c = true;
        pc.pse__Expense_Ops_Edit__c = true;
        pc.pse__Forecast_Edit__c = true;
        pc.pse__Forecast_View__c = true;
        pc.pse__Invoicing__c = true;
        pc.pse__Edit_Task_Manager__c = true;
        pc.pse__View_Task_Manager__c = true;
        pc.pse__Resource_Request_Entry__c = true;
        pc.pse__Skills_And_Certifications_Entry__c = true;
        pc.pse__Skills_And_Certifications_View__c = true;
        pc.pse__Staffing__c = true;
        pc.pse__Timecard_Entry__c = true;
        pc.pse__Timecard_Ops_Edit__c = true;
        pc.Unit_Entry_Ops_Edit__c = true;
        insert pc;
        
        //Contact
        Contact contact = UTL_PSA_TestData.createResources(1,false)[0];
        contact.pse__Is_Resource__c = true;
        contact.pse__Is_Resource_Active__c = true;
        //contact.pse__Group__c = grp.Id;
        contact.FirstName = UserInfo.getFirstName();
        contact.LastName = UserInfo.getLastName();
        contact.pse__Salesforce_User__c = userInfo.getUserId();
        insert contact;
        
        //Resource Request
        pse__Resource_Request__c resourcerequest = new pse__resource_request__c();
        resourcerequest.CurrencyIsoCode = project.CurrencyIsoCode;
        resourcerequest.pse__Resource_Request_Name__c = 'Test request 1';
        resourcerequest.pse__Project__c = project.id;
        resourcerequest.pse__Start_Date__c = project.pse__start_date__c;
        resourcerequest.pse__End_Date__c = project.pse__start_date__c.addDays(1);
        resourcerequest.pse__Region__c = project.pse__Region__c;
        resourcerequest.pse__Group__c = project.pse__Group__c;
        resourcerequest.pse__Resource_Role__c = CON_PSA.RESOURCE_ROLE_SERVICELINE_LEAD;
        resourcerequest.pse__Requested_Bill_Rate__c = 200.0;
        resourcerequest.pse__SOW_Hours__c = 500;
        resourcerequest.pse__Planned_Bill_Rate__c = 200.0;
        resourcerequest.pse__Notes__c = 'Test';
        resourcerequest.pse__Status__c = CON_PSA.RESOURCE_REQUEST_STATUS_DRAFT;
        resourcerequest.recordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Resource_Request__c', CON_PSA.RESOURCE_REQUEST_REC_TYPE_RDS_REQUEST); 
        insert resourcerequest;
        
        //Assignment 1
        List<Contact> resList = new List<Contact>();
        resList.add(contact);
        pse__Assignment__c assignment = UTL_PSA_TestData.createAssignments(resList, literatureProject, false)[0];
        assignment.pse__Is_Billable__c = project.pse__Is_Billable__c;
        assignment.pse__Bill_Rate__c = (assignment.pse__Is_Billable__c && project.pse__Billing_Type__c == CON_PSA.PROJ_BILL_TYPE_FIXED) ? 200 : 0;
        assignment.pse__Planned_Hours__c = 100;
        assignment.pse__Project__c = project.Id;
        assignment.pse__Resource__c = contact.id;
        assignment.pse__Role__c = CON_PSA.RESOURCE_ROLE_SERVICELINE_LEAD;
        assignment.pse__Status__c = CON_PSA.ASSIGNMENT_STATUS_SCHEDULED;
        assignment.pse__Time_Credited__c = project.pse__Time_Credited__c;
        assignment.pse__Time_Excluded__c = project.pse__Time_Excluded__c;
        assignment.RecordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Assignment__c', CON_PSA.ASSIGNMENT_REC_TYPE_RDS);
        assignment.Primary_Service_Line_Lead__c = true;
        assignment.Resource_Language_Skill_Set__c = 'Vietnamese: A1 (Breakthrough)<br>';
        insert assignment;
        
        pse__Skill__c skill = UTL_OWF_TestData.createSkills('Test Skill',CON_OWF.SKILL_TYPE_INDICATION);
        skill.pse__Type__c ='Language';
        insert skill;
        pse__Skill_Certification_Rating__c skillCertificationRating1 = new pse__Skill_Certification_Rating__c();
        skillCertificationRating1.pse__Resource__c = contact.Id;
        skillCertificationRating1.pse__Skill_Certification__c = skill.Id; 
        skillCertificationRating1.pse__Rating__c = 'A1 (Breakthrough)';
        skillCertificationRating1.Language__c ='vi';
        insert skillCertificationRating1;
        
        Test.startTest();
        CNT_PSA_LanguageCapability lc = new CNT_PSA_LanguageCapability();
        CNT_PSA_LanguageCapability.getResourceInfo(project.Id,1,'', '', true);
        CNT_PSA_LanguageCapability.getLanguageOptions(String.valueOf(assignment.Id));
        CNT_PSA_LanguageCapability.saveOptions(String.valueOf(assignment.Id), new List<String>{'ar'}, responseList);
        System.assertEquals(resList.size(), 1, 'Testing');
        Test.stopTest();
    }
}
