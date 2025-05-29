trigger MI_BNF_OLI_Revised_Price on MI_BNF_LineItem__c (before insert) {

     
     set<String> OLIIDs = new Set<String>(); 
     set<ID> componentIds = new Set<ID>();
     List<Opportunitylineitem> UpdateOLI= new List<OpportunityLineitem>(); 
     
     for(MI_BNF_LineItem__c Lineitem : Trigger.new)
     {
         componentIds.add(Lineitem.MIBNF_Component__c);
     }
     
     Map<ID, MIBNF_Component__c> componentMap = new Map<ID, MIBNF_Component__c>([select id, Addendum__c from MIBNF_Component__c where id IN: componentIds]);    
     for(MI_BNF_LineItem__c Lineitem : Trigger.new)
     {
         /*if (LineItem.MIBNF_Component__r.Addendum__c == false)
         	OLIIDs.add(Lineitem.Opportunity_Line_Itemid__c);*/
         
         //Update by: Suman Sharma Date: 31 March, 2017 : Issue-10628 ---Start----
         Lineitem.MIBNFComponent_OLI_ID__c = Lineitem.MIBNF_Component__c + Lineitem.Opportunity_Line_Itemid__c; 
         //---End----         
         if (componentMap.get(LineItem.MIBNF_Component__c).Addendum__c == false)
         	OLIIDs.add(Lineitem.Opportunity_Line_Itemid__c);         	
         	
     }
     
     for(Opportunitylineitem objOLI: [select id,revised_price__c from Opportunitylineitem where id in : OLIIDs])
     {
          objOli.revised_price__c=null;
          objOli.Revised_Revenue_Schedule__c = null;
          UpdateOLI.add(objOLI);
     }
     
      if(UpdateOLI.size()>0)
      {
         Update UpdateOLI; 
      }

}