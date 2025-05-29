@isTest
public class TST_DAOH_PSA_Journals_Main_Catalogue {
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
        //parentproject.Go_Live_Date__c = System.today();
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
        
        Journals_Main_Catalogue__c jMCRec = new Journals_Main_Catalogue__c();        
        jMCRec.Country__c='AF';
        jMCRec.Paper_Journal__c='Yes';
        jMCRec.Name='123';
        jMCRec.Journal_Name__c='Jou1';
        jMCRec.URL__c='www.xyz.com';
        jMCRec.Periodicity__c='per';
        jMCRec.Regulatory_requirement__c='Yes';
        jMCRec.Subscription__c='Yes';        
        jMCRec.Therapeutic_Area__c='Area';        
        insert jMCRec;
        
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
    static void testSynchValueForEJ(){
        
        Journals_Main_Catalogue__c jMCRec = [Select Id, Country__c, Paper_Journal__c, Name, Journal_Name__c, URL__c, Periodicity__c, Regulatory_requirement__c, Subscription__c, Therapeutic_Area__c From Journals_Main_Catalogue__c where Name = '123' limit 1];
        Test.startTest();
            jMCRec.Subscription__c = 'No';
            update jMCRec;
        Test.stopTest();
        
        Event_Journals__c eventJournalRec = [Select Id, Country__c, Paper_Journal__c, Name, Journal_Name__c, URL__c, Periodicity__c, Regulatory_requirement__c, Subscription__c, Therapeutic_Area__c From Event_Journals__c where Name = '123' limit 1];
        System.assertEquals(eventJournalRec.Subscription__c, 'No');
    }
}