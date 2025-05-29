@isTest
private class TST_DAOH_CLM_Proposal {
    @TestSetup
    public static void dataSetup() {
        Account account = UTL_TestData.createAccount();
        insert account;

        Contact contact = new Contact(AccountId = account.Id, FirstName='test', Email='testuser3133@iqvia.com', LastName ='lastname', RecordTypeId = CON_CLM.CONTACT_IQVIA_USER_CONTACT_RECORDTYPEID, EmployeeNumber__c = '123456789');
        insert contact; 
        
        Opportunity testOpp = TST_CLM_TestDataFactory.createOpportunity(false);
        testOpp.Name = 'Test Opp 1';
        testOpp.stageName = '1. Identifying Opportunity';
        testOpp.AccountId = account.Id;
        insert testOpp;
        
        Bid_History__c bid = TST_CLM_TestDataFactory.createBidHistory(CON_CLM.CONTRACT_POST_AWARD_BID_HISTORY_RECORD_TYPE_ID, testOpp.Id, false);
        bid.Contract_Ranking__c = '1.1';
        bid.Triage_Notes__c = 'Triage Notes';
        bid.Date_Tracking_Started__c = Date.today();
        insert bid;
		
        List<Apttus_Proposal__Proposal__c> lstProposalsToInsert = new List<Apttus_Proposal__Proposal__c>();
        Apttus_Proposal__Proposal__c proposal = TST_CLM_TestDataFactory.createProposalQuote(false);
        proposal.Apttus_Proposal__Proposal_Name__c = 'Ready to Accept Budget';
        proposal.Covid_19_Comment__c = 'Test Covid Comment';
        proposal.RecordTypeId = CON_CLM.QUOTE_RDS_BUDGET_RECORDTYPE;
        proposal.Apttus_Proposal__Opportunity__c = testOpp.Id;
        proposal.Apttus_Proposal__Primary__c = true;
        proposal.Apttus_Proposal__Proposal_Category__c = CON_CLM.PROPOSAL_PROJECT_SPECIFIC;
        proposal.Scenario_Number__c = 123.0;
        proposal.Budget_Iteration__c = 1;
        proposal.Select_Pricing_Tool__c = 'CPQ_UPT';
        proposal.Apttus_QPConfig__ConfigurationFinalizedDate__c = Date.today();
        proposal.Scenario_Description__c = 'Test Proposal PSA-GSA';
        lstProposalsToInsert.add(proposal);
        Apttus_Proposal__Proposal__c coProposal = TST_CLM_TestDataFactory.createProposalQuote(false);
        coProposal.Covid_19_Comment__c = 'Test Covid Comment';
        coProposal.Apttus_Proposal__Proposal_Name__c = 'Test Proposal CO';
        coProposal.Scenario_Description__c = 'Test Proposal CO';
        coProposal.Apttus_Proposal__Opportunity__c = testOpp.Id;
        coProposal.Clinical_Bid__c = bid.Id;
        lstProposalsToInsert.add(coProposal);
        insert lstProposalsToInsert;
        
        List<Apttus__APTS_Agreement__c> lstAGRsToInsert = new List<Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c gsaAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        gsaAgreement.Name = 'Test Agreement PSA-GSA';
        gsaAgreement.Apttus__Related_Opportunity__c = testOpp.Id;
        gsaAgreement.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_GSA;
        lstAGRsToInsert.add(gsaAgreement);
        Apttus__APTS_Agreement__c coAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        coAgreement.Name = 'Test Agreement CO';
        coAgreement.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_CHANGEORDER;
        coAgreement.Apttus__Related_Opportunity__c = testOpp.Id;
        lstAGRsToInsert.add(coAgreement);
        Apttus__APTS_Agreement__c woAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        woAgreement.Name = 'Test Agreement WO';
        woAgreement.Apttus__Subtype__c = 'Work Order';
        woAgreement.Apttus__Related_Opportunity__c = testOpp.Id;
        lstAGRsToInsert.add(woAgreement);
        insert lstAGRsToInsert;
        
        woAgreement.Apttus__Contract_End_Date__c = Date.today();
        woAgreement.Apttus__Status_Category__c = CON_CLM.IN_EFFECT;
        woAgreement.Apttus__Status__c = CON_CLM.ACTIVATED;
        update woAgreement;
    }

    @isTest
    private static void testUpdatePSAAGRForPSBudgetType() {
        Apttus__APTS_Agreement__c agreementForProposal = [SELECT Id, Name, Special_Terms_Included__c, Apttus__Account__c,
			Apttus__Related_Opportunity__c, CurrencyIsoCode FROM Apttus__APTS_Agreement__c WHERE Name = 'Test Agreement PSA-GSA' LIMIT 1];
        
        Apttus_Proposal__Proposal__c proposal = [SELECT id, Apttus_Proposal__Proposal_Name__c, Apttus_QPComply__MasterAgreementId__c, 
            Apttus_Proposal__Approval_Stage__c, Apttus_Proposal__Account__c, Apttus_Proposal__Opportunity__c, CurrencyIsoCode,
            Apttus_Proposal__Proposal_Category__c,Covid_19_Comment__c, Covid_19_Impact__c, Estimate_of_budget_related_to_Covid_19__c, 
            Select_Pricing_Tool__c, Project_Expense__c, Actual_Quote_Amount__c, Total_Quote_Amount__c, Bid_Sent_Date__c
            FROM Apttus_Proposal__Proposal__c WHERE Scenario_Description__c = 'Test Proposal PSA-GSA' LIMIT 1];
            //WHERE Apttus_QPComply__MasterAgreementId__r.RecordTypeId =:CON_CLM.PSA_RECORDTYPEID LIMIT 1];
        proposal.Project_Expense__c = 1000;
        proposal.Apttus_QPComply__MasterAgreementId__c = agreementForProposal.Id;
        
        
        Apttus_Proposal__Proposal__c proposalCloneOld = proposal.clone(true, false, false, false);
        proposalCloneOld.Project_Expense__c = 100;

        Map<Id, Apttus_Proposal__Proposal__c> oldMap = new Map<Id, Apttus_Proposal__Proposal__c>();
        oldMap.put(proposalCloneOld.Id, proposalCloneOld);

        Test.startTest();
            DAOH_CLM_Proposal.updatePSAAGRForPSBudgetType(new List<Apttus_Proposal__Proposal__c>{proposal}, oldMap);
        Test.stopTest();
        
        Apttus__APTS_Agreement__c agreement = [SELECT id, Name, Apttus_QPComply__RelatedProposalId__c, Actual_Agreement_Value__c
            FROM Apttus__APTS_Agreement__c WHERE Name = 'Test Agreement PSA-GSA' LIMIT 1];
        System.assertNotEquals(null, agreement.Apttus_QPComply__RelatedProposalId__c, 
        	'Agreement Related Proposal/Quote Id should not be equal to null.');
    }
    
    
    @isTest
    private static void testcreateCOAGRForCOQuote() {
                
        Apttus_Proposal__Proposal__c proposal = [SELECT id, Apttus_Proposal__Proposal_Name__c, 
            Apttus_QPComply__MasterAgreementId__c, Apttus_Proposal__Approval_Stage__c, Apttus_Proposal__Account__c, 
            Apttus_Proposal__Opportunity__c, CurrencyIsoCode, Apttus_Proposal__Proposal_Category__c,
            Covid_19_Comment__c, Covid_19_Impact__c, Estimate_of_budget_related_to_Covid_19__c, Select_Pricing_Tool__c,
            Project_Expense__c, Actual_Quote_Amount__c, Total_Quote_Amount__c, Contract__c, Clinical_Bid__c
            FROM Apttus_Proposal__Proposal__c WHERE Scenario_Description__c = 'Test Proposal CO' LIMIT 1];
        proposal.Apttus_Proposal__Approval_Stage__c = CON_CLM.PROPOSAL_APPROVAL_STAGE_ACCEPTED;
        proposal.Apttus_Proposal__Proposal_Category__c = CON_CLM.PROPOSAL_CHANGE_ORDER;
        proposal.Apttus_QPComply__MasterAgreementId__c = null;

        Test.startTest();
            DAOH_CLM_Proposal.createCOAGRForCOQuote(new List<Apttus_Proposal__Proposal__c>{proposal});
        Test.stopTest();
        
        Apttus__APTS_Agreement__c agreement = [SELECT Name, Apttus_QPComply__RelatedProposalId__c, Apttus__Subtype__c, Date_Tracking_Started__c
            FROM Apttus__APTS_Agreement__c WHERE Apttus_QPComply__RelatedProposalId__c = :proposal.Id];
        System.assertEquals(CON_CLM.REQUESTED_AGREEMENT_TYPE_CHANGEORDER, agreement.Apttus__Subtype__c,
        	'Requested agreement type should be equal to Change Order which is not happening.');
        System.assertEquals(System.today(), agreement.Date_Tracking_Started__c, 'The date tracking started field should contain current date');       
    }
    
    @isTest
    private static void testCreateRelatedAGRRecordsToReplicateAmend() {
        Apttus__APTS_Agreement__c fromAgreement = [SELECT Id, Name, Special_Terms_Included__c, Apttus__Account__c,
            Apttus__Related_Opportunity__c, CurrencyIsoCode FROM Apttus__APTS_Agreement__c WHERE Name = 'Test Agreement PSA-GSA' LIMIT 1];
        Apttus__APTS_Agreement__c toAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, true);

        Map<Id, Apttus__APTS_Agreement__c> mapOfIdAgreement = new Map<Id, Apttus__APTS_Agreement__c>();
        mapOfIdAgreement.put(fromAgreement.Id, toAgreement);

        Test.startTest();
            DAOH_CLM_Proposal.createRelatedAGRRecordsToReplicateAmend(mapOfIdAgreement);
        Test.stopTest();

        Apttus__APTS_Related_Agreement__c relatedAgreement = [SELECT Id, Name FROM Apttus__APTS_Related_Agreement__c 
            WHERE Apttus__APTS_Contract_From__c=:fromAgreement.Id];
        System.assertNotEquals(null, relatedAgreement, 'Related Agreement record is null when not expected');
    }

    @isTest
    private static void testSetAGRFieldsFromProposal() {
        Apttus__APTS_Agreement__c agreementForProposal = [SELECT Id, Name, Special_Terms_Included__c, Apttus__Account__c,
            Apttus__Related_Opportunity__c, CurrencyIsoCode FROM Apttus__APTS_Agreement__c WHERE Name = 'Test Agreement PSA-GSA' LIMIT 1];

        Apttus_Proposal__Proposal__c proposal = [SELECT id, Apttus_Proposal__Proposal_Name__c, Apttus_QPComply__MasterAgreementId__c, 
            Apttus_Proposal__Approval_Stage__c, Apttus_Proposal__Account__c, Apttus_Proposal__Opportunity__c, CurrencyIsoCode,
            Apttus_Proposal__Proposal_Category__c,Estimate_of_budget_related_to_Covid_19__c, Actual_Quote_Amount__c , Total_Quote_Amount__c , Project_Expense__c
            FROM Apttus_Proposal__Proposal__c
            WHERE Scenario_Description__c = 'Test Proposal PSA-GSA' LIMIT 1];
        
        proposal.Bid_Sent_Date__c = Date.today();
        proposal.Covid_19_Impact__c = true;
        proposal.Select_Pricing_Tool__c = 'CPQ_UPT';
        proposal.Covid_19_Comment__c = 'Test Covid-19 Comments';
        proposal.Estimate_of_budget_related_to_Covid_19__c = '25%';

        Test.startTest();
            DAOH_CLM_Proposal.setAGRFieldsFromProposal(agreementForProposal,proposal, CON_CLM.PROPOSAL_PROJECT_SPECIFIC);
        Test.stopTest();
        
        System.assertEquals('CPQ_UPT', agreementForProposal.Select_Pricing_Tool__c, 
        	'Agreement not updated when expected');
    }

    @isTest
    private static void testUpdateAgreement() {
        Apttus__APTS_Agreement__c agreementForProposal = [SELECT Id, Name, Special_Terms_Included__c, Apttus__Account__c,
            Apttus__Related_Opportunity__c, CurrencyIsoCode FROM Apttus__APTS_Agreement__c WHERE Name = 'Test Agreement PSA-GSA' LIMIT 1];
        agreementForProposal.Name = 'Test Proposal';
        
        Test.startTest();
            DAOH_CLM_Proposal.updateAgreement(new List<Apttus__APTS_Agreement__c>{agreementForProposal});
        Test.stopTest();
        
        Apttus__APTS_Agreement__c agreement = [SELECT id, Name 
            FROM Apttus__APTS_Agreement__c WHERE RecordTypeId =:CON_CLM.PSA_RECORDTYPEID AND Id =: agreementForProposal.Id LIMIT 1];
        System.assertEquals('Test Proposal', agreement.Name, 'Agreement not updated when expected');
    }

    @isTest
    private static void testUpdateAgreementCurrencyFromQuote() {
        Apttus__APTS_Agreement__c agreementForProposal = [SELECT Id, Name, Special_Terms_Included__c,Apttus_QPComply__RelatedProposalId__c, CurrencyIsoCode FROM 
            Apttus__APTS_Agreement__c WHERE Name = 'Test Agreement PSA-GSA' LIMIT 1];
        Apttus_Proposal__Proposal__c proposalRecord = [SELECT Id, Apttus_Proposal__Proposal_Name__c, CurrencyIsoCode, Apttus_Proposal__Proposal_Category__c FROM 
            Apttus_Proposal__Proposal__c WHERE Scenario_Description__c = 'Test Proposal PSA-GSA' LIMIT 1];
        agreementForProposal.Apttus_QPComply__RelatedProposalId__c = proposalRecord.Id;
        update agreementForProposal;
        
        Apttus_Proposal__Proposal__c proposalCloneOld = proposalRecord.clone(true, false, false, false);

        Map<Id, Apttus_Proposal__Proposal__c> oldMap = new Map<Id, Apttus_Proposal__Proposal__c>();
        oldMap.put(proposalCloneOld.Id, proposalCloneOld);

        proposalRecord.CurrencyIsoCode = 'AED';

        Test.startTest();
            DAOH_CLM_Proposal.updateAgreementCurrencyFromQuote(new List<Apttus_Proposal__Proposal__c>{proposalRecord}, oldMap);
        Test.stopTest();

        Apttus__APTS_Agreement__c agreementForProposal1 = [SELECT Id, Name, CurrencyIsoCode FROM Apttus__APTS_Agreement__c WHERE Apttus_QPComply__RelatedProposalId__r.Id =: proposalRecord.Id];
        System.assertEquals(agreementForProposal1.CurrencyIsoCode, proposalRecord.CurrencyIsoCode, 
        	'Agreement Currency not updated when expected');
    }
}