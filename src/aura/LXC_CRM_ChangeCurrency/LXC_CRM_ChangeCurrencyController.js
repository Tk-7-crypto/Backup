({
    doInit : function(component, event, helper) {
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "start"}).fire();
    },
    
    changeCurrency : function(component, event, helper) {
        helper.changeCurrency(component, event, helper);
    },
    
    handleRecordUpdated : function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
           helper.validateForExsistingProxyObjects(component, event, helper);
        }
    },
    
    closeQuickAction : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})