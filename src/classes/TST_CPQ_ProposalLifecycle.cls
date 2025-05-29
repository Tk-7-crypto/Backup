@isTest
public class TST_CPQ_ProposalLifecycle {
    @testsetup
    static void setupTestData(){
    
        Account testAccount = UTL_TestData.createAccount();
        insert testAccount;
        
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        OWF_Config__c owfConfig = UTL_OWF_TestData.createOWFConfig(grp.Id);
        insert owfConfig;
        
        Opportunity testOpportunity= UTL_TestData.createOpportunity(testAccount.id);
        testOpportunity.Line_of_Business__c = CON_CPQ.SAMPLE_LINE_OF_BUSINESS;
        testOpportunity.Is_this_IQVIA_Biotech__c = CON_CPQ.YES_TITLE_CASE;
        testOpportunity.CurrencyIsoCode = CON_CPQ.USD;
        testOpportunity.Legacy_Quintiles_Opportunity_Number__c = 'MVP123';
        insert testOpportunity;
        Product2 testProduct = UTL_TestData.createProduct();
        insert testProduct;
        PricebookEntry testPricebookEntry = UTL_TestData.createPricebookEntry(testProduct.id);
        testPricebookEntry.CurrencyIsoCode = CON_CPQ.USD;
        testPricebookEntry.Pricebook2Id = Test.getStandardPricebookId();
        insert testPricebookEntry;
        
        Bid_History__c testClinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
     
        Apttus_Proposal__Proposal__c parentBudget = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, testClinicalBid.Id);
        
																																																	   
        Apttus_Proposal__Proposal__c childBudget = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, testClinicalBid.Id);
        childBudget.Apttus_Proposal__RelatedProposalId__c = parentBudget.Id;
        Update childBudget;

        CLM_Field_Mappings__c agrQuoteCustomSetting = TST_CLM_TestDataFactory.createClmAgreementQuoteFieldMappingSetting(false);
        agrQuoteCustomSetting.Source_Field_API_Name__c = 'Select_Pricing_Tool__c';
        agrQuoteCustomSetting.Target_Field_API_Name__c = 'Select_Pricing_Tool__c';
        agrQuoteCustomSetting.Record_Type_Developer_Name__c = 'AMESA';
        insert agrQuoteCustomSetting;

        Apttus__APTS_Agreement__c agreementAMESA = TST_CLM_TestDataFactory.createAgreement(CON_CLM.AMESA_RECORDTYPEID, false);
        agreementAMESA.Name = 'Test AMESA Agreement';
        agreementAMESA.Apttus__Account__c = TST_CLM_TestDataFactory.createAccount('TEST AMESA ACCOUNT', true).Id;
        agreementAMESA.Apttus_QPComply__RelatedProposalId__c =  parentBudget.Id;
        insert agreementAMESA;

    }
    
    @isTest
    static void testAfterClone(){
        Test.startTest();
        List <Apttus_Proposal__Proposal__c> budgets = [SELECT Id, Name, Apttus_Proposal__RelatedProposalId__c FROM Apttus_Proposal__Proposal__c];
        Apttus_Proposal__Proposal__c parentBudget;
        Apttus_Proposal__Proposal__c childBudget;
        
        for(Apttus_Proposal__Proposal__c record : budgets){
            if (record.Apttus_Proposal__RelatedProposalId__c == NULL)
                parentBudget = record;
            else if (record.Apttus_Proposal__RelatedProposalId__c != NULL)
                childBudget = record;
        }
        
        CPQ_ProposalLifecycle obj = new CPQ_ProposalLifecycle();
        
        obj.afterClone(parentBudget, childBudget);
        Test.stopTest();
        
        System.assertEquals(childBudget.Apttus_Proposal__RelatedProposalId__c, parentBudget.Id, 
                            'Budget clone from field of ChildBudget should be updated to ParentBudget');
    }

    @isTest
    static void testAfterCreateAgreement(){
        
        Apttus_Proposal__Proposal__c proposal = [SELECT Id, Name, Apttus_Proposal__RelatedProposalId__c,Select_Pricing_Tool__c FROM Apttus_Proposal__Proposal__c 
                                                       WHERE Apttus_Proposal__RelatedProposalId__c = null LIMIT 1];
        Apttus__APTS_Agreement__c amesaAGR = [SELECT Id,RecordTypeId FROM Apttus__APTS_Agreement__c WHERE  Name = 'Test AMESA Agreement' LIMIT 1];
        CPQ_ProposalLifecycle obj = new CPQ_ProposalLifecycle();

        Test.startTest();
            obj.afterCreateAgreement(proposal, amesaAGR);
        Test.stopTest();
        
        System.assertEquals(amesaAGR.Select_Pricing_Tool__c, proposal.Select_Pricing_Tool__c, 'The fields are not copied when expected');
    }
}