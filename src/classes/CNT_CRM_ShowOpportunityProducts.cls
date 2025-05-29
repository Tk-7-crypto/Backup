public class CNT_CRM_ShowOpportunityProducts {
    public BNF2__c bNFRecord{get; private set;}
    public String OpportunityLineItemListStr{get; private set;}
    public CNT_CRM_ShowOpportunityProducts(ApexPages.StandardController stdController) {
        Id bNFId = ApexPages.currentPage().getParameters().get('id');
        BNF_Settings__c bnfSetting = BNF_Settings__c.getInstance();
        Set<String> excludedProducts = new Set<String>();
        if(bnfSetting.Excluded_Products__c != null) {
            excludedProducts = new Set<String>(bnfSetting.Excluded_Products__c.split('\\|'));
        }
        if(bNFId != null){
            bNFRecord = [select Id,Opportunity__c,CurrencyIsoCode,Addendum__c from BNF2__c where id =: bNFId];
            List<OpportunityLineItem> OpportunityLineItemList = [Select Id, PricebookEntry.Name,Book_No__c,CurrencyISOCode,Position_Number__c,TotalPrice,Delivery_Media__c,PricebookEntry.ProductCode,Billing_Frequency__c,Proj_Rpt_Frequency__c, Discount_Percentage_Formula__c,Product_Start_Date__c,Product_End_Date__c, Product_Invoice_Text__c,Nbr_of_Users__c, Delivery_Country__c, Discount_Reason__c,PO_line_item_number__c, Invoice_Date__c,Therapy_Area__c, Revised_Price__c, Cancel_Text__c From OpportunityLineItem where OpportunityId =:bNFRecord.Opportunity__c  and Product_Material_Type__c NOT IN :excludedProducts order by PricebookEntry.ProductCode asc, Product_Start_Date__c asc];
            OpportunityLineItemListStr = JSON.serialize(OpportunityLineItemList);
        }
    }
}