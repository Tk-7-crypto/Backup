/*
 * TST_CNT_PSA_ProjectMetric
 *
 * Providing proofs for the CNT PSA ProjectMetric page
 *
 * Revisions    2019-Apr  cld      Initial version
 */
/*
   sfdx force:apex:test:run -t TST_CNT_PSA_ProjectMetric -c -r json

   public without sharing

 */
@isTest(isParallel=false)
public class TST_CNT_PSA_ProjectMetric {
    /*
     * Common verification for listing metrics
     */
    @isTest
    public static void verifyItGetsMetrics() {
	    TST_CNT_PSA_ProjectMetric.setupTestData();
	    test.startTest();
	   
	    Boolean errorsAsExpected = false;
	    CNT_PSA_ProjectMetric.ActionResult actionResult = null;
	    try {
		    actionResult = CNT_PSA_ProjectMetric.getMetrics(null, null, null, null, null, null, null,null,null);
	    } catch (Exception e) {
		    errorsAsExpected = true;
	    }
	    system.assert (errorsAsExpected == true, 'Expected an error when getting metrics for bogus project id, but it succeeded!');

        pse__Proj__c parentproj = [Select Id, Name, RecordType.Name from pse__Proj__c where RecordType.Name=: CON_PSA.PROJ_REC_TYPE_RDS_PROJECT limit 1];
     
	    // verify it succeeds with valid data
	    actionResult = CNT_PSA_ProjectMetric.getMetrics(parentproj.id,null, null, null, null, null, null,null,null);
	    system.assertNotEquals(null, actionResult,'Tested');
	    system.assert (actionResult.records != null && actionResult.records.size() > 0, 'Missing expected project metric records');

	// verify it returned expected data
	CNT_PSA_ProjectMetric.ProjectMetricWrapper projMetricWrapper = (CNT_PSA_ProjectMetric.ProjectMetricWrapper) actionResult.records[0];
	system.assertNotEquals(null, projMetricWrapper.metricUrl,'Tested');
	system.assertNotEquals(null, projMetricWrapper.serviceLineUrl,'Tested');

	test.stopTest();
}

    /*
     * Common verification for listing active metrics
     */
    @isTest
    public static void verifyItGetsActivePsaMetrics () {
	setupTestData();
	test.startTest();

	CNT_PSA_ProjectMetric.ActionResult actionResult = CNT_PSA_ProjectMetric.getActivePsaMetrics();
	system.assertNotEquals(null, actionResult, 'Tested');
	system.assert (actionResult.records != null && actionResult.records.size() > 0, 'Missing expected active psa metric records');

	test.stopTest();
    }

    /*
     * Common verification for listing manual metrics
     */
    @isTest
    public static void verifyItGetsManualMetrics () {
	setupTestData();
	test.startTest();
	pse__Proj__c parentprojRec = [Select Id, Name, RecordType.Name from pse__Proj__c where RecordType.Name=: CON_PSA.PROJ_REC_TYPE_RDS_PROJECT limit 1];
	String projectId = parentprojRec.id;
	String frequency = CNT_PSA_ProjectMetric.MONTHLY;
	String frequencyQuarterly = CNT_PSA_ProjectMetric.QUARTERLY;
	Service_Line__c servicelineRec = [Select Id, Name FROM Service_Line__c LIMIT 1];
	String serviceLineId = serviceLineRec.id;

	// verify it errors when supplying bogus data!
	Boolean errorsAsExpected = false;
	CNT_PSA_ProjectMetric.ActionResult actionResult = null;
	try{
	    actionResult = CNT_PSA_ProjectMetric.getManualMetrics(null, null, null, null, null, null,null,'');
	} catch(Exception e) {
	    errorsAsExpected = true;
	}
	system.assert (errorsAsExpected == true, 'Expected an error when getting manual metrics with invalid data, but it succeeded!');

	// verify it succeeds with valid data
	actionResult = CNT_PSA_ProjectMetric.getManualMetrics(projectId, frequency, serviceLineId, null, Date.today(), Date.today().addMonths(5),null,'');
	system.assertNotEquals(null, actionResult,'Tested');
    
        // verify it succeeds with valid data where Frequency is quarterly
	actionResult = CNT_PSA_ProjectMetric.getManualMetrics(projectId, frequencyQuarterly, serviceLineId, null, Date.today(), Date.today().addMonths(5),null,'');
	system.assertNotEquals(null, actionResult,'Tested');

	// grab history!
	CNT_PSA_ProjectMetric.ActionResult historyResult = CNT_PSA_ProjectMetric.getManualMetricsHistory(projectId, frequency, serviceLineId, null, Date.today(), Date.today().addMonths(5));
	system.assertNotEquals(null, historyResult,'Tested');

	// !frequecy options
	// - verify it fails with bogus data
	errorsAsExpected = false;
	CNT_PSA_ProjectMetric.ActionResult freqResult = null;
	try {
	    freqResult = CNT_PSA_ProjectMetric.getProjectFrequencyOptions(null);
	} catch (Exception e) {
	    errorsAsExpected = true;
	}
	system.assert (errorsAsExpected == true, 'Expected an error when getting project frequency options for invalid project, but it succeeded!');

	// verify it succeeds with valid data
	freqResult = CNT_PSA_ProjectMetric.getProjectFrequencyOptions(projectId);
	system.assertNotEquals(null, freqResult,'Tested');

	/*
	// WARNING - Hitting CPU limits on this test. We need to circle back around and optimize it
	// handle semi-anuall frequency
	frequency = CNT_PSA_ProjectMetric.SEMI_ANNUALLY;
	psaMetric.Frequency__c = frequency;
	update psaMetric;

	CNT_PSA_ProjectMetric.ActionResult semiActionResult = CNT_PSA_ProjectMetric.getManualMetrics(projectId, frequency, serviceLineId, null, Date.today(), Date.today().addMonths(5));
	system.assertNotEquals(null, semiActionResult);

	// handle quarterly frequency
	frequency = CNT_PSA_ProjectMetric.QUARTERLY;
	psaMetric.Frequency__c = frequency;
	update psaMetric;

	CNT_PSA_ProjectMetric.ActionResult qtrlyActionResult = CNT_PSA_ProjectMetric.getManualMetrics(projectId, frequency, serviceLineId, null, Date.today(), Date.today().addMonths(5));
	system.assertNotEquals(null, qtrlyActionResult);

	Date today = Date.today();
	Date[] qDates = new Date[] {
		Date.newInstance(today.year(), 2, 1),
		Date.newInstance(today.year(), 5, 1),
		Date.newInstance(today.year(), 8, 1),
		Date.newInstance(today.year(), 11, 1)
	};
	for (Date qd : qDates) {
		Date quarterStart = CNT_PSA_ProjectMetric.toStartOfQuarter(qd);
		system.assertNotEquals(null, quarterStart);
		String rslt = CNT_PSA_ProjectMetric.buildQuarterlyLabel(qd);
		system.assertNotEquals(null, rslt);
	}
	*/

	// cover raising exceptions
	String errMsg = 'Testing Raise Exception';
	try {
	    AuraHandledException ahe = new AuraHandledException(errMsg);
	    ahe.setMessage(errMsg);
	    CNT_PSA_ProjectMetric.raise(ahe);
	} catch (Exception e) {
	    system.assertEquals(errMsg, e.getMessage(),'Tested');
	    }
	    test.stopTest();
    }

    /*
     * Common verification for history instance
     */
    @isTest
    public static void verifyHistoryInstance () {
	setupTestData();
	Project_Metric_Actual__History hist = new Project_Metric_Actual__History(
	    field = 'Comments__c',
	    parentId = projectMetricActual.id
	    );
	insert hist;

	test.startTest();
	CNT_PSA_ProjectMetric.ProjectMetricActualHistoryWrapper w = new CNT_PSA_ProjectMetric.ProjectMetricActualHistoryWrapper(hist);
	system.assertNotEquals(null, w,'Tested');
	test.stopTest();
    }

    /*
     * Common verification for saving manual metrics
     */
    @isTest
    public static void verifyItSavesManualMetrics () {
	setupTestData();
	Date recordSOM = Date.today().toStartOfMonth();
	String recordDateKey = DateTime.newInstance(recordSOM.year(),recordSOM.month(),recordSOM.day()).format('yyyy-MM-dd');

	test.startTest();

	CNT_PSA_ProjectMetric.ProjectMetricActualWrapper wrapper = new CNT_PSA_ProjectMetric.ProjectMetricActualWrapper();
	pse__Proj__c parentprojRec = [Select Id, Name, RecordType.Name from pse__Proj__c where RecordType.Name=: CON_PSA.PROJ_REC_TYPE_RDS_PROJECT limit 1];
	wrapper.projectId = parentprojRec.id;
	wrapper.projectMetricId = projectMetric.id;
	wrapper.psaMetricId = psaMetric.id;
	wrapper.quantity = 1;
	wrapper.comments = 'test';
	wrapper.recordDateKey = recordDateKey;

	// verify it errors inserting invalid data
	Boolean errorsAsExpected = false;
	CNT_PSA_ProjectMetric.ActionResult actionResult = null;
	try {
	    actionResult = CNT_PSA_ProjectMetric.saveMetricActual(new CNT_PSA_ProjectMetric.ProjectMetricActualWrapper());
	} catch (Exception e) {
	    errorsAsExpected = true;
	}
	system.assert (errorsAsExpected == true, 'Expected an error when inserting invalid data, but it succeeded!');


	// verify it inserts with valid data
	actionResult = CNT_PSA_ProjectMetric.saveMetricActual(wrapper);
	system.assertNotEquals(null, actionResult,'Tested');
	system.assertNotEquals(null, actionResult.items,'Tested');
	system.assertEquals(true, actionResult.isSuccess,'Tested');

	String recordId = String.valueOf(actionResult.items.get('recordId'));
	system.assertNotEquals(null, recordId,'Tested');

	// update
	wrapper.id = recordId;
	wrapper.comments = 'update 01';
	actionResult = CNT_PSA_ProjectMetric.saveMetricActual(wrapper);
	system.assertNotEquals(null, actionResult,'Tested');
	system.assertEquals(true, actionResult.isSuccess,'Tested');

	test.stopTest();

	    // post history ??
	    CNT_PSA_ProjectMetric.ActionResult historyResult = CNT_PSA_ProjectMetric.getManualMetricsHistory(parentprojRec.id, 'Monthly', null, null, Date.today(), Date.today().addMonths(5));
	    system.assertNotEquals(null, historyResult,'Tested');
    }
    
    @isTest
    public static void verifyItHidesSelectedMetrics () {
	setupTestData();
	test.startTest();

	CNT_PSA_ProjectMetric.ProjectMetricWrapper[] wrappers = new CNT_PSA_ProjectMetric.ProjectMetricWrapper[] {};
	CNT_PSA_ProjectMetric.ProjectMetricWrapper wrapper = new CNT_PSA_ProjectMetric.ProjectMetricWrapper();
	wrapper.id = projectMetric.id;
	wrapper.psaMetricClientFacing = true;
	wrapper.clientFacing = false;
	wrappers.add(wrapper);

	// for verifying it fails with invalid data
	CNT_PSA_ProjectMetric.ProjectMetricWrapper[] invalidWrappers = new CNT_PSA_ProjectMetric.ProjectMetricWrapper[] {};
	CNT_PSA_ProjectMetric.ProjectMetricWrapper invalidWrapper = new CNT_PSA_ProjectMetric.ProjectMetricWrapper();
	pse__Proj__c parentproj = [Select Id, Name, RecordType.Name from pse__Proj__c where RecordType.Name=: CON_PSA.PROJ_REC_TYPE_RDS_PROJECT limit 1];
	invalidWrapper.id = parentproj.id; // use project.id instead of metric id, to cause error??
	invalidWrapper.psaMetricClientFacing = true;
	invalidWrappers.add(invalidWrapper);

	// verify it errors retrieving
	Boolean errorsAsExpected = false;
	CNT_PSA_ProjectMetric.ActionResult actionResult = null;
	try {
		actionResult = CNT_PSA_ProjectMetric.hideSelectedMetrics(null);
	} catch (Exception e) {
		errorsAsExpected = true;
	}
	system.assert (errorsAsExpected == true, 'Expected an error when retrieving with null data, but it succeeded!');

	// verify it fails with invalid data
	errorsAsExpected = false;
	try {
		actionResult = CNT_PSA_ProjectMetric.hideSelectedMetrics(invalidWrappers);
	} catch (Exception e) {
		errorsAsExpected = true;
	}
	system.assert (errorsAsExpected == true, 'Expected an error when hiding with invalid data, but it succeeded!');

	// verify it succeeds
	actionResult = CNT_PSA_ProjectMetric.hideSelectedMetrics(wrappers);
	system.assertNotEquals(null, actionResult,'Tested');

	test.stopTest();
}

    @isTest
    public static void verifyItAddsSelectedMetrics () {
	setupTestData();
	test.startTest();
        
	CNT_PSA_ProjectMetric.ProjectMetricWrapper[] wrappers = new CNT_PSA_ProjectMetric.ProjectMetricWrapper[] {};
	CNT_PSA_ProjectMetric.ProjectMetricWrapper pmWrapper = new CNT_PSA_ProjectMetric.ProjectMetricWrapper();
	pmWrapper.id = projectMetric.id;
	wrappers.add(pmWrapper);

	CNT_PSA_ProjectMetric.PsaMetricWrapper[] selectedPSAMetrics = new CNT_PSA_ProjectMetric.PsaMetricWrapper[] {};
	CNT_PSA_ProjectMetric.PsaMetricWrapper psaMetricWrapper = new CNT_PSA_ProjectMetric.PsaMetricWrapper(psaMetric);
	system.assert (true, psaMetricWrapper.serviceLineUrl != null);
	selectedPSAMetrics.add(psaMetricWrapper);
    
        // Parent project id
        pse__Proj__c parentprojRec = [Select Id, Name, RecordType.Name from pse__Proj__c where RecordType.Name=: CON_PSA.PROJ_REC_TYPE_RDS_PROJECT limit 1];
    
    //RDS Project
    pse__Proj__c parentprojectWithoutSLProjects = UTL_PSA_TestData.createProjects(1, false)[0];
    Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
    parentprojectWithoutSLProjects.recordTypeId = parentrecTypeId;
    parentprojectWithoutSLProjects.pse__Project_Status__c = CON_PSA.PROJ_STAGE_STARTUP;
    insert parentprojectWithoutSLProjects;
    
    //service line
    List<Service_Line__c> serviceLineList = [Select Id, Name FROM Service_Line__c LIMIT 50];

    // service
    List<Service__c> serviceList = [Select Id, Name FROM Service__c LIMIT 50];

    // psa metric
    PSA_Metric__c psaMetric2 = UTL_PSA_TestData.createPSAmetric(serviceList[0].Id, serviceLineList[0].id);
    psaMetric2.Service_Line__r = serviceLineList[0];
    insert psaMetric2;
    CNT_PSA_ProjectMetric.PsaMetricWrapper psaMetricWrapper2 = new CNT_PSA_ProjectMetric.PsaMetricWrapper(psaMetric2);
    CNT_PSA_ProjectMetric.PsaMetricWrapper[] selectedPSAMetrics2 = new CNT_PSA_ProjectMetric.PsaMetricWrapper[] {};
    selectedPSAMetrics2.add(psaMetricWrapper2);

	// verify it errors with null data
	Boolean errorsAsExpected = false;
	CNT_PSA_ProjectMetric.ActionResult actionResult = null;
	try {
		actionResult = CNT_PSA_ProjectMetric.addSelectedMetrics(null, selectedPSAMetrics);
	} catch (Exception e) {
		errorsAsExpected = true;
	}
	system.assert (errorsAsExpected == true, 'Expected an error when adding with null data, but it succeeded!');

	// verify it succeeds
	actionResult = CNT_PSA_ProjectMetric.addSelectedMetrics(parentprojRec.id, selectedPSAMetrics);
	system.assertNotEquals(null, actionResult,'Tested');
        errorsAsExpected = false;
        //  verify it errors
	try {
	    actionResult = CNT_PSA_ProjectMetric.addSelectedMetrics(parentprojectWithoutSLProjects.Id, selectedPSAMetrics2);
	} catch (Exception e) {
	    errorsAsExpected = true;
	}
        system.assert (errorsAsExpected == true, 'Expected an error when service line project does not exist on the project, but it succeeded!');
	test.stopTest();
    }

    @isTest
    public static void verifyItGetsCurrentAssignedResources () {
	setupTestData();

	// stub up assignment
	UTL_PSA_TestData.createPermissionControls();

	test.startTest();
	// verify it errors retrieving
	Boolean errorsAsExpected = false;
	CNT_PSA_ProjectMetric.ActionResult actionResult = null;
	try {
	    // use projectMetric.id...instead of project.id
	    actionResult = CNT_PSA_ProjectMetric.getCurrentAssignedResources('000000000000');
	} catch (Exception e) {
	    errorsAsExpected = true;
	}
	system.assert (errorsAsExpected == true, 'Expected an error when retrieving with invalid data, but it succeeded!');

	// verify it succeeds
	actionResult = CNT_PSA_ProjectMetric.getCurrentAssignedResources(UTL_PSA_TestData.projects[0].id);
	system.assertNotEquals(null, actionResult,'Tested');

	test.stopTest();
}

    @isTest
    public static void verifyItClonesProjectMetrics () {
	setupTestData();

	// build field values to update on cloned items
	String metricNameTestVal = 'FLD Value Test!';
	List<Map<String, Object> > fieldValues = new List<Map<String, Object> >();
	fieldValues.add(new Map<String, Object> {'fieldName' => 'Metric_Name__c', 'fieldValue' => metricNameTestVal});
	fieldValues.add(new Map<String, Object> {'fieldName' => 'Red_Threshold__c', 'fieldValue' => 'RED FLD Value'});
	fieldValues.add(new Map<String, Object> {'fieldName' => 'Hidden__c', 'fieldValue' => true});
	fieldValues.add(new Map<String, Object> {'fieldName' => 'Effective_Date__c', 'fieldValue' =>  (DateTime.now()).format('YYYY-MM-dd') });

	test.startTest();

	// verify it errors with null data
	Boolean errorsAsExpected = false;
	CNT_PSA_ProjectMetric.ActionResult actionResult = null;
	try {
		actionResult = CNT_PSA_ProjectMetric.cloneProjectMetric('000000000000', fieldValues);
	} catch (Exception e) {
		errorsAsExpected = true;
	}
	system.assert (errorsAsExpected == true, 'Expected an error when cloning with invalid data, but it succeeded!');


	// success! clone record applying field values
	actionResult = CNT_PSA_ProjectMetric.cloneProjectMetric(projectMetric.Id, fieldValues);
	system.assertNotEquals(null, actionResult,'Tested');
	system.assertNotEquals(null, actionResult.items,'Tested');
	system.assertEquals(true, actionResult.isSuccess,'Tested');
	system.assertNotEquals(null, actionResult.items.get('recordId'),'Tested');

	// verify cloned metric name is updated and project and psa metric are set (from clone)
	String clonedRecId = String.valueOf(actionResult.items.get('recordId'));
	Project_Metric__c[] clonedMetrics = [SELECT Id, Metric_Name__c, PSA_Metric__c, Project__c FROM Project_Metric__c WHERE Id =:clonedRecId];
	system.assert (clonedMetrics != null && clonedMetrics.size() > 0, 'Expected clone metrics');
	system.assertEquals(clonedMetrics[0].Metric_Name__c, metricNameTestVal,'Tested');
	system.assertNotEquals(null, clonedMetrics[0].PSA_Metric__c,'Tested');
	system.assertNotEquals(null, clonedMetrics[0].Project__c,'Tested');

	// cover sobjContainsFields..
	system.assertEquals(true, CNT_PSA_ProjectMetric.sobjContainsField(projectMetric, 'Metric_Name__c'),'Tested');
	system.assertEquals(false, CNT_PSA_ProjectMetric.sobjContainsField(projectMetric, 'Bogus__c'),'Tested');

	test.stopTest();
    }
    @isTest static void testgetPSA_MetricsFromIds () {
        setupTestData();
        Test.startTest();
        PSA_Metric__c psaMetricRec = [SELECT Id, Name from PSA_Metric__c LIMIT 1];
        Set<Id> psaMetricIds = new Set<Id>();
        psaMetricIds.add(psaMetricRec.Id);
        List<PSA_Metric__c> psaMetricsList = new SLT_PSA_Metric().getPSA_MetricsFromIds( psaMetricIds, new Set<String>{'Id','Frequency__c','Service_Line__c','Service_Line__r.Name'} );
        System.assertEquals(1, psaMetricsList.size(),'Tested');
        Test.stopTest();
    }
    
    @isTest static void testHasRDSAdminPermission() {
        Boolean result;
        Test.startTest();
        System.runAs(new User (Id = UserInfo.getUserId())) {
            List<PermissionSet> rdsPermissionSet = [SELECT Id FROM PermissionSet WHERE Name = 'RDS_Admin'];
            List<PermissionSetAssignment>  permissionSetAssigmentList = [SELECT Id 
                                                                         FROM PermissionSetAssignment 
                                                                         WHERE AssigneeId =: UserInfo.getUserId() 
                                                                         AND PermissionSetId =: rdsPermissionSet[0].Id ];
            result = CNT_PSA_ProjectMetric.hasRDSPermission();
            if(permissionSetAssigmentList.size() > 0){
                System.assertEquals(true, result,'Tested'); 
            }else{
                System.assertEquals(false, result,'Tested'); 
            }
        }
        Test.stopTest();
    }

public static PSA_Metric__c psaMetric;
public static pse__Proj__c parentproject;
public static Project_Metric__c projectMetric;
public static Service_Line__c serviceLine;
public static Project_Metric_Actual__c projectMetricActual;

public static void setupTestData () {
    //Program
    Program__c program = UTL_PSA_TestData.createPrograms(1, true)[0];
    
    //Contact
    RecordType contactRT = [SELECT Id from RecordType where Name='IQVIA User Contact'];
    Contact testResource = UTL_PSA_TestData.createResources(1, false)[0];
    testResource.RecordTypeId = contactRT.Id;
    testResource.pse__Salesforce_User__c = UserInfo.getUserId();
    insert testResource;
        
    //RDS Project
    parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
    Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);
    parentproject.recordTypeId = parentrecTypeId;
    parentproject.pse__Project_Status__c = CON_PSA.PROJ_STAGE_STARTUP;
    parentproject.Program__c = program.id;
    insert parentproject;
    
    //Service Line
    Service_Line__c serviceline = UTL_PSA_TestData.createServiceLine(1, true)[0];
    
    //Service
    Service__c service = UTL_PSA_TestData.createService(1, serviceline, true)[0];
        
    //Service Line Project
    pse__Proj__c project = UTL_PSA_TestData.createProjects(1, false)[0];
    Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);
    project.recordTypeId = recTypeId;
    project.pse__Project_Status__c = 'Start-up';
    project.pse__Parent_Project__c = parentproject.Id;
    project.Service_Line__c = serviceline.Id;
    project.pse__Start_Date__c = Date.newInstance(2020, 07, 25);
    project.pse__End_Date__c = Date.newInstance(System.Today().year(), 12, 31);
    insert project;
    
    // psa metric
    psaMetric = new PSA_Metric__c(
        Active__c = true,
        Non_Standard__c = true,
        External_Id__c = 'psa metric external id for this test from TST_CNT_PSA_ProjectMetric',
        Frequency__c = 'Monthly',
        Service__c = service.Id,
        Service_Line__c = serviceLine.id
        //PSA_Metric_Unique_ID__c='TestId1'
        );
    insert psaMetric;

    // project metric
    projectMetric = new Project_Metric__c(
        PSA_Metric__c = psaMetric.id,
        Project__c = parentproject.id
        //Service__c = UTL_PSA_TestData.milestones[0].id
        //Service__c = service.id
    );
    insert projectMetric;

    // metric actual
    projectMetricActual = new Project_Metric_Actual__c(
        Project__c = parentproject.id,
        Project_Metric__c = projectMetric.id,
        PSA_Metric__c = psaMetric.id,
        Quantity__c = 1,
        Date__c = Date.newInstance(2022, 01, 01),
        Comments__c = 'test'
    );
    insert projectMetricActual;
    
    //Psa Metric Quarterly
    PSA_Metric__c psaMetricQuarterly = UTL_PSA_TestData.createPSAmetric(service.Id, serviceline.Id);
    psaMetricQuarterly.Frequency__c = CON_PSA.PSA_METRIC_Frequency_Quarterly;
    insert psaMetricQuarterly;
        
    //Project Metric linked to Quarterly
    Project_Metric__c projectMetricForQuarterly = UTL_PSA_TestData.createProjectMetric(psaMetricQuarterly.id, parentproject.id);
    insert projectMetricForQuarterly;
    
    //Project Metric Actual for Quarterly
    Project_Metric_Actual__c projectMetricActualQuarterly = UTL_PSA_TestData.createProjectMetricActual(parentproject.id, projectMetricForQuarterly.id, psaMetricQuarterly.id);
    projectMetricActualQuarterly.Date__c = Date.newInstance(2022, 01, 01);
    insert projectMetricActualQuarterly;
}
}
