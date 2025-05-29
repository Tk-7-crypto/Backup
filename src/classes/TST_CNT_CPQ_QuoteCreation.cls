@IsTest
public class TST_CNT_CPQ_QuoteCreation {
    
    static Id iqviaTechnologiesRecordType = SObjectType.CollectionTool__c.getRecordTypeInfosByDeveloperName().get(CON_CPQ.IQVIA_TECHNOLOGIES_API).getRecordTypeId();
    static Id q2SolutionsRecordType = Schema.SObjectType.CollectionTool__c.getRecordTypeInfosByName().get(CON_CPQ.Q2_Solutions).getRecordTypeId();

	@TestSetup
    static void dataSetup() {
	    CPQ_Proposal_Create_Settings__c customSettingsObj = new CPQ_Proposal_Create_Settings__c();
        customSettingsObj.Name = 'DPS';
        customSettingsObj.Permission_Set_Name__c = 'CPQ_RDS_DPS_ReadWrite';
        customSettingsObj.Proposal_Record_Type_Name__c = CON_CPQ.TECH_SOLUTION;
        customSettingsObj.Price_List__c = 'DPS - USD';
        customSettingsObj.Available_Pricing_Tools__c = 'Complete Consent';
        customSettingsObj.Conga_Setup__c = true;
        insert customSettingsObj;

        CPQ_Settings__c cus1 =  new CPQ_Settings__c();
        cus1.Name =  'NameSpacePrefix';
        cus1.Package_Namespace_Prefix__c = 'Apttus_Config2;Apttus_Proposal;';
        insert cus1;
        
        Account acc = UTL_TestData.createAccount();
        acc.AccountCountry__c = 'AL';
        insert acc;
        
        Opportunity testOpportunity= UTL_TestData.createOpportunity(acc.id);
        testOpportunity.Line_of_Business__c = 'Clinical';
        testOpportunity.Is_this_IQVIA_Biotech__c = CON_CPQ.YES_TITLE_CASE;
        testOpportunity.CurrencyIsoCode = CON_CPQ.USD;
        testOpportunity.Legacy_Quintiles_Opportunity_Number__c = 'MVP123';
        testOpportunity.Potential_Regions__c = CON_CPQ.REGION_ASIA_PASIFIC;
        testOpportunity.Number_of_Potential_Regions__c = 0;
        testOpportunity.AccountId = acc.Id;
        testOpportunity.Account = acc;
        insert testOpportunity;
        
        Quote__c quote = new Quote__c();
        quote.Pricing_Tools__c = CON_CPQ.Complete_Consent;
        quote.GBU__c = CON_CPQ.GBU_DPS;
        quote.Related_Opportunity__c = testOpportunity.Id;
        quote.Related_Account__c = acc.Id;
        insert quote;

        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        
        OWF_Config__c owfConfig = UTL_OWF_TestData.createOWFConfig(grp.Id);
        insert owfConfig;
        
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        
        Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, testOpportunity.Id, CON_OWF.OWF_CSS_BID_BID_HISTORY_RECORD_TYPE_ID);
        bidHistory.Preferred_Training_Method__c = 'Site';
        bidHistory.Translations_Required__c = 'Yes';
        bidHistory.How_Many_Tablets_Site__c = 2;
        bidHistory.Institutional_Review_Board_allocation__c = 3;
        bidHistory.Number_of_ICF_Documents_Main_and_Short__c = 5;
        bidHistory.Study_Number__c = '01';
        bidHistory.Deployment_Mode__c = CON_CPQ.SAAS_MODEL;
        bidHistory.Rate_card_MSA_explanation__c = 'Testing Quote Field';
        bidHistory.Complete_Consent__c = true;
        insert bidHistory;

        Product2 prod = TST_TestGeneratorClass.buildTestProduct('SL-Discovery Metabolism', 'Bundle', 'Q_111813', 'US', 'Go Blue');
        prod.Apttus_Config2__HasOptions__c = true;
        prod.Apttus_Config2__HasAttributes__c = true;
        insert prod;
        
        List<CollectionTool__c> collectionToolRecords = new List<CollectionTool__c>();
        CollectionTool__c collectionToolRecord1 = new CollectionTool__c(LPI_Date__c = Date.today(), LPO_Date__c = Date.today(), FPI_Date__c = Date.today(), DBL_Date__c = Date.today(), Scenario_Number__c = 1, Countries__c = CON_CPQ.UNITED_STATES_OF_AMERICA, Number_of_Sites__c = 5, Bid_History__c = bidHistory.Id);
        collectionToolRecords.add(collectionToolRecord1);
        CollectionTool__c collectionToolRecord2 = new CollectionTool__c(Bid_History__c = bidHistory.Id, Number_of_Sites__c = 2, Countries__c = CON_CPQ.UNITED_STATES_OF_AMERICA, Scenario_Number__c = 1, Type__c = CON_CPQ.OTHER, RecordTypeId = iqviaTechnologiesRecordType);
        collectionToolRecords.add(collectionToolRecord2);
        CollectionTool__c collectionToolRecord3 = new CollectionTool__c(Bid_History__c = bidHistory.Id, Number_of_Sites__c = 3, Countries__c = CON_CPQ.UNITED_STATES_OF_AMERICA, Scenario_Number__c = 2, Type__c = CON_CPQ.OTHER, RecordTypeId = iqviaTechnologiesRecordType);
        collectionToolRecords.add(collectionToolRecord3);
        CollectionTool__c collectionToolRecord4 = new CollectionTool__c(ServiceLine__c = prod.Id, Number_of_Sites__c = 4, Countries__c = CON_CPQ.BRAZIL, Site_Global__c = CON_CPQ.INDIANAPOLIS_ADME, Study_Type_Global__c = CON_CPQ.METHOD_FEASIBILITY, Species_Global__c = CON_CPQ.BABOON, Biological_Matrix_Global__c = 'BI - Bile', Compound_Molecules__c = 'test 2', Study_Number__c = 2, Clinical_Type_Global__c = CON_CPQ.CLINICAL, Number_of_Analyte_Global__c = '1', Bid_History__c = bidHistory.Id, RecordTypeId = q2SolutionsRecordType, Type__c = CON_CPQ.COLLECTION_TOOL_TYPE_BIOSCIENCES);
        collectionToolRecords.add(collectionToolRecord4);
        insert collectionToolRecords;

        CPQ_Proposal_Create_Settings__c customSettingsObjforQ2 = UTL_TestData.createCPQProposalCreateSettings(CON_CPQ.Q2_Solutions, 'CPQ_RDS_Q2_Solutions_ReadWrite', CON_CPQ.Q2_Solutions , true, 'Q2 Solutions-USD', false);
        customSettingsObjforQ2.Identified_Business__c = 'BioSciences;Vaccines';
        customSettingsObjforQ2.Line_of_Business__c = CON_CPQ.Q2_Solutions;
        insert customSettingsObjforQ2;
    }
    
    @IsTest
    static void testGetRecordTypesPermissionSetAssignedToUser() {
        Id oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        Test.startTest();
            String str = CNT_CPQ_QuoteCreation.getDetails(oppId);
        Test.stopTest();
        Assert.isNotNull(str, 'result should not be null.');
    }
        
    @isTest
    static void testCreateQuote() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Test.startTest();
            String firstBudgetId = CNT_CPQ_QuoteCreation.createQuote(CON_CPQ.Complete_Consent, CON_CPQ.GBU_DPS,opp.Id, CON_CPQ.OPPORTUNITY,'1');
        Test.stopTest();
        Assert.isNotNull(firstBudgetId, 'Quote Id should not be null.');
    }
    @isTest
    static void testCreateQuoteFromOpp() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        opp.Line_of_Business__c = 'Clinical';
        Test.startTest();
            String firstBudgetId = CNT_CPQ_QuoteCreation.createRDSQuote(opp.Id, 'RDS Non-SF WRF', 'test', 'Central Lab Spreadsheet Calculator', 'CNF', 'WRF', 1, '');
        Test.stopTest();
        Assert.isNotNull(firstBudgetId, 'Quote Id should not be null.');
    }
    @isTest
    static void testCreateChangeOrderQuote() {
        Bid_History__c  bidHistory = [SELECT Id FROM Bid_History__c LIMIT 1];
        bidHistory.Bid_Type__c = CON_CPQ.CHANGE_ORDER;
        update bidHistory;
        Test.startTest();
        try {
            CNT_CPQ_QuoteCreation.createQuote(CON_CPQ.Q2_Solutions, CON_CPQ.GBU_RDS, bidHistory.Id, CON_CPQ.BID_HISTORY,'1');
        } catch (Exception e) {
            Assert.isNotNull(e.getMessage(), 'Quote should not be created for change order');
        }   
        Test.stopTest();
        
    }
    
    @isTest
    static void testCreateQuotebyBidHistory() {
        Bid_History__c  bidHistory = [SELECT Id FROM Bid_History__c LIMIT 1];
        Test.startTest();
            String firstBudgetId = CNT_CPQ_QuoteCreation.createQuote(CON_CPQ.Complete_Consent, CON_CPQ.GBU_DPS,bidHistory.Id, CON_CPQ.BID_HISTORY,'1');
        Test.stopTest();
        Assert.isNotNull(firstBudgetId, 'Quote Id should not be null.');
    }

    @isTest
    static void testnumberOfScenarioOnBidHistory() {
        Bid_History__c bidHistory = [SELECT Id FROM Bid_History__c LIMIT 1];
        List<CollectionTool__c> collectionToolRecords = [SELECT Id FROM CollectionTool__c WHERE RecordTypeId =: iqviaTechnologiesRecordType];
        Test.startTest();
            Double scenarioNumber = CNT_CPQ_QuoteCreation.getNumberOfScenario(bidHistory.Id);
        Test.stopTest();
        Assert.areEqual(collectionToolRecords.size(), scenarioNumber, 'Expected result size is not obtained.');
    }

    @isTest
    static void testCollectionToolRecords() {
        Bid_History__c bidHistory = [SELECT Id FROM Bid_History__c LIMIT 1];
        CollectionTool__c collectionToolRecord = [SELECT Id, Scenario_Number__c FROM CollectionTool__c WHERE RecordTypeId =: iqviaTechnologiesRecordType AND Scenario_Number__c = 1 LIMIT 1];
        Test.startTest();
            String getCollectionTool = CNT_CPQ_QuoteCreation.collectionToolRecordsErrorMessage(bidHistory.Id, double.valueof(collectionToolRecord.Scenario_Number__c));
        Test.stopTest();
        Assert.areEqual('\nDatabase Lock (DBL)\nFirst Patient In (FPI)\nLast Patient In (LPI)\nLast Patient Out (LPO)', getCollectionTool, 'Expected result is not obtained.');
    }

    @isTest
    static void testCreateQuote2() {
        Bid_History__c  bidHistory = [SELECT Id FROM Bid_History__c LIMIT 1];
        Opportunity  opp = [SELECT Id FROM Opportunity LIMIT 1];
        opp.Line_of_Business__c = CON_CPQ.Q2_Solutions;
        opp.Identified_Business__c = CON_CPQ.COLLECTION_TOOL_TYPE_BIOSCIENCES;
        opp.Q2_Bioscience_Location__c = CON_CPQ.INDIANAPOLIS_ADME;
        update opp;
        Test.startTest();
            String firstBudgetId = CNT_CPQ_QuoteCreation.createQuote(CON_CPQ.Q2_Solutions, CON_CPQ.GBU_RDS, bidHistory.Id, CON_CPQ.BID_HISTORY, '1');
            Quote_Requisites__c  quoteReq = [SELECT Id, Type__c FROM Quote_Requisites__c LIMIT 1];
        Test.stopTest();
        Assert.isNotNull(firstBudgetId, 'Quote Id should not be null.');
        Assert.isNotNull(quoteReq.Id, 'Quote Requisite Id should not be null.');
        Assert.areEqual('Quote Sections', quoteReq.Type__c, 'Quote Requisites type should be Quote Sections.');
    }

    @isTest
    static void testCreateQuoteAccToLicenseWithCongaPathway() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Test.startTest();
            String firstBudgetId = CNT_CPQ_QuoteCreation.createQuoteAccToLicense(CON_CPQ.Complete_Consent, CON_CPQ.GBU_DPS,opp.Id, CON_CPQ.OPPORTUNITY,'1', CON_CPQ.CONGA_PATHWAY);
        Test.stopTest();
        Assert.isNotNull(firstBudgetId, 'Quote Id should not be null.');
    }

    @isTest
    static void testCreateQuoteAccToLicenseWithoutPathway() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Test.startTest();
            String firstBudgetId = CNT_CPQ_QuoteCreation.createQuoteAccToLicense(CON_CPQ.Complete_Consent, CON_CPQ.GBU_DPS,opp.Id, CON_CPQ.OPPORTUNITY,'1', '');
        Test.stopTest();
        Assert.isNotNull(firstBudgetId, 'Quote Id should not be null.');
    }
}
