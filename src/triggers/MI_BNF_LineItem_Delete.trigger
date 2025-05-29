trigger MI_BNF_LineItem_Delete on OpportunityLineItem (after delete) {
    
     Map<id,id> oliMap=new Map<id,id>();

     List<MI_BNF_LineItem__c> MIBNF_LineItem_Delete_List = new List<MI_BNF_LineItem__c>();
    
     List<id> oliid=new List<id>();
     List<id> oppid=new List<id>();
     set<id> RTCD = new set<id>();
     MI_BNF_LineItem__c MI_BNFLineItem;
     List<Opportunity> UpdatedOpp=new List<Opportunity>();
     Boolean isOppUpdaterequired=false;
      
     for(OpportunityLineItem oli : Trigger.old)
     {
        oppid.add(oli.Opportunityid);
        oliid.add(oli.id);
        oliMap.put(oli.id,oli.id);
        if(oli.Revenue_dynamics__c!=null)
        {
            RTCD.add(oli.Revenue_dynamics__c);
        }
     }
     
     for(MI_BNF_LineItem__c MIBNF_LineItemList : [select id,Opportunity_Line_Itemid__c from MI_BNF_LineItem__c where MIBNF_Component__r.MIBNF__r.Opportunity__r.Id in :oppid and Opportunity_Line_Itemid__c in : oliid])
     {
          MI_BNFLineItem=new MI_BNF_LineItem__c(id=MIBNF_LineItemList.id);
          MIBNF_LineItem_Delete_List.add(MI_BNFLineItem);
           
     }
    
     // Added by : Himanshu : 29 Jan 2014 : Delete Renewal Task change details 
     List<Renewal_Task_Change_Detail__c> DeleteRtcd=new List<Renewal_Task_Change_Detail__c>([select id from Renewal_Task_Change_Detail__c where id in : RTCD and type__c='New']); // Delete Renewal Task change details
     if(DeleteRtcd.size()>0)
         delete DeleteRtcd;
     
     if(MIBNF_LineItem_Delete_List.size()>0)
     delete MIBNF_LineItem_Delete_List;
     
     //Added By : Himanshu : ER-1013 : 6 nov 2014
     for(Opportunity Opp : [SELECT ID,/*Enterprise_lead__c,Relationship_Manager__c,*/
     (SELECT id FROM OpportunityLineItems where PricebookEntry.Product2.Offering_Type__c = 'Technology & Applications' and Delivery_Country__c='USA')
                            FROM Opportunity where id in : oppid])
     {
         if(Opp.OpportunityLineItems.size()==0)
         {/*
             if(Opp.Enterprise_lead__c!=null)
             {
                 Opp.Enterprise_lead__c=null;
                 isOppUpdaterequired=true;
             }       
             if(Opp.Relationship_Manager__c!=null)
             {
                  Opp.Relationship_Manager__c=null;
                  isOppUpdaterequired=true;
             }
             */
             if(isOppUpdaterequired)
                 UpdatedOpp.add(Opp);
         
         }
         
         
     }
     
     //Update opp if Tech and Apps removed
     if(UpdatedOpp.size()>0)
         update UpdatedOpp;
     
}