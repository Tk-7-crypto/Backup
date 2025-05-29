/**
 * This test class is used to test all methods in Resource Skill Request service class
 * version : 1.0
 */
@isTest
private class TST_SLT_Resource_Skill_Request {

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
        Contact cont = UTL_OWF_TestData.createContact(acc.Id);
        cont.pse__Is_Resource__c = true;
        cont.pse__Is_Resource_Active__c = true;
        cont.pse__Group__c = grp.Id;
        insert cont; 
    }
    
	
    /**
    * This test method used to cover basic methods
    */ 
    static testMethod void testServiceResourceRequest() 
	{   
        List<Schema.SObjectField> resourceRequestList = new SLT_Resource_Skill_Request().getSObjectFieldList();
        Schema.SObjectType resourceRequest = new SLT_Resource_Skill_Request(true).getSObjectType();
		
		Integer expected = 0;
		System.assertEquals(expected, resourceRequestList.size());
	}


//The following methods are for PSA
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
    static void setupTestData () 
	{  
       //contacts
        contact = UTL_PSA_TestData.resources[0];
        
        anothercontact = UTL_PSA_TestData.resources[1];
       
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
        project.pse__Project_Manager__c = contact.id;
        project.Service_Line_Lead__c = contact.id;
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
        SLT_Resource_Skill_Request sltRRSkill = new SLT_Resource_Skill_Request();
        sltRRSkill.getSObjectType();
        Test.stopTest();
		
		String expected = 'pse__Resource_Skill_Request__c';
        String actual = String.valueof(sltRRSkill.getSObjectType());
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
        SLT_Resource_Skill_Request sltRRSkill = new SLT_Resource_Skill_Request();
        List<Schema.SObjectField> sltRRSObjectFieldlist = sltRRSkill.getSObjectFieldList();
        Test.stopTest();
		
		Integer expected = 0;
		System.assertEquals(expected, sltRRSObjectFieldlist.size());
    }   

	
    /**
     * This method used to get Resource Skill Request by Resource Request Id
     * @params  Set<Id> rrIdset
     * @params  Set<String> rsrFieldSet
     * @return  Map<Id, pse__Resource_Skill_Request__c>
     */
    @IsTest
    static void testGetResourceSkillRequestByRrID() 
	{
        setupTestData();
        Test.startTest();
        Set<String> fieldSet = new Set<String>{'pse__Resource_Request__r.id','pse__Resource_Request__c','pse__Skill_Certification__c'};
        Map<Id,pse__Resource_Skill_Request__c> idToRRMap = new SLT_Resource_Skill_Request().getResourceSkillRequestByRrID(new Set<Id> {resourcerequest.id}, fieldSet );
        Test.stopTest();
        
		String expected = resourcerequest.id;
        String actual = idToRRMap.get(resourcerequestskill.id).pse__Resource_Request__r.id;
        System.assertEquals(expected, actual);
    } 
}