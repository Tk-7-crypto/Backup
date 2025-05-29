({
    doInit : function(component, event, helper) {
        component.set("v.CloneScreen", true);
        component.set("v.InactiveProductScreen", false);
        helper.checkEmeaOpportunity(component, event, helper);
        helper.getStageFieldValues(component, event, helper);
    },
    
    handleChange: function (component, event) {
        var changeValue = event.getParam("value");
        if(changeValue === "Clone with Products") {
            component.set("v.isRenewalOptions", true);
        } else {
            component.set("v.isRenewalOptions", false);
        }
    },
    
    handleRecordUpdated : function(component, event, helper) {
    },
    
    cloneOpportunity : function(component, event, helper) {
        helper.openInactiveProductScreen(component, event, helper);
    },
    
    confirmcloneOpportunity : function(component, event, helper) {
        helper.doCloneOpportunity(component, event, helper);
    },
    
    closeQuickAction : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    
    setDecimalPlace : function(component, event, helper) {
        var inputComp = event.getSource();
        if(inputComp.get("v.value") == null || inputComp.get("v.value") == "") {
            event.getSource().set("v.value", 0.00);
        } else {
            var decimalValue = parseFloat(inputComp.get("v.value")).toFixed(2);
            event.getSource().set("v.value", decimalValue);
        }
    },
    
    showSpinner: function(component, event, helper) {
        component.set("v.Spinner", true);
    },
    
    hideSpinner : function(component, event, helper){
        component.set("v.Spinner", false);
    }
})