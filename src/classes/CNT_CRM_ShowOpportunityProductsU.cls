public class CNT_CRM_ShowOpportunityProductsU {
    public BNF2__c bNFRecord{get; private set;}
    public String OpportunityLineItemListStr{get; private set;}
    public CNT_CRM_ShowOpportunityProductsU(ApexPages.StandardController stdController) {
        Id bNFId = ApexPages.currentPage().getParameters().get('id');
        if(bNFId != null){
            bNFRecord = [select Id,Opportunity__c,CurrencyIsoCode,Addendum__c from BNF2__c where id =: bNFId];
            List<OpportunityLineItem> OpportunityLineItemList = [Select Id, PricebookEntry.Name,Book_No__c,CurrencyISOCode,TotalPrice,Delivery_Media__c,PricebookEntry.ProductCode,Billing_Frequency__c,Proj_Rpt_Frequency__c, Discount_Percentage_Formula__c,Product_End_Date__c,Product_Start_Date__c, Product_Invoice_Text__c,Nbr_of_Users__c, Delivery_Country__c, Discount_Reason__c, Invoice_Date__c,Therapy_Area__c, Revised_Price__c, Cancel_Text__c From OpportunityLineItem where OpportunityId =:bNFRecord.Opportunity__c order by PricebookEntry.ProductCode asc, Product_Start_Date__c asc];
            OpportunityLineItemListStr = JSON.serialize(OpportunityLineItemList);
        }
    }
}