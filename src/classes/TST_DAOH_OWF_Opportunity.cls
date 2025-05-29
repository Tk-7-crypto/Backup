/**
* This test class is used to test methods in opportunity trigger.
* version : 1.0
*/
@isTest(seeAllData=false)
public class TST_DAOH_OWF_Opportunity {
    
    /**
    * This method is used to setup data for all methods.
    */
    @testSetup
    static void dataSetup() 
	{
        upsert new  Mulesoft_Integration_Control__c(Enable_OLIS_JSON__c = true, Is_Mulesoft_User__c = true, Enable_OLI_Sync_Validation__c = true, Enable_Opportunity_Sync_Validation__c = true);
        Account acc = UTL_OWF_TestData.createAccount();
        insert acc;
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        List<User> userList = UTL_TestData.createUser('System Administrator', 2);
        userList[0].FirstName = 'Test1';
        userList[0].PIC_Eligible__c = true;
        userList[0].SUBREGION__c = 'United States of America';
        userList[0].IsActive = true;
        userList[1].FirstName = 'Test2';
        userList[1].PIC_Eligible__c = true;
        userList[1].SUBREGION__c = 'United States of America';
        userList[1].IsActive = true;
        insert userList;
        OWF_Config__c owfConfig = UTL_OWF_TestData.createOWFConfig(grp.Id);
        insert owfConfig;
        Contact cont = UTL_OWF_TestData.createContact(acc.Id);
        cont.pse__Is_Resource__c = true;
        cont.pse__Is_Resource_Active__c = true;
        cont.pse__Group__c = grp.Id;
        cont.RecordTypeId = CON_CRM.IQVIA_USER_CONTACT_RECORD_TYPE_ID;
        cont.pse__Salesforce_User__c = userList[0].id;
        cont.Salesforce_User__c = userList[0].id;
        test.startTest();
        insert cont;
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        Indication_List__c indication = UTL_OWF_TestData.createIndication('Test Indication', 'Acute Care');
        insert indication;
        Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
        opp.Potential_Regions__c = 'Japan';
        opp.Line_of_Business__c = 'Clinical';
        insert opp;
        Bid_History__c agreement = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        agreement.Requested_Services__c = CON_OWF.OWF_BID_HISTORY_REQUESTED_INTERNAL_SERVICES_CLINICAL_MONITORING;
        agreement.Pricing_Monitoring_Model__c = CON_OWF.OWF_BID_HISTORY_PRICING_MONITORING_MODEL_IQVIA_RBM;
        agreement.DTE_Study__c = CON_OWF.OWF_BID_HISTORY_DTE_STUDY_NO;
        insert agreement;
        test.stopTest();
    }
    
	
    /**
    * This test method used to test method setNoOfPotentialRegionsBasedOnPotentialRegions
    */
    @isTest
    static void testSetNoOfPotentialRegionsBasedOnPotentialRegions()
	{
        Opportunity opp = [SELECT id FROM Opportunity limit 1];
        opp.Potential_Regions__c = 'Asia Pacific';
        opp.Bid_Defense_Date__c = system.today().addDays(5);
        Test.startTest();
        update opp;
        Opportunity modifiedOpp = [Select Id, Number_of_Potential_Regions__c From Opportunity Where Id = :opp.Id];
        system.assertEquals(1, modifiedOpp.Number_of_Potential_Regions__c, 'Validating no of potential regions after inserting opportunity.');
        opp.Potential_Regions__c = 'Asia Pacific;Japan';
        update opp;
        modifiedOpp = [Select Id, Number_of_Potential_Regions__c From Opportunity Where Id = :opp.Id];
        system.assertEquals(2, modifiedOpp.Number_of_Potential_Regions__c, 'Validating no of potential regions after inserting opportunity.');
        opp.Potential_Regions__c = '';
        update opp;
        modifiedOpp = [Select Id, Number_of_Potential_Regions__c From Opportunity Where Id = :opp.Id];
        system.assertEquals(0, modifiedOpp.Number_of_Potential_Regions__c, 'Validating no of potential regions after inserting opportunity.');
        Test.stopTest();
    }
    
	
    /**
    * This test method used to delete Agreement Bases On Opportunity
    */ 
    @isTest
    static void testDeleteAgreementBasesOnOpportunity() 
	{   
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [SELECT id , Phase_P__c FROM Opportunity limit 1];
        opp.Potential_Regions__c = 'Asia Pacific';
        opp.Bid_Defense_Date__c = system.today().addDays(5);
        Test.startTest();
        update opp;
        Bid_History__c agreement = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        agreement.Bid_Due_Date__c = system.today().addDays(5);
        insert agreement;
        List<Opportunity> oppList = [SELECT Id FROM Opportunity limit 100];
        delete oppList;
        Test.stopTest();
     
        List<Opportunity> opptyList = [Select Id From Opportunity limit 100];
        Integer expected = 0;
        System.assertEquals(expected, opptyList.size(), 'Verifying DeleteAgreementBasesOnOpportunity Functionality');
    }
    
	@isTest
    static void testCreateClinicalBidResRequestsOnOppUpdate() 
	{   
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [SELECT id FROM Opportunity limit 1];
        opp.Potential_Regions__c = 'Asia Pacific';
        opp.Bid_Defense_Date__c = system.today().addDays(5);
        update opp;
        Bid_History__c agreement = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        agreement.Bid_Due_Date__c = system.today().addDays(5);
        Test.startTest();
        insert agreement;
        pse__Proj__c bidProject = [Select id from pse__Proj__c where Bid_History__c =: agreement.Id];
        pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(agreement.Id, opp.Id, bidProject.Id);
        insert resourceRequest;
        opp.QI_Invited_to_Present__c = 'Not Sure';
        update opp;
        Test.stopTest();
		
        pse__Resource_Request__c rr = [select Id, Name from pse__Resource_Request__c limit 1];
        system.assertNotEquals(null, rr, 'Verifying createClinicalBidResRequestsOnOppUpdate Functionality');	
    }
	
    @isTest     
    static void testupdatebiotech()
	{   
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [SELECT id , Phase_P__c FROM Opportunity limit 1];
        opp.Potential_Regions__c = 'Asia Pacific';
        opp.Bid_Defense_Date__c = system.today().addDays(5);
        update opp;
        Bid_History__c agreement = UTL_OWF_TestData.createBidHistory(acc.Id, opp.Id);
        agreement.RecordTypeId = CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID;
        agreement.Bid_Due_Date__c = system.today().addDays(5);
        agreement.IQVIA_biotech__c = 'Yes';
        Test.startTest();
        insert agreement;
        opp.Is_this_IQVIA_Biotech__c = 'No';
        Update opp;
        Test.stopTest();
        
		String expected = 'No';
		Bid_History__c agr = [Select Id, Name, IQVIA_biotech__c from Bid_History__c limit 1];
		String actual = agr.IQVIA_biotech__c;
		system.assertEquals(expected, actual, 'Verifying updatebiotech Functionality');
    }
    
    @isTest
    static void testupdateComplexityScoreTotalOnRR()
	{   
        User u = [Select Id, SUBREGION__c from User where IsActive = true limit 1];
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [SELECT id FROM Opportunity limit 1];
        opp.Potential_Regions__c = 'Asia Pacific';
        opp.Bid_Defense_Date__c = system.today().addDays(5);
        opp.Owner = u;					 
        update opp;
        Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistory(acc.Id, opp.Id);
        bidHistory.RecordTypeId = CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID;
        bidHistory.Bid_Due_Date__c = system.today().addDays(5);
        Test.startTest();
        insert bidHistory;
        pse__Proj__c bidProject = [Select id from pse__Proj__c where Bid_History__C =: bidHistory.Id];
        pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(bidHistory.Id, opp.Id, bidProject.Id);
        resourceRequest.RecordTypeId = CON_OWF.OWF_RR_RECORD_TYPE_ID;
        resourceRequest.Bid_History__c = bidHistory.Id;
        insert resourceRequest;
        opp.Potential_Regions__c = 'Latin America;Asia Pacific';
        update opp;
        Test.stopTest();
        	
		pse__Resource_Request__c rr = [Select Id, Name, Complexity_Score_Total__c from pse__Resource_Request__c limit 1];
		Decimal actual = rr.Complexity_Score_Total__c;
		system.assertNotEquals(null, actual, 'Verifying updateComplexityScoreTotalOnRR Functionality');	
    }
    
    @isTest
    static void testcreateClinicalBidResourceRequestsOnPhaseUpdate() 
	{
        Opportunity opp = [SELECT id , Phase_P__c FROM Opportunity limit 1];
        Test.startTest();
            opp.Phase_P__c = 'Phase 2';
            update opp;
        Test.stopTest();
		
        system.assert([Select id from pse__Resource_Request__c limit 10].size() > 0, 'Verifying createClinicalBidResourceRequestsOnPhaseUpdate Functionality');
    }
    @isTest
    static void testUpdateOCTRFxBid(){
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Competitor__c comp = UTL_TestData.createCompetitor();
        insert comp;
       	Opportunity opp=[select id,StageName from Opportunity limit 1];
        Contact cnt = [SELECT id,Salesforce_User__c,Salesforce_User__r.PIC_Eligible__c,RecordType.Name FROM Contact WHERE LastName = 'TestContact'];
        OpportunityContactRole contactRole = UTL_TestData.createOpportunityContactRole(cnt.Id, opp.Id);
        insert contactRole;
        Product2 product = UTL_TestData.createProduct();
        product.Material_Type__c = 'ZREP';
        product.Hierarchy_Level__c = 'Material';
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, pbEntry.Id);
        insert oppLineItem;
        opp.Principle_inCharge__c = cnt.Id;
        opp.Potential_Competitor_1__c = comp.Id;
        opp.Global_Project_Unit__c = CON_CRM.GPU_RADDS;													   
        opp.stageName= CON_CRM.DEVELOPING_PROP_STAGE;
        opp.US_government_fully_or_partially_funded__c= 'No';
        update opp;
        Bid_History__c agreement = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CONTRACT_POST_AWARD_BID_HISTORY_RECORD_TYPE_ID);
        agreement.Requested_Services__c = CON_OWF.OWF_BID_HISTORY_REQUESTED_INTERNAL_SERVICES_CLINICAL_MONITORING;
        agreement.Pricing_Monitoring_Model__c = CON_OWF.OWF_BID_HISTORY_PRICING_MONITORING_MODEL_IQVIA_RBM;
        agreement.DTE_Study__c = CON_OWF.OWF_BID_HISTORY_DTE_STUDY_NO;

        insert agreement;
        test.startTest();
        	opp.Global_Project_Unit__c = CON_CRM.GPU_AA_excluding_Japan;
        	update opp;
        test.stopTest();
        Bid_History__c agreement1 =[Select id,Bid_Sent_Date__c,Global_Project_Unit__c from Bid_History__c where RecordTypeId =: CON_OWF.OWF_CONTRACT_POST_AWARD_BID_HISTORY_RECORD_TYPE_ID];
        System.assertEquals(CON_CRM.GPU_AA_excluding_Japan, agreement1.Global_Project_Unit__c, 'Verifying updateOCTRFxBid Functionality');
        
    }
      @isTest
    static void testUpdateOCTRFxBioScienceBid(){
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Competitor__c comp = UTL_TestData.createCompetitor();
        insert comp;
       	Opportunity opp=[select id,Line_of_Business__c ,Q2_Budget_Tool__c from Opportunity limit 1];
        opp.Line_of_Business__c = 'Q2 Solutions';
        update opp;
        Contact cnt = [SELECT id,Salesforce_User__c,Salesforce_User__r.PIC_Eligible__c,RecordType.Name FROM Contact WHERE LastName = 'TestContact'];
        Bid_History__c agreement = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
        agreement.Requested_Services__c = CON_OWF.OWF_BID_HISTORY_REQUESTED_INTERNAL_SERVICES_CLINICAL_MONITORING;
        agreement.Pricing_Monitoring_Model__c = CON_OWF.OWF_BID_HISTORY_PRICING_MONITORING_MODEL_IQVIA_RBM;
        agreement.DTE_Study__c = CON_OWF.OWF_BID_HISTORY_DTE_STUDY_NO;
        agreement.Q2_Business_Area__c = CON_OWF.Q2_BUSINESS_AREA_BIOSCIENCE;
        insert agreement;
        test.startTest();
        	opp.Q2_Budget_Tool__c = 'BioFortis' ;
        	update opp;
        test.stopTest();
        Bid_History__c agreement1 =[Select id,Bid_Sent_Date__c,Q2_Budget_Tools__c from Bid_History__c where RecordTypeId =: CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID];
        System.assertEquals('BioFortis', agreement1.Q2_Budget_Tools__c, 'Verifying updateOCTRFxBioScienceBid Functionality');
        
    }
    @isTest
    static void testUpdateOCTRFxVaccinesBid(){
        Account acc = [SELECT Id, Name FROM Account WHERE Name = 'TestAccount'];
        Opportunity opp = [SELECT id,Line_of_Business__c ,Q2_Budget_Tool__c FROM Opportunity limit 1]; 
        opp.Line_of_Business__c = 'Q2 Solutions';
        update opp;
        Bid_History__c agreement = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID);
        agreement.Q2_Business_Area__c = CON_OWF.Q2_BUSINESS_AREA_VACCINES;
        insert agreement;
        test.startTest();
           opp.Q2_Budget_Tool__c = 'Vaccines' ;
           opp.Advanced_Plan__c = 'testPlan';
           update opp;
        test.stopTest();
        Bid_History__c bids = [SELECT id,Q2_Budget_Tools__c,Advance_Plan__c FROM Bid_History__c WHERE Q2_Business_Area__c =: CON_OWF.Q2_BUSINESS_AREA_VACCINES and RecordTypeId =: CON_OWF.OWF_Q2_Solutions_BID_HISTORY_RECORD_TYPE_ID];
        System.assertEquals('Vaccines', bids.Q2_Budget_Tools__c, 'Verifying updateOCTRFxBid Functionality');
        System.assertEquals('testPlan', bids.Advance_Plan__c, 'Verifying updateOCTRFxBid Functionality');

        
    }
    
    
}