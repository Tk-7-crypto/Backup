({
	doInit : function(component, event, helper) {
        component.set('v.isLoading', true);              
        helper.getValidationMessages(component, event, helper);
	},
    showSpinner: function(component) {
        component.set("v.spinner", true); 
    },
    hideSpinner : function(component){
        component.set("v.spinner", false); 
    },
    backToOpportunity : function(component, event, helper) {
        var url = "/one/one.app#/sObject"; 
        window.open(url+"/"+component.get("v.opportunityId"),"_parent");        
    },
    handleCancelActiveQuotes : function(component, event, helper) {
      component.set('v.isLoading', true);
      helper.processCancelActiveQuotes(component, event, helper);    
    },
    handleCancelQuoteDialogBox : function(component, event, helper) {
      component.set("v.showQuoteWarning",false);
      var url = "/one/one.app#/sObject"; 
      window.open(url+"/"+component.get("v.opportunityId"),"_parent");
    },
})