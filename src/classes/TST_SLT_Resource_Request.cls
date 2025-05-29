/**
 * This test class is used to test all methods in Resource Request service class
 * version : 1.0
 */

@isTest
private class TST_SLT_Resource_Request {
	

    /**
     * This method is used to setup data for all methods.
     */
    @testSetup
    static void dataSetup()
	{
        Account acc = UTL_OWF_TestData.createAccount();
        insert acc;
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        Contact cont = UTL_OWF_TestData.createContact(acc.Id);
        cont.pse__Is_Resource__c = true;
        cont.pse__Is_Resource_Active__c = true;
        cont.pse__Group__c = grp.Id;
        insert cont;
        Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
        insert opp;
        Bid_History__c agreement = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        insert agreement;
    }
	
    
    /**
     * This test method used to cover basic methods
     */ 
    static testMethod void testServiceResourceRequest() 
	{   
        List<Schema.SObjectField> resourceRequestList = new SLT_Resource_Request().getSObjectFieldList();
        Schema.SObjectType resourceRequest = new SLT_Resource_Request(true).getSObjectType();
		
		Integer expected = 0;
		System.assertEquals(expected, resourceRequestList.size());
    }    
    
	
    /**
     * This test method used to get Resource Request By Project ID
     */ 
    static testMethod void testGetResourceRequestByProjectID() 
	{   
        pse__Proj__c project = [Select Id From pse__Proj__c limit 1];
        Set<ID> projectIdset = new Set<Id>{project.Id};
        Set<String> resourceRequestFieldSet = new Set<String>{'Id','pse__Project__c'};
        Test.startTest();
            Map<Id, pse__Resource_Request__c> rrIdToResourceRequestMap = new SLT_Resource_Request().getResourceRequestByProjectID(projectIdset, resourceRequestFieldSet);
        Test.stopTest();
    
        String expected = project.Id;
        String actual = String.valueof(rrIdToResourceRequestMap.values()[0].get('pse__Project__c'));
        system.assertEquals(expected, actual);
    }
    
	
    /**
    * This test method used to test selectByIdWithResReqsAndRSRs method
    */ 
    static testMethod void testSelectByIdWithResReqsAndRSRs() 
	{   
        pse__Proj__c project = [Select Id From pse__Proj__c limit 1];
        Set<ID> projectIdset = new Set<Id>{project.Id};
        Set<String> resourceRequestFieldSet = new Set<String>{'Id'};
        String resReqCondition = 'RecordType.DeveloperName = \'' + CON_OWF.OWF_RESOURCE_REQUEST_RECORD_TYPE_NAME + '\'';
        Set<String> resRequestFieldSet = new Set<String>{'Id', 'pse__Assignment__c', 'Therapy_Area__c', 'Indication__c'};
        Set<String> resSkillRequestFieldSet = new Set<String>{'Id', 'pse__Is_Primary__c', 'pse__Resource_Request__c', 'pse__Skill_Certification__c', 'pse__Skill_or_Certification__c', 'pse__Skill_Record_Type__c'};    
        String resSkillReqCondition = '(pse__Skill_Certification__r.pse__Type__c = \'' + CON_OWF.SKILL_TYPE_INDICATION 
                    + '\' OR pse__Skill_Certification__r.pse__Type__c = \''  + CON_OWF.SKILL_TYPE_THERAPY_AREA + '\')';
        Test.startTest();
            Map<Id, pse__Resource_Request__c> rrIdToRresourceRequestWithSkillMap = new SLT_Resource_Request(false).selectByIdWithResReqsAndRSRs(null, resReqCondition, resRequestFieldSet, resSkillRequestFieldSet, resSkillReqCondition);
        Test.stopTest();
    
        Integer expected = 2;
        System.assertEquals(expected, rrIdToRresourceRequestWithSkillMap.size());
    }
    
	
    /**
     * This test method used to test getResourceRequestByAgrID method

    static testMethod void testGetResourceRequestByAgrID() 
	{   
        Set<String> resourceRequestFieldSet = new Set<String>{'Id','Bid_History__c'};
        Bid_History__c agreement = [Select id from Bid_History__c limit 1];
        Set<Id> aggrementIdSet = new Set<Id>();
        aggrementIdSet.add(agreement.Id);
        Test.startTest();
            Map<Id, pse__Resource_Request__c> resourceRequestByAgrID = new SLT_Resource_Request(false).getResourceRequestByAgrID(aggrementIdSet,  resourceRequestFieldSet);
        Test.stopTest();
    
       	//String expected = agreement.Id;
        //String actual = String.valueof(resourceRequestByAgrID.values()[0].get('Agreement__c'));
        //System.assertEquals(expected, actual);
    }
     */
    /**
    * This test method used to test selectResReqsById method
    */ 
    static testMethod void testSelectResReqsById()
	{   
        Set<String> resourceRequestFieldSet = new Set<String>{'Id'};
        Bid_History__c agreement = [SELECT Id, Name FROM Bid_History__c][0];
        Contact cont = [Select Id From Contact Where LastName = 'TestContact' limit 1];
        Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
        pse__Proj__c project = [Select Id From pse__Proj__c Where Bid_History__c =: agreement.Id];
        pse__Grp__c grp1 = [Select Id From pse__Grp__c Where Name = 'TestGroup'];
        pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, oppty.Id, project.Id);
        resourceRequest.pse__Group__c = grp1.Id;
        Test.startTest();
            insert resourceRequest;
            Set<Id> rrIdSet = new Set<Id>();
            rrIdSet.add(resourceRequest.Id);
            Map<Id, pse__Resource_Request__c> resReqsById = new SLT_Resource_Request(false).selectResReqsById(rrIdSet,  resourceRequestFieldSet);
        Test.stopTest();
    
        Integer expected = 1;
        System.assertEquals(expected, resReqsById.size());
    }


    static testMethod void testGetResourceRequestByOppID() 
	{   
        Set<String> resourceRequestFieldSet = new Set<String>{'Id','pse__Opportunity__c'};
        Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
        Set<Id> oppIdSet = new Set<Id>();
        oppIdSet.add(oppty.Id);
        Test.startTest();
            List<pse__Resource_Request__c> resourceRequestByOppID = new SLT_Resource_Request(false).getResourceRequestListFromOpportunity(oppIdSet,  resourceRequestFieldSet,'');
        Test.stopTest();
    
        String expected = oppty.Id;
        String actual = resourceRequestByOppID[0].pse__Opportunity__c;
        System.assertEquals(expected, actual);
    }
    
    static testMethod void testResourceRequestListFromOpportunityforPostAward() 
	{   
        Set<String> resourceRequestFieldSet = new Set<String>{'Id','pse__Opportunity__c'};
        Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
        Set<Id> oppIdSet = new Set<Id>();
        oppIdSet.add(oppty.Id);
        Test.startTest();
            List<pse__Resource_Request__c> resourceRequestByOppID = new SLT_Resource_Request(false).getResourceRequestListFromOpportunityforPostAward(oppIdSet,  resourceRequestFieldSet,'');
        Test.stopTest();
    
        String expected = oppty.Id;
        String actual = resourceRequestByOppID[0].pse__Opportunity__c;
        System.assertEquals(expected, actual);
    }
    
    static testMethod void testResourceRequestListFromBidHistory(){
        Set<String> resourceRequestFieldSet = new Set<String>{'Id','Bid_History__c'};
        Bid_History__c bidHistory = [SELECT Id from Bid_History__c limit 1];
        Set<Id> agreementIdSet = new Set<Id>();
        agreementIdSet.add(bidHistory.Id);
        Test.startTest();
            List<pse__Resource_Request__c> resourceRequestByOppID = new SLT_Resource_Request(false).getResourceRequestListFromBidHistory(agreementIdSet,  resourceRequestFieldSet,'');
        Test.stopTest();
    }

//PSA Test Methods start here
    static pse__Proj__c parentproject;
    static pse__Proj__c project;
    static pse__Proj__c anotherproject;
    static Service_Line__c serviceLine;
    static pse__Milestone__c milestones;
    static Contact contact;
    static Contact anothercontact;
    static pse__Resource_Request__c resourcerequest;
    static pse__Skill__c skill;
    static pse__Resource_Skill_Request__c resourcerequestskill;
    static pse__Project_Task__c projecttask;
    static pse__Assignment__c assignment;
    static void setupTestData () {  
       //contacts
        //contact = UTL_PSA_TestData.resources[0];
        
        //anothercontact = UTL_PSA_TestData.resources[1];
       
        // Parent Project
        parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);  
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Project_Status__c = 'Start-up';
        insert parentproject;
      
        // project
        project = UTL_PSA_TestData.createProjects(1, false)[0];
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);  
        project.recordTypeId = recTypeId;
        project.pse__Project_Status__c = 'Start-up';
        project.pse__Parent_Project__c = parentproject.id;
        //project.pse__Project_Manager__c = contact.id;
        //project.Service_Line_Lead__c = contact.id;
        insert project;
       
        UTL_PSA_TestData.createPermissionControls(); 
        //milestones
        milestones = UTL_PSA_TestData.createMilestones(1, false)[0];
        
        Id milestonerecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Milestone__c', CON_PSA.MILESTONE_REC_TYPE_SERVICE);  
        milestones.RecordTypeId = milestonerecTypeId;
        milestones.pse__Project__c = project.Id; 
        insert milestones;
        
        //resource request
        resourcerequest = UTL_PSA_TestData.createResourceRequests(1,false)[0];
        resourcerequest.pse__Project__c = project.Id;
        insert resourcerequest;

        //pse__Skill__c
        skill = new pse__Skill__c(Name='Test Skill',pse__Type__c='Technical');
        insert skill;

        //insert resource request skill
        resourcerequestskill = new pse__Resource_Skill_Request__c(pse__Resource_Request__c= resourcerequest.id,pse__Skill_Certification__c= skill.id,pse__Minimum_Rating__c='1 - Limited Exposure' );
        insert resourcerequestskill;
        
        //Project Task
        /*  projecttask = new pse__Project_Task__c(Name = 'PTATestPT');
        Id recordTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Project_Task__c', CON_PSA.RDS_DELIVERABLE_TASK); 
        projecttask.pse__Project__c = project.id;
        insert projecttask;*/
         

        //project task assignment
        /* projecttaskassignment = new pse__Project_Task_Assignment__c();
        //projecttaskassignment.pse__Project_Task__c = projecttask.id;
        projecttaskassignment.pse__Resource__c = contact.Id;
        projecttaskassignment.Is_Primary__c = true;
        projecttaskassignment.pse__Resource_Request__c = resourcerequest.Id;
        insert projecttaskassignment;*/
    }


    /**
     * This method used to test set up type of sobject
     * @return  Schema.SObjectType
     */
	@IsTest
    static void testGetSObject ()
	{
        //setupTestData();
        Test.startTest();
        SLT_Resource_Request sltRR = new SLT_Resource_Request();
        sltRR.getSObjectType();
        Test.stopTest();
        
        String expected = 'pse__Resource_Request__c';
        String actual = String.valueof(sltRR.getSObjectType());
		System.assertEquals(expected, actual);
    }


    /**
    * This method used to get test field list of sobject
    * @return  List<Schema.SObjectField>
    */
    @IsTest
    static void testSObjectFieldList() 
	{
        //setupTestData();
        Test.startTest();
        SLT_Resource_Request sltRR = new SLT_Resource_Request();
        List<Schema.SObjectField> sltRRSObjectFieldlist = sltRR.getSObjectFieldList();
        Test.stopTest();
        if (sltRRSObjectFieldlist != null && sltRRSObjectFieldlist.size() > 0) {
            for( Schema.SObjectField sobjectField : sltRRSObjectFieldlist){
                System.debug('***'+String.valueof(sobjectField));
            }
        }
    }  

	
	/**
    * This method used to get Resource Request by with Project
    * @params  Set<Id> projectIdset
    * @params  Set<String> resourceRequestFieldSet
    * @return  Map<Id, List<pse__Resource_Request__c>>
    */
	@IsTest
    static void testGetResourceRequestListByProjectID() 
	{
        setupTestData();
        Test.startTest();
        Set<String> fieldSet = new Set<String>{'Id','pse__Project__c'};
        Map<Id,List<pse__Resource_Request__c>> idToRRMap = new SLT_Resource_Request().getResourceRequestListByProjectID(new Set<Id> {project.id}, fieldSet );
        Test.stopTest();
        
        String expected = resourcerequest.id;
        List<pse__Resource_Request__c> rrList = idToRRMap.get(resourcerequest.pse__Project__c);
        String actual = rrList[0].Id;
        System.assertEquals(expected, actual);
    } 


	/**
    * This method used to get Resource Request by Assignment Id
    * @params  Set<Id> assignmentIdset
    * @params  Set<String> resourceRequestFieldSet
    * @return  Map<Id, pse__Resource_Request__c>
    */
	@IsTest
    static void testGetResourceRequestByAssignmentID() 
	{
        setupTestData();
        Test.startTest();
        //assignemnt
        assignment = UTL_PSA_TestData.createAssignments(false)[0];
        assignment.pse__Project__c = project.Id;
        assignment.pse__Resource_Request__c = resourcerequest.id;
        //assignment.pse__Bill_Rate__c = 100;
        insert assignment;
        Set<String> fieldSet = new Set<String>{'Id','pse__Project__c'};
        Map<Id,pse__Resource_Request__c> idToRRMap = new SLT_Resource_Request().getResourceRequestByAssignmentID(new Set<Id> {assignment.id}, fieldSet );
        Test.stopTest();
        
        String expected = resourcerequest.id;
		//String actual = idToRRMap.get(assignment.id).id;
		//System.assertEquals(expected, actual);
    }
}
