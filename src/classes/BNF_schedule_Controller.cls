public class BNF_schedule_Controller {
    
    Public boolean showbutton{get; private set;}
    private static String MATERIAL_TYPE = 'ZREP';
    public BNF_Settings__c bnfSetting;
    public String opportunityNumber {get; set;}
    public BNF_schedule_Controller(ApexPages.StandardController controller) {
        showbutton = false;
        BNF2__c bnf = (BNF2__c)controller.getRecord();
        bnf = [select id, Opportunity__c from BNF2__c where id =: bnf.id limit 1];
        //system.debug('bnf.opportunity__c = ' + bnf.Opportunity__c );
         bnfSetting =BNF_Settings__c.getInstance();
        for(OpportunityLineItem oppLineItem : [select Opportunity.opportunity_number__c, PricebookEntry.Product2.material_type__c, PricebookEntry.Product2.Item_Category_Group__c from OpportunityLineItem where Opportunity.id =/*'006Q0000007D88h']){//*/: bnf.Opportunity__c ]) {
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
              break;
           }
        }
    }   
}