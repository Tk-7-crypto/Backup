@isTest
private class TST_CNT_PSA_filteredDetailsTab {

    @isTest static void testGetFieldSet(){
        setupTestData();
        Test.startTest();
        List<String> fields = CNT_PSA_filteredDetailsTab.getFieldSet('Deliverable', 'PVA1', null, 'Service Line');
        Test.stopTest();
        System.assertNotEquals(0,fields.size());

    }

    @isTest static void testGetValidMetricsForService(){
        setupTestData();
        Test.startTest();
        List<Project_Metric__c> metrics = CNT_PSA_filteredDetailsTab.getValidMetricsForService(parentproject.Id, serviceLine.Id, service.Id);
        Test.stopTest();
    }

    @isTest static void testCreateMisses(){
        setupTestData();
        Set<String> fields = new Set<String>{'Id', 'Metric_Name__c', 'PSA_Metric__r.Validation_Target_Field__c', 'PSA_Metric__r.Validation_Actual_Field__c', 'PSA_Metric__r.Validation_Type__c'};
        Project_Metric__c[] metrics = new SLT_Project_Metric().selectByProject(new Set<Id>{parentProject.Id},fields);
        List<Project_Metric__c> toMiss = new List<Project_Metric__c>{metrics[0]};

        Test.startTest();
        List<Project_Log__c> logs = CNT_PSA_filteredDetailsTab.createMisses(toMiss, null, 'CMC', null);
        Test.stopTest();
        System.assertEquals(1,logs.size());
    }

    @isTest
    static void testSearchDrug(){
        Test.startTest();
        List<UTL_LookupSearchResult> result = CNT_PSA_filteredDetailsTab.searchDrug('Test',new List<String>());
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

    /*
    @isTest static void testGetExistingMisses(){
        setupTestData();
        Set<String> fields = new Set<String>{'Id', 'Metric_Name__c', 'PSA_Metric__r.Validation_Target_Field__c', 'PSA_Metric__r.Validation_Actual_Field__c', 'PSA_Metric__r.Validation_Type__c'};
        Project_Metric__c[] metrics = new SLT_Project_Metric().selectByProject(new Set<Id>{parentProject.Id},fields);
        List<Project_Metric__c> toMiss = new List<Project_Metric__c>{metrics[0]};
        List<Project_Log__c> logs = CNT_PSA_filteredDetailsTab.createMisses(toMiss, null, 'CMC', null);

        Test.startTest();
        List<Project_Log__c> misses = CNT_PSA_filteredDetailsTab.getExistingMisses();
        Test.stopTest();
        System.assertEquals(1,logs.size());
    }*/

    @isTest static void testGetDrugDependentOptions() {
        setupTestData();
		
        Program__c programRecord = [SELECT Id, Name from Program__c LIMIT 1];
        Drug__c newDrug = new Drug__c(Name='Test Drug');
        newDrug.Program__c = programRecord.Id;
        newDrug.Service_Lines__c = 'Aggregate Reporting';
        insert newDrug;
        insert new Trade_Name__c(Name='My Test Trade Name', Drug__c = newDrug.id);
        insert new Formulation__c(Drug__c = newDrug.id);

        test.startTest();

        Map<String, Object> response =  CNT_PSA_filteredDetailsTab.getDrugDependentOptions(newDrug.id);
        system.assertEquals(true, response.containsKey('Trade_Name__c'));
        system.assertEquals(true, response.containsKey('Formulation__c'));

        Map<String, Object> response2 =  CNT_PSA_filteredDetailsTab.getProjectDependentOptions(parentproject.id);
        system.assertEquals(true, response2.containsKey('Resource__c'));

        test.stopTest();
    }

    static Service_Line__c serviceLine;
    static Service__c service;
    static pse__Proj__c parentproject;

    static void setupTestData() {
        //Program
        Program__c program = UTL_PSA_TestData.createPrograms(1, true)[0];

        // service line
        serviceLine = new Service_Line__c (
            Active__c = true,
            Service_Line_Code__c = 'PVA',
            Name = 'PVA'
            );
        insert serviceLine;

        // service
        service = new Service__c(
            Active__c = true,
            Service_Line__c = serviceLine.id,
            Service_Code__c = 'PVA1'
            );
        insert service;

        parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Project_Status__c = 'Start-up';
        insert parentproject;

        PSA_Metric__c metric = new PSA_Metric__C(
            //PSA_Metric_Unique_ID__c='12345',
            Name='Test PSA Metric',
            Validation_Type__c='Actual date is late',
            External_ID__c='abcdefg',
            Service_Line__c = serviceLine.Id
        );
        insert metric;

        Project_Metric__c pMetric = new Project_Metric__c(
            PSA_Metric__c=metric.Id,
            Project__c=parentProject.Id
        );
        insert pMetric;
    }
}
