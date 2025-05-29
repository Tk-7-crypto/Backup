/**
 * This test class is used to test all methods in Project service class.
 * version : 1.0
 */
@isTest
private class TST_SLT_Project {

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
        User testUser = new User(Id = UserInfo.getUserId());
        testUser.SUBREGION__c = 'United States of America';
        testUser.EmployeeNumber = '0808080810';
        testUser.IsActive = true;
        update testUser;
        Contact cont = UTL_OWF_TestData.createContact(acc.Id);
        cont.pse__Is_Resource__c = true;
        cont.pse__Is_Resource_Active__c = true;
        cont.pse__Group__c = grp.Id;
        cont.pse__Salesforce_User__c = testUser.id;
        insert cont;
        Indication_List__c indication = UTL_OWF_TestData.createIndication('Test Indication', 'Acute Care');
        insert indication; 
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
        opp.Potential_Regions__c = 'Global';
        opp.OwnerId = testUser.id;
        insert opp;
        Bid_History__c agreement = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        agreement.Requested_Services__c = CON_OWF.OWF_BID_HISTORY_REQUESTED_INTERNAL_SERVICES_CLINICAL_MONITORING;
        agreement.Pricing_Monitoring_Model__c = CON_OWF.OWF_BID_HISTORY_PRICING_MONITORING_MODEL_IQVIA_RBM;
        agreement.DTE_Study__c = CON_OWF.OWF_BID_HISTORY_DTE_STUDY_NO;
        insert agreement;
	}
   /* @testSetup
    static void dataSetup() 
	{
        Account acc = UTL_OWF_TestData.createAccount();
        insert acc;
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        User testUser = new User(Id = UserInfo.getUserId());
        testUser.SUBREGION__c = 'United States of America';
        testUser.EmployeeNumber = '0808080810';
        testUser.IsActive = true;
        update testUser;
        Contact cont = UTL_OWF_TestData.createContact(acc.Id);
        cont.pse__Is_Resource__c = true;
        cont.pse__Is_Resource_Active__c = true;
        cont.pse__Group__c = grp.Id;
        cont.pse__Salesforce_User__c = testUser.id;
        insert cont;
        Indication_List__c indication = UTL_OWF_TestData.createIndication('Test Indication', 'Acute Care');
        insert indication; 
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
        opp.Potential_Regions__c = 'Global';
        opp.Line_of_Business__c = 'Core Clinical';
        opp.Is_this_IQVIA_Biotech__c = 'Yes';
        opp.OwnerId = testUser.id;
        insert opp;
        Apttus__APTS_Agreement__c agreement = UTL_OWF_TestData.createAgreementByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_AGREEMENT_RECORD_TYPE_ID);
        agreement.Requested_Services__c  = 'Clinical Monitoring';
        insert agreement;
	}
    */
    
    
    /**
    * This test method used to cover basic methods
    */ 
    @isTest
    static void testServiceProject() 
	{   
        List<Schema.SObjectField> projectList = new SLT_Project().getSObjectFieldList();
        Integer expected = 0;
        System.assertEquals(expected, projectList.size(), 'Test testServiceProject');
    }    
    
    /**
     * This test method used to cover getProjectByBidHistoryID
     */ 
    @isTest
    static void testGetProjectByBidHistoryID() 
	{   
        List<Bid_History__c> agreementList = [Select Id From Bid_History__c Limit 1];
        Set<ID> agreementIDSet = new Set<ID>{agreementList[0].Id};
        Set<String> projectFieldSet = new Set<String>{'Id','Bid_History__c'};
        Test.startTest();
        Map<Id, pse__Proj__c> projectMap = new SLT_Project(false,false).getProjectByBidHistoryID(agreementIDSet, projectFieldSet);
        Test.stopTest();
        
        String expected = agreementList[0].Id;
        String actual = String.valueof(projectMap.values()[0].get('Bid_History__c'));
        System.assertEquals(expected, actual, 'Test testGetProjectByBidHistoryID');
    }
    
//These Methods are for testing PSA
    
	static Program__c program;
    static pse__Proj__c parentproject;
    static pse__Proj__c project;
    static Service_Line__c serviceLine;
    static void setupTestData () 
	{

        program = new Program__c(Name = 'SLTTestProgram');
        insert program;  

        // Parent Project
        parentproject = UTL_PSA_TestData.createProjects(1, false)[0];
        //project.recordTypeId = '012e0000000DQQpAAO';
        Id parentrecTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_PROJECT);  
        parentproject.recordTypeId = parentrecTypeId;
        parentproject.pse__Project_Status__c = 'Start-up';
        parentproject.Name = 'SLTTestParentProject';
        parentproject.Program__c = program.id;
        insert parentproject;
        
        // service line
        serviceLine = new Service_Line__c();
        serviceLine.Name = 'PV Solutions';
        serviceLine.Service_Line_Code__c = 'test';
        insert serviceLine;
      
        // project
        project = UTL_PSA_TestData.createProjects(1, false)[0];
        //project.recordTypeId = '012e0000000DQQpAAO';
        Id recTypeId = UTL_PSA_TestData.lookupRecordTypeId('pse__Proj__c', CON_PSA.PROJ_REC_TYPE_RDS_SERVICELINE);  
        project.recordTypeId = recTypeId;
        project.pse__Project_Status__c = 'Start-up';
        project.Name = 'SLTTestServiceLineProject';
        project.pse__Parent_Project__c = parentproject.id;
        project.Project_Code__c ='12345';
        project.Program__c = program.id;
        project.Service_Line__c = serviceLine.id;
        insert project;    
        
    }  
    
	
	/**
     * This method used to get Project by Project Id.
    */    
    @IsTest
    static void testSelectById() 
	{
        setupTestData();
        Test.startTest();
        Set<String> fieldSet = new Set<String>{'Name','pse__Account__c','pse__Is_Active__c','pse__Start_Date__c','pse__End_Date__c'};
        pse__Proj__c idToProject = new SLT_Project().selectByProjectId(new Set<Id> {project.id}, fieldSet );
        Test.stopTest();
        String expected = 'SLTTestServiceLineProject';
        String actual = idToProject.Name;
        System.assertEquals(expected, actual, 'Test testSelectById');
    }


    /**
    * This method used to get ServiceLine Project by Id matching to the  Project ID.
    */    
    @IsTest
    static void testServicelineProjectById() 
	{
        setupTestData();
        Test.startTest();
        Set<String> fieldSet = new Set<String>{'Name','pse__Account__c','pse__Is_Active__c','pse__Start_Date__c','pse__End_Date__c'};
        List<pse__Proj__c> idToProjectList = new SLT_Project().selectServiceLineByProject(new Set<Id> {project.id}, fieldSet );
        Test.stopTest();
        
		String expected = 'SLTTestServiceLineProject';
        String actual = idToProjectList[0].Name;
        System.assertEquals(expected, actual, 'Test testServicelineProjectById');
    }


    /**
    * This method used to get ServiceLine Project by Id matching to the  Parent Project ID.
    */    
    @IsTest
    static void testServicelineProjectByParentProjectId() 
	{
        setupTestData();
        Test.startTest();
        Set<String> fieldSet = new Set<String>{'Name','pse__Account__c','pse__Is_Active__c','pse__Start_Date__c','pse__End_Date__c'};
        List<pse__Proj__c> idToProjectList = new SLT_Project().selectServiceLineByParentProject(new Set<Id> {parentproject.id}, fieldSet );
        Test.stopTest();
		
        String expected = 'SLTTestServiceLineProject';
        String actual = idToProjectList[0].Name;
        System.assertEquals(expected, actual, 'Test testServicelineProjectByParentProjectId');
    }


    /**
     * This method used to get Map<Id, pse__Proj__c> by Project Id.
     */    
    @IsTest
    static void testGetProjectMapById() 
	{
        setupTestData();
        Test.startTest();
        Set<String> fieldSet = new Set<String>{'Name','pse__Account__c','pse__Is_Active__c','pse__Start_Date__c','pse__End_Date__c'};
        Map<Id, pse__Proj__c> idToProjectMap = new SLT_Project().getProjectById(new Set<Id> {project.id}, fieldSet );
        Test.stopTest();
		
        String expected = 'SLTTestServiceLineProject';
        String actual = idToProjectMap.get(project.id).Name;
        System.assertEquals(expected, actual, 'Test testGetProjectMapById');
    }
    
    /**
     * This method used to get Map<Id, pse__Proj__c> by Project Id and condition
     */    
    @IsTest
    static void testgetProjectByIdAndCondition() 
    {
        setupTestData();
        Test.startTest();
        Set<String> fieldSet = new Set<String>{'Name','pse__Account__c','pse__Is_Active__c','pse__Start_Date__c','pse__End_Date__c','Project_Code__c'};
            Map<Id, pse__Proj__c> idToProjectMap = new SLT_Project().getProjectByIdAndCondition(new Set<Id> {project.id}, fieldSet, 'Project_Code__c =\'12345\'');
        Test.stopTest();
        String expected = '12345';
        String actual = idToProjectMap.get(project.id).Project_Code__c;
        System.assertEquals(expected, actual, 'Test testgetProjectByIdAndCondition');
    }


    /**
    * This method used to get ServiceLine Project by Parent Project Id.
    */    
    @IsTest
    static void selectByParentProjectId() 
	{
        setupTestData();
        Test.startTest();
        Set<String> fieldSet = new Set<String>{'Name','pse__Parent_Project__c','pse__Account__c','pse__Is_Active__c','pse__Start_Date__c','pse__End_Date__c'};
        List<pse__Proj__c> idToProjectList = new SLT_Project().selectByParentProjectId(new Set<Id> {parentproject.id}, fieldSet );
        Test.stopTest();
		
        Integer expected = 1;
        Integer actual = idToProjectList.size();
        System.assertEquals(expected, actual, 'Test selectByParentProjectId');
        String expectedName = 'SLTTestServiceLineProject';
        String actualName = idToProjectList[0].Name;
        System.assertEquals(expectedName, actualName, 'Test selectByParentProjectId');
        
    }

    /**
    * This method used to get ProjectList by matching to the Program ID.
    */    
    @IsTest
    static void selectByProgramId() 
	{
        setupTestData();
        Test.startTest();
        Set<String> fieldSet = new Set<String>{'Name','Program__c','pse__Parent_Project__c','pse__Account__c','pse__Is_Active__c','pse__Start_Date__c','pse__End_Date__c'};
        List<pse__Proj__c> idToProjectList = new SLT_Project().selectByProgramId(new Set<Id> {program.id}, fieldSet );
        Test.stopTest();
		
        Integer expected = 1;
        Integer actual = idToProjectList.size();
        System.assertEquals(expected, actual, 'Test selectByProgramId');
        String expectedName = 'SLTTestParentProject';
        String actualName = idToProjectList[0].Name;
        System.assertEquals(expectedName, actualName, 'Test selectByProgramId');

    }

    /**
    * This method selects projects by Project Code (Project_Code__c).
    * @return  List<pse__Proj__c>
    */ 
    @IsTest
    static void selectByProjectCode() 
	{
        setupTestData();
        Test.startTest();
        Set<String> fieldSet = new Set<String>{'Name','Program__c','pse__Parent_Project__c','pse__Account__c','pse__Is_Active__c','pse__Start_Date__c','pse__End_Date__c'};
        List<pse__Proj__c> idToProjectList = new SLT_Project().selectByProjectCode(new Set<String> {project.Project_Code__c}, fieldSet );
        Test.stopTest();
		
        Integer expected = 1;
        Integer actual = idToProjectList.size();
        System.assertEquals(expected, actual, 'Test selectByProjectCode');
        String expectedName = 'SLTTestServiceLineProject';
        String actualName = idToProjectList[0].Name;
        System.assertEquals(expectedName, actualName, 'Test selectByProjectCode');

    }

    /**
    * This method used to get Project Map by Id matching to the Parent Project ID.
    * @return  Map<Id, List<pse__Proj__c>>
    */ 
    @IsTest
    static void testGetMapByParentProjectId()
	{
        setupTestData();
        Test.startTest();
        Set<String> fieldSet = new Set<String>{'Name','pse__Parent_Project__c','pse__Account__c','pse__Is_Active__c','pse__Start_Date__c','pse__End_Date__c'};
        Map<Id, List<pse__Proj__c>> idToProjectMap = new SLT_Project().selectMapByParentProjectId(new Set<Id> {project.pse__Parent_Project__c}, fieldSet );
        Test.stopTest();
		
        String expected = 'SLTTestServiceLineProject';
        List<pse__Proj__c> projectlist = idToProjectMap.get(parentproject.id);
        String actual = projectlist[0].Name;
        System.assertEquals(expected, actual, 'Test testGetMapByParentProjectId');
    }

    @IsTest
    static void testSelectChildsByProgramId() 
	{
        setupTestData();
        Test.startTest();
        List<pse__Proj__c> projectList = new SLT_Project().selectChildsByProgramId(new Set<Id>{program.Id}, new Set<String>{'Id'});
        System.assert(projectList.size() > 0, 'Test testSelectChildsByProgramId');
    }
    
    @isTest
    static void testlookUpPVSolutionsProjects()
	{
        setupTestData();
        Test.startTest();
        Map<Id,pse__Proj__c> projectMap = new SLT_Project().lookUpPVSolutionsProjects(new Set<Id>{project.Id}, new Set<String>{'Id'});
        System.assert(projectMap.size() > 0, 'Test testSelectChildsByProgramId');
        Test.stopTest();
    }
}
