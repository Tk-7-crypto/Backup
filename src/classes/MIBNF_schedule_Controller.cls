public class MIBNF_schedule_Controller {
    
    Public boolean showbutton{get; private set;}
    private static String MATERIAL_TYPE = 'ZREP';
    public BNF_Settings__c bnfSetting {get; set;}
    public String opportunityNumber {get; set;}    
    public MIBNF_schedule_Controller(ApexPages.StandardController controller) {
        showbutton = false;      
        MIBNF_Component__c bnf = (MIBNF_Component__c)controller.getRecord();
        bnf = [select id, Opportunity__c from MIBNF_Component__c where id =: bnf.id limit 1];
        bnfSetting =BNF_Settings__c.getInstance();
        //system.assert(false, 'bnfSetting.BNF_Opportunity_Threshold__c = ' + bnfSetting.BNF_Opportunity_Threshold__c);	
        
        //get the list of junction objects      
        List<MI_BNF_LineItem__c> lstJo = [Select Id, Opportunity_Line_Itemid__c,MIBNF_Component__c From MI_BNF_LineItem__c 
                                          where MIBNF_Component__c = :bnf.Id];
        //put all the opplineitem ids in a set from the list of JO 
        Set<Id> JoOppLineItemidSet = new set<Id>();
        for (MI_BNF_LineItem__c MibnfLi :lstJo)
        {
            JoOppLineItemidSet.add(MibnfLi.Opportunity_Line_Itemid__c);
        }
        	    	
        
        for(OpportunityLineItem oppLineItem : [select Opportunity.opportunity_number__c, PricebookEntry.Product2.material_type__c, PricebookEntry.Product2.Item_Category_Group__c from OpportunityLineItem where Id in :JoOppLineItemidSet ]) {
            if((oppLineItem .PricebookEntry.Product2.material_type__c == MATERIAL_TYPE) || (oppLineItem.PricebookEntry.Product2.Material_Type__c =='ZPUB' && oppLineItem.PricebookEntry.Product2.Item_Category_Group__c == 'ZLIC')){
		    	if(bnfSetting.BNF_Opportunity_Threshold__c != null) {
		    		opportunityNumber = oppLineItem.Opportunity.opportunity_number__c;
		    		try {
			    		if(opportunityNumber !=null && opportunityNumber != '' && bnfSetting.BNF_Opportunity_Threshold__c < Integer.valueOf(opportunityNumber)) {
			    			showbutton = true;
			    		} else {
			    			showbutton = false;
			    		}
		    		} catch(Exception exp) {
		    			showbutton = false;
		    		}
		    	} else {
		    		showbutton = true;
		    	}
		    		//system.assert(false, 'bnfSetting.BNF_Opportunity_Threshold__c = ' + bnfSetting.BNF_Opportunity_Threshold__c  + ', opportunityNumber = ' + opportunityNumber + ', showbutton = ' + showbutton);		    	
              break;
           }
        }
        
    }   
}