/**
 * This test class is used to test DAOH_PSA_LR_Project_Overview cls.
 * version : 1.0
*/
@isTest
public class TST_DAOH_PSA_LR_Project_Overview {
    @testSetup
    static void dataSetup(){
        UTL_PSA_TestData.createPermissionControls();
        
        //Contact
        Contact contact = UTL_PSA_TestData.createResources(1,false)[0];
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
        
        Account acct2 = new Account(Name = 'testSetupTestSponsorAccount1',RDCategorization__c = 'Sponsor',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert acct2;
        
        pse__Proj__c project = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        project.recordTypeId = recTypeId;
        project.pse__Stage__c = CON_PSA.PROJ_STAGE_STARTUP;
        project.pse__Parent_Project__c = parentproject.Id;
        project.Service_Line__c = serviceline.Id;
        project.Program__c = program.id;
        project.pse__Account__c = acct2.Id;
        insert project;     
        
        Drug__c prod = new Drug__c(
            Name = 'testProduct', 
            Program__c = program.id,
            Active__c = true,
            Service_Lines__c = 'Literature');
        insert prod;
        
        //LR Project Overview
        LR_Project_Overview__c lrProjectOverview = UTL_PSA_TestData.createLRProjectOverview();
        lrProjectOverview.Program__c = program.id;
        lrProjectOverview.Project__c = project.id;
        lrProjectOverview.Product__c = prod.id;
        lrProjectOverview.LR_Type__c = CON_PSA.LR_PROJECT_OVERVIEW_LR_Type_LOCAL;
        insert lrProjectOverview;
        
        Search_Strategy__c searchStrategy = UTL_PSA_TestData.createSeachStrategyOverview();
        Account account = UTL_PSA_TestData.accounts[0];
        searchStrategy.Account__c = acct2.id;
        searchStrategy.Project__c = project.id;
        searchStrategy.Product__c = prod.id;
        searchStrategy.LR_Type__c = CON_PSA.LR_PROJECT_OVERVIEW_LR_Type_LOCAL;
        searchStrategy.LR_Project_Overview__c = lrProjectOverview.Id;
        insert searchStrategy;
        
        Event_Journals__c eventJournal = UTL_PSA_TestData.createEventJournal();
        eventJournal.LR_Project_Overview__c = lrProjectOverview.Id;
        eventJournal.Active__c = 'Yes';
        eventJournal.Inactive_since__c = Null;
        eventJournal.Account__c = acct2.id;
        eventJournal.Project__c = project.id;
        eventJournal.Product__c = prod.id;
        eventJournal.LR_Type__c = CON_PSA.LR_PROJECT_OVERVIEW_LR_Type_LOCAL;
        insert eventJournal;
        
        CFI_Meetings__c cm = UTL_PSA_TestData.createCfiMeetings();
        cm.LR_Project_Overview__c = lrProjectOverview.Id;
        insert cm;
        
        PSA_Event__c psaEvent = new PSA_Event__c();
        psaEvent.Object__c = 'LR_Project_Overview__c';
        psaEvent.Planned_Date_Field__c = 'LR_LBI_Period_Stop_Date__c';
        psaEvent.Notification_Offset__c = -2;
        psaEvent.Event_Name__c = 'DLP 30 days approaching email trigger';
        psaEvent.Send_Missed_Due_Date_Noti_Offset__c = 1;
        insert psaEvent;
        
        Project_Event__c pje = new Project_Event__c();
        pje.Project__c = project.id;
        pje.PSA_Event__c = psaEvent.id;
        pje.LR_Project_Overview__c = lrProjectOverview.id;
        pje.Notification_Date__c = DATE.today();
        pje.Event_Due_Date__c = Date.today().addDays(-1);
        insert pje;
        
        //Assignment
        List<Contact> resList = new List<Contact>();
        resList.add(contact);
        pse__Assignment__c assignment = UTL_PSA_TestData.createAssignments(resList, project, false)[0];
        assignment.pse__Is_Billable__c = project.pse__Is_Billable__c;
        assignment.pse__Bill_Rate__c = (assignment.pse__Is_Billable__c && project.pse__Billing_Type__c == CON_PSA.PROJ_BILL_TYPE_FIXED) ? 200 : 0;
        assignment.pse__Planned_Hours__c = 100;
        assignment.Active__c = true;
        assignment.pse__Role__c = CON_PSA.RESOURCE_ROLE_SERVICELINE_LEAD;
        assignment.pse__Status__c = CON_PSA.ASSIGNMENT_STATUS_SCHEDULED;
        assignment.pse__Time_Credited__c = project.pse__Time_Credited__c;
        assignment.pse__Time_Excluded__c = project.pse__Time_Excluded__c;
        assignment.RecordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Assignment__c', CON_PSA.ASSIGNMENT_REC_TYPE_RDS);
        assignment.Primary_Service_Line_Lead__c = true;
        insert assignment;
    }

    @IsTest
    static void testSetFieldValue(){
        Test.startTest();
        LR_Project_Overview__c lrRec = [Select Id from LR_Project_Overview__c  limit 1];
        lrRec.Aggregate_Reports__c = 'Yes';
        lrRec.Account__c = null;
        lrRec.DLP_Enter_only_for_Aggregate_Reports__c = system.today();
        lrRec.Full_Text_Articles_Reviewed__c = 'test Full Text Articles Reviewed';
        update lrRec;
        Test.stopTest();
    }

    @IsTest
    static void testRelatedChildObjectUpdate (){
        Test.startTest();
        try{
            Program__c program = new Program__c(Name = 'TestProgram');
            insert program;

            Account acc = new Account( Name = 'Test',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE' );
            insert acc;
            
            Drug__c drug2 = new Drug__c(Name = 'Test2');
            drug2.Service_Lines__c = 'Literature';
            drug2.Program__c = program.Id;
            insert drug2; 
            
            Service_Line__c serviceline = UTL_PSA_TestData.createSMServiceLine();
            insert serviceline;

            pse__Proj__c parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
            Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
            parentproject.recordTypeId = parentrecTypeId;
            parentproject.pse__Project_Status__c = 'Start-up';
            parentproject.Program__c = program.id;
            insert parentproject;
            
            RecordType contactRT = [SELECT Id from RecordType where Name='IQVIA User Contact'];
            Contact testResource = UTL_PSA_TestData.createResources(1,false)[0];
            testResource.RecordTypeId = contactRT.Id;
            testResource.pse__Salesforce_User__c = UserInfo.getUserId();
            testResource.Location_Code_text__c = 'USDUR1';
            insert testResource;
            
            pse__Proj__c project = UTL_PSA_TestData.createProjects(1, false)[0];
            Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
            project.recordTypeId = recTypeId;
            project.pse__Project_Status__c = 'Start-up';
            project.pse__Parent_Project__c = parentproject.Id;
            project.Service_Line__c = serviceline.Id;
            project.Go_Live_Date__c = date.today();
            project.pse__Account__c = acc.Id;
            insert project;

            LR_Project_Overview__c lrRec = [Select Id from LR_Project_Overview__c  limit 1];
            lrRec.Aggregate_Reports__c = 'Yes';
            lrRec.DLP_Enter_only_for_Aggregate_Reports__c = system.today();
            lrRec.Full_Text_Articles_Reviewed__c = 'test Full Text Articles Reviewed';
            lrRec.Project__c = project.Id;
            lrRec.Product__c = drug2.Id;
            lrRec.Account__c = acc.Id;
            lrRec.Program__c = program.Id;
            lrRec.Status__c = 'Completed';
            lrRec.Date_this_LR_Project_Completed__c = system.today();
            update lrRec;
        }catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        Test.stopTest();
    }

    @IsTest
    static void cloneRecord(){
        Test.startTest();
        try{
            Program__c program = new Program__c(Name = 'TestProgram');
            insert program;
            
            Account acc = new Account( Name = 'Test',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE' );
            insert acc;
            
            Drug__c drug2 = new Drug__c(Name = 'Test2');
            drug2.Service_Lines__c = 'Literature';
            drug2.Program__c = program.Id;
            insert drug2; 
            
            Service_Line__c serviceline = UTL_PSA_TestData.createLitrServiceLine();
            //insert serviceline;

            pse__Proj__c parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
            Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
            parentproject.recordTypeId = parentrecTypeId;
            parentproject.pse__Project_Status__c = 'Start-up';
            parentproject.Program__c = program.id;
            insert parentproject;
            
            RecordType contactRT = [SELECT Id from RecordType where Name='IQVIA User Contact'];
            Contact testResource = UTL_PSA_TestData.createResources(1,false)[0];
            testResource.RecordTypeId = contactRT.Id;
            testResource.pse__Salesforce_User__c = UserInfo.getUserId();
            testResource.Location_Code_text__c = 'USDUR1';
            insert testResource;

            pse__Proj__c project = UTL_PSA_TestData.createProjects(1, false)[0];
            Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
            project.recordTypeId = recTypeId;
            project.pse__Project_Status__c = 'Start-up';
            project.pse__Parent_Project__c = parentproject.Id;
            project.Service_Line__c = serviceline.Id;
            project.Go_Live_Date__c = date.today();
            project.pse__Account__c = acc.Id;
            insert project;           

            LR_Project_Overview__c lrRec = [Select Id from LR_Project_Overview__c  limit 1];
            lrRec.Aggregate_Reports__c = 'Yes';
            lrRec.DLP_Enter_only_for_Aggregate_Reports__c = system.today();
            lrRec.Full_Text_Articles_Reviewed__c = 'test Full Text Articles Reviewed';
            lrRec.Project__c = serviceline.Id;
            lrRec.Product__c = drug2.Id;
            lrRec.Account__c = acc.Id;
        	lrRec.Status__c = CON_PSA.LR_PROJECT_REVIEW_STATUS_COMPLETED;
            lrRec.Date_this_LR_Project_Completed__c = system.today();
            update lrRec;
        }catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        Test.stopTest();
    }

    @isTest
    static void testSynchSearchStrageyrecord(){
        Test.startTest();
        try{
            Program__c program = new Program__c(Name = 'TestProgram');
            insert program;
            
            Account acc = new Account( Name = 'Test',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE' );
            insert acc;
            
            Drug__c drug2 = new Drug__c(Name = 'Test2');
            drug2.Service_Lines__c = 'Literature';
            drug2.Program__c = program.Id;
            insert drug2; 
            
            Service_Line__c serviceline = new Service_Line__c(
            Name = 'Literature',
            Active__c=true,
            Service_Line_Code__c = 'LIT');
        	insert serviceline;

            pse__Proj__c parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
            Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
            parentproject.recordTypeId = parentrecTypeId;
            parentproject.pse__Project_Status__c = 'Start-up';
            parentproject.Program__c = program.id;
            insert parentproject;
            
            RecordType contactRT = [SELECT Id from RecordType where Name='IQVIA User Contact'];
            Contact testResource = UTL_PSA_TestData.createResources(1,false)[0];
            testResource.RecordTypeId = contactRT.Id;
            testResource.pse__Salesforce_User__c = UserInfo.getUserId();
            testResource.Location_Code_text__c = 'USDUR1';
            insert testResource;

            pse__Proj__c project = UTL_PSA_TestData.createProjects(1, false)[0];
            Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
            project.recordTypeId = recTypeId;
            project.pse__Project_Status__c = 'Start-up';
            project.pse__Parent_Project__c = parentproject.Id;
            project.Service_Line__c = serviceline.Id;
            project.Go_Live_Date__c = date.today();
            project.pse__Account__c = acc.Id;
            insert project;
        
        	LR_Project_Overview__c lrRec = [Select Id, Account__c, Project__c, Product__c, LR_Type__c, Program__c from LR_Project_Overview__c  limit 1];
        	lrRec.Account__c = null;
        	lrRec.Project__c = project.Id;
        	update lrRec;

        	LR_Project_Overview__c lrRec2 = UTL_PSA_TestData.createLRProjectOverview();
        	lrRec2.Program__c = lrRec.Program__c;
        	lrRec2.Account__c = lrRec.Account__c;
        	lrRec2.Project__c = lrRec.Project__c;
        	lrRec2.Product__c = lrRec.Product__c;
        	lrRec2.LR_Type__c = lrRec.LR_Type__c;
        	insert lrRec2;

        	Search_Strategy__c searchStrategy = UTL_PSA_TestData.createSeachStrategyOverview();
        	searchStrategy.Account__c = lrRec.Account__c;
        	searchStrategy.Project__c = lrRec.Project__c;
        	searchStrategy.Account__c = lrRec.Account__c;
        	searchStrategy.Product__c = lrRec.Product__c;
        	searchStrategy.LR_Type__c = lrRec.LR_Type__c;
        	searchStrategy.LR_Project_Overview__c = lrRec2.Id;
        	insert searchStrategy;
        }catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        Test.stopTest();
    }

    @isTest
    static void testSynchSearchStrageyrecord2(){
        LR_Project_Overview__c lrRec = [Select Id, Account__c, Project__c, Product__c, LR_Type__c from LR_Project_Overview__c  limit 1];
        Test.startTest();
        lrRec.Account__c = null;
        lrRec.Countries_Searched__c ='test';
        lrRec.Journals_Screened_Reviewed__c = 'test';
        update lrRec;
        Test.stopTest();
    }

    @isTest
    static void testDeleteSSRecords(){
        LR_Project_Overview__c lrRec = [Select Id from LR_Project_Overview__c  limit 1];
        Test.startTest();
        delete lrRec;
        Test.stopTest(); 
    }

    @isTest
    static void testAccountValidation(){
        LR_Project_Overview__c lrRec = [Select Id, Account__c, Project__c, Product__c, LR_Type__c from LR_Project_Overview__c  limit 1];
        Test.startTest();
        try{
            if(lrRec.Account__c == null){
                lrRec.Account__c = 'test';
            }
            update lrRec;
        }catch(Exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Script-thrown exception') ? true : false;
            System.assertEquals(expectedExceptionThrown, false);
        }
        Test.stopTest(); 
    }
    
    @isTest
    static void testpopulateAccount(){
        LR_Project_Overview__c lrRec = [Select Id, Account__c, Project__c, Product__c, LR_Type__c, Program__c from LR_Project_Overview__c  limit 1];
        Test.startTest();
        lrRec.Account__c = null;
        update lrRec;
        
        LR_Project_Overview__c lrRec2 = UTL_PSA_TestData.createLRProjectOverview();
        lrRec2.Program__c = lrRec.Program__c;
        lrRec2.Product__c = lrRec.Product__c;
        lrRec2.LR_Type__c = lrRec.LR_Type__c;
        lrRec2.Project__c = lrRec.Project__c;
        insert lrRec2;
        Test.stopTest();
    }
    
    @isTest
    static void testCloneSSWhenLRStatusComplete(){
        LR_Project_Overview__c lrRec = [Select Id, Status__c from LR_Project_Overview__c limit 1];
        Test.startTest();
        lrRec.Status__c = 'Completed';
        lrRec.Aggregate_Reports__c = 'Yes';
        lrRec.DLP_Enter_only_for_Aggregate_Reports__c = system.today();
        lrRec.Full_Text_Articles_Reviewed__c = 'test Full Text Articles Reviewed';
        lrRec.Status__c = CON_PSA.LR_PROJECT_REVIEW_STATUS_COMPLETED;
        lrRec.Date_this_LR_Project_Completed__c = system.today();
        lrRec.Countries_Searched__c ='test';
        lrRec.Journals_Screened_Reviewed__c = 'test';
        update lrRec;
        Test.stopTest();
    }
    
    @isTest
    static void testEnableChkboxForBatchProcessing(){
        LR_Project_Overview__c lrRec = [SELECT Status__c, Date_this_LR_Project_Started__c, Date_this_LR_Project_Completed__c, Full_Text_Articles_ordered__c FROM LR_Project_Overview__c LIMIT 1];
        Test.startTest();
        lrRec.Status__c = CON_PSA.LR_PROJECT_OVERVIEW_STATUS_COMPLETED;
        update lrRec;
        lrRec.Date_this_LR_Project_Started__c = Date.today().addDays(-10);
        lrRec.Date_this_LR_Project_Completed__c = Date.today().addDays(-1);
        lrRec.Full_Text_Articles_ordered__c = 'test';
        update lrRec;
        lrRec = [Select To_be_tracked_by_batch__c from LR_Project_Overview__c limit 1];
        System.assertEquals(true, lrRec.To_be_tracked_by_batch__c, 'Assert: To_be_tracked_by_batch__c');
        Test.stopTest();
    }
}
  
