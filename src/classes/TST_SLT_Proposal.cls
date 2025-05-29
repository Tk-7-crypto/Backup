/*
 * Version       : 1.0
 * Description   : This test class is used for SLT_Proposal
 */
@isTest
private class TST_SLT_Proposal {
    /**
    * This method used to set up testdata
    */ 
    @testSetup
    static void dataSetup() 
    {
        Account acc = UTL_OWF_TestData.createAccount();
        insert acc;
        
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        
        Contact cont = UTL_OWF_TestData.createContact(acc.Id);
        cont.pse__Is_Resource__c = true;
        cont.pse__Is_Resource_Active__c = true;
        cont.pse__Group__c = grp.Id;
        insert cont;
        
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        
        Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
        insert opp;
        
        
        Bid_History__c clinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
       
        Apttus_Proposal__Proposal__c budget = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, clinicalBid.Id); 
    }
    
    @IsTest
    static void testgetProposalsById() {
        
        Apttus_Proposal__Proposal__c budgetRecord = [SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1];
        Set<String> fieldSet =  new Set<String>{CON_CPQ.ID, CON_CPQ.RFP_SCENARIO, CON_CPQ.SCENARIO_DESCRIPTION, 
                CON_CPQ.SCENARIO_NUMBER, CON_CPQ.BUDGET_ITERATION, CON_CPQ.PROPOSAL_NAME, CON_CPQ.APTTUS_PROPOSAL_PRIMARY, 
                CON_CPQ.RECORDTYPE_NAME};
                    
        Test.startTest();
            List<Apttus_Proposal__Proposal__c> budgetList = new SLT_Proposal().getProposalsById(new Set<Id>{budgetRecord.Id}, fieldSet);
        Test.stopTest();
        
        System.assertEquals(budgetList.size()>0, true, 'BudgetList size should be greater then zero.');
    }
    
    @IsTest
    static void testgetProposalDetails() {
        
        Apttus_Proposal__Proposal__c budgetRecord = [SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1];
        Set<String> fieldSet =  new Set<String>{CON_CPQ.ID, CON_CPQ.RFP_SCENARIO, CON_CPQ.SCENARIO_DESCRIPTION, 
                CON_CPQ.SCENARIO_NUMBER, CON_CPQ.BUDGET_ITERATION, CON_CPQ.PROPOSAL_NAME, CON_CPQ.APTTUS_PROPOSAL_PRIMARY, 
                CON_CPQ.RECORDTYPE_NAME};
                    
        Test.startTest();
            Apttus_Proposal__Proposal__c budget = new SLT_Proposal().getProposalDetails(budgetRecord.Id, fieldSet);
        Test.stopTest();
        
        System.assertEquals(budget.Id != null, true, 'Budget id should not null');
    }
    
    @IsTest
    static void testGetQuoteByParentClinicalBid() {
        
        Bid_History__c parentRecord = [SELECT Id FROM Bid_History__c LIMIT 1];																	  
        Apttus_Proposal__Proposal__c budgetRecord = [SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1];
        Set<String> fieldSet =  new Set<String>{CON_CPQ.ID, CON_CPQ.RFP_SCENARIO, CON_CPQ.SCENARIO_DESCRIPTION, 
                CON_CPQ.SCENARIO_NUMBER, CON_CPQ.BUDGET_ITERATION, CON_CPQ.PROPOSAL_NAME, CON_CPQ.APTTUS_PROPOSAL_PRIMARY, 
                CON_CPQ.RECORDTYPE_NAME};
                    
        Set<Id> clinicalBidIds = new Set<Id>{parentRecord.Id};
        String condition = 'Clinical_Bid__c in :clinicalBidIds';
                    
        Test.startTest();
        List<Apttus_Proposal__Proposal__c> budgetList = new SLT_Proposal().getQuoteByParentClinicalBid(clinicalBidIds, fieldSet, condition);
        Test.stopTest();
        
        System.assertEquals(budgetList.size()>0, true, 'BudgetList size should be greater then zero.');
    }
    
    @IsTest
    static void testgetQuoteByParentRelatedOpportunity() {
        
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Apttus_Proposal__Proposal__c budgetRecord = [SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1];
        Set<String> fieldSet =  new Set<String>{CON_CPQ.ID, CON_CPQ.RFP_SCENARIO, CON_CPQ.SCENARIO_DESCRIPTION, 
                CON_CPQ.SCENARIO_NUMBER, CON_CPQ.BUDGET_ITERATION, CON_CPQ.PROPOSAL_NAME, CON_CPQ.APTTUS_PROPOSAL_PRIMARY, 
                CON_CPQ.RECORDTYPE_NAME};
                    
        Set<Id> oppIdSet = new Set<Id>{opp.Id};
        String condition = 'Clinical_Bid__r.Bid_History_Related_Opportunity__c in :opportunityIdSet';
                    
        Test.startTest();
        List<Apttus_Proposal__Proposal__c> budgetList = new SLT_Proposal().getQuoteByParentRelatedOpportunity(oppIdSet, fieldSet, condition);
        Test.stopTest();
        
        System.assertEquals(budgetList.size()>0, true, 'BudgetList size should be greater then zero.');
    }
    
    @IsTest
    static void testGetProposalFieldsById() {
        
        Apttus_Proposal__Proposal__c budgetRecord = [SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1];
        Set<String> fieldSet =  new Set<String>{CON_CPQ.ID, CON_CPQ.RFP_SCENARIO, CON_CPQ.SCENARIO_DESCRIPTION, 
            CON_CPQ.SCENARIO_NUMBER, CON_CPQ.BUDGET_ITERATION, CON_CPQ.PROPOSAL_NAME, CON_CPQ.APTTUS_PROPOSAL_PRIMARY, 
            CON_CPQ.RECORDTYPE_NAME};
                    
        Test.startTest();
            List<Apttus_Proposal__Proposal__c> budgetList = new SLT_Proposal().getProposalFieldsById(new Set<ID> {budgetRecord.Id}, fieldSet);
        Test.stopTest();
        
        System.assertEquals(budgetList.size() > 0, true, 'Budget List should not null');
    }
    
    @IsTest
    static void testSelectByProposalIds() {
        
        Apttus_Proposal__Proposal__c budgetRecord = [SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1];
        Set<String> fieldSet =  new Set<String>{CON_CPQ.ID, CON_CPQ.RFP_SCENARIO, CON_CPQ.SCENARIO_DESCRIPTION, 
            CON_CPQ.SCENARIO_NUMBER, CON_CPQ.BUDGET_ITERATION, CON_CPQ.PROPOSAL_NAME, CON_CPQ.APTTUS_PROPOSAL_PRIMARY, 
            CON_CPQ.RECORDTYPE_NAME};
                    
        Test.startTest();
            Map<Id, Apttus_Proposal__Proposal__c> budgetMap = new SLT_Proposal().selectByProposalIds(new Set<ID> {budgetRecord.Id}, fieldSet);
        Test.stopTest();
        
        System.assertEquals(budgetMap.size() > 0, true, 'Budget Map should not null');
    }
    
    @IsTest
    static void testGetQuoteMapByParentAgreementAndApprovalStage() {
        
        Bid_History__c parentRecord = [SELECT Id FROM Bid_History__c LIMIT 1];
        Apttus_Proposal__Proposal__c budgetRecord = [SELECT Id, Apttus_Proposal__Approval_Stage__c, Approval_Status__c FROM Apttus_Proposal__Proposal__c LIMIT 1];
        budgetRecord.Apttus_Proposal__Approval_Stage__c = CON_CPQ.SUBMIT_FOR_REVIEW;
        budgetRecord.Approval_Status__c = CON_CPQ.SUBMITTED_FOR_FUNCTIONAL_REVIEW;
        update budgetRecord;
        
        String condition = 'Apttus_Proposal__Approval_Stage__c IN : approvalStageSet';
        Set<String> approvalStageSet = new Set<String>{CON_CPQ.DRAFT, CON_CPQ.SUBMIT_FOR_REVIEW, CON_CPQ.PENDING_APPROVAL};
        Set<String> fieldSet =  new Set<String>{CON_CPQ.ID, CON_CPQ.RFP_SCENARIO, CON_CPQ.SCENARIO_DESCRIPTION,
            CON_CPQ.SCENARIO_NUMBER, CON_CPQ.BUDGET_ITERATION, CON_CPQ.PROPOSAL_NAME, CON_CPQ.APTTUS_PROPOSAL_PRIMARY, 
            CON_CPQ.RECORDTYPE_NAME};
                    
        Test.startTest();
            Map<Id, Apttus_Proposal__Proposal__c> budgetMap = new SLT_Proposal().getQuoteMapByParentAgreementAndApprovalStage(new Set<ID> {parentRecord.Id}, fieldSet, condition, approvalStageSet);
        Test.stopTest();
        
        System.assertEquals(budgetMap.size()>0, true, 'Budget Map should not null');
    }

    @IsTest
    private static void testGetQuoteByParentRelatedOppIdOrIds() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Apttus_Proposal__Proposal__c budgetRecord = [SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1];
        Set<String> fieldSet =  new Set<String>{'Id', 'Name'};
        Set<Id> oppIdSet = new Set<Id>{opp.Id};
        String condition = 'Clinical_Bid__r.Bid_History_Related_Opportunity__c in :opportunityIdSet';
                    
        Test.startTest();
            List<Apttus_Proposal__Proposal__c> budgetList = new SLT_Proposal().getQuoteByParentRelatedOppIdOrIds(oppIdSet, new Set<Id>{budgetRecord.Id}, fieldSet, condition);
        Test.stopTest();
        
        System.assertEquals(budgetList.size() > 0, true, 'BudgetList size should be greater then zero.');
    }
    
    @IsTest
    static void testGetProposalByParentClinicalBidAndBudgetType() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Bid_History__c parentRecord = [SELECT Id FROM Bid_History__c LIMIT 1];
        Apttus_Proposal__Proposal__c proposal = new Apttus_Proposal__Proposal__c();
        Id recordTypeId =
            SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByDeveloperName().get('RDS_Budget').getRecordTypeId();
        proposal.RecordTypeId = recordTypeId;
        proposal.Apttus_Proposal__Opportunity__c = opp.Id;
        proposal.Apttus_Proposal__Proposal_Category__c = CON_CPQ.INITIAL;
        proposal.Select_Pricing_Tool__c = CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT;
        proposal.Clinical_Bid__c = parentRecord.Id;
        proposal.Scenario_Number__c = 123.0;
        proposal.DTE_Study__c = CON_CPQ.YES_TITLE_CASE;
        proposal.Scenario_Description__c = CON_CPQ.OPPORTUNITY_BALLPARK;
        proposal.Budget_Iteration__c = 1;
        proposal.Apttus_Proposal__Primary__c = true;
        insert proposal;
        Set<String> fieldSet =  new Set<String>{CON_CPQ.ID, CON_CPQ.NAME, CON_CPQ.REALTED_AGREEMENT};
                    
        Test.startTest();
            List<Apttus_Proposal__Proposal__c> budgetList = new SLT_Proposal().getProposalByParentClinicalBidAndBudgetType(new Set<ID> {parentRecord.Id}, new Set<String> {CON_CPQ.INITIAL}, fieldSet);
        Test.stopTest();
        
        System.assertEquals(budgetList.size()>0, true, 'Budget List should not null');
    }
    
    
    @IsTest
    static void testGetQuoteWithLineItemsById() {
        Apttus_Proposal__Proposal__c proposal = [SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1];
        
        // Create Proposal Line Items
        Product2 product = UTL_TestData.createProduct();
        Apttus_Proposal__Proposal_Line_Item__c lineItem = UTL_TestData.createProposalLineItem(proposal.Id, product.Id);
        insert lineItem;
        
        Test.startTest();
            List<Apttus_Proposal__Proposal__c> quoteList = new SLT_Proposal().getQuoteWithLineItemsById(new Set<Id>{proposal.Id}, new Set<String>{CON_CPQ.Name}, new Set<String>{CON_CPQ.Name});
        Test.stopTest();
        
        System.assertEquals(1, quoteList.size(), 'Quote size mis-match');
    }
    
    @IsTest
    static void testGetQuoteByRelatedOpportunity() {
        
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Apttus_Proposal__Proposal__c budgetRecord = [SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1];
        Set<String> fieldSet =  new Set<String>{CON_CPQ.ID, CON_CPQ.RFP_SCENARIO, CON_CPQ.SCENARIO_DESCRIPTION, 
                CON_CPQ.SCENARIO_NUMBER, CON_CPQ.BUDGET_ITERATION, CON_CPQ.PROPOSAL_NAME, CON_CPQ.APTTUS_PROPOSAL_PRIMARY, 
                CON_CPQ.RECORDTYPE_NAME};
                    
        Set<Id> oppIdSet = new Set<Id>{opp.Id};
        String condition = 'Clinical_Bid__r.Bid_History_Related_Opportunity__c in :opportunityIdSet';
                    
        Test.startTest();
        List<Apttus_Proposal__Proposal__c> budgetList = new SLT_Proposal().getQuoteByRelatedOpportunity(oppIdSet, fieldSet, condition);
        Test.stopTest();
        
        System.assertEquals(budgetList.size()>0, true, 'BudgetList size should be greater then zero.');
    }
    @IsTest
    static void testGetProposalByQuoteIds() {
        
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
       
        Apttus_Config2__PriceList__c pl = TST_TestGeneratorClass.buildTestPriceList('Test PriceList');
        pl.CurrencyIsoCode = 'USD';
        insert pl;
        Quote__c quote = new Quote__c();
        quote.Pricing_Tools__c = CON_CPQ.Complete_Consent;
        quote.GBU__c = CON_CPQ.GBU_DPS;
        quote.Related_Opportunity__c = opp.Id;
        quote.Related_Account__c = acc.Id;
        insert quote;
        
        RecordType recordType  = [SELECT Id FROM RecordType WHERE DeveloperName = :CON_CPQ.TECH_SOLUTION 
                                  AND SobjectType = 'Apttus_Proposal__Proposal__c' LIMIT 1];
        Apttus_Proposal__Proposal__c budget = UTL_TestData.createQuote();
        budget.Select_Pricing_Tool__c = CON_CPQ.Complete_Consent;
        budget.RecordTypeId = recordType.Id;
        budget.Apttus_Proposal__Account__c = acc.Id;
        budget.Apttus_Proposal__Opportunity__c = opp.Id;
        budget.Apttus_QPConfig__PriceListId__c = pl.Id;
        budget.Apttus_Proposal__Approval_Stage__c = 'Draft';
        budget.IQVIA_Quote__c = quote.Id;
        insert budget;
        Set<String> proposalFieldSet = new Set<String>{'Id', 'CurrencyIsoCode', 'IQVIA_Quote__c', 'Apttus_Proposal__Approval_Stage__c', 'Select_Pricing_Tool__c'};
        String condition = 'IQVIA_Quote__c =' + '\'' + quote.Id + '\'';
        Test.startTest();
            List<Apttus_Proposal__Proposal__c> budgetList = new SLT_Proposal().getProposalByQuoteIds(proposalFieldSet, condition, new set<Id>{quote.Id});
            List<Apttus_Proposal__Proposal__c> budgetList1 = new SLT_Proposal().getProposalByPricingToolIds(new set<String>{quote.Pricing_Tools__c}, 'IQVIA_Quote__c = \'' + quote.Id + '\'', proposalFieldSet);
        Test.stopTest();
        
        System.assertEquals(budgetList.size(), 1, 'BudgetList size should be greater then zero.');
        System.assertEquals(budgetList1.size(), 1, 'BudgetList size should be greater then zero.');
    }
    @IsTest
    static void testGetFinalizedProposals() {
        
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
       
        Apttus_Config2__PriceList__c pl = TST_TestGeneratorClass.buildTestPriceList('Test PriceList');
        pl.CurrencyIsoCode = 'USD';
        insert pl;
        Quote__c quote = new Quote__c();
        quote.Pricing_Tools__c = CON_CPQ.Complete_Consent;
        quote.GBU__c = CON_CPQ.GBU_DPS;
        quote.Related_Opportunity__c = opp.Id;
        quote.Related_Account__c = acc.Id;
        insert quote;
        
        RecordType recordType  = [SELECT Id FROM RecordType WHERE DeveloperName = :CON_CPQ.TECH_SOLUTION 
                                  AND SobjectType = 'Apttus_Proposal__Proposal__c' LIMIT 1];
        Apttus_Proposal__Proposal__c budget = UTL_TestData.createQuote();
        budget.Select_Pricing_Tool__c = CON_CPQ.Complete_Consent;
        budget.RecordTypeId = recordType.Id;
        budget.Apttus_Proposal__Account__c = acc.Id;
        budget.Apttus_Proposal__Opportunity__c = opp.Id;
        budget.Apttus_QPConfig__PriceListId__c = pl.Id;
        budget.IQVIA_Quote__c = quote.Id;
        budget.Apttus_Proposal__Approval_Stage__c = 'Finalized';
        insert budget;
        Test.startTest();
            List<Apttus_Proposal__Proposal__c> budgetList = new SLT_Proposal().getFinalizedProposals(quote.Id);
        Test.stopTest();
        
        System.assertEquals(budgetList.size(), 1, 'BudgetList size should be greater then zero.');
    }
}
