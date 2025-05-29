({
    doInit: function(component, event, helper) {
        helper.getOpportunityRelatedQuotesDetails(component, event, helper);
        if (component.get("v.sObjectName") == 'Contract') {
            component.set("v.contractId", component.get("v.recordId"));
        }
    },
    handleYesConfirmation : function(component, event, helper) {
        component.set('v.showConfirmation', false);
        component.set('v.cloneConfirmed', true);
        helper.callChildFunction(component, event);
    },
    handleNoConfirmation : function(component, event, helper) {
        component.set('v.showConfirmation', false);
        component.set('v.cloneConfirmed', false);
        $A.get("e.force:closeQuickAction").fire();
    }
})
