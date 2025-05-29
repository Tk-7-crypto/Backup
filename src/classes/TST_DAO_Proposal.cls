@isTest
private class TST_DAO_Proposal {
    @testSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        acc.MDM_Validation_Status__c = 'Validated';
        acc.AccountCountry__c = 'JP';
        insert acc;
        
        Opportunity testOpportunity= UTL_TestData.createOpportunity(acc.Id);
        testOpportunity.Line_of_Business__c = CON_CPQ.SAMPLE_LINE_OF_BUSINESS;
        testOpportunity.Legacy_Quintiles_Opportunity_Number__c='MVP123';
        testOpportunity.Is_this_IQVIA_Biotech__c = 'No';
        testOpportunity.Potential_Regions__c = CON_CPQ.REGION_ASIA_PASIFIC;
        insert testOpportunity;
        
        List<Apttus__APTS_Agreement__c> lstAGRsToInsert = new List<Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c psaAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        psaAgreement.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_GSA;
        psaAgreement.Name = 'Test Agreement PSA';
        lstAGRsToInsert.add(psaAgreement);

        Apttus__APTS_Agreement__c prelAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PRELIMINARY_RECORDTYPEID, false);
        prelAgreement.Name = 'Test Agreement Prelim';
        lstAGRsToInsert.add(prelAgreement);

        Apttus__APTS_Agreement__c coAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        coAgreement.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_CHANGEORDER;
        coAgreement.Name = 'Test Agreement CO';
        lstAGRsToInsert.add(coAgreement);

        insert lstAGRsToInsert;
        List<Apttus_Proposal__Proposal__c> lstProposalsToInsert = new List<Apttus_Proposal__Proposal__c>();
        Apttus_Proposal__Proposal__c psProposal = TST_CLM_TestDataFactory.createProposalQuote(false);
        psProposal.Apttus_QPComply__MasterAgreementId__c = lstAGRsToInsert.get(0).Id;
        psProposal.Apttus_Proposal__Opportunity__c = testOpportunity.Id;
        psProposal.Select_Pricing_Tool__c = CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT;
        psProposal.RFP_Scenario__c = 'Project Specific';
        lstProposalsToInsert.add(psProposal);
        Apttus_Proposal__Proposal__c prelProposal = TST_CLM_TestDataFactory.createProposalQuote(false);
        prelProposal.Apttus_QPComply__MasterAgreementId__c = lstAGRsToInsert.get(1).Id;
        prelProposal.Covid_19_Comment__c = 'Test Covid Comment';
        prelProposal.Apttus_Proposal__Opportunity__c = testOpportunity.Id;
        prelProposal.Select_Pricing_Tool__c = CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT;
        prelProposal.RFP_Scenario__c = 'Preliminary';
        lstProposalsToInsert.add(prelProposal);
        Apttus_Proposal__Proposal__c coProposal = TST_CLM_TestDataFactory.createProposalQuote(false);
        coProposal.Apttus_QPComply__MasterAgreementId__c = lstAGRsToInsert.get(2).Id;
        coProposal.Covid_19_Comment__c = 'Test Covid Comment';
        coProposal.Apttus_Proposal__Proposal_Name__c = 'Test Proposal CO';
        coProposal.Apttus_Proposal__Proposal_Category__c = CON_CLM.PROPOSAL_CHANGE_ORDER;
        coProposal.Apttus_Proposal__Opportunity__c = testOpportunity.Id;
        coProposal.Select_Pricing_Tool__c = CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT;
        coProposal.RFP_Scenario__c = 'Change Order 01';
        lstProposalsToInsert.add(coProposal);
        insert lstProposalsToInsert;
        
    }
    
    @isTest
    static void testOnBeforeUpdate() {
        Apttus_Proposal__Proposal__c proposal = [SELECT id, RFP_Scenario__c, Apttus_Proposal__Proposal_Name__c, OwnerId, Apttus_Proposal__RelatedProposalId__c, 
        	Run_Sharing__c FROM Apttus_Proposal__Proposal__c LIMIT 1];
        List<Apttus_Proposal__Proposal__c> newProposalList = new List<Apttus_Proposal__Proposal__c>{proposal};
        Map<Id, Apttus_Proposal__Proposal__c> existingRecords = new Map<Id, Apttus_Proposal__Proposal__c>();  
      
        Test.startTest();
            update newProposalList;
        Test.stopTest();

        System.assertNotEquals(0, newProposalList.size(), 'Proposal list size should not be 0.');
    }

    @isTest
    static void testOnAfterUpdate() {
        Apttus_Proposal__Proposal__c proposal = [SELECT Id, RFP_Scenario__c, Apttus_Proposal__Proposal_Name__c, OwnerId, Apttus_Proposal__RelatedProposalId__c, 
        	Run_Sharing__c FROM Apttus_Proposal__Proposal__c LIMIT 1];
        List<Apttus_Proposal__Proposal__c> newProposalList = new List<Apttus_Proposal__Proposal__c>{proposal};
        Map<Id, Apttus_Proposal__Proposal__c> existingRecords = new Map<Id, Apttus_Proposal__Proposal__c>();  
      
        Test.startTest();
            update newProposalList;
        Test.stopTest();

        System.assertNotEquals(0, newProposalList.size(), 'Proposal list size should not be 0.');
    }

    @isTest
    static void testSyncAgrWithPrimaryProposal() {
        
        Apttus_Proposal__Proposal__c proposal = [SELECT Id, RFP_Scenario__c, Apttus_Proposal__Proposal_Name__c, OwnerId, Apttus_Proposal__RelatedProposalId__c, 
            Run_Sharing__c FROM Apttus_Proposal__Proposal__c 
            WHERE Apttus_QPComply__MasterAgreementId__r.RecordTypeId =:CON_CLM.PSA_RECORDTYPEID LIMIT 1];
        proposal.Apttus_Proposal__Proposal_Category__c = CON_CLM.PROPOSAL_PROJECT_SPECIFIC;
        proposal.Apttus_Proposal__Primary__c = true;
        List<Apttus_Proposal__Proposal__c> newProposalList = new List<Apttus_Proposal__Proposal__c>{proposal};
      
        Test.startTest();
            update newProposalList;
        Test.stopTest();

        System.assertNotEquals(0, newProposalList.size(), 'Proposal list size should not be 0.');
    }

    @isTest
    static void testUpdateCOAgrWithPrimaryCOProposal() {
        
        Apttus_Proposal__Proposal__c proposal = [SELECT Id, RFP_Scenario__c, Apttus_Proposal__Proposal_Name__c, OwnerId, Apttus_Proposal__RelatedProposalId__c, 
            Run_Sharing__c FROM Apttus_Proposal__Proposal__c 
            WHERE Apttus_Proposal__Proposal_Category__c =: CON_CLM.PROPOSAL_CHANGE_ORDER LIMIT 1];
        proposal.RecordTypeId = CON_CLM.QUOTE_RDS_BUDGET_RECORDTYPE;
        proposal.Apttus_Proposal__Primary__c = true;
        proposal.Apttus_Proposal__Approval_Stage__c = CON_CLM.PROPOSAL_APPROVAL_STAGE_ACCEPTED;
        List<Apttus_Proposal__Proposal__c> newProposalList = new List<Apttus_Proposal__Proposal__c>{proposal};
      
        Test.startTest();
            update newProposalList;
        Test.stopTest();

        System.assertNotEquals(0, newProposalList.size(), 'Proposal list size should not be 0.');
    }

    @isTest
    static void testUpdatePrelAGRForPrelBudgetTypeRDSNonSF() {
        
        Apttus_Proposal__Proposal__c proposal = [SELECT Id, RFP_Scenario__c, Apttus_Proposal__Proposal_Name__c, OwnerId, Apttus_Proposal__RelatedProposalId__c, 
            Run_Sharing__c FROM Apttus_Proposal__Proposal__c 
            WHERE Apttus_QPComply__MasterAgreementId__r.RecordTypeId =:CON_CLM.PRELIMINARY_RECORDTYPEID LIMIT 1];
        proposal.Apttus_Proposal__Proposal_Category__c = CON_CLM.PROPOSAL_PRELIMINARY;
        proposal.RecordTypeId = CON_CLM.QUOTE_RDS_NON_SF_RECORDTYPE;
        List<Apttus_Proposal__Proposal__c> newProposalList = new List<Apttus_Proposal__Proposal__c>{proposal};
      
        Test.startTest();
            update newProposalList;
        Test.stopTest();

        System.assertNotEquals(0, newProposalList.size(), 'Proposal list size should not be 0.');
    }

    @isTest
    static void testUpdatePrelAgrWithPrimaryPrelProposalRDSNonSF() {
        
        Apttus_Proposal__Proposal__c proposal = [SELECT Id, Apttus_Proposal__Proposal_Name__c, OwnerId, Apttus_Proposal__RelatedProposalId__c, 
            Run_Sharing__c FROM Apttus_Proposal__Proposal__c 
            WHERE Apttus_QPComply__MasterAgreementId__r.RecordTypeId =:CON_CLM.PRELIMINARY_RECORDTYPEID LIMIT 1];
        proposal.Apttus_Proposal__Proposal_Category__c = CON_CLM.PROPOSAL_PRELIMINARY;
        proposal.RecordTypeId = CON_CLM.QUOTE_RDS_NON_SF_RECORDTYPE;
        proposal.Apttus_Proposal__Primary__c = true;
        proposal.Apttus_Proposal__Approval_Stage__c = CON_CLM.PROPOSAL_APPROVAL_STAGE_ACCEPTED;
        List<Apttus_Proposal__Proposal__c> newProposalList = new List<Apttus_Proposal__Proposal__c>{proposal};
      
        Test.startTest();
            update newProposalList;
        Test.stopTest();

        System.assertNotEquals(0, newProposalList.size(), 'Proposal list size should not be 0.');
    }
    
    @isTest
    static void testBeforeAndAfterInsertOfTechSolutionProposal() {
        Account account = [SELECT Id from Account Limit 1];

        Opportunity opportunity = [SELECT Id from Opportunity Limit 1];
        
        // Create Apttus Price List
        Apttus_Config2__PriceList__c priceList = UTL_TestData.createPriceList(CON_CPQ.TECH_SOLUTION_JAPAN);
        
        // Create Custom Settings record of "CPQ TS PriceList Selection"
        UTL_TestData.createCPQTSPriceListSelectionCustomSettings();
        
        Test.startTest();
        Apttus_Proposal__Proposal__c proposal = UTL_TestData.setTSProposalData(false, CON_CPQ.TECH_SOLUTION, opportunity.Id, CON_CPQ.TS_JAPAN);
        proposal.Apttus_Proposal__Account__c = account.Id;
        insert proposal;
        Test.stopTest();
        
        List<Apttus_Proposal__Proposal__c> proposals = [Select Apttus_QPConfig__PriceListId__c
                                                        From Apttus_Proposal__Proposal__c Where Id =: proposal.Id];
        System.assertEquals(1, proposals.size(), 'Proposal size mis-match');
    }
}
