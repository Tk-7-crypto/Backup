@isTest
public class TST_SLT_ProposalProductAttributeValue {
    
/**
* This method used to set up testdata
*/ 
    @testSetup
    static void dataSetup() 
    {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;  
        Apttus_Proposal__Proposal__c quote = UTL_TestData.setTSProposalData(true, CON_CPQ.TECH_SOLUTION, opp.Id, CON_CPQ.OCE);			 
        
        Apttus_Proposal__Proposal_Line_Item__c quoteLineItem = UTL_TestData.createQuoteLineItem(quote.Id);
        quoteLineItem.IQVIA_Line_Type__c = CON_CPQ.CRM_Product;
        insert quoteLineItem;
        
        Apttus_QPConfig__ProposalProductAttributeValue__c proposalProdAttribute = new Apttus_QPConfig__ProposalProductAttributeValue__c();
        proposalProdAttribute.Apttus_QPConfig__LineItemId__c = quoteLineItem.Id;
        proposalProdAttribute.O_Country__c = 'India';
        insert proposalProdAttribute;
    }
    
    @IsTest
    static void testGetProposalAttributeRecords() {
        
        Apttus_QPConfig__ProposalProductAttributeValue__c proposalProdAttribute = [SELECT Id FROM Apttus_QPConfig__ProposalProductAttributeValue__c LIMIT 1];
        Set<String> attributeSet = new Set<String>{'O_Country__c'};
        Test.startTest();
            Map<Id, Apttus_QPConfig__ProposalProductAttributeValue__c> attributeValue = new SLT_ProposalProductAttributeValue().getProposalAttributeRecords(new Set<Id>{proposalProdAttribute.Id}, attributeSet);
            Map<Id, Apttus_QPConfig__ProposalProductAttributeValue__c> attributeValue1 = new SLT_ProposalProductAttributeValue(true).getProposalAttributeRecords(new Set<Id>{proposalProdAttribute.Id}, attributeSet);
        Test.stopTest();
		
        System.assertEquals(attributeValue.size()>0, true, 'Proposal Product Attribute Value record exists');
        System.assertEquals(attributeValue1.size()>0, true, 'Proposal Product Attribute Value record exists');
    }
    
}