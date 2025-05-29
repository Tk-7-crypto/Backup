({
    doInit : function(component, event, helper) {
        helper.checkVisibility(component);
        var caseId = component.get("v.recordId");
        component.set("v.caseId", caseId); 
        helper.loadPicklistValues(component);
        component.set("v.cssStyle", "<style>.cuf-scroller-outside {background: rgb(255, 255, 255) !important;}</style>");
    },
    
    showSpinner: function(component, event, helper) {
        component.set("v.Spinner", true); 
    },
    
    hideSpinner : function(component, event, helper) {
        component.set("v.Spinner", false);
    },
})