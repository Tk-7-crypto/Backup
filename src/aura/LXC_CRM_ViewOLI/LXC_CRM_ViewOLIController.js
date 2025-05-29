({ 
    doInit : function(component, event, helper) {
        helper.getOliItems(component, event, helper);
    },
    
    editRecord : function(component, event, helper) {
        helper.editRecord(component, event, helper);
    },
    
    editAllRecord : function(component, event, helper) {
        helper.editAllRecord(component, event, helper);
    },
    
    navigateToRecord : function(component, event, helper) {
        helper.navigateToRecord(component, event, helper);
    },
    
    deleteRecord : function(component, event, helper) {
        helper.deleteRecord(component, event, helper);
    },
    
    reload: function(component, event, helper) {
        helper.getOliItems(component, event, helper);
    },
    
    resolveLineItem : function(component, event, helper) {
        helper.resolveLineItem(component, event, helper, "resolve");
    },
    
    showpopover : function(component, event, helper) {
        helper.togglePopOver(component, event, helper, true);
    },
    
    hidepopover : function(component, event, helper) {
        helper.togglePopOver(component, event, helper, false);
    },
    
    changeLineItem : function(component, event, helper) {
        helper.resolveLineItem(component, event, helper, "change");
    },
    
    cloneRecord : function(component, event, helper) {
        helper.cloneRecord(component, event, helper);
    },
})