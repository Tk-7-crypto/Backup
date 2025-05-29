@isTest
public class TST_UTL_CPQ_DownloadExcel {

    static Apttus_Proposal__Proposal__c dataSetup(String pricingTool, String budgetTool) {
        
        Document documentRecord = UTL_TestData.createDocument(CON_CPQ.UPT_TEMPLATE_QUOTE, CON_CPQ.UPT_TEMPLATE_API, CON_CPQ.APPLICATION_PDF);
        documentRecord.IsPublic = true;
        documentRecord.FolderId = UserInfo.getUserId();
        insert documentRecord;
        
        Account testAccount = UTL_TestData.createAccount();
        insert testAccount;

        Opportunity testOpportunity= UTL_TestData.createOpportunity(testAccount.Id);
        testOpportunity.Line_of_Business__c = CON_CPQ.SAMPLE_LINE_OF_BUSINESS;
        testOpportunity.Is_this_IQVIA_Biotech__c = CON_CPQ.YES_TITLE_CASE;
        insert testOpportunity;

        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        OWF_Config__c owfConfig = UTL_OWF_TestData.createOWFConfig(grp.Id);
        insert owfConfig;
        Apttus_Config2__PriceList__c priceList = UTL_TestData.createPriceList();
        Id recordTypeId = SObjectType.Bid_History__c.getRecordTypeInfosByName().get(CON_CPQ.RECORD_TYPE_CLINICAL_BID).getRecordTypeId();
        Bid_History__c testClinicalBid = UTL_TestData.createClinicalBid();
        testClinicalBid.Bid_History_Related_Opportunity__c = testOpportunity.Id;
        testClinicalBid.RecordTypeId = recordTypeId;
        testClinicalBid.Opportunity_Type__c = CON_CPQ.OPPORTUNITY_TYPE_FSP;
        testClinicalBid.Budget_Tools__c = budgetTool;
        testClinicalBid.Unblinded_CVs_required__c = 'None';
        testClinicalBid.Is_PPT_Format_Required__c = 'No';
        insert testClinicalBid;
        
        Apttus_Proposal__Proposal__c quote = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, testClinicalBid.Id);
        quote.Apttus_QPConfig__PriceListId__c = priceList.Id;
        update quote;
        return quote;
    }
    
    @isTest
    static void testDownloadExcel() {
        	
        Apttus_Proposal__Proposal__c budget = dataSetup(CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, CON_CPQ.UNIT_PRICING_TOOL);
		
        ApexPages.currentPage().getParameters().put(CON_CPQ.ID, budget.Id);
        ApexPages.currentPage().getParameters().put(CON_CPQ.TOOL, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
        UTL_CPQ_DownloadExcel classInstance = new UTL_CPQ_DownloadExcel();
        
        Test.startTest();
            classInstance.downloadExcel();
        Test.stopTest();
        
        System.assertNotEquals(null, classInstance.returnString, 'Should return a page reference');
        
    }
	
    @isTest
    static void testDownloadExcelLCS() {
        	
        Apttus_Proposal__Proposal__c budget = dataSetup(CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_LCS_UPT, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_LCS_UPT_LABEL);
		
        ApexPages.currentPage().getParameters().put(CON_CPQ.ID, budget.Id);
        ApexPages.currentPage().getParameters().put(CON_CPQ.TOOL, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_LCS_UPT);
        UTL_CPQ_DownloadExcel classInstance = new UTL_CPQ_DownloadExcel();
        
        Test.startTest();
            classInstance.downloadExcel();
        Test.stopTest();
    }
    
    @isTest
    static void testDownloadExcelGRA() {
        	
        Apttus_Proposal__Proposal__c budget = dataSetup(CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_GRA_UPT_LABEL);
		
        ApexPages.currentPage().getParameters().put(CON_CPQ.ID, budget.Id);
        ApexPages.currentPage().getParameters().put(CON_CPQ.TOOL, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_GRA_UPT);
        UTL_CPQ_DownloadExcel classInstance = new UTL_CPQ_DownloadExcel();
        
        Test.startTest();
            classInstance.downloadExcel();
        Test.stopTest();
    }
    
    @isTest
    static void testDownloadExcelIQB() {
        	
        Apttus_Proposal__Proposal__c budget = dataSetup(CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, CON_CPQ.UNIT_PRICING_TOOL);
		
        ApexPages.currentPage().getParameters().put(CON_CPQ.ID, budget.Id);
        ApexPages.currentPage().getParameters().put(CON_CPQ.TOOL, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_IQB_UPT);
        UTL_CPQ_DownloadExcel classInstance = new UTL_CPQ_DownloadExcel();
        
        Test.startTest();
            classInstance.downloadExcel();
        Test.stopTest();
    }
}