//  Trigger to select the product with the highest contract value.
//  This is used so that a product code can be inserted in the subject
//  line of the BNF submission email
trigger BNF_Select_Representative_Product on BNF2__c (before insert, before update) 
{
    if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_BNF_Trigger__c) {
        //  Get a map of all opportunities linked to BNF's
        Map<Id,Id> Opportunity_Id_Map = new Map<Id,Id>();
        for (BNF2__c BNF:Trigger.new)
        {
            if (Opportunity_Id_Map.containsKey(BNF.Opportunity__c) == false)
            {
                Opportunity_Id_Map.put(BNF.Opportunity__c,BNF.Opportunity__c);
            }
        }   
        //  Get a list of all line items linked to opps to which the BNF's belong. 
        //  Order the line items by descending contract value
        List<OpportunityLineItem> OLI_Array_All = new List<OpportunityLineItem>([select Id, OpportunityId, TotalPrice, PricebookEntry.Product2.ProductCode from OpportunityLineItem where OpportunityId in :Opportunity_Id_Map.keySet() order by OpportunityId, TotalPrice desc]);     
        List<OpportunityLineItem> OLI_Array_Ordered = new List<OpportunityLineItem>();
        Id LastId;
        //  Keep only one line item per opp - the line item with the highest value
        for (OpportunityLineItem OLI:OLI_Array_All)
        {
            if (OLI.OpportunityId!= LastId)
            {
                OLI_Array_Ordered.add(OLI);
            }
            LastId = OLI.OpportunityId;
        }
        //  Update the Product_SAP_Code__c field on the BNF to hold the SAP material
        //  code of the product with the highest contract value
        for (BNF2__c BNF:Trigger.new)
        {
            for (OpportunityLineItem OLI:OLI_Array_Ordered)
            {
                if (BNF.Opportunity__c == OLI.OpportunityId)
                {
                    BNF.Product_SAP_Code__c = OLI.PricebookEntry.Product2.ProductCode;
                }
            }
        }
    }
}