/**
 * This test class is used to test all methods in Assignment service class
 * version : 1.0
 */
@isTest
private class TST_SLT_Assignment {

    /**
     * This method is used to setup data for all methods.
     */
    @testSetup
    static void dataSetup() 
	{
        Test.startTest();
        Account acc = UTL_OWF_TestData.createAccount();
        insert acc;
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        Contact cont = UTL_OWF_TestData.createContact(acc.Id);
        cont.FirstName = UserInfo.getFirstName();
        cont.LastName = UserInfo.getLastName();
        cont.pse__Is_Resource__c = true;
        cont.pse__Is_Resource_Active__c = true;
        cont.pse__Group__c = grp.Id;
        cont.Sub_Group__c = CON_CPQ.MEDICAL_MSL;
        cont.available_for_triage_flag__c = true;
        cont.pse__Salesforce_User__c = UserInfo.getUserId();
        insert cont;
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
        insert opp;
		Bid_History__c agreement =  UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        agreement.Bid_Number__c = 0;
        agreement.Opportunity_Type__c = CON_OWF.OPPORTUNITY_TYPE;
        agreement.RFP_Ranking__c = '2';
        agreement.Budget_Deliverable__c= CON_OWF.BUDGET_DELIVERABLE;
		insert agreement;
        pse__proj__c bidProject = [SELECT Id FROM pse__Proj__c WHERE Bid_History__c =: agreement.Id];
        pse__Schedule__c schedule = UTL_OWF_TestData.createSchedule();
        insert schedule;
        pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, opp.Id, bidProject.Id);
        resourceRequest.SubGroup__c = CON_CPQ.MEDICAL_MSL;
        resourceRequest.pse__Group__c = grp.Id;
        resourceRequest.Is_Created_Automatically__c = true;                                                   
        insert resourceRequest;
        pse__Assignment__c assignement =  UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id, bidProject.Id, schedule.Id, cont.Id, resourceRequest.Id);
        assignement.Pse__resource__c = cont.Id;
        insert assignement;       
        Agreement__c testAgreement = new Agreement__c(Name ='testAgree2',Account__c = acc.id,Active__c = false,Contract_Type__c = 'CES Memorandum',Agreement_Term__c = 'Ad-Hoc'); 
        insert testAgreement;
        Test.stopTest();
    }
    
	
    /**
     * This test method used to cover basic methods
     */ 
    static testMethod void testAssignment() 
	{
        List<Schema.SObjectField> assignmenetList = new SLT_Assignment().getSObjectFieldList();
        Schema.SObjectType assignment = new SLT_Assignment(true).getSObjectType();
		
		Integer expected = 0;
        System.assertEquals(expected, assignmenetList.size());
    } 
	
	
	/**
    * This test method used to get assignment by Agreement Id

    static testMethod void testSelectAssignmentByAgreementId() 
	{
        Bid_History__c agreement = [SELECT Id FROM Bid_History__c  LIMIT 1];
        pse__Resource_Request__c resourceRequest = [SELECT Id FROM pse__Resource_Request__c LIMIT 1];    
        Test.startTest();
            List<pse__Assignment__c> assignmentList = new SLT_Assignment(true).selectAssignmentByAgreementId(agreement.Id ,CON_CPQ.MEDICAL_MSL);
        Test.stopTest();
        
        Integer expected = 1;
        //System.assertEquals(expected, assignmentList.size());
    }
    */ 
    
    static testMethod void testSelectAssignmentByClinicalBidId() 
	{
        Bid_History__c clinicalBid = [SELECT Id FROM Bid_History__c  LIMIT 1];
        pse__Resource_Request__c resourceRequest = [SELECT Id FROM pse__Resource_Request__c LIMIT 1];    
        Test.startTest();
            List<pse__Assignment__c> assignmentList = new SLT_Assignment(true).selectAssignmentByClinicalBidId(clinicalBid.Id ,CON_CPQ.MEDICAL_MSL);
        Test.stopTest();
        
        Integer expected = 1;
        //System.assertEquals(expected, assignmentList.size());
    }
	
	
	static testMethod void testgetAssignmentByResourceAndCondition()
	{
        Contact cont = [Select Id From Contact Limit 1];
        Set<ID> sObjectIdset = new Set<ID>{cont.Id};
        Set<String> assignmentFieldSet = new Set<String>{'Id','pse__Resource__c'};
        String assignmentCondition1 = 'pse__resource__c in: sObjectIdset';   
        Test.startTest();
            List<pse__Assignment__c> assignmentList = new SLT_Assignment(true).getAssignmentByResourceAndCondition(sObjectIdset, System.today(), assignmentCondition1, assignmentFieldSet);
        Test.stopTest();
		
		String expected = cont.Id;
        String actual = assignmentList[0].pse__Resource__c;
        system.assertEquals(expected, actual);
    }
	
	
	/**
    * This test method used to get Assignment by resource id or any sobject id
    */ 
    static testMethod void testGetAssignmentWithCondition() 
	{   
        Contact cont = [Select Id From Contact Limit 1];
        Bid_History__c agr = [Select Id from Bid_History__c  limit 1];
        Set<ID> sObjectIdset = new Set<ID>{cont.Id};
        Set<ID> agrIdset = new Set<ID>{agr.Id};
        Set<String> assignmentFieldSet = new Set<String>{'Id'};
        String assignmentCondition1 = 'pse__resource__c in: sObjectIdset';
        String assignmentCondition2 = '';    
        Test.startTest();
            List<pse__Assignment__c> assignmentList = new SLT_Assignment(true).getAssignmentByResource(sObjectIdset,assignmentCondition1, assignmentFieldSet);
            assignmentList = new SLT_Assignment(true).getAssignmentByBhrAndCondition(agrIdset,assignmentCondition2 , assignmentFieldSet);
        Test.stopTest();
        
        Integer expected = 1;
        System.assertEquals(expected, assignmentList.size());
    }
	/*
    static testMethod void testgetAssignmentByAgrAndConditionOrderByAgreementOwner() 
    {   
        Contact cont = [Select Id From Contact Limit 1];
        Bid_History__c agr = [Select Id from Bid_History__c  limit 1];
        Set<ID> sObjectIdset = new Set<ID>{cont.Id};
        Set<ID> agrIdset = new Set<ID>{agr.Id};
        Set<String> assignmentFieldSet = new Set<String>{'Id'};
        String assignmentCondition1 = 'pse__resource__c in: sObjectIdset';
        String assignmentCondition2 = '';    
        Test.startTest();
            List<pse__Assignment__c> assignmentList = new SLT_Assignment(true).getAssignmentByResource(sObjectIdset,assignmentCondition1, assignmentFieldSet);
            assignmentList = new SLT_Assignment(true).getAssignmentByAgrAndConditionOrderByAgreementOwner(agrIdset,assignmentCondition2 , assignmentFieldSet);
        Test.stopTest();
        
        Integer expected = 1;
        //System.assertEquals(expected, assignmentList.size());
    }
    */
	
//These Methods are for testing PSA	
    static pse__Proj__c parentproject;
    static pse__Proj__c project;
    static pse__Milestone__c milestones;
    static Contact contact;
    static pse__Resource_Request__c resourcerequest;
    static pse__Assignment__c assignment;
    static void setupTestData(){
		List<sObject> toSave = new List<sObject>();

		// Parent Project
		parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
		parentproject.pse__Stage__c = 'Start-up';
		insert parentproject;

		// project
		project = UTL_PSA_TestData.createServiceLineProject(parentProject, 'Test Project 1 FF', true);
      
        
        UTL_PSA_TestData.createPermissionControls(); 
      
         //contacts
		contact = UTL_PSA_TestData.createResources(1,false)[0];
		contact.pse__Salesforce_User__c = UserInfo.getUserId();
		//toSave.add(contact);
        //insert toSave;

        //assignment
        assignment = UTL_PSA_TestData.createAssignments(false)[0];
        assignment.pse__Project__c = project.Id;
        insert assignment;
    }
    
    @IsTest
    static void testGetSObject () 
	{
        //setupTestData();
        Test.startTest();
        SLT_Assignment sltassignment = new SLT_Assignment(true,true);
        sltassignment.getSObjectType();
        Test.stopTest();
    }
    
	
    /**
    * This method used to get Resource requests with Assigments
    */    
    @IsTest
    static void testSelectAssignmentsByIdSet() 
	{
        Test.startTest();
        setupTestData();
        //system.debug('After startTest');
        Set<String> fieldSet = new Set<String>{'Name', 'pse__project__c'};
        String condition = 'pse__Project__c = \'' +assignment.pse__Project__c+'\'';
        system.debug('Before SLT_Assignment');
        Map<Id, pse__Assignment__c> idWithAssignments = new SLT_Assignment().selectAssignmentsByIdSet(new Set<Id> {assignment.id}, condition, fieldSet );
        Map<Id, pse__Assignment__c> idWithAssignments1 = new SLT_Assignment().selectAssignmentsByFilter(new Set<Id> {assignment.id}, condition, new Set<String>(), new Set<String>(),fieldSet );
        system.debug('After SLT_Assignment');
        Test.stopTest();
        
        String expected = 'Test Project 1 FF - Test Resource 1 FF';
        String actual = idWithAssignments.get(assignment.id).Name;
        System.assertEquals(expected, actual);
    }
	
     
    /**
    * This method used to get Assignemnt of Resource Request
    */    
    @IsTest
    static void testGetAssignmentResourceRequest(){
        Test.startTest();
        setupTestData();
        Set<String> fieldSet = new Set<String>{'Name', 'pse__project__c'};
        Map<Id, pse__Assignment__c> idtoAssignment = new SLT_Assignment().getAssignmentResourceRequest(new Set<Id> {assignment.pse__Resource_Request__c}, fieldSet );
        Test.stopTest();
        
		String expected = 'Test Project 1 FF - Test Resource 1 FF';
        String actual = idtoAssignment.get(assignment.id).Name;
        System.assertEquals(expected, actual);
    }


    /**
     * This method used to get Assignemnt of Resource
     */    
    @IsTest
    static void testGetAssignmentByResource(){
        Test.startTest();
        setupTestData();
        Set<String> fieldSet = new Set<String>{'Name', 'pse__project__c'};
        String assignmentCondition = 'pse__Resource__c = \'' +assignment.pse__Resource__c+'\'';
        List<pse__Assignment__c> idByResource = new SLT_Assignment().getAssignmentByResource(new Set<Id> {assignment.id}, assignmentCondition, fieldSet );
        Test.stopTest();
		
        /*String expected = assignmentCondition;
        String actual = idByResource[0].Id;
        System.assertEquals(expected, actual);*/
    }

    
    /**
     * This method used to get assignments associated with a program
     */    
    @IsTest
    static void testGetAssignmentsByProgram(){
        Test.startTest();
        setupTestData();
        Set<String> fieldSet = new Set<String>{'Name', 'pse__project__c'};
        List<pse__Assignment__c> idWithProgram = new SLT_Assignment().getAssignmentsByProgram(new Set<Id> {assignment.pse__Project__r.Program__c}, fieldSet );
        Test.stopTest();
		
        String expected = 'Test OWF Assignment';
        String actual = idWithProgram[0].Name;
        System.assertEquals(expected, actual);
    }

    /**
     * This method used to get assignments associated with a projects or it's child project
     */    
    @IsTest
    static void testGetAssignmentsByProjectChild(){
        Test.startTest();
        setupTestData();
        Set<String> fieldSet = new Set<String>{'Name', 'pse__project__c'};
        List<pse__Assignment__c> idWithChild = new SLT_Assignment().getAssignmentsByProject(new Set<Id> {assignment.pse__Project__r.pse__Parent_Project__c}, fieldSet );
        Test.stopTest();
		
        /*String expected = assignment.id;
        String actual = idWithChild[0].Name;
        System.assertEquals(expected, actual);*/
    }


    @IsTest
    static void testGetAssignmentByResourceAndProject(){
        Test.startTest();
        setupTestData();
        Set<String> fieldSet = new Set<String>{'Name', 'pse__project__c','pse__Resource_Request__c'};
        List<pse__Assignment__c> idWithProgram = new SLT_Assignment().getAssignmentByResourceAndProject(new Set<Id> {assignment.pse__Resource_Request__r.Id}, new Set<Id> {assignment.pse__Project__r.Id}, fieldSet );
        Test.stopTest();
    }
    
    /**
    * This test method used to get assignment by Agreement Id, Record Type Name and Status
    */ 
    @IsTest
    static void testGetAssignmentByAgreementRecordTypeAndStatus() {
        Bid_History__c agreement = [SELECT Id FROM Bid_History__c  LIMIT 1];
        pse__Resource_Request__c resourceRequest = [SELECT Id FROM pse__Resource_Request__c LIMIT 1];
        Set<String> rrRoles = new Set<String>{CON_CPQ.TSL_JAPAN};
        Test.startTest();
            List<pse__Assignment__c> assignmentList = new SLT_Assignment(true).getAssignmentByAgreementRecordTypeAndStatus(new Set<Id> {agreement.Id} ,CON_CPQ.PENDING, CON_CPQ.OWF_ASSIGNMENT, rrRoles);
        Test.stopTest();
        
        Integer expected = 1;
        //System.assertEquals(expected, assignmentList.size());
    }
    
    /**
    * This test method used to get assignment by Agreement Id and SubGroup

    @IsTest
    static void testGetAssignmentByDSBSubgroupAndAgreementId() {
        Bid_History__c agreement = [SELECT Id FROM Bid_History__c  LIMIT 1];
        pse__Resource_Request__c resourceRequest = [SELECT Id FROM pse__Resource_Request__c LIMIT 1];
        Test.startTest();
            List<pse__Assignment__c> assignmentList = new SLT_Assignment(true).getAssignmentByDSBSubgroupAndAgreementId(new Set<Id>{agreement.Id},
                CON_CPQ.MEDICAL_MSL, new Set<String>{CON_CPQ.ID, CON_CPQ.NAME});
        Test.stopTest();
        
        Integer expected = 1;
        //System.assertEquals(expected, assignmentList.size());
    }
    */ 
    /**
    * This test method used to get assignment by Agreement Id and SubGroup
    */ 
    @isTest
    static void testGetAssignmentByClinicalBidAndUser() {
        Bid_History__c agreement = [SELECT Id FROM Bid_History__c  LIMIT 1];
        pse__Resource_Request__c resourceRequest = [SELECT Id FROM pse__Resource_Request__c LIMIT 1];
        Test.startTest();
            List<pse__Assignment__c> assignmentList = new SLT_Assignment(true).getAssignmentClinicalBidAndUser(new List<Id>{agreement.Id}, new List<Id>{UserInfo.getUserId()});
        Test.stopTest();
        
        //System.assertEquals(1, assignmentList.size());
    }
    
    /**
    * This test method used to get Automatic assignment by Agreement Id and Status

    
    @IsTest
    static void testGetAssignmentByAgreementRecordTypeAndStatusAndAutomatic() {
        Bid_History__c agreement = [SELECT Id FROM Bid_History__c  LIMIT 1];
        pse__Resource_Request__c resourceRequest = [SELECT Id FROM pse__Resource_Request__c LIMIT 1];
        Test.startTest();
            List<pse__Assignment__c> assignmentList = new SLT_Assignment(true).getAssignmentByAgreementRecordTypeAndStatusAndAutomatic(new Set<Id> {agreement.Id} ,CON_CPQ.PENDING, CON_CPQ.OWF_ASSIGNMENT);
        Test.stopTest();
        
        Integer expected = 1;
        //System.assertEquals(expected, assignmentList.size());
    }
    */
    /**
    * This test method used to get assignment List by Agreement Id 
   
    @IsTest
    static void testGetAssignmentListFromAgreement() {
        Bid_History__c agreement = [SELECT Id FROM Bid_History__c  LIMIT 1];
        
        Test.startTest();
            List<pse__Assignment__c> assignmentList = new SLT_Assignment(true).getAssignmentListFromAgreement(new Set<Id> {agreement.Id} ,new Set<String>{CON_CPQ.ID});
        Test.stopTest();
        
        Integer expected = 1;
        //System.assertEquals(expected, assignmentList.size());
    }
    */ 
    /**
    * This test method used to get Automatic assignment by Agreement Id, Status and SubGroup

    @IsTest
    static void testGetAssignmentByAgreementRecordTypeAndStatusAndAutomaticBySubGroup() {
        Bid_History__c agreement = [SELECT Id FROM Bid_History__c  LIMIT 1];
        
        Test.startTest();
            List<pse__Assignment__c> assignmentList = new SLT_Assignment(true).getAssignmentByAgreementRecordTypeAndStatusAndAutomaticBySubGroup(new Set<Id> {agreement.Id} ,
                CON_CPQ.PENDING, CON_CPQ.OWF_ASSIGNMENT, new List<String>{CON_CPQ.MEDICAL_MSL});
        Test.stopTest();
        
        Integer expected = 1;
        //System.assertEquals(expected, assignmentList.size());
    }
    */
    /**
    * This test method used to get Manual assignment by Agreement Id, Status and SubGroup

    @IsTest
    static void testGetAssignmentByAgreementRecordTypeAndStatusAndManualBySubGroup() {
        Test.startTest();
            Bid_History__c agreement = [SELECT Id FROM Bid_History__c  LIMIT 1];
            Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
            pse__proj__c bidProject = [SELECT Id FROM pse__Proj__c WHERE Bid_History__c =: agreement.Id];
            Contact cont = [SELECT Id FROM Contact LIMIT 1];
            pse__Grp__c grp = [SELECT Id FROM pse__Grp__c LIMIT 1];
            pse__Schedule__c schedule1 = UTL_OWF_TestData.createSchedule();
            insert schedule1;
            pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, opp.Id, bidProject.Id);
            resourceRequest.SubGroup__c = CON_CPQ.MEDICAL_MSL;
            resourceRequest.pse__Group__c = grp.Id;
            resourceRequest.Is_Created_Automatically__c = false;
            insert resourceRequest;
            pse__Assignment__c assignement =  UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id, bidProject.Id, schedule1.Id, cont.Id, resourceRequest.Id);
            assignement.Pse__resource__c = cont.Id;
            insert assignement;
            
            List<pse__Assignment__c> assignmentList = new SLT_Assignment(true).getAssignmentByAgreementRecordTypeAndStatusAndManualBySubGroup(new Set<Id> {agreement.Id} ,
                CON_CPQ.PENDING, CON_CPQ.OWF_ASSIGNMENT, new List<String>{CON_CPQ.MEDICAL_MSL});
        Test.stopTest();
        
        Integer expected = 1;
        //System.assertEquals(expected, assignmentList.size());
    }
    */
    /**
    * This test method used to get Automatic assignment by Agreement Id, Status and SubGroup

    @IsTest
    static void testGetAssignmentByAgreementRecordTypeStatusAndSubGroup() 
	{
        Test.startTest();
            Bid_History__c agreement = [SELECT Id FROM Bid_History__c  LIMIT 1];
            Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
            pse__proj__c bidProject = [SELECT Id FROM pse__Proj__c WHERE Bid_History__c =: agreement.Id];
            Contact cont = [SELECT Id FROM Contact LIMIT 1];
            pse__Grp__c grp = [SELECT Id FROM pse__Grp__c LIMIT 1];
            pse__Schedule__c schedule1 = UTL_OWF_TestData.createSchedule();
            insert schedule1;
            pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, opp.Id, bidProject.Id);
            resourceRequest.SubGroup__c = CON_CPQ.MEDICAL_MSL;
            resourceRequest.pse__Group__c = grp.Id;
            resourceRequest.Is_Created_Automatically__c = true;
            insert resourceRequest;
            pse__Assignment__c assignement =  UTL_OWF_TestData.createAssignmentForBidHistory(agreement.Id, bidProject.Id, schedule1.Id, cont.Id, resourceRequest.Id);
            assignement.Pse__resource__c = cont.Id;
            insert assignement;
        
            List<pse__Assignment__c> assignmentList = new SLT_Assignment(true).getAssignmentByAgreementRecordTypeStatusAndSubGroup(new Set<Id> {agreement.Id} ,
                CON_CPQ.PENDING, CON_CPQ.OWF_ASSIGNMENT, new List<String>{CON_CPQ.MEDICAL_MSL});
        Test.stopTest();
        
        //System.assertEquals(assignmentList.size() > 0, true , 'Assignment found');
    }
    */
	@IsTest
    static void testgetActiveAssignmentsByProject()
    {
        Test.startTest();
        setupTestData();
        Set<String> fieldSet = new Set<String>{'Name', 'pse__project__c','Active__c'};
        List<pse__Assignment__c> idWithChild = new SLT_Assignment().getActiveAssignmentsByProject(new Set<Id> {assignment.pse__Project__c}, fieldSet );
        Test.stopTest();
    }
	
	@IsTest
	static void testgetAssignmentByBhrAndConditionOrderByBhrOwner() 
    {   
        Set<String> resourceRequestFieldSet = new Set<String>{'Id','Bid_History__c'};
        Bid_History__c oppty = [SELECT Id FROM Bid_History__c limit 1];
        Set<Id> oppIdSet = new Set<Id>();
        oppIdSet.add(oppty.Id);
        Test.startTest();
        List<pse__Assignment__c> resourceRequestByOppID = new SLT_Assignment(true).getAssignmentByBhrAndConditionOrderByBhrOwner(oppIdSet, '', resourceRequestFieldSet);
        Test.stopTest();
    }
    
    @IsTest
    static void testgetActiveAssignmentsByProjectLitratureANDPvSolution()
    {
        Test.startTest();
        setupTestData();
        Set<String> fieldSet = new Set<String>{'Name'};
        List<pse__Assignment__c> idWithChild = new SLT_Assignment().getActiveAssignmentsByProjectLitratureANDPvSolution(new Set<Id> {assignment.pse__Project__c}, 'pse__Project__c IN :parentProjectIdSet', fieldSet);
        Test.stopTest();
    }
}