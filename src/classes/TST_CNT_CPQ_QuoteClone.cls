@IsTest
public class TST_CNT_CPQ_QuoteClone {
    @TestSetup
    static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        acc.AccountCountry__c = 'AL';
        insert acc;

        Opportunity testOpportunity = UTL_TestData.createOpportunityData(acc.id, CON_CPQ.Q2_Solutions, CON_CPQ.COLLECTION_TOOL_TYPE_BIOSCIENCES, CON_CPQ.REGION_ASIA_PASIFIC, CON_CPQ.USD, false);
        insert testOpportunity;

        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;

        OWF_Config__c owfConfig = UTL_OWF_TestData.createOWFConfig(grp.Id);
        insert owfConfig;
        
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        
        Bid_History__c bidHistory = UTL_TestData.createBidHistoryData(acc.Id, testOpportunity.Id, UTL_TestData.getBidHistoryRecordtypeId(CON_CPQ.Q2_RECORDTYPE_DEVELOPER_NAME), false);
        insert bidHistory;

        Quote__c quote = UTL_TestData.createIqviaQuote(acc.Id, testOpportunity.Id, bidHistory.Id, CON_CPQ.Q2_Solutions, CON_CPQ.GBU_RDS, false);
        quote.Scenario__c = 2;
        insert quote;
        
        Apttus_Proposal__Proposal__c proposal = UTL_TestData.createProposalData(acc.Id, testOpportunity.Id, quote.Id, UTL_TestData.getProposalRecordtypeId(CON_CPQ.TECH_SOLUTION), CON_CPQ.Q2_Solutions, CON_CPQ.FINALIZED, false);
        insert proposal;

        Quote_Line_Item__C testQLI = UTL_TestData.createIqviaQuoteLineItem(quote.Id, CON_CPQ.Q2_Solutions, false);
        insert testQLI;

        Product2 prod = TST_TestGeneratorClass.buildTestProduct('SL-Development Metabolism', 'Bundle', 'Q_111813', 'US', 'Go Blue');
        prod.Apttus_Config2__HasOptions__c = true;
        prod.Apttus_Config2__HasAttributes__c = true;
        insert prod;
        
        CollectionTool__c collectionTool = UTL_TestData.createCollectionTool(bidHistory.Id, CON_CPQ.COLLECTION_TOOL_TYPE_BIOSCIENCES, false);
        collectionTool.ServiceLine__c = prod.Id;
        collectionTool.Site_Global__c = 'Indianapolis - ADME';
        collectionTool.Study_Type_Global__c = 'Method Feasibility';
        collectionTool.Species_Global__c = 'Baboon';
        collectionTool.Biological_Matrix_Global__c ='N/A';
        collectionTool.Compound_Molecules__c = 'dummy Molecule';
        collectionTool.Study_Number__c = 1;
        collectionTool.Number_of_Analyte_Global__c = '1';
        collectionTool.Clinical_Type_Global__c = 'Non-Clinical';
        insert collectionTool;

        Quote_Requisites__c quoteRequisite = UTL_TestData.createQuoteRequisites(quote.Id, CON_CPQ.STUDY_TYPE, false);
        quoteRequisite.Service_Line_Product__c = prod.Id;
        insert quoteRequisite; 

        CPQ_Settings__c cus1 =  new CPQ_Settings__c();
        cus1.Name =  'NameSpacePrefix';
        cus1.Package_Namespace_Prefix__c = 'Apttus_Config2;Apttus_Proposal;';
        insert cus1;

        CPQ_Proposal_Create_Settings__c customSettingsObjforQ2 = UTL_TestData.createCPQProposalCreateSettings(CON_CPQ.Q2_Solutions, 'CPQ_RDS_Q2_Solutions_ReadWrite', CON_CPQ.Q2_Solutions , true, 'Q2 Solutions-USD', false);
        customSettingsObjforQ2.Identified_Business__c = 'BioSciences;Vaccines';
        customSettingsObjforQ2.Line_of_Business__c = CON_CPQ.Q2_Solutions;
        insert customSettingsObjforQ2;
    }

    @IsTest
    static void cloneQuoteWithDetails_test() {
        Test.startTest();
            CNT_CPQ_QuoteClone.WPR_CPQ_WrapperClassToBeReturn res = new CNT_CPQ_QuoteClone.WPR_CPQ_WrapperClassToBeReturn();
            Quote__c  quote = [SELECT Id FROM Quote__c LIMIT 1];
            res = CNT_CPQ_QuoteClone.cloneQuoteWithDetails(quote.Id, false, CON_CPQ.BLANK, null, CON_CPQ.GBU_DPS, CON_CPQ.BLANK);
            CNT_CPQ_QuoteClone.WPR_CPQ_WrapperClassToBeReturn res2 = new CNT_CPQ_QuoteClone.WPR_CPQ_WrapperClassToBeReturn();
            res2 = CNT_CPQ_QuoteClone.cloneQuoteWithDetails(quote.Id, true, '1', null, CON_CPQ.GBU_DPS, CON_CPQ.BLANK);
            CNT_CPQ_QuoteClone.WPR_CPQ_WrapperClassToBeReturn res4 = new CNT_CPQ_QuoteClone.WPR_CPQ_WrapperClassToBeReturn();
            res4 = CNT_CPQ_QuoteClone.cloneQuoteWithDetails(quote.Id, false, CON_CPQ.BLANK, null, CON_CPQ.RECORD_TYPE_TECH_SOLUTION, CON_CPQ.CANCELLED_STATUS);
            try {
                CNT_CPQ_QuoteClone.WPR_CPQ_WrapperClassToBeReturn res3 = new CNT_CPQ_QuoteClone.WPR_CPQ_WrapperClassToBeReturn();
                res3 = CNT_CPQ_QuoteClone.cloneQuoteWithDetails('fakeId342423423423', false, CON_CPQ.BLANK, null, CON_CPQ.GBU_DPS, CON_CPQ.BLANK);
            } catch(Exception e) {
                system.assert(e !=null, e.getMessage());
            }
        Test.stopTest();
    }

    @IsTest
    static void testCloneQuoteWithDetailsForChangeOrder() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Opportunity oppClosedWonUpdate = UTL_TestData.createOpportunity(acc.Id);
        Opportunity opp = [Select Id from Opportunity Limit 1];
        oppClosedWonUpdate.Id = opp.Id;
        Contact cnt = UTL_TestData.createContact(acc.Id);
        insert cnt;
        OpportunityContactRole contactRole = UTL_TestData.createOpportunityContactRole(cnt.Id, oppClosedWonUpdate.Id);
        insert contactRole;
        Product2 product = UTL_TestData.createProduct();
        product.Hierarchy_Level__c = CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI;
        product.Offering_Group_Code__c = CON_CRM.OFFERING_GROUP_CODE_GLOBAL_RND;
        insert product;
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(oppClosedWonUpdate.Id, pbEntry.Id);
        insert oppLineItem;
        oppClosedWonUpdate.StageName = CON_CRM.CLOSED_WON_STAGE;
        oppClosedWonUpdate.QI_Invited_to_Present__c = 'No';
        update oppClosedWonUpdate;
        
        Quote__c  quote = [SELECT Id FROM Quote__c LIMIT 1];
        quote.Approval_Stage__c = CON_CPQ.ACCEPTED;
        quote.Related_Opportunity__c = oppClosedWonUpdate.Id;
        quote.Pricing_Tools__c = CON_CPQ.COMPLETE_CONSENT;
        quote.GBU__c = CON_CPQ.GBU_DPS;							   
        update quote;
        
        Test.startTest();
            CNT_CPQ_QuoteClone.WPR_CPQ_WrapperClassToBeReturn res = new CNT_CPQ_QuoteClone.WPR_CPQ_WrapperClassToBeReturn();
            res = CNT_CPQ_QuoteClone.cloneQuoteWithDetails(quote.Id, false, CON_CPQ.BLANK, null, CON_CPQ.GBU_DPS, CON_CPQ.BLANK);
        Test.stopTest();
        
        Assert.areEqual(CON_CPQ.CHANGE_ORDER, res.clonedQuote.Quote_Type__c, 'Change Order quote should be created.');
    }

    @IsTest
    static void testCloneQuoteWithDetailsForChangeOrderQ2() {
        Quote__c  quote = [SELECT Id FROM Quote__c LIMIT 1];
        quote.Approval_Stage__c = CON_CPQ.ACCEPTED;
        update quote;
        Bid_History__c bid = [SELECT Id FROM Bid_History__c LIMIT 1];
        bid.Bid_Type__c = CON_CPQ.CHANGE_ORDER;
        update bid;
        Test.startTest();
            CNT_CPQ_QuoteClone.WPR_CPQ_WrapperClassToBeReturn res = new CNT_CPQ_QuoteClone.WPR_CPQ_WrapperClassToBeReturn();
            res = CNT_CPQ_QuoteClone.cloneQuoteWithDetails(quote.Id, false, CON_CPQ.BLANK, null, CON_CPQ.GBU_DPS, CON_CPQ.BLANK);
        Test.stopTest();
        Assert.areEqual(CON_CPQ.CHANGE_ORDER, res.clonedQuote.Quote_Type__c, 'Change Order quote should be created.');
    }

    @IsTest
    static void getValidateData_test() {
        Test.startTest();
            Quote__c  quote = [SELECT Id, Related_Opportunity__c, Pricing_Tools__c FROM Quote__c LIMIT 1];
            String res = CNT_CPQ_QuoteClone.getValidateData(quote);
            System.assertEquals('Success', res, 'The desired result should be Success.');
        Test.stopTest();
    }
    @IsTest
    static void getQuotesList_test() {
        CNT_CPQ_QuoteClone.WPR_CPQ_WrapperClassToBeReturn res = new CNT_CPQ_QuoteClone.WPR_CPQ_WrapperClassToBeReturn();
        Test.startTest();
            Bid_History__c  bidH = [SELECT Id FROM Bid_History__c LIMIT 1];
            res = CNT_CPQ_QuoteClone.getQuotesList(bidH.Id);
            System.assertEquals('Success', res.message, 'The desired result should be Success.');
        Test.stopTest();
    }
    
    @IsTest
    static void testcloneQuoteLineItem() {
        Quote__c  quote = [SELECT Id from Quote__c LIMIT 1];
        Quote__c oldIQQuoteRecord = new SLT_IQVIA_Quote().getQuoteId(quote.Id, CON_CPQ.QUOTE_FIELDSET_FOR_COMMON_CLONE);
        Quote__c cloneIqQuote = new Quote__c(); 
        cloneIqQuote = oldIQQuoteRecord.clone();
        insert cloneIqQuote;
        Test.startTest();
            CNT_CPQ_QuoteClone.cloneQuoteLineItem(quote.Id, cloneIqQuote.Id);
        Test.stopTest();
        List<Quote_Line_Item__c> clonedItems = [SELECT Id FROM Quote_Line_Item__c WHERE Quote__c = :cloneIqQuote.Id];
        System.assertEquals(1, clonedItems.size(),'The number of cloned items does not match the expected size.');
    }
}