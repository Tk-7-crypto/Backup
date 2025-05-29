@isTest
public class TST_CNT_PSA_JournalCalendar {
    @isTest
    public static void testJournals(){
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
        
        Account acct2 = new Account(Name = 'testSetupTestSponsorAccount1',RDCategorization__c = 'Sponsor', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert acct2;

        pse__Proj__c project = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        project.recordTypeId = recTypeId;
        project.pse__Project_Status__c = 'Start-up';
        project.pse__Parent_Project__c = parentproject.Id;
        project.Service_Line__c = serviceline.Id;
        project.Program__c = program.id;
        project.pse__Account__c = acct2.id;
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
        eventJournal.Review_Dates__c ='2022-01-01,2022-01-08,2022-01-15,2022-01-22,2022-01-29,2022-02-05,2022-02-12,2022-02-19,2022-02-26,2022-03-05,2022-03-12,2022-03-19,2022-03-26,2022-04-02,2022-04-09,2022-04-16,2022-04-23,2022-04-30,2022-05-07,2022-05-14,2022-05-21,2022-05-28,2022-06-04,2022-06-11,2022-06-18,2022-06-25,2022-07-02,2022-07-12,2022-08-06,2022-08-13,2022-08-20,2022-08-27,2022-09-03,2022-09-10,2022-09-17,2022-09-24,2022-10-01,2022-10-08,2022-10-15,2022-10-22,2022-10-29,2022-11-05,2022-11-12,2022-11-19,2022-11-26,2022-12-03,2022-12-10,2022-12-17,2022-12-24,2022-12-31,2023-01-07,2023-01-14,2023-01-21,2023-01-28,2023-02-04,2023-02-11,2023-02-18,2023-02-25,2023-03-04,2023-03-11,2023-03-18,2023-03-25,2023-04-01';
        eventJournal.Old_Frequency_of_Journal_Details__c = '2022-01-22/Weekly';
        insert eventJournal;
        Test.startTest();
        CNT_PSA_JournalCalendar.updateReviewDate(new List<Event_Journals__c>{eventJournal});
        CNT_PSA_JournalCalendar.haveEditablePermission( UserInfo.getUserId() );
        CNT_PSA_JournalCalendar.getjournals( '2021-01-01', 'PAST', new List<String>(), String.valueOf(project.id));
        CNT_PSA_JournalCalendar.getRecord(new List<String>{eventJournal.Id});
        CNT_PSA_JournalCalendar.getjournalsForExport( '2022-01-01','2023-12-12', new List<String>{'Monthly'},new List<String>(), String.valueOf(project.id));
        System.assertEquals(0, CNT_PSA_JournalCalendar.getjournalsForExport( '2022-01-01','2022-12-12', new List<String>{'Monthly'},new List<String>(), String.valueOf(project.id)).size(), 'Assert getjournalsForExport');
        Test.stopTest();
    }
}
