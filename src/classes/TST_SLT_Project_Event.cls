/**
 * This test class is used to test the Project Event selector
 */
@isTest
private class TST_SLT_Project_Event {

    @isTest
    static void testGetSObjectFieldList() {
        Test.startTest();
        List<Schema.SObjectFIeld> fields = new SLT_Project_Event(false).getSObjectFieldList();
        Test.stopTest();
        System.assertNotEquals(0,fields.size());
    }

    @isTest
    static void testGetProjectEventsByReport(){
        setupTestData();
        Test.startTest();
        Set<String> defaultFields = new SLT_Project_Event().getDefaultFields(); 
        System.debug(reportIds);
        System.debug(defaultFields);
        List<Project_Event__c> events = new SLT_Project_Event().getProjectEventsByReport(reportIds,defaultFields);
        List<Project_Event__c> events1 = new SLT_Project_Event().getProjectEventsBySS(ssIds,defaultFields);
        List<Project_Event__c> events2 = new SLT_Project_Event().getProjectEventsBySignal(signalIds,defaultFields);
        List<Project_Event__c> events3 = new SLT_Project_Event().getProjectEventsByPSSF(pssfIds,defaultFields);
        List<Project_Event__c> events4 = new SLT_Project_Event().getProjectEventsBysdRun(sdIds,defaultFields);
        List<Project_Event__c> events5 = new SLT_Project_Event().getProjectEventsByLR(lrRecIds,defaultFields);
        Test.stopTest();
        System.assertNotEquals(0,events.size());
        System.assertEquals(psaEvent.Id, events.get(0).PSA_Event__c);
    }

    static Set<Id> reportIds;
    static Set<Id> ssIds;
    static Set<Id> lrRecIds;
    static Set<Id> signalIds;
    static Set<Id> sdIds;
    static Set<Id> pssfIds;
    static Aggregate_Report__c ar; 
    static PSA_Event__c psaEvent;
    
    static void setupTestData () {
        UTL_PSA_TestData.createPermissionControls();
        Account acct2 = new Account(Name = 'testSetupTestSponsorAccount1',RDCategorization__c = 'Sponsor',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert acct2;
        
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
        insert project;
        
        psaEvent = new PSA_Event__c();
        psaEvent.RecordTypes__c = 'General_Report';
        psaEvent.Object__c = 'Aggregate_Report__c';
        psaEvent.Planned_Date_Field__c = 'Client_First_Draft_Due__c';
        psaEvent.Primary_Resource_Field__c = 'Primary_Author__c';
        psaEvent.Stakeholder_Fields__c = 'Primary_Author__c';
        psaEvent.Notification_Offset__c = -2;
        psaEvent.Event_Name__c = 'Test Event';
        insert psaEvent;

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
        ar = new Aggregate_Report__c();
        ar.Client_First_Draft_Due__c = Date.today().addDays(7);
        ar.Primary_Author__c = testResource.Id;
        ar.RecordTypeId = recordId.Id;
        ar.Project__c = project.Id;
        ar.Project_Files_SMP__c = 'http://salesforce.com';
        ar.Client_Final_Report__c = 'http://salesforce.com';
        insert ar;

        reportIds = new Set<Id>();
        reportIds.add(ar.Id);
        
        Drug__c prod = new Drug__c(Name = 'testProduct',
                                        Program__c = program.id,
                                   		Active__c = true,
                                        Service_Lines__c = 'Aggregate Reporting');
        insert prod;
        
        LR_Project_Overview__c lrRec = UTL_PSA_TestData.createLRProjectOverview();
        lrRec.Program__c = program.id;
        lrRec.Project__c = project.id;
        lrRec.Product__c = prod.id;
        lrRec.LR_Type__c = 'Local';
        //insert lrRec;
        lrRecIds = new Set<Id>();
        //lrRecIds.add( lrRec.Id );
        
        Search_Strategy__c searchStrategy = UTL_PSA_TestData.createSeachStrategyOverview();
        Account account = UTL_PSA_TestData.accounts[0];
        searchStrategy.Account__c = acct2.id;
        searchStrategy.Project__c = project.id;
        searchStrategy.Product__c = prod.id;
        searchStrategy.LR_Type__c = 'Local';
        searchStrategy.Date_Annual_Search_Strategy_Due__c = System.today();
        searchStrategy.LR_Project_Overview__c = lrRec.Id;
        insert searchStrategy;
        ssIds = new Set<Id>();
        ssIds.add( searchStrategy.Id );
        
        //Signal__c sigRec = UTL_PSA_TestData.createSignal();
        //insert sigRec;
        
        signalIds = new Set<Id>();
        //signalIds.add( sigRec.Id );
        
        PSSF__c pssf = new PSSF__c();
        pssf.In_Scope__c = 'Yes';
        pssf.Account__c = acct2.id;
        pssf.Project_Name__c = project.id;
        pssf.Name = 'Others1';
        insert pssf;
        
        pssfIds = new Set<Id>();
        pssfIds.add( pssf.Id );
        
        Target__c target =UTL_PSA_TestData.createTarget();
        target.Indication__c = 'abcd';
        target.Protocol_Number__c = '1234';
        target.Therapeutic_Area__c = 'Acute Care';
        target.Date_Activated__c = System.today();
        target.Inactivated_Date__c = System.today();
        insert target;
        
        SD_Runs__c sdrunRec1 = new SD_Runs__c();
        sdrunRec1.Frequency__c = 'Weekly';
        sdrunRec1.Project__c = project.id;
        sdrunRec1.Product__c = target.id;
        sdrunRec1.SD_Run_Date_Completed__c = Date.newInstance(2022, 3, 4);
        sdrunRec1.Date_Medical_Review_Completed__c = Date.newInstance(2022, 3, 4);
        sdrunRec1.Date_QC_Completed__c = Date.newInstance(2022, 3, 4);
        sdrunRec1.Date_BRM_Review_Completed__c = Date.newInstance(2022, 3, 4);
        sdrunRec1.SD_Run_Start_Date__c = Date.newInstance(2022, 3, 4);
        sdrunRec1.Service_Line_Lead__c = testResource.id;
        sdrunRec1.SD_Run_Outcome__c = 'No Action';
        //insert sdrunRec1;
        
        sdIds = new Set<Id>();
        //sdIds.add( sdrunRec1.Id );
        
    }
}
