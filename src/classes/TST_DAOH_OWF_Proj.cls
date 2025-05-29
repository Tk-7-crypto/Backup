@isTest
private class TST_DAOH_OWF_Proj {

    /**
    * This method is used to setup data for all methods.
    */
    @testSetup
    static void dataSetup() 
	{
        Account acc = UTL_OWF_TestData.createAccount();
        insert acc;
        Account acc2 = UTL_OWF_TestData.createAccount();
        acc2.name='testingggg';
        insert acc2;
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;  
        pse__Grp__c grp1 = UTL_OWF_TestData.createGroup();
        grp1.Name = 'OWF TSL';
        insert grp1;
        Contact cont = UTL_OWF_TestData.createContact(acc.Id);
        cont.pse__Is_Resource__c = true;
        cont.pse__Is_Resource_Active__c = true;
        cont.pse__Group__c = grp1.Id;
        cont.sub_group__c = 'TSL-Japan';
        cont.available_for_triage_flag__c = true;
        cont.pse__Salesforce_User__c = UserInfo.getUserId();
        insert cont;
        OWF_Config__c owfConfig = UTL_OWF_TestData.setupOWFConfig(grp.Id);
        owfConfig.OWF_Compatible_Group_Set_1__c = 'OWF TSL';
        owfConfig.OWF_Compatible_Group_Set_2__c = 'OWF DSB-DM';
        insert owfConfig;
        Indication_List__c indication = UTL_OWF_TestData.createIndication('Test Indication', 'Acute Care');
        insert indication;     
        Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
        insert opp;
        Opportunity opp2 = UTL_OWF_TestData.createOpportunity(acc.Id);
        opp2.name ='test2244';
        insert opp2;
        List<pse__Skill__c> testSkills = new List<pse__Skill__c>();
        testSkills.add(UTL_OWF_TestData.createSkills('Australia', CON_OWF.SKILL_TYPE_GLOBAL_ANALYTICS_COUNTRY));
        testSkills.add(UTL_OWF_TestData.createSkills('Belgium', CON_OWF.SKILL_TYPE_GLOBAL_ANALYTICS_COUNTRY));
        insert testSkills;
        pse__Permission_Control__c grpPermissionControl = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert grpPermissionControl;
        List<OWF_Resources_Needed_to_SubGroup_Map__c> resourceToSubGroupSettingList = new List<OWF_Resources_Needed_to_SubGroup_Map__c>();
        resourceToSubGroupSettingList.add(new OWF_Resources_Needed_to_SubGroup_Map__c(
            Resources_Needed__c = 'MSL',
            Sub_Group__c = 'Medical-MSL',
            Name = 'MSL'
        ));
        resourceToSubGroupSettingList.add(new OWF_Resources_Needed_to_SubGroup_Map__c(
            Resources_Needed__c = 'Global Analytics',
            Sub_Group__c = 'Global Analytics',
            Name = 'Global Analytics'
        ));
        insert resourceToSubGroupSettingList;
    }
    
	
    /**
    * This test method used for Creating RR Based On Agreement Associated With Project
    */
    @isTest
    static void testCreateRRBasedOnAgrAssociatedWithProj()
	{
        Account account = [Select Id From Account Where Name = 'TestAccount'];
        Opportunity oppty = [Select Id From Opportunity Where Name = 'TestOpportunity'];
        List<pse__Skill__c> skillList = new List<pse__Skill__c>();
        pse__Skill__c skill = UTL_OWF_TestData.createSkills('Strategic Analytics', 'Global Analytics Country');
        skillList.add(skill);
        insert skillList;
        Bid_History__c agreement = UTL_OWF_TestData.createBidHistory(account.Id, oppty.Id);
        agreement.Resources_Needed__c = 'Global Analytics';
        agreement.Regional_Analytics_Country__c='Strategic Analytics';
        agreement.Bid_Due_Date__c = Date.today().addDays(7);
        agreement.recordTypeId = Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('Early_Engagement_Bid').getRecordTypeId();
        agreement.Type_of_Engagement_Activity__c = 'Client Meeting Support';
        Test.startTest();
            insert agreement;
        Test.stopTest();
		
        system.assert([Select id from pse__Resource_Request__c limit 10].size() > 0, 'Verifying CreateRRBasedOnAgrAssociatedWithProj Functionality');
    }
    
	
    /**
    * This test method used for Deleting Resource Request Based On Project
    */
    @isTest
    static void testDeleteResourceRequestBasedOnProject()
	{
        Account account = [Select Id From Account Where Name = 'TestAccount'];
        Opportunity oppty = [Select Id From Opportunity Where Name = 'TestOpportunity'];
        Bid_History__c agreement = UTL_OWF_TestData.createBidHistory(account.Id, oppty.Id);
        agreement.Resources_Needed__c = 'MSL';
        agreement.Bid_Due_Date__c = Date.today().addDays(7);
        agreement.recordTypeId = Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('Early_Engagement_Bid').getRecordTypeId();
        agreement.Type_of_Engagement_Activity__c = 'Client Meeting Support';
		insert agreement;
        Map<Id,pse__Proj__c> bidProject = new Map<Id,pse__Proj__c>([Select Id From pse__Proj__c Where Bid_History__c = :agreement.Id]);
        Test.startTest();
            delete bidProject.values();
        Test.stopTest();
        
        List<pse__Resource_Request__c> rrList = [Select Id From pse__Resource_Request__c Where pse__Project__c = :bidProject.KeySet()];
        Integer expected = 0;
        System.assertEquals(expected, rrList.size(), 'Verifying DeleteResourceRequestBasedOnProject Functionality');
    }
    
	
    /**
    * This test method used for Creating RR Based On Agreement Associated With Project
    */
    @isTest
    static void testCreateRRBasedOnRFIAgrAssociatedWithProj()
	{
        Account account = [Select Id From Account Where Name = 'TestAccount'];
        Opportunity oppty = [Select Id From Opportunity Where Name = 'TestOpportunity'];    
        Bid_History__c agreement = UTL_OWF_TestData.createBidHistory(account.Id, oppty.Id);
        agreement.Resources_Needed__c = 'MSL';
        agreement.Bid_Due_Date__c = Date.today().addDays(7);
        agreement.recordTypeId = CON_OWF.OWF_RFI_BID_HISTORY_RECORD_TYPE_ID;
        agreement.Triage_Level__c = 'Level A Experience or Staffing';
        Test.startTest();
            insert agreement;
        Test.stopTest();
        
		system.assert([Select id from pse__Resource_Request__c limit 10].size() > 0, 'Verifying CreateRRBasedOnRFIAgrAssociatedWithProj Functionality');
    }
    
	
    /**
     * This test method used to validate created Resource Request based on project inserted
     */
    @isTest
    static void testCreateClinicalBidRRsBasedOnBidNoOfProjects_Scenario1() 
	{
        Account account = [Select Id From Account Where Name = 'TestAccount'];
        Opportunity oppty = [Select Id From Opportunity Where Name = 'TestOpportunity'];
            oppty.Potential_Regions__c = 'Asia Pacific';
            oppty.Line_of_Business__c = 'Clinical';
            update oppty;
            Test.startTest();
            Bid_History__c agreement = UTL_OWF_TestData.createBidHistoryByRecordType(account.Id, oppty.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
            agreement.Resources_Needed__c = 'MSL';
            agreement.Bid_Due_Date__c = Date.today().addDays(7);
            insert agreement;
            
			List<pse__Resource_Request__c> resReqsList = [Select Id, SubGroup__c From pse__Resource_Request__c Where Bid_History__c = :agreement.Id and SubGroup__c = 'GBO-Lead PD'];
        	System.assertEquals(1, resReqsList.size(), 'Verifying CreateClinicalBidRRsBasedOnBidNoOfProjects Functionality');
                
            Bid_History__c agreement1 = UTL_OWF_TestData.createBidHistoryByRecordType(account.Id, oppty.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
            agreement1.Resources_Needed__c = 'MSL';
            agreement1.Bid_Due_Date__c = Date.today().addDays(5);
            insert agreement1;
            
			resReqsList = [Select Id, SubGroup__c From pse__Resource_Request__c Where Bid_History__c = :agreement1.Id];
            System.assertNotEquals(Null, resReqsList.size(), 'Verifying CreateClinicalBidRRsBasedOnBidNoOfProjects Functionality');
        Test.stopTest();
    }
    @isTest
    static void testCreateRRForContractPostAwardBids(){
        Account account = [Select Id From Account Where Name = 'TestAccount'];
        Opportunity oppty = [Select Id From Opportunity Where Name = 'TestOpportunity'];
        Test.startTest();
            oppty.Line_of_Business__c = 'Clinical';
        	oppty.Is_this_a_Virtual_Trials_Study__c = 'Yes Fully Hybrid';
        	oppty.Is_this_IQVIA_Biotech__c = 'No';
            update oppty;
            Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(account.Id, oppty.Id, CON_OWF.OWF_CONTRACT_POST_AWARD_BID_HISTORY_RECORD_TYPE_ID);
            bidHistory.Bid_Due_Date__c = Date.today().addDays(7);
        	bidHistory.Requested_Services__c = 'IQB Safety Processing;Pharmacovigilance LifeCycle Safety;CEVA;IQB Ongoing DM';
            insert bidHistory;
			List<pse__Resource_Request__c> resReqsList = [Select Id, SubGroup__c From pse__Resource_Request__c Where Bid_History__c = :bidHistory.Id and SubGroup__c = 'DSB-Clinical Post'];
        Test.stopTest();
        System.assertEquals(0, resReqsList.size(), 'Success');
    }


	@isTest
    static void testCreateRRForCSMSBids() {
        Account account = [SELECT Id FROM Account WHERE Name = 'testingggg'];
        Opportunity oppty = [SELECT Id FROM Opportunity WHERE Name = 'test2244']; 
        Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(account.Id, oppty.Id, CON_OWF.OWF_CSMS_Bid_RECORD_TYPE_ID);
        bidHistory.Bid_Number__c = 1;
        bidHistory.Bid_Due_Date__c = Date.today().addDays(7);
        insert bidHistory;
        List<pse__Proj__c> existingProjects = [SELECT Id FROM pse__Proj__c WHERE Bid_History__c = :bidHistory.Id];
        if (!existingProjects.isEmpty()) {
            delete existingProjects;
        }
        pse__Proj__c project= UTL_OWF_TestData.createBidProject([SELECT Id FROM pse__Grp__c LIMIT 1].Id);
        project.Name = 'Test Project1122';
        project.Bid_History__c = bidHistory.Id;
        project.pse__Opportunity__c = oppty.Id;
        project.pse__Account__c	 = account.id;
        project.Go_Live_Date__c	 = Date.today().addDays(7);
        insert project;
        List<pse__Proj__c> projectList = [
            SELECT Id, Bid_History__c, RecordTypeId FROM pse__Proj__c WHERE Id = :project.Id
        ];
        Test.startTest();
        pse__Resource_Request__c RR = UTL_OWF_TestData.createResourceRequest(bidHistory.id, oppty.Id,project.id);
        RR.recordTypeId = CON_OWF.OWF_RR_RECORD_TYPE_ID;
        RR.Bid_Category__c = CON_OWF.RFI_RR;
        RR.SubGroup__c = CON_OWF.CSMS_LEAD_PD;
        RR.pse__Start_Date__c = Date.Today();
        RR.pse__SOW_Hours__c = 0.01;
        RR.Is_Created_Automatically_Initial_Bid__c = true;
        RR.Is_Created_Automatically__c = true;
        insert RR;
        Test.stopTest();
        List<pse__Resource_Request__c> resourceRequests = [
            SELECT Id, SubGroup__c, Bid_Category__c
            FROM pse__Resource_Request__c
            WHERE Bid_History__c = :bidHistory.Id
        ];
        System.assertEquals(2, resourceRequests.size(), 'Success');
    }

}
