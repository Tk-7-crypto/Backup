public class CNT_CRM_ShowOpportunityProductsMDM {
    public BNF2__c bNFRecord{get; private set;}
    public String OpportunityLineItemListStr{get; private set;}
    public Boolean wbsCodeCheck {get; private set;}
    public Boolean isPrebillingSalesCode {get; private set;}
    public CNT_CRM_ShowOpportunityProductsMDM(ApexPages.StandardController stdController) {
        isPrebillingSalesCode = false;
        Id bNFId = ApexPages.currentPage().getParameters().get('id');
        BNF_Settings__c bnfSetting = BNF_Settings__c.getInstance();
        Set<String> excludedProducts = new Set<String>();
        if(bnfSetting.Excluded_Products__c != null) {
            excludedProducts = new Set<String>(bnfSetting.Excluded_Products__c.split('\\|'));
        }				
        if(bNFId != null){
            bNFRecord = [select Id,Opportunity__c,CurrencyIsoCode,Addendum__c, Sales_Org_Code__c from BNF2__c where id =: bNFId];
            Set<String> prebillingSalesOrgSet = new Set<String>{'MX02', 'GT01', 'CO01', 'CO71'};
            if(prebillingSalesOrgSet.Contains(bNFRecord.Sales_Org_Code__c)) {
                isPrebillingSalesCode = true;
            }
            List<OpportunityLineItem> OpportunityLineItemList = [Select Id, PricebookEntry.Name,Book_No__c,CurrencyISOCode,Position_Number__c,TotalPrice,Delivery_Media__c,UnitPrice,
                                                                 PricebookEntry.ProductCode,Billing_Frequency__c, Proj_Rpt_Frequency__c, Sales_Text__c, Discount_Percentage_Formula__c,
                                                                 Product_Start_Date__c,Product_End_Date__c, Product_Invoice_Text__c,Nbr_of_Users__c,PO_line_item_number__c, Delivery_Country__c, 
                                                                 Discount_Reason__c, Invoice_Date__c,Therapy_Area__c, Revised_Price__c, Cancel_Text__c, WBS__c, WBS__r.Name, WBS_R_Element__c,
                                                                 Business_Line__c, Business_Type__c, Service_Line__c, Practice_Area__c, Other_Ship_To_Address__r.Name, Other_Ship_To_Address__c, Prebilling__c  From OpportunityLineItem 
                                                                 where OpportunityId =:bNFRecord.Opportunity__c  and Product_Material_Type__c NOT IN :excludedProducts 
                                                                 order by PricebookEntry.ProductCode asc, Product_Start_Date__c asc];
            OpportunityLineItemListStr = JSON.serialize(OpportunityLineItemList);
            for(Integer i = 0 ; i < OpportunityLineItemList.size() ; i++) {
                if(!String.isEmpty(OpportunityLineItemList[i].WBS_R_Element__c)) {
                    wbsCodeCheck = true;
                }
            }
        }
    }
}