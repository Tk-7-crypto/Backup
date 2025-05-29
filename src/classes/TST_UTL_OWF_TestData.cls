@isTest
public class TST_UTL_OWF_TestData{
    
	@isTest
    public static void testMethod1()
	{
		test.startTest();
			UTL_OWF_TestData.createUser('System Administrator',1);
		test.stopTest();
		
		List<User> userList = UTL_OWF_TestData.createUser('System Administrator',1);
        system.assertNotEquals(0, userList.size()); 
	}
	
	
	@isTest
    public static void testMethod2()
	{
		test.startTest();
			UTL_OWF_TestData.createAccount();
		test.stopTest();
		
		Account account = UTL_OWF_TestData.createAccount();
        system.assertNotEquals(null, account);
	}
	
	@isTest
    public static void testMethod3()
	{
		test.startTest();
			UTL_OWF_TestData.createOpportunity(null);
		test.stopTest();
		
		Opportunity opp = UTL_OWF_TestData.createOpportunity(null);
        system.assertNotEquals(null, opp);
	}

	
	@isTest
    public static void testMethod4()
	{
		test.startTest();
			UTL_OWF_TestData.createAgreement(null,null);
		test.stopTest();
		
		Apttus__APTS_Agreement__c agr = UTL_OWF_TestData.createAgreement(null,null);
		system.assertNotEquals(null, agr);
	}
	
	
	@isTest
    public static void testMethod5()
	{
		test.startTest();
			UTL_OWF_TestData.createAgreementByRecordType(null,null,null);
		test.stopTest();
		
		Apttus__APTS_Agreement__c agreement = UTL_OWF_TestData.createAgreementByRecordType(null,null,null);
        system.assertNotEquals(null, agreement);
	}

	
	@isTest
    public static void testMethod6()
	{
		test.startTest();
			UTL_OWF_TestData.createGroup();
		test.stopTest();
		
		pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        system.assertNotEquals(null, grp);
	}	
	
    
	@isTest
    public static void testMethod7()
	{
		test.startTest();
			UTL_OWF_TestData.createPermissionControl(null,null,null,null);
		test.stopTest();
		
		pse__Permission_Control__c pc = UTL_OWF_TestData.createPermissionControl(null,null,null,null);
        system.assertNotEquals(null, pc);
	}


	@isTest
    public static void testMethod8()
	{
		test.startTest();
			UTL_OWF_TestData.createOWFConfig(null);
		test.stopTest();
		
		OWF_Config__c config = UTL_OWF_TestData.createOWFConfig(null);
		system.assertNotEquals(null, config);
	}


	@isTest
    public static void testMethod9()
	{
		test.startTest();
			UTL_OWF_TestData.createBidProject(null);
		test.stopTest();
		
		pse__Proj__c proj =  UTL_OWF_TestData.createBidProject(null);
        system.assertNotEquals(null, proj);
	}


	@isTest
    public static void testMethod10()
	{
		test.startTest();
			UTL_OWF_TestData.createResourceRequest(null,null,null);
		test.stopTest();
		
		pse__Resource_Request__c rr = UTL_OWF_TestData.createResourceRequest(null,null,null);
        system.assertNotEquals(null, rr);
	}


	@isTest
    public static void testMethod11()
	{
		test.startTest();
			UTL_OWF_TestData.createSchedule();
		test.stopTest();
		
		pse__Schedule__c schedule = UTL_OWF_TestData.createSchedule();
		system.assertNotEquals(null, schedule);
	}


	@isTest
    public static void testMethod12()
	{
		test.startTest();
			UTL_OWF_TestData.createAssignment(null,null,null,null,null);
		test.stopTest();
		
		pse__Assignment__c assignment = UTL_OWF_TestData.createAssignment(null,null,null,null,null);
        system.assertNotEquals(null, assignment);
	}
	
	
	@isTest
    public static void testMethod13()
	{
		test.startTest();
			UTL_OWF_TestData.setupOWFBatchConfig('test');
		test.stopTest();
		
        OWF_Batch_Config__c owfbatchconfig = UTL_OWF_TestData.setupOWFBatchConfig('test');
        system.assertNotEquals(null, owfbatchconfig);
	}
	
	
	@isTest
    public static void testMethod14()
	{
		test.startTest();
			UTL_OWF_TestData.setupOWFConfig(null);
		test.stopTest();
		
		OWF_Config__c owfconfig = UTL_OWF_TestData.setupOWFConfig(null);
        system.assertNotEquals(null, owfconfig);
	}
	
	
	@isTest
    public static void testMethod15()
	{
		test.startTest();
			UTL_OWF_TestData.createSkills('Test','test');
		test.stopTest();
		
		pse__Skill__c skill =  UTL_OWF_TestData.createSkills('Test','test');
        system.assertNotEquals(null, skill);	
	}
	
	
	@isTest
    public static void testMethod16()
	{
		test.startTest();
			UTL_OWF_TestData.createSkillCertificationRating(null,null);
		test.stopTest();
		
		pse__Resource_Skill_Request__c rsr = UTL_OWF_TestData.createResourceSkillRequest(null,null);
        system.assertNotEquals(null, rsr);
	}
	
	
	@isTest
    public static void testMethod17()
	{
		test.startTest();
			UTL_OWF_TestData.createIndication('Test','test');
		test.stopTest();
		
        Indication_List__c indication = UTL_OWF_TestData.createIndication('Test','test');
        system.assertNotEquals(null, indication);
	}
		
	@isTest
    public static void testMethod19()
	{
		test.startTest();
			UTL_OWF_TestData.createDaysOff(null);
		test.stopTest();
		
		Days_Off__c daysoff = UTL_OWF_TestData.createDaysOff(null);
        system.assertNotEquals(null, daysoff);
	}
    
    @isTest
    public static void testMethod20()
	{
		test.startTest();
			UTL_OWF_TestData.createInvestigatorGrantByAgreementId(null);
		test.stopTest();
		
		Investigator_Grant__c ig = UTL_OWF_TestData.createInvestigatorGrantByAgreementId(null);
        system.assertNotEquals(null, ig);
	}
	@isTest
    public static void testMethod21()
	{
		test.startTest();
			CollectionTool__c ct = UTL_OWF_TestData.createCollectionTool(null,null);
		test.stopTest();
	
        system.assertNotEquals(null, ct);
	}
}