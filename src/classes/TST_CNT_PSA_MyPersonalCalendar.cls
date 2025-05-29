// Test class for controller class CNT_PSA_MyPersonalCalendar

@isTest
public class TST_CNT_PSA_MyPersonalCalendar {
    @testSetup
    static void dataSetup() 
    {
        
        //Contact
        Id contactTypeId = UTL_PSA_TestData.lookupRecordTypeId('Contact', CON_PSA.CONTACT_REC_TYPE_IQVIA_USER_CONTACT);
        Contact contact = UTL_PSA_TestData.createResources(1,false)[0];
        contact.RecordTypeId = contactTypeId;
        insert contact;
        
        //Program
        Program__c program = new Program__c(Name = 'TestProgram');
        insert program;
        
        //Service Line [Literature]
        Service_Line__c serviceline = UTL_PSA_TestData.createServiceLine(1, false)[0];
        serviceline.Name = CON_PSA.LITERATURE;
        serviceline.Service_Line_Code__c = CON_PSA.SERVICE_LINE_CODE_LIT;
        insert serviceline;
        
        //Parent Project
        pse__Proj__c parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Stage__c = CON_PSA.PROJ_STAGE_STARTUP;
        parentproject.Program__c = program.id;
        insert parentproject;
        
        //Account
        Account acct2 = new Account(Name = 'testSetupTestSponsorAccount1',RDCategorization__c = 'Sponsor', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert acct2;
        
        //Service Line Project
        pse__Proj__c project = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        project.recordTypeId = recTypeId;
        project.pse__Stage__c = CON_PSA.PROJ_STAGE_STARTUP;
        project.pse__Parent_Project__c = parentproject.Id;
        project.Service_Line__c = serviceline.Id;
        project.Program__c = program.id;
        project.pse__Account__c = acct2.Id;
        insert project;     
        
        List<user> currentuser = [SELECT Id,Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        //LR Project Overview
        LR_Project_Overview__c lrProjectOverview = UTL_PSA_TestData.createLRProjectOverview();
        lrProjectOverview.Program__c = program.id;
        lrProjectOverview.Project__c = project.id;
        lrProjectOverview.LR_Type__c = CON_PSA.LR_PROJECT_OVERVIEW_LR_Type_LOCAL;
        insert lrProjectOverview;
        
        PSA_Event__c psaEvent = new PSA_Event__c();
        psaEvent.Object__c = 'LR_Project_Overview__c';
        psaEvent.Planned_Date_Field__c = 'LR_LBI_Period_Stop_Date__c';
        psaEvent.Notification_Offset__c = -2;
        psaEvent.Event_Name__c = 'DLP 30 days approaching email trigger';
        psaEvent.Send_Missed_Due_Date_Noti_Offset__c = 1;
        insert psaEvent;
        
        PSA_Event__c psaEvent1 = new PSA_Event__c();
        psaEvent1.Object__c = 'LR_Project_Overview__c';
        psaEvent1.Planned_Date_Field__c = 'DLP_Enter_only_for_Aggregate_Reports__c';
        psaEvent1.Notification_Offset__c = -2;
        psaEvent1.Event_Name__c = 'DLP 30 days approaching email trigger';
        psaEvent1.Send_Missed_Due_Date_Noti_Offset__c = 1;
        insert psaEvent1;
        
        Project_Event__c pje = new Project_Event__c();
        pje.Project__c = project.id;
        pje.PSA_Event__c = psaEvent.id;
        pje.LR_Project_Overview__c = lrProjectOverview.id;
        pje.Notification_Date__c = DATE.today();
        pje.Event_Due_Date__c = Date.newInstance(1960, 2, 17);
        insert pje;
        
        Project_Event__c pje1 = new Project_Event__c();
        pje1.Project__c = project.id;
        pje1.PSA_Event__c = psaEvent.id;
        pje1.LR_Project_Overview__c = lrProjectOverview.id;
        pje1.Notification_Date__c = DATE.today();
        pje1.Event_Due_Date__c = Date.newInstance(1960, 2, 17);
        insert pje1;
    }
    
    @IsTest
    static void testGetMyLRProjectOverviews() {
        List<user> currentuser = [SELECT Id,Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        Test.startTest();
        List<CNT_PSA_MyPersonalCalendar.CalendarWrapper> lstCalendar = new List<CNT_PSA_MyPersonalCalendar.CalendarWrapper>();
        lstCalendar = CNT_PSA_MyPersonalCalendar.getData(currentuser[0].Name,currentuser[0].Id, '1');
        Test.stopTest();
	System.assertEquals(0,lstCalendar.size(), 'Expected Result');
    }
}
