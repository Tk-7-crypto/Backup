@isTest
public class TST_EXT_PSA_OpportunityProjectCreation {

    @isTest
    static void testGetProgramListing(){
        setupTestData();
        Map<String,String> options = new Map<String,String>();
        options.put('opportunityId',opp.Id); 
        Test.startTest();
        List<Program__c> programs = EXT_PSA_OpportunityProjectCreation.getAvailableProgramsForOpportunity(options);
        Test.stopTest();
        System.assertEquals(1,programs.size());
    }

    @isTest
    static void testGetProjectPreview(){
        setupTestData();
        Map<String,String> options = new Map<String,String>();
        options.put('programId', program.Id);
        options.put('opportunityId', opp.Id);
        options.put('budget type', '');
        Test.startTest();
        EXT_PSA_OpportunityProjectCreation.ProjectHierarchy hierarchy = EXT_PSA_OpportunityProjectCreation.getProjectHierarchyPreview(options, psaReport);
        Test.stopTest();
    }

    @isTest
    static void testProjectCreation(){
        setupTestData();
        Map<String,String> options = new Map<String,String>();
        options.put('programId', program.Id);
        options.put('opportunityId', opp.Id);
        options.put('createResourceRequests','true');
        Test.startTest();
        String programPath = EXT_PSA_OpportunityProjectCreation.createProjectFromReport(options, psaReport);
        Test.stopTest();
    }
    
    @isTest
    static void testProjectUpdate(){
        setupTestData();
        Map<String,String> options = new Map<String,String>();
        options.put('programId', program.Id);
        options.put('opportunityId', opp.Id);
        options.put('createResourceRequests','true');
        EXT_PSA_OpportunityProjectCreation.createProjectFromReport(options, psaReport);
        psaReport.get('services').get(0).put('Amount', '600');
        Test.startTest();
        EXT_PSA_OpportunityProjectCreation.ProjectHierarchy mergedHierarchy = EXT_PSA_OpportunityProjectCreation.getProjectHierarchyPreview(options, psaReport);
        String updatedProgramPath = EXT_PSA_OpportunityProjectCreation.createProjectFromReport(options, psaReport);
        Test.stopTest();
    }

    static Opportunity opp;
    static Account acc;
    static Program__c program;
    static pse__Proj__c parentProject;
    static pse__Proj__c servicelineproject;
    static pse__Proj__c anotherservicelineproject;
    static pse__Proj__c anotherproject;
    static Service_Line__c serviceLine;
    static Service_Line__c anotherserviceLine;
    static Contact contact;
    static Contact anothercontact;
    static pse__Milestone__c milestone;
    static pse__Milestone__c anothermilestone;
    static pse__Project_Task__c deliverable;
    static pse__Project_Task__c anotherdeliverable;
    static pse__Resource_Request__c resourcerequest;
    static pse__Schedule__c schedule;
    static Map<String,List<Map<String,String>>> psaReport;

    static void setupTestData () {

        opp = UTL_PSA_TestData.opportunities[0];
        acc = UTL_PSA_TestData.accounts[0];

        program = UTL_PSA_TestData.programs[0];
        program.Name = 'TestProgram';
        program.Account__c=acc.Id;
        update program;

        pse__Region__c region = UTL_PSA_TestData.regions[0];
        region.Name = 'APAC';
        update region; 

        //Groups
        List<pse__Grp__c> groups = new List<pse__Grp__c>();
        groups.add(new pse__Grp__c(Name='DSSR'));
        groups.add(new pse__Grp__c(Name='RADDS'));
        groups.add(new pse__Grp__c(Name='Clinical Operations'));
        groups.add(new pse__Grp__c(Name='Lifecycle Safety'));
        insert groups;

        //Service Line
        Service_Line__c serviceLine = UTL_PSA_TestData.serviceLines[0];
		serviceline.Name = 'Regulatory Reporting';
		serviceline.Service_Line_Code__c = 'RR';
        update serviceLine;

        //Service
        Service__c service = UTL_PSA_TestData.services[0];
        service.Name = 'Regulatory Reporting of Aggregate Reports and Periodic Listings';
		service.Service_Line__c = serviceline.Id;
		service.Service_Code__c = 'AGG1';
        update service;

        //contacts
        Contact contact = UTL_PSA_TestData.resources[0];

        PSA_RDS_Settings__c rdsSettings = new PSA_RDS_Settings__c();
        rdsSettings.Resource_Demand_Contact_ID__c = contact.id;
        insert rdsSettings;

        //Permission Control for resources/assignments
        pse__Permission_Control__c permissionControl = UTL_PSA_TestData.permissionControls[0];  

        String psaReportString = '{'+
            '"project":['+
                '{'+
                    '"Customer Name":"CLD Test Account",'+
                    '"Project Name":"CLD Test Account TESTPROJECT1 - Project",'+
                    '"budget type":"",'+
                    '"contract type":"",'+
                    '"contract start date":"2019-04-01",'+
                    '"contract end date":"2024-01-24",'+
                    '"go-live date":"2019-07-30",'+
                    '"close-out date":"2023-12-27",'+
                    '"project code":"TESTPROJECT1",'+
                    '"project category":"Pre-Marketing",'+
                    '"lead country":"",'+
                    '"is change order":"N",'+
                    '"change order number":"NA",'+
                    '"change order description":"",'+
                    '"currency":"USD",'+
                    '"qip template name":"LCS QIP",'+
                    '"pricing tool version":"2.03.000",'+
                    '"version date":"2019-04-18",'+
                    '"region":"APAC"}'+
            '],'+
            '"services":['+
                '{'+
                    '"service code":"AGG1",'+
                    '"business unit":"Lifecycle Safety",'+
                    '"service line":"Regulatory Reporting",'+
                    '"service":"Regulatory Reporting of Aggregate Reports and Periodic Listings",'+
                    '"country":"IE",'+
                    '"start date":"2019-07-30",'+
                    '"end date":"2023-12-25",'+
                    '"unit of measure":"Per Submission",'+
                    '"billing type":"Unit-Based",'+
                    '"quantity":"4",'+
                    '"unit price":"135.75",'+
                    '"amount":"543",'+
                    '"budgeted hours":"2.48",'+
                    '"client grid code":"CSUB1",'+
                    '"client grid name":""}'+
            '],'+
            '"tasks":['+
                '{'+
                    '"task id":"SSR30.070.111.2",'+
                    '"country":"US",'+
                    '"service name":"Regulatory Reporting of Aggregate Reports and Periodic Listings",'+
                    '"service code":"AGG1",'+
                    '"primary service code":"",'+
                    '"task name":"DSUR Regulatory Submission QC",'+
                    '"budget hours":"0.64",'+
                    '"hourly price table rate":"234.88",'+
                    '"adjusted hourly price table rate":"234.88",'+
                    '"include in tasks":""}'+
            '],'+
            '"resources":['+
                '{'+
                    '"resource request name":"Literature - Coordinator",' +
                    '"service line":"Regulatory Reporting",' +
                    '"country":"US",' +
                    '"business unit":"Lifecycle Safety",' +
                    '"role":"Coordinator",' +
                    '"job grade":"26",' +
                    '"iqvia job grade":"110",' +
                    '"start date":"2020-10-01",' +
                    '"end date":"2020-10-31",' +
                    '"hours":"264",' +
                    '"fte":"2.5",' +
                    '"bill rate":"0"}'+
            ']}';

        Map<String,Object> rehydrated = (Map<String,Object>) JSON.deserializeUntyped(psaReportString);
        psaReport = new Map<String,List<Map<String,String>>>();
        for( String key : rehydrated.keySet() ){
            List<Object> rows = (List<Object>) rehydrated.get(key);
            List<Map<String,String>> finalRows = new List<Map<String,String>>();
            for( Object row : rows ){
                Map<String,Object> mappedRow = (Map<String,Object>) row;
                Map<String,String> finalRow = new Map<String,String>();
                for(String objectKey : mappedRow.keySet()){
                    finalRow.put(objectKey, (String)mappedRow.get(objectKey));
                }
                finalRows.add(finalRow);
            }
            psaReport.put(key,finalRows);
            system.debug('');    
        }
    }
}