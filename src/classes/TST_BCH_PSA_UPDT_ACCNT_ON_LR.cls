@IsTest
public class TST_BCH_PSA_UPDT_ACCNT_ON_LR {
    
    @testSetup
    static void setupTestData(){
        
        test.startTest();
        //contact
        Contact contact = UTL_PSA_TestData.createResources(1,false)[0];
        insert contact;
        
        // Parent Project
        pse__Proj__c parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Project_Status__c = 'Start-up';
        parentproject.Project_Code__c ='12345';
        insert parentproject;
        
        //Service Line
        Service_Line__c serviceline = new Service_Line__c(
            Name = 'Literature',
            Active__c=true,
            Service_Line_Code__c = 'LIT');
        insert serviceline;
        
        Account account = UTL_PSA_TestData.accounts[0];
        Account acct1 = new Account(Name = 'testSetupTestSiteAccount2',RDCategorization__c = 'Site', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert acct1;
        
        // project
        pse__Proj__c project = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        project.recordTypeId = recTypeId;
        project.pse__Project_Status__c = 'Start-up';
        project.pse__Parent_Project__c = parentproject.id;
        project.pse__Project_Manager__c = contact.id;
        project.Service_Line__c = serviceline.Id;
        project.Service_Line_Lead__c = contact.id;
        project.Has_Account_Changed__c = true;
        insert project;
        
        Program__c program = UTL_PSA_TestData.programs[0];
        
        Drug__c prod = new Drug__c(
            Name = 'testProduct', 
            Program__c = program.id,
            Active__c = true,
            Service_Lines__c = 'Literature');
        insert prod;
        
        Event_Journals__c eventJournal = UTL_PSA_TestData.createEventJournal();
        eventJournal.Active__c = 'Yes';
        eventJournal.Inactive_since__c = Null;
        eventJournal.Account__c = account.id;
        eventJournal.Project__c = project.id;
        eventJournal.Product__c = prod.id;
        eventJournal.LR_Type__c = CON_PSA.LR_PROJECT_OVERVIEW_LR_Type_LOCAL;
        insert eventJournal;
        
        LR_Project_Overview__c lrRec2 = UTL_PSA_TestData.createLRProjectOverview();
        lrRec2.Program__c = program.id;
        lrRec2.Account__c = account.id;
        lrRec2.Project__c = project.id;
        lrRec2.Product__c = prod.id;
        lrRec2.Status__c = 'In Progress';
        lrRec2.LR_Type__c = CON_PSA.LR_PROJECT_OVERVIEW_LR_Type_LOCAL;
        insert lrRec2;
    }
    
    @isTest
    static void testExecuteBatch(){
        Account acct1 = new Account(Name = 'testSetupTestSiteAccount2',RDCategorization__c = 'Site', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert acct1;
        test.startTest();
        LR_Project_Overview__c lrRec3 = [Select id from LR_Project_Overview__c limit 1];
        lrRec3.Account__c = acct1.Id;
        update lrRec3;
        Database.executeBatch(new BCH_PSA_UPDT_ACCNT_ON_LR());
        test.stopTest();
    }
}
