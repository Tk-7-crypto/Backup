/**************************************************************************************************/
// This Trigger Sync MIBNF LineItem Price with Opportunity LineItem
// Created by : Himanshu Parashar
// Date : 19 oct 2011
/**************************************************************************************************/

trigger MI_BNF_PriceUpdate on OpportunityLineItem (after update) {
     /*Update by :Sunil Kumar Sharma : Issue IM1342651 : If condition added to reduce Too many SOQL queries on Create change Request functionality - START
      * Flad is set to true when create change request is processed and Pricing calculator triggers are hault.
      */
     if(!Global_Variables.PCTrigger_Hault_Execution){
         Map<id,Double> oliMap=new Map<id,Double>();
         List<id> oppid=new List<id>();
         List<id> oliid=new List<id>();
         List<MI_BNF_LineItem__c> MIBNF_LineItem_Update_List = new List<MI_BNF_LineItem__c>();
         MI_BNF_LineItem__c MI_BNFLineItem;
    
          
         for(OpportunityLineItem oli : Trigger.new)
         {
            if(oli.TotalPrice!=null && oli.TotalPrice!=Trigger.oldMap.get(oli.id).TotalPrice)
            {
                oppid.add(oli.Opportunityid);
                oliid.add(oli.id);
                oliMap.put(oli.id,oli.TotalPrice);
            }
         }
         
         if(oliid.size()>0)
         {
             for(MI_BNF_LineItem__c MIBNF_LineItemList : [select id,Total_Price__c,Opportunity_Line_Itemid__c from MI_BNF_LineItem__c where MIBNF_Component__r.MIBNF__r.Opportunity__r.Id in :oppid and Opportunity_Line_Itemid__c in : oliid])
             {
                  MI_BNFLineItem=new MI_BNF_LineItem__c(id=MIBNF_LineItemList.id);
                  MI_BNFLineItem.Total_Price__c=oliMap.get(MIBNF_LineItemList.Opportunity_Line_Itemid__c);
                  MIBNF_LineItem_Update_List.add(MI_BNFLineItem);
                   
             }
             if(MIBNF_LineItem_Update_List.size()>0)
                 update MIBNF_LineItem_Update_List;
         }
     }
}