@isTest
public class TST_UTL_CPQ_DeleteQuoteLineItems 
{
    @isTest
    public static void testDeleteQuoteLineItems()
    {         
        Account acc = UTL_TestData.createAccount();
        insert acc;
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        OWF_Config__c owfConfig = UTL_OWF_TestData.createOWFConfig(grp.Id);
        insert owfConfig;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.Line_of_Business__c = CON_CPQ.SAMPLE_LINE_OF_BUSINESS;
        opp.CurrencyIsoCode = CON_CPQ.USD;
        opp.Is_this_IQVIA_Biotech__c = CON_CPQ.YES_TITLE_CASE;
        opp.Legacy_Quintiles_Opportunity_Number__c = CON_CPQ.TEST_OPPORTUNITY_NUMBER;
        insert opp;
        Bid_History__c testClinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
        testClinicalBid.Budget_Tools__c = CON_CPQ.UNIT_PRICING_TOOL;
        update testClinicalBid;
        Apttus_Proposal__Proposal__c quote = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, testClinicalBid.Id);
        
        List<Product2> prodList = new List<Product2>();
        Product2 prod = TST_TestGeneratorClass.buildTestProduct('COMPLETE CONSENT LICENSES', 'Bundle', 'US_DD_STUDLIC', '', '');       
        prod.CanUseRevenueSchedule = true;
        prod.Billing_System__c = CON_CPQ.SAP;
        prodList.add(prod);
        insert prodList;
        
        List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemList = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        proposalLineItemList.add(new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = quote.Id, Apttus_QPConfig__NetPrice__c = 2000, Apttus_Proposal__Product__c= prodList[0].Id, Apttus_QPConfig__OptionId__c = prodList[0].Id, Apttus_Proposal__Quantity__c = 1, Apttus_QPConfig__ExtendedPrice__c = 100, Cost_Price__c = 110, Apttus_QPConfig__PrimaryLineNumber__c = 2));
        proposalLineItemList.add(new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = quote.Id, Apttus_QPConfig__NetPrice__c = 2000, Apttus_Proposal__Product__c= prodList[0].Id, Apttus_Proposal__Quantity__c = 1, Apttus_QPConfig__PrimaryLineNumber__c = 1));
        insert proposalLineItemList;
        
        Attachment attach = UTL_TestData.createAttachment();
        attach.Name = 'FINAL_123.xlsb';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId = quote.Id;
        attach.contentType = CON_CPQ.ATTACHMENT_CONTENT_TYPE;
        insert attach;
        
        RestRequest request = new RestRequest();
        request.requestUri = URL.getOrgDomainUrl().toExternalForm() + '/services/apexrest/DeleteAGRLineItems/' + quote.Id;
        request.httpMethod = CON_CPQ.GET;
		
        RestContext.request = request;
		
        Test.startTest();
            UTL_CPQ_DeleteQuoteLineItems.ResponseObject responseObj = UTL_CPQ_DeleteQuoteLineItems.deleteQuoteLineItems();
        Test.stopTest();
        
        System.assertEquals(true, responseObj.isSuccess);
    }
}