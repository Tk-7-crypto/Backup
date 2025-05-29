@isTest
public class TST_TGR_Event_Journals {
@testsetup
    static void dataSetup() {
        UTL_PSA_TestData.createPermissionControls();

        Program__c program = new Program__c(Name = 'TestProgram');
        insert program;
        
        Service_Line__c serviceline = new Service_Line__c(
            Name = 'Literature',
            Active__c=true,
            Service_Line_Code__c = 'LIT');
        insert serviceline;
        
        // Parent Project
        pse__Proj__c parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Project_Status__c = 'Start-up';
        parentproject.Program__c = program.id;
        insert parentproject;
        
        Account acct2 = new Account(Name = 'testSetupTestSponsorAccount1',RDCategorization__c = 'Sponsor',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert acct2;

        pse__Proj__c project = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        project.recordTypeId = recTypeId;
        project.pse__Project_Status__c = 'Start-up';
        project.pse__Parent_Project__c = parentproject.Id;
        project.Service_Line__c = serviceline.Id;
        project.Program__c = program.id;
        project.pse__Account__c = acct2.Id;
        insert project;
        
        Drug__c prod = new Drug__c(Name = 'testProduct',
                                        Program__c = program.id,
                                   		Active__c = true,
                                        Service_Lines__c = 'Literature');
        insert prod;
        
        LR_Project_Overview__c lrRec = UTL_PSA_TestData.createLRProjectOverview();
        lrRec.Program__c = program.id;
        lrRec.Project__c = project.id;
        lrRec.Product__c = prod.id;
        lrRec.LR_Type__c = 'Local';
        insert lrRec;
        
        Event_Journals__c eventJournal = UTL_PSA_TestData.createEventJournal();
        eventJournal.LR_Project_Overview__c = lrRec.Id;
        eventJournal.Active__c = 'Yes';
        eventJournal.Inactive_since__c = Null;
        eventJournal.Account__c = acct2.id;
        eventJournal.Project__c = project.id;
        eventJournal.Product__c = prod.id;
        eventJournal.LR_Type__c = 'Local';
        eventJournal.LR_Project_Overview__c = lrRec.Id;
        insert eventJournal;
    }
    
    @istest
    static void testStrategy_testUpdate(){
        
        Test.startTest();
        Event_Journals__c BiAnnualTest = [Select Name,Frequency_of_Journal__c,Date_Last_Journal_Search_was_Performed__c,Date_Next_Journal_Search_is_Due__c from Event_Journals__c WHERE Name = '123'];
        BiAnnualTest.Frequency_of_Journal__c = 'Bi-Annual (Twice a year)';
        update BiAnnualTest;
        Event_Journals__c newData1 = [Select Name,Frequency_of_Journal__c,Date_Last_Journal_Search_was_Performed__c,Date_Next_Journal_Search_is_Due__c from Event_Journals__c WHERE Name = '123'];
        System.assertEquals(Date.newInstance(2022,6,7),newData1.Date_Next_Journal_Search_is_Due__c);
        
        Event_Journals__c BiMonthlyTest = [Select Name,Frequency_of_Journal__c,Date_Last_Journal_Search_was_Performed__c,Date_Next_Journal_Search_is_Due__c from Event_Journals__c WHERE Name = '123'];
        BiMonthlyTest.Frequency_of_Journal__c = 'Bi-Monthly (Every two months)';
        update BiMonthlyTest;
        Event_Journals__c newData2 = [Select Name,LR_Type__c,Frequency_of_Journal__c,Date_Last_Journal_Search_was_Performed__c,Date_Next_Journal_Search_is_Due__c from Event_Journals__c WHERE Name = '123'];
        System.assertEquals(Date.newInstance(2022,2,7),newData2.Date_Next_Journal_Search_is_Due__c);
        
        Event_Journals__c BiWeeklyTest = [Select Name,Frequency_of_Journal__c,Date_Last_Journal_Search_was_Performed__c,Date_Next_Journal_Search_is_Due__c from Event_Journals__c WHERE Name = '123'];
        BiWeeklyTest.Frequency_of_Journal__c = 'Bi-Weekly (Every two weeks)';
        update BiWeeklyTest;
        Event_Journals__c newData3 = [Select Name,Frequency_of_Journal__c,Date_Last_Journal_Search_was_Performed__c,Date_Next_Journal_Search_is_Due__c from Event_Journals__c WHERE Name = '123'];
        System.assertEquals(Date.newInstance(2021,12,23),newData3.Date_Next_Journal_Search_is_Due__c);
        
        Event_Journals__c Every9MonthsTest = [Select Name,LR_Type__c,Frequency_of_Journal__c,Date_Last_Journal_Search_was_Performed__c,Date_Next_Journal_Search_is_Due__c from Event_Journals__c WHERE Name = '123'];
        Every9MonthsTest.Frequency_of_Journal__c = 'Every 9 Months';
        update Every9MonthsTest;
        Event_Journals__c newData4 = [Select Name,Frequency_of_Journal__c,Date_Last_Journal_Search_was_Performed__c,Date_Next_Journal_Search_is_Due__c from Event_Journals__c WHERE Name = '123'];
        System.assertEquals(Date.newInstance(2022,9,5),newData4.Date_Next_Journal_Search_is_Due__c);
        
        Event_Journals__c MonthlyTest = [Select Name,Frequency_of_Journal__c,Date_Last_Journal_Search_was_Performed__c,Date_Next_Journal_Search_is_Due__c from Event_Journals__c WHERE Name = '123'];
        MonthlyTest.Frequency_of_Journal__c = 'Monthly';
        update MonthlyTest;
        Event_Journals__c newData5 = [Select Name,Frequency_of_Journal__c,Date_Last_Journal_Search_was_Performed__c,Date_Next_Journal_Search_is_Due__c from Event_Journals__c WHERE Name = '123'];
        System.assertEquals(Date.newInstance(2022,1,8),newData5.Date_Next_Journal_Search_is_Due__c);
        
        Event_Journals__c QuarterlyTest = [Select Name,Frequency_of_Journal__c,Date_Last_Journal_Search_was_Performed__c,Date_Next_Journal_Search_is_Due__c from Event_Journals__c WHERE Name = '123'];
        QuarterlyTest.Frequency_of_Journal__c = 'Quarterly';
        update QuarterlyTest;
        Event_Journals__c newData6 = [Select Name,Frequency_of_Journal__c,Date_Last_Journal_Search_was_Performed__c,Date_Next_Journal_Search_is_Due__c from Event_Journals__c WHERE Name = '123'];
        System.assertEquals(Date.newInstance(2022,3,9),newData6.Date_Next_Journal_Search_is_Due__c);
        
        Event_Journals__c WeeklyTest = [Select Name,Frequency_of_Journal__c,Date_Last_Journal_Search_was_Performed__c,Date_Next_Journal_Search_is_Due__c from Event_Journals__c WHERE Name = '123'];
        WeeklyTest.Frequency_of_Journal__c = 'Weekly';
        update WeeklyTest;
        Event_Journals__c newData7 = [Select Name,Frequency_of_Journal__c,Date_Last_Journal_Search_was_Performed__c,Date_Next_Journal_Search_is_Due__c from Event_Journals__c WHERE Name = '123'];
        System.assertEquals(Date.newInstance(2021,12,16),newData7.Date_Next_Journal_Search_is_Due__c);
        
        Event_Journals__c YearlyTest = [Select Name,Frequency_of_Journal__c,Date_Last_Journal_Search_was_Performed__c,Date_Next_Journal_Search_is_Due__c from Event_Journals__c WHERE Name = '123'];
        YearlyTest.Frequency_of_Journal__c = 'Yearly (Annual)';
        update YearlyTest;
        Event_Journals__c newData8 = [Select Name,Frequency_of_Journal__c,Date_Last_Journal_Search_was_Performed__c,Date_Next_Journal_Search_is_Due__c from Event_Journals__c WHERE Name = '123'];
        System.assertEquals(Date.newInstance(2022,12,9),newData8.Date_Next_Journal_Search_is_Due__c);
        
        Event_Journals__c OtherTest = [Select Name,Frequency_of_Journal__c,Date_Last_Journal_Search_was_Performed__c,Date_Next_Journal_Search_is_Due__c from Event_Journals__c WHERE Name = '123'];
        OtherTest.Frequency_of_Journal__c = 'Other';
        update OtherTest;
        Event_Journals__c newData9 = [Select Name,Frequency_of_Journal__c,Date_Last_Journal_Search_was_Performed__c,Date_Next_Journal_Search_is_Due__c from Event_Journals__c WHERE Name = '123'];
        System.assertEquals(Date.newInstance(2021,12,9),newData9.Date_Next_Journal_Search_is_Due__c);
        
        Event_Journals__c NATest = [Select Name,Frequency_of_Journal__c,Date_Last_Journal_Search_was_Performed__c,Date_Next_Journal_Search_is_Due__c from Event_Journals__c WHERE Name = '123'];
        NATest.Frequency_of_Journal__c = 'N/A';
        update NATest;
        Event_Journals__c newData10 = [Select Name,Frequency_of_Journal__c,Date_Last_Journal_Search_was_Performed__c,Date_Next_Journal_Search_is_Due__c from Event_Journals__c WHERE Name = '123'];
        System.assertEquals(Date.newInstance(2021,12,9),newData10.Date_Next_Journal_Search_is_Due__c);
        
        
        try{
            Event_Journals__c TestForPast = [Select Name,Frequency_of_Journal__c,Date_Last_Journal_Search_was_Performed__c,Date_Next_Journal_Search_is_Due__c from Event_Journals__c WHERE Name = '123'];
            TestForPast.Date_Next_Journal_Search_is_Due__c = Date.newInstance(2021,12,16);
            update TestForPast;
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Date Next Journal Search is Due cannot be in the past') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
    }
}
