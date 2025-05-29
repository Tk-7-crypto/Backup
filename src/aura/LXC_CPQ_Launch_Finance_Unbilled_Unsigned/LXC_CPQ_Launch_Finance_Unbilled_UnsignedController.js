({
    doInit : function(component, event, helper) {
        component.set("v.isOpen", true);
    },
    
    closeModel : function(component, event, helper) {
        component.set("v.isOpen", false);
    },
    
    LaunchFinance : function(component, event, helper) {
        component.set("v.appName", 'Finance Unbilled_Unsigned');
        helper.LaunchFinance(component, event, helper);
    }
})