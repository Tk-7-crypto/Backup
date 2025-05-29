@isTest
private class TST_CPQ_CLM_Utility {
    
    @testSetup
    static void setUpTestData() {
        Account acc = UTL_TestData.createAccount();
        acc.AccountCountry__c = 'AL';
        insert acc;
        
        Opportunity testOpportunity= UTL_TestData.createOpportunity(acc.id);
        testOpportunity.Line_of_Business__c = 'Data Sciences';
        testOpportunity.Is_this_IQVIA_Biotech__c = CON_CPQ.YES_TITLE_CASE;
        testOpportunity.CurrencyIsoCode = CON_CPQ.USD;
        testOpportunity.Legacy_Quintiles_Opportunity_Number__c = 'MVP123';
        testOpportunity.Potential_Regions__c = CON_CPQ.REGION_ASIA_PASIFIC;
        testOpportunity.Number_of_Potential_Regions__c = 0;
        testOpportunity.StageName = '5. Finalizing Deal';
        testOpportunity.Awarded_Date__c = System.today();
        testOpportunity.QI_Invited_to_Present__c = 'No';
        testOpportunity.FSP__c = 'No';
        testOpportunity.Expected_Project_End_Date__c = System.today();
        testOpportunity.Expected_Project_Start_Date__c = System.today();
        testOpportunity.Verbatim_Indication_Term__c = 'Test';
        testOpportunity.FPI_Date__c = System.today();
        testOpportunity.InterventionType__c = 'Vaccine';
        testOpportunity.Expect_ATP_or_WO_in_Awarded_Qtr__c = 'Very Likely';
        testOpportunity.Global_Public_Health__c = CON_CPQ.NO;
        insert testOpportunity;
        
        Apttus__APTS_Agreement__c coAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        coAgreement.Name = 'Test Agreement CO';
        coAgreement.Apttus__Subtype__c = CON_CPQ.CHNAGE_ORDER;
        insert coAgreement;
        
        Apttus__APTS_Agreement__c psaAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        psaAgreement.Name = 'Test Agreement PSA';
        psaAgreement.Apttus__Subtype__c = 'Work Order';
        insert psaAgreement;
        
        Bid_History__c clinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
        
        Apttus_Proposal__Proposal__c quote1 = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, clinicalBid.Id);	
        quote1.Apttus_Proposal__Approval_Stage__c = CON_CPQ.DRAFT;
        quote1.Apttus_Proposal__Proposal_Category__c = CON_CPQ.PROJECT_SPECIFIC;
        quote1.CurrencyIsoCode = CON_CPQ.USD;
        quote1.Number_of_Line_Items__c = 2;
        update quote1;
        
        Apttus_Proposal__Proposal_Line_Item__c proposalLineItem1 = UTL_TestData.createQuoteLineItem(quote1.Id);
        proposalLineItem1.IQVIA_Line_Type__c = CON_CPQ.CRM_Product;
        insert proposalLineItem1;
        
        Apttus_Proposal__Proposal_Line_Item__c proposalLineItem2 = UTL_TestData.createQuoteLineItem(quote1.Id);
        proposalLineItem2.IQVIA_Line_Type__c = CON_CPQ.CRM_Product;
        insert proposalLineItem2;

        Apttus_Proposal__Proposal__c quote2 = UTL_TestData.setProposalData(CON_CPQ.RDS_NON_SF, testOpportunity.Id, CON_CPQ.NON_SF_UNIT_PRICING_TOOL, clinicalBid.Id);
        quote2.Apttus_Proposal__Approval_Stage__c = CON_CPQ.DRAFT;
        quote2.Apttus_Proposal__Proposal_Category__c = CON_CPQ.CHNAGE_ORDER;
        quote2.Executed_Date__c = null;
        quote2.Apttus_QPComply__MasterAgreementId__c = coAgreement.ID;
        quote2.Apttus_Proposal__Primary__c = true;
        update quote2;

        Quote__c iqviaQuote = UTL_TestData.createIqviaQuote(acc.Id, testOpportunity.Id, clinicalBid.Id, CON_CPQ.UNIT_PRICING_TOOL, 'RDS SF', false);
        iqviaQuote.Approval_Stage__c = CON_CPQ.DRAFT;
        iqviaQuote.Quote_Type__c = CON_CPQ.PROJECT_SPECIFIC;
        iqviaQuote.CurrencyIsoCode = CON_CPQ.USD;
        iqviaQuote.Number_of_Line_Items__c = 2;
        insert iqviaQuote;

        Quote_Line_Item__c quoteLineItem1 = UTL_TestData.createIqviaQuoteLineItem(iqviaQuote.Id, CON_CPQ.UNIT_PRICING_TOOL, false);
        quoteLineItem1.IQVIA_Line_Type__c = CON_CPQ.CRM_Product;
        quoteLineItem1.Pricing_Tool__c ='';
        insert quoteLineItem1;
        
        Quote_Line_Item__c quoteLineItem2 = UTL_TestData.createIqviaQuoteLineItem(iqviaQuote.Id, CON_CPQ.UNIT_PRICING_TOOL, false);
        quoteLineItem2.IQVIA_Line_Type__c = CON_CPQ.CRM_Product;
        quoteLineItem2.Pricing_Tool__c ='';
        insert quoteLineItem2;

        Quote__c iqviaQuote2 = UTL_TestData.createIqviaQuote(acc.Id, testOpportunity.Id, clinicalBid.Id, CON_CPQ.NON_SF_UNIT_PRICING_TOOL, 'RDS NON-SF', false);
        iqviaQuote2.Approval_Stage__c = CON_CPQ.DRAFT;
        iqviaQuote2.Quote_Type__c = CON_CPQ.CHNAGE_ORDER;
        iqviaQuote2.Executed_Date__c = null;
        iqviaQuote2.Primary__c = true;
        insert iqviaQuote2;
    }
    
    @isTest 
    static void testNonSFValidation() {
        Apttus_Proposal__Proposal__c proposal =[SELECT Id FROM Apttus_Proposal__Proposal__c WHERE Recordtype.DeveloperName =: CON_CPQ.RDS_NON_SF Limit 1];
        Apttus__APTS_Agreement__c agreement = [SELECT Id, Name, Apttus__Other_Party_Signed_Date__c FROM Apttus__APTS_Agreement__c WHERE Name  =: 'Test Agreement PSA' Limit 1];
         
        Test.startTest();
            Map<Id, List<String>> statusOnQuoteAcceptance = CPQ_CLM_Utility.acceptQuoteOnAgreementActivation(new Map<Id, Apttus__APTS_Agreement__c>{proposal.Id => agreement}, true);
        Test.stopTest();
        
        String status = statusOnQuoteAcceptance.get(proposal.Id)[0] + '. ' + statusOnQuoteAcceptance.get(proposal.Id)[2];
        System.assertEquals('Agreement and Quote linkage is not correct, Agreement "Proposal/Quote" and Proposal "Related Agreement" field should be in sync. Please enter the “Executed Date” to move to Accepted Stage.', status,'Non- SF Validation');
    }
	
	@isTest
    static void testFinalizationValidation() {
        Apttus_Proposal__Proposal__c proposal =[SELECT Id FROM Apttus_Proposal__Proposal__c WHERE Recordtype.DeveloperName =: CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET Limit 1];
        
        Test.startTest();
            Map<Id, List<String>> statusOnQuoteAcceptance = CPQ_CLM_Utility.acceptQuoteOnAgreementActivation(new Map<Id, Apttus__APTS_Agreement__c>{proposal.Id => null}, false);
        Test.stopTest();
        
        String status = statusOnQuoteAcceptance.get(proposal.Id)[0];
        System.assertEquals('Please Finalize the Budget.',status,'Test');
    }
    
    @isTest
    static void testAgreementActivateValidation() {
        Apttus_Proposal__Proposal__c proposal =[SELECT Id, Apttus_QPComply__MasterAgreementId__r.Apttus__Status_Category__c, 
            Apttus_QPComply__MasterAgreementId__r.Apttus__Status__c FROM Apttus_Proposal__Proposal__c WHERE Recordtype.DeveloperName =: CON_CPQ.RDS_NON_SF Limit 1];
        proposal.Executed_Date__c = Date.Today();
        update proposal;
        Apttus__APTS_Agreement__c agreement = [SELECT Id, Name, Apttus__Other_Party_Signed_Date__c FROM Apttus__APTS_Agreement__c WHERE Name  =: 'Test Agreement CO' Limit 1];
        
        Test.startTest();
            Map<Id, List<String>> statusOnQuoteAcceptance = CPQ_CLM_Utility.acceptQuoteOnAgreementActivation(new Map<Id, Apttus__APTS_Agreement__c>{proposal.Id => agreement}, true);
        Test.stopTest();
        
        String status = statusOnQuoteAcceptance.get(proposal.Id)[0];
        System.assertEquals('There is no activated Change Order Agreement associated with this Quote so it could not be marked as Accepted. Please ensure the related Change Order Agreement is Activated before Accepting the Quote.',status,'Test');
    }
    
    @isTest 
    static void testCancelQuoteOnAgreementCancellation() {
        Apttus_Proposal__Proposal__c proposal =[SELECT Id,Apttus_Proposal__Approval_Stage__c,Approval_Status__c FROM Apttus_Proposal__Proposal__c Limit 1];
        
        Test.startTest();
            CPQ_CLM_Utility.cancelQuoteOnAgreementCancellation(new Set<Id>{proposal.Id});
        Test.stopTest();
        
        Apttus_Proposal__Proposal__c proposal1 =[SELECT Id,Apttus_Proposal__Approval_Stage__c,Approval_Status__c FROM Apttus_Proposal__Proposal__c Limit 1];

        System.assertEquals(CON_CPQ.CANCELLED, proposal1.Apttus_Proposal__Approval_Stage__c, 'Approval Stage updated to Cancelled');
    } 
    @isTest
    static void test_syncProtocolNumberOnOpp() {
        Apttus_Proposal__Proposal__c proposal =[SELECT Id, Apttus_Proposal__Approval_Stage__c, Approval_Status__c FROM Apttus_Proposal__Proposal__c WHERE Recordtype.DeveloperName =: CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET Limit 1];
        proposal.Executed_Date__c = Date.today();
        proposal.Apttus_QPConfig__ConfigurationFinalizedDate__c = Date.today();
        proposal.Protocol_Number__c = 'test12345';
        update proposal;
        
        Test.startTest();
            Map<Id, List<String>> statusOnQuoteAcceptance = CPQ_CLM_Utility.acceptQuoteOnAgreementActivation(new Map<Id, Apttus__APTS_Agreement__c>{proposal.Id => null}, true);
            Apttus_Proposal__Proposal__c res =[SELECT Id,Apttus_Proposal__Opportunity__r.Protocol_Number__c  FROM Apttus_Proposal__Proposal__c WHERE Recordtype.DeveloperName =: CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET Limit 1];
        Test.stopTest();

        System.assertEquals(res.Apttus_Proposal__Opportunity__r.Protocol_Number__c,proposal.Protocol_Number__c,'Value should be test12345');
    }
    @isTest 
    static void testCancelIqviaQuoteOnAgreementCancellation() {
        Quote__c quote =[SELECT Id,Approval_Stage__c FROM Quote__c Limit 1];
        
        Test.startTest();
            CPQ_CLM_Utility.cancelIqviaQuoteOnAgreementCancellation(new Set<Id>{quote.Id});
        Test.stopTest();
        
        Quote__c quote1 =[SELECT Id,Approval_Stage__c FROM Quote__c Limit 1];
        System.assertEquals(CON_CPQ.CANCELLED, quote1.Approval_Stage__c, 'Approval Stage updated to Cancelled');
    }
    @isTest
    static void testQuoteFinalizationValidation() {
        Quote__c quote =[SELECT Id FROM Quote__c WHERE GBU__c =: CON_CPQ.GBU_RDS_SF Limit 1];
        
        Test.startTest();
            Map<Id, List<String>> statusOnQuoteAcceptance = CPQ_CLM_Utility.acceptIqviaQuoteOnAgreementActivation(new Map<Id, SObject>{quote.Id => null}, false);
        Test.stopTest();
        
        String status = statusOnQuoteAcceptance.get(quote.Id)[0];
        System.assertEquals('Please Finalize the Budget.',status,'Test');
    }

    @isTest 
    static void testNonSFQuoteValidation() {
        Quote__c quote =[SELECT Id FROM Quote__c WHERE GBU__c =: CON_CPQ.GBU_RDS_NON_SF Limit 1];
        Apttus__APTS_Agreement__c agreement = [SELECT Id, Name, Apttus__Other_Party_Signed_Date__c FROM Apttus__APTS_Agreement__c WHERE Name  =: 'Test Agreement PSA' Limit 1];
         
        Test.startTest();
            Map<Id, List<String>> statusOnQuoteAcceptance = CPQ_CLM_Utility.acceptIqviaQuoteOnAgreementActivation(new Map<Id, SObject>{quote.Id => agreement}, true);
        Test.stopTest();
        
        String status = statusOnQuoteAcceptance.get(quote.Id)[0];
        System.assertEquals('Please enter the “Executed Date” to move to Accepted Stage.', status,'Non- SF Validation');
    }
}