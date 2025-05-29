/**
 * This test class is used to test all methods in CNT_OWF_CreateReourceRequest.
 * version : 1.0
 */
@isTest
private class TST_CNT_OWF_CreateReourseRequest {
    
    /**
    * This method used to set up testdata
    */ 
    @testSetup
    static void dataSetup() 
	{
        List<pse__Skill__c> skillList = new List<pse__Skill__c>();
        pse__Skill__c skill1 = UTL_OWF_TestData.createSkills('Australia', 'Global Analytics Country');
        pse__Skill__c skill2 = UTL_OWF_TestData.createSkills('Belgium', 'Global Analytics Country');
        skillList.add(skill1);
        skillList.add(skill2);

        insert skillList;
		Account acc = UTL_OWF_TestData.createAccount();
		insert acc;
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        pse__Grp__c grp1 = UTL_OWF_TestData.createGroup();
        grp1.Name = 'OWF TSL';
        insert grp1;
        Contact cont2 = UTL_OWF_TestData.createContact(acc.Id);
        cont2.pse__Is_Resource__c = true;
        cont2.pse__Is_Resource_Active__c = true;
        cont2.pse__Group__c = grp1.Id;
        cont2.sub_group__c = 'TSL-Japan';
        cont2.available_for_triage_flag__c = true;
        cont2.pse__Salesforce_User__c = UserInfo.getUserId();
        insert cont2;
        OWF_Config__c owfConfig = UTL_OWF_TestData.setupOWFConfig(grp.Id);
        owfConfig.OWF_Compatible_Group_Set_1__c = 'OWF TSL';
        owfConfig.OWF_Compatible_Group_Set_2__c = 'OWF DSB-DM';
        owfConfig.OWF_Multiple_RR_Compatible_Subgroups__c= 'TAL;Feasibility Analytics;Site Analytics';
        insert owfConfig;
        Contact cont = UTL_OWF_TestData.createContact(acc.Id);
        cont.pse__Is_Resource__c = true;
        cont.pse__Is_Resource_Active__c = true;
        cont.pse__Group__c = grp.Id;
        insert cont;
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
        insert opp;
        Bid_History__c agreement = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        agreement.Bid_Due_Date__c = system.today().addDays(5);
        insert agreement;
    }
    
    @isTest
    static void testSaveResourceRequest() 
	{
		test.startTest();
			Bid_History__c agrmnt = [SELECT Id FROM Bid_History__c LIMIT 1];
			pse__Resource_Request__c rrObject=new pse__Resource_Request__c();
        	rrObject.Bid_History__c = agrmnt.Id;
        	rrObject.SubGroup__c = CON_OWF.RES_REQ_TYPE_GLOBAL_ANALYTICS;
        	List<string> selectedCountryList = new List<string>();
        	selectedCountryList.add('Australia');
        	selectedCountryList.add('Belgium');
        CNT_OWF_CreateReourseRequest.saveResourceRequest(rrObject,selectedCountryList,false,2);  
        test.stopTest();
        List<pse__Resource_Request__c> resourceRequestList = [Select id from pse__Resource_Request__c limit 10];
        system.assertNotEquals(0, resourceRequestList.size(), 'Resource Request Created');

    }
    
    @isTest
    static void testSaveResourceRequestForGlobal() 
	{
		test.startTest();
			Bid_History__c agrmnt = [SELECT Id FROM Bid_History__c LIMIT 1];
			pse__Resource_Request__c rrObject=new pse__Resource_Request__c();
        	rrObject.Bid_History__c = agrmnt.Id;
        	rrObject.SubGroup__c = CON_OWF.RES_REQ_TYPE_GLOBAL_ANALYTICS;
        	List<string> selectedCountryList = new List<string>();
        	selectedCountryList.add('Australia');
        	selectedCountryList.add('Belgium');
        try{
            CNT_OWF_CreateReourseRequest.saveResourceRequest(rrObject,selectedCountryList,true,2);  
        }
        catch(Exception e){
            System.assert(e.getMessage().contains('exception'), e.getMessage());
        }
        
        test.stopTest();
        List<pse__Resource_Request__c> resourceRequestList = [Select id from pse__Resource_Request__c limit 10];
        system.assertNotEquals(0, resourceRequestList.size(), 'Resource Request Created');

    }
    
    @isTest
    static void testSaveResourceRequestForAll() 
    {
        test.startTest();
        Bid_History__c agrmnt = [SELECT Id FROM Bid_History__c LIMIT 1];
        pse__Resource_Request__c rrObject=new pse__Resource_Request__c();
        rrObject.Bid_History__c = agrmnt.Id;
        rrObject.SubGroup__c = CON_OWF.RES_REQ_TYPE_Clinical_Coding;
        List<string> selectedCountryList = new List<string>();
        selectedCountryList.add('Australia');
        selectedCountryList.add('Belgium');
        CNT_OWF_CreateReourseRequest.saveResourceRequest(rrObject,selectedCountryList,false,2);        
        test.stopTest();
        List<pse__Resource_Request__c> resourceRequestList = [Select id from pse__Resource_Request__c limit 10];
        
        
    }
    
    @isTest
    static void testgetSubgroup()
    {
        test.startTest();
       	Map<String,String> subgroupList = CNT_OWF_CreateReourseRequest.getSubgroup();
       	test.stopTest();
        System.assertNotEquals(null, subgroupList, 'Verifying getRecordRype Functionality');
    }
    
    @isTest    
    static void testGetPiklistValues()
    {
        test.startTest();
        List<String> regionalList = CNT_OWF_CreateReourseRequest.getPiklistValues();
       	test.stopTest();
        System.assertNotEquals(null, regionalList, 'Verifying getRecordRype Functionality');
    }
    
    @isTest
    static void testgetRecordType()
    {
        test.startTest();
        pse__Resource_Request__c rr = CNT_OWF_CreateReourseRequest.getRecordType();
       	test.stopTest();
        System.assertNotEquals(null, rr, 'Verifying getRecordRype Functionality');
    }
    
    @isTest
    static void testGetResourceRequestTypesForMultipleRR()
    {
        Test.startTest();
        List<String> resourceRequestTypesList = CNT_OWF_CreateReourseRequest.getResourceRequestTypesForMultipleRR();
        Test.stopTest();
        System.assertNotEquals(0, resourceRequestTypesList.size(), 'Resource Request types');
    }
    
    @isTest
    static void testSaveMultipleAnalyticsRequests()
    {
        test.startTest();
			Bid_History__c agrmnt = [SELECT Id FROM Bid_History__c LIMIT 1];
			pse__Resource_Request__c rrObject=new pse__Resource_Request__c();
        	rrObject.Bid_History__c = agrmnt.Id;
        	rrObject.SubGroup__c = CON_OWF.RES_REQ_TYPE_TSL;
        CNT_OWF_CreateReourseRequest.saveMultipleAnalyticsRequests(new List<pse__Resource_Request__c>{rrObject});
        test.stopTest();
        List<pse__Resource_Request__c> resourceRequestList = [Select id from pse__Resource_Request__c limit 10];
        system.assertNotEquals(0, resourceRequestList.size(), 'Resource Request Created');
    }

}
