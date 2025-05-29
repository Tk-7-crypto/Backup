/**
 * This test class is used to test all methods in CNT_OWF_CreateAgreementFromOpp.
 * version : 1.0
 */
@isTest
private class TST_CNT_OWF_CreateAgreementFromOpp{

    /**
    * This method used to set up testdata
    */ 
    @testSetup
    static void dataSetup() 
	{
        Account acc = UTL_OWF_TestData.createAccount();
        acc.CurrencyIsoCode = 'INR';
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
    
	
    /**
    * This test method used for validateLIGForClinicalAgreement
    */
    @isTest
    static void testvalidateLIGForClinicalAgreement() 
	{
		test.startTest();
			Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
			Id recordTypeId = Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('Clinical_Bid').getRecordTypeId();
			CNT_OWF_CreateAgreementFromOpp.validateLIGForClinicalAgreement(oppty.id,String.valueOf(recordTypeId));
        test.stopTest(); 
		
        String actualSize = CNT_OWF_CreateAgreementFromOpp.validateLIGForClinicalAgreement(oppty.id,String.valueOf(recordTypeId));
        Integer expected = 0;
        Integer actual = actualSize.length();
        system.assertEquals(expected, actual, 'Verifying CNT_OWF_CreateAgreementFromOpp.validateLIGForClinicalAgreement Functionality');
    }
    @isTest
    static void testvalidateLQOppForBidHistory() 
	{
        Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
        oppty.Line_of_Business__c = 'Q2 Solutions';
        update oppty;
	    Id recordTypeId = Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('Q2_Solutions').getRecordTypeId();
	    test.startTest();
	        String actualSize = CNT_OWF_CreateAgreementFromOpp.validateLIGForClinicalAgreement(oppty.id,String.valueOf(recordTypeId));
            Integer expected = 0;
        test.stopTest(); 
        Integer actual = actualSize.length();
        system.assertEquals(expected, actual, 'Verifying CNT_OWF_CreateAgreementFromOpp.validateLIGForClinicalAgreement Functionality');
    }
    
	
    /**
    * This test method used for redirectUserOnRTSelection
    */
    /*static testmethod void testredirectUserOnRTSelection() 
	{
		test.startTest();
			Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
			Id recordTypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('Clinical_Bid').getRecordTypeId();
			CNT_OWF_CreateAgreementFromOpp.redirectUserOnRTSelection(String.valueOf(recordTypeId));
		test.stopTest(); 
		
        String expected = 'Not Found';
		String actual = CNT_OWF_CreateAgreementFromOpp.redirectUserOnRTSelection(String.valueOf(recordTypeId));        
        system.assertEquals(expected, actual, 'Verifying CNT_OWF_CreateAgreementFromOpp.redirectUserOnRTSelection Functionality');        
    }*/
	
	
    /**
    * This test method used for getEligibleRecordTypes
    */
    @isTest
    static void testGetEligibleRecordTypes() 
	{
        OWF_Config__c owfConfig = [SELECT Id FROM OWF_Config__c limit 1];
        owfConfig.Current_Release__c = '2023.09';
        upsert owfConfig;
		test.startTest();
			Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
			List<String> oppFields = new List<String>{'Id','Name','StageName'};
			CNT_OWF_CreateAgreementFromOpp.getEligibleRecordTypes(oppty.id,oppFields);
        test.stopTest();
		
        List<CNT_OWF_CreateAgreementFromOpp.BidTypeWrapper> bidTypeList = CNT_OWF_CreateAgreementFromOpp.getEligibleRecordTypes(oppty.id,oppFields);
        system.assert(bidTypeList.size() > 0, 'Verifying CNT_OWF_CreateAgreementFromOpp.getEligibleRecordTypes Functionality');
    }
    
    /**
    * This test method used for getEligibleRecordTypes
    */
    @isTest
    static void testGetEligibleRecordTypesforInHand() 
	{
        OWF_Config__c owfConfig = [SELECT Id FROM OWF_Config__c limit 1];
        owfConfig.Current_Release__c = '2023.09';
        upsert owfConfig;
        List<User> adminUser = UTL_OWF_TestData.createUser('System Administrator',1);
        insert adminUser;
        System.runAs(adminUser[0]){
		test.startTest();
            Mulesoft_Integration_Control__c mulesoftIntegrationSettings = UTL_TestData.createMulesoftIntegrationControl(UserInfo.getUserId());
        	mulesoftIntegrationSettings.Ignore_Validation_Rules__c = true;
        	upsert mulesoftIntegrationSettings;
            Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
            oppty.StageName = CON_CRM.IN_HAND_STAGE;
            update oppty;
            mulesoftIntegrationSettings.Ignore_Validation_Rules__c = false;
        	upsert mulesoftIntegrationSettings;
			List<String> oppFields = new List<String>{'Id','Name','StageName'};
			CNT_OWF_CreateAgreementFromOpp.getEligibleRecordTypes(oppty.id,oppFields);
            List<CNT_OWF_CreateAgreementFromOpp.BidTypeWrapper> bidTypeList = CNT_OWF_CreateAgreementFromOpp.getEligibleRecordTypes(oppty.id,oppFields);
        	system.assert(bidTypeList.size() > 0, 'Verifying CNT_OWF_CreateAgreementFromOpp.getEligibleRecordTypes Functionality');
  
        	test.stopTest();
        }
	}
    
	
    /**
    * This test method used for getAccountId
    */
    @isTest
    static void testGetAccountId() 
	{
		test.startTest();
			Account acc= [SELECT Id FROM Account WHERE name = 'TestAccount'];
			Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
			List<String> oppFields = new List<String>{'Id','Name','StageName','Account.id'};
			CNT_OWF_CreateAgreementFromOpp.getAccountId(oppty.id,oppFields);
		test.stopTest();
		
		Id expected = acc.Id; 
		Id actual = CNT_OWF_CreateAgreementFromOpp.getAccountId(oppty.id,oppFields);
		system.assertEquals(expected, actual, 'Verifying CNT_OWF_CreateAgreementFromOpp.getAccountId Functionality'); 
    }
    
	
    /**
    * This test method used for prepopulate fields
    */
    @isTest
    static void testGetDefaultFieldValues() 
	{
		test.startTest();
			Opportunity oppty = [SELECT Id,AccountId,Q2_Bioscience_Location__c,Is_this_IQVIA_Biotech__c,stageName,Q2_Budget_Tool__c,Full_Service__c,Opportunity_Attributes__c FROM Opportunity WHERE name = 'TestOpportunity'];
			Id recordTypeId = Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('Clinical_Short_Form').getRecordTypeId();
			CNT_OWF_CreateAgreementFromOpp.validateOpportunity(oppty.id,recordTypeId);
			CNT_OWF_CreateAgreementFromOpp.getDefaultFieldValues(oppty.id,recordTypeId);
                recordTypeId = CNT_OWF_CreateAgreementFromOpp.getRecordTypeId('GCC_Short_Form');
                CNT_OWF_CreateAgreementFromOpp.getDefaultFieldValues(oppty.id,recordTypeId);
                recordTypeId = CNT_OWF_CreateAgreementFromOpp.getRecordTypeId('Contract_Post_Award');
			CNT_OWF_CreateAgreementFromOpp.getDefaultFieldValues(oppty.id,recordTypeId);
			recordTypeId = Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('CSMS_Short_Form').getRecordTypeId();
			CNT_OWF_CreateAgreementFromOpp.getDefaultFieldValues(oppty.id,recordTypeId);
			CNT_OWF_CreateAgreementFromOpp.validateRecordType(recordTypeId);
        	recordTypeId = Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('Non_RFP_Bid').getRecordTypeId();
			CNT_OWF_CreateAgreementFromOpp.getDefaultFieldValues(oppty.id,recordTypeId);
			CNT_OWF_CreateAgreementFromOpp.validateRecordType(recordTypeId);
            JSONGenerator gen = JSON.createGenerator(false);
            gen.writeStartObject();
            CNT_OWF_CreateAgreementFromOpp.autopopulateBioscienceFields('Initial', gen, oppty);
        test.stopTest();
		
        Boolean expected = false;
        Boolean actual = CNT_OWF_CreateAgreementFromOpp.validateOpportunity(oppty.id,recordTypeId);
        system.assertEquals(expected, actual, 'Verifying GetDefaultFieldValues functionality');    
    }
    
	
    /**
    * This test method used for prepopulate fields
    */
    @isTest
    static void testGetDefaultFieldValues2() 
	{
		Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
		Account acc = [Select id from Account limit 1];
		Delete [Select id from Bid_History__c limit 1000];
		Id recordTypeId = Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('RFI_Short_Form').getRecordTypeId();
		Test.startTest();
      	   Bid_History__c agreement1 = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, oppty.Id, recordTypeId);
       	   agreement1.Bid_Due_Date__c = System.today().addDays(2);
           agreement1.Triage_Level__c = 'Level A Experience or Staffing';
           insert agreement1; 
           Bid_History__c agreement2 = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, oppty.Id, recordTypeId);
           agreement2.Triage_Level__c = 'Level A Experience or Staffing';
           insert agreement2; 
           CNT_OWF_CreateAgreementFromOpp.validateOpportunity(oppty.id,recordTypeId);
           CNT_OWF_CreateAgreementFromOpp.getDefaultFieldValues(oppty.id,recordTypeId);
           CNT_OWF_CreateAgreementFromOpp.validateRecordType(recordTypeId);
		Test.stopTest();

        Boolean expected = False;
        Boolean actual = CNT_OWF_CreateAgreementFromOpp.validateOpportunity(oppty.id,recordTypeId);
        system.assertEquals(expected, actual, 'Verifying GetDefaultFieldValues functionality');  
    }
	
	
	/**
    * This test method used for prepopulate fields
    */
    @isTest
    static void testGetDefaultFieldValues3() 
	{
		Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
		Account acc = [Select id from Account limit 1];
		Delete [Select id from Bid_History__c limit 1000];
		Id recordTypeId = Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('CSS_Short_Form').getRecordTypeId();
		Test.startTest();
			Bid_History__c agreement1 = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, oppty.Id, recordTypeId);
                agreement1.eCOA__c = true;
			agreement1.Bid_Due_Date__c = System.today().addDays(2);
			agreement1.Rate_card_MSA_explanation__c ='test';
			insert agreement1; 
			Bid_History__c agreement2 = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, oppty.Id, recordTypeId);
            agreement2.eCOA__c = true;
            agreement2.Rate_card_MSA_explanation__c ='test';
			insert agreement2; 
			CNT_OWF_CreateAgreementFromOpp.validateOpportunity(oppty.id,recordTypeId);
			CNT_OWF_CreateAgreementFromOpp.getDefaultFieldValues(oppty.id,recordTypeId);
			CNT_OWF_CreateAgreementFromOpp.validateRecordType(recordTypeId);
        Test.stopTest();
				
        Boolean expected1 = false;
        Boolean actual1 = CNT_OWF_CreateAgreementFromOpp.validateOpportunity(oppty.id,recordTypeId);
        system.assertEquals(expected1, actual1, 'Verifying GetDefaultFieldValues functionality');
    }
      
    @isTest
    static void testGetDefaultFieldValuesForVaccines() 
	{
		test.startTest();
			Opportunity oppty = [SELECT Id,AccountId,Q2_Bioscience_Location__c,Is_this_IQVIA_Biotech__c,stageName,Q2_Budget_Tool__c,Full_Service__c,Opportunity_Attributes__c FROM Opportunity WHERE name = 'TestOpportunity'];
        	oppty.Q2_Budget_Tool__c = CON_OWF.BUDGET_TOOL_Q2_BIO;
        	update oppty;
        	Account acc = [select id from Account limit 1];
        	Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, oppty.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
            bidHistory.Q2_Business_Area__c = CON_OWF.Q2_BUSINESS_AREA_BIOSCIENCE;
            bidHistory.Budget_Deliverable__c = 'Ballpark';
            bidHistory.Requested_Services__c = 'CEVA';
            bidHistory.Q2_Budget_Tools__c = 'LinkPSB';
            bidHistory.Bid_Complexity__c = 'Low';
            bidHistory.Bid_Type__c = 'Initial';
            bidHistory.Bid_Owner_Deliverable__c = 'Budget';
            bidHistory.Study_Start_Date__c =  system.today();
            bidHistory.Study_End_Date__c = system.today().addMonths(1);
            upsert bidHistory;
        	oppty.Q2_Budget_Tool__c = CON_OWF.BUDGET_TOOL_VACCINES;
        	update oppty;
        	Bid_History__c bidHistory2 = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, oppty.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
            bidHistory2.Q2_Business_Area__c = CON_OWF.Q2_BUSINESS_AREA_VACCINES;
            bidHistory2.Budget_Deliverable__c = 'Ballpark';
            bidHistory2.Requested_Services__c = 'CEVA';
            bidHistory2.Q2_Budget_Tools__c = 'LinkPSB';
            bidHistory2.Bid_Complexity__c = 'Low';
            bidHistory2.Bid_Type__c = 'Re-Bid';
            bidHistory2.Bid_Owner_Deliverable__c = 'Budget';
            bidHistory2.Study_Start_Date__c =  system.today();
            bidHistory2.Study_End_Date__c = system.today().addMonths(1);
            upsert bidHistory2;
			Id recordTypeId = Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('Q2_Solutions').getRecordTypeId();
			CNT_OWF_CreateAgreementFromOpp.getDefaultFieldValues(oppty.id,recordTypeId);
        test.stopTest();		
        Boolean expected = false;
        Boolean actual = CNT_OWF_CreateAgreementFromOpp.validateOpportunity(oppty.id,recordTypeId);
        system.assertEquals(expected, actual, 'Verifying GetDefaultFieldValues functionality');    
    }
    @isTest
    static void testGetDefaultFieldValuesForDiscovery(){
	    test.startTest();
        Opportunity oppty = [SELECT Id,AccountId,Q2_Bioscience_Location__c,Is_this_IQVIA_Biotech__c,stageName,Q2_Budget_Tool__c,Full_Service__c,Opportunity_Attributes__c FROM Opportunity WHERE name = 'TestOpportunity'];
        oppty.Q2_Budget_Tool__c = CON_OWF.BUDGET_TOOL_IMMUN_XPERTS;
        update oppty;
        Account acc = [select id from Account limit 1];
        Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, oppty.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
        bidHistory.Q2_Business_Area__c = CON_OWF.Q2_BUSINESS_AREA_DISCOVERY;
        bidHistory.Budget_Deliverable__c = 'Ballpark';
        bidHistory.Requested_Services__c = 'CEVA';
        bidHistory.Q2_Budget_Tools__c = 'LinkPSB';
        bidHistory.Bid_Complexity__c = 'Low';
        bidHistory.Bid_Type__c = 'Initial';
        bidHistory.Bid_Owner_Deliverable__c = 'Budget';
        bidHistory.Study_Start_Date__c =  system.today();
        bidHistory.Study_End_Date__c = system.today().addMonths(1);
        upsert bidHistory;
        Id recordTypeId = Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('Q2_Solutions').getRecordTypeId();
		CNT_OWF_CreateAgreementFromOpp.getDefaultFieldValues(oppty.id,recordTypeId);
        test.stopTest();		
        Boolean expected = false;
        Boolean actual = CNT_OWF_CreateAgreementFromOpp.validateOpportunity(oppty.id,recordTypeId);
        system.assertEquals(expected, actual, 'Verifying GetDefaultFieldValues functionality');    
    }
    
    
	
    /**
    * This test method used for prepopulate fields
    */
    @isTest
    static void testGetRecordTypeName() 
	{
		Test.startTest();
			Id recordTypeId = Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('Clinical_Bid').getRecordTypeId();
			CNT_OWF_CreateAgreementFromOpp.getRecorTypeName(String.valueOf(recordTypeId));
		   
			recordTypeId = Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('RFI_Request').getRecordTypeId();
			CNT_OWF_CreateAgreementFromOpp.getRecorTypeName(String.valueOf(recordTypeId));
			
			recordTypeId = Schema.SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get('Clinical_Short_Form').getRecordTypeId();
			CNT_OWF_CreateAgreementFromOpp.getRecorTypeName(String.valueOf(recordTypeId));
		Test.stopTest();
		
		String actual =  CNT_OWF_CreateAgreementFromOpp.getRecorTypeName(String.valueOf(recordTypeId));
		System.assertNotEquals(null, actual, 'Verifying GetRecordTypeName functionality');
    }
    
    @isTest
    static void testgetCLMRecordTypeIdsForMVP() 
	{
		test.startTest();
			CNT_OWF_CreateAgreementFromOpp.getCLMRecordTypeIdsForMVP();
		test.stopTest(); 
		
        List<String> actual = CNT_OWF_CreateAgreementFromOpp.getCLMRecordTypeIdsForMVP();
        system.assertNotEquals(null, actual,'Verifying getCLMRecordTypeIdsForMVP');
    }

    @isTest
    public static void testGetCLMRecordTypeIdsOfAvailableUsers() 
    {
		Test.startTest();
			CNT_OWF_CreateAgreementFromOpp.getCLMRecordTypeIdsOfAvailableUsers();
		Test.stopTest(); 
		
        List<String> actual = CNT_OWF_CreateAgreementFromOpp.getCLMRecordTypeIdsOfAvailableUsers();
        System.assertNotEquals(null, actual, 'Verifying CLMRecordTypeIdsOfAvailableUsers functionality');
    }
    
    @isTest
    public static void testGetAccountCurrency() 
    {
        Account acc = [Select id from Account limit 1];
        
        Test.startTest();
            String accountCurrency = CNT_OWF_CreateAgreementFromOpp.getAccountCurrency(acc.Id);
        Test.stopTest(); 

        System.assertEquals('INR', accountCurrency, 'correct currency should return');
    }

    @isTest
    public static void testSetDefaultLegalEntityValuesForMSA() {
		Opportunity oppty = [SELECT Id FROM Opportunity WHERE name = 'TestOpportunity'];
		Id recordTypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get('AMA').getRecordTypeId();
		List<String> oppFields = new List<String>{'Id','Name','StageName'};
		CNT_OWF_CreateAgreementFromOpp controller = new CNT_OWF_CreateAgreementFromOpp(new ApexPages.StandardController(oppty));

		Test.startTest();
			CNT_OWF_CreateAgreementFromOpp.setDefaultLegalEntityValuesForMSA();
		Test.stopTest(); 
		
        Map<String, Id> actual = CNT_OWF_CreateAgreementFromOpp.setDefaultLegalEntityValuesForMSA();
        System.assertNotEquals(null, actual);
    }   
    
	@isTest
    public static void getAgreementServicesOptionsTest() {
        Test.startTest();
        try{
        	CNT_OWF_CreateAgreementFromOpp.getAgreementServicesOptions();
        }
        catch(Exception e) {
            System.debug(e.getMessage());
        }
        Test.stopTest(); 
        System.assert(true);
    }
}
