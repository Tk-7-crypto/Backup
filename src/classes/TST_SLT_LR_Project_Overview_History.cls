@isTest
public class TST_SLT_LR_Project_Overview_History {
    public static LR_Project_Overview__History LRhistory;
    @testSetup 
    static void setup() {
        
        Contact contact = UTL_PSA_TestData.createResources(1,false)[0];
        insert contact;
        
        // Parent Project
        pse__Proj__c parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Project_Status__c = 'Start-up';
        parentproject.Project_Code__c ='12345';
        insert parentproject;
        
        Service_Line__c serviceline = new Service_Line__c(
            Name = 'Literature',
            Active__c=true,
            Service_Line_Code__c = 'LIT');
        insert serviceline;
        
        // project
        pse__Proj__c project = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
        project.recordTypeId = recTypeId;
        project.pse__Project_Status__c = 'Start-up';
        project.pse__Parent_Project__c = parentproject.id;
        project.pse__Project_Manager__c = contact.id;
        project.Service_Line__c = serviceline.Id;
        project.Service_Line_Lead__c = contact.id;
        insert project;
        
        Program__c program = UTL_PSA_TestData.programs[0];
        
        Account account = UTL_PSA_TestData.accounts[0]; 
        
        Drug__c prod = new Drug__c(
            Name = 'testProduct', 
            Program__c = program.id,
            Active__c = true,
            Service_Lines__c = 'Literature');
        insert prod;
        
        LR_Project_Overview__c lrRec2 = UTL_PSA_TestData.createLRProjectOverview();
        lrRec2.Program__c = program.id;
        lrRec2.Account__c = account.id;
        lrRec2.Project__c = project.id;
        lrRec2.Product__c = prod.id;
        lrRec2.LR_Type__c = CON_PSA.LR_PROJECT_OVERVIEW_LR_Type_LOCAL;
        lrRec2.Date_this_LR_Project_Completed__c = Date.today().addMonths(-1).toStartOfMonth();
        insert lrRec2;
        
        Event_Journals__c eventJournal = UTL_PSA_TestData.createEventJournal();
        eventJournal.LR_Project_Overview__c = lrRec2.Id;
        eventJournal.Active__c = 'Yes';
        eventJournal.Account__c = account.id;
        eventJournal.Project__c = project.id;
        eventJournal.Product__c = prod.id;
        eventJournal.LR_Type__c = 'Local';
        insert eventJournal;
        
        lrRec2.Status__c = CON_PSA.LR_PROJECT_OVERVIEW_STATUS_COMPLETED;
        update lrRec2;
        
        LRhistory = new LR_Project_Overview__History();
        LRhistory.ParentId = lrRec2.id;
        LRhistory.Field = 'Date_this_LR_Project_Started__c';
        insert LRhistory;
    }
    
    static testMethod void testLRHistory() 
    {
        List<Schema.SObjectField> LRHistoryList = new SLT_LR_Project_Overview_History().getSObjectFieldList();
        Schema.SObjectType LRHistory = new SLT_LR_Project_Overview_History(true).getSObjectType();
        
        Integer expected = 0;
        System.assertEquals(expected, LRHistoryList.size());
    } 
    
    @IsTest
    static void testGetSObject () 
    {
        Test.startTest();
        SLT_LR_Project_Overview_History sltLRHistory = new SLT_LR_Project_Overview_History(true,true);
        sltLRHistory.getSObjectType();
        Test.stopTest();
    }
    
    @IsTest
    static void testgetHistoryRecByParentLRId() 
    {
        Test.startTest();
        LR_Project_Overview__History lrhistory = [Select id,ParentId from LR_Project_Overview__History limit 1];
        Set<String> fieldSet = new Set<String>{'id','ParentId'};
            List<LR_Project_Overview__History> idtoLRHistory = new SLT_LR_Project_Overview_History().getHistoryRecByParentLRId(new Set<Id> {lrhistory.ParentId}, fieldSet );
        Test.stopTest();
    }
}
