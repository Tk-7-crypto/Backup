({
    doInit : function(component, event, helper) {
        var action = component.get("c.getBudgetDetails");
        
        action.setParams({
            'recordId': component.get("v.recordId"),
            'objectName': component.get("v.sObjectName")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                console.log(returnValue);
                component.set("v.budgetDetails", returnValue);
            }
        });
        $A.enqueueAction(action);
    },
    openComposeEmail : function(component, event, helper) {
        component.set("v.isEmail", true);
    },
    openSignOffComposeEmail : function(component, event, helper) {
        component.set("v.isSignOffEmail", true);
    },
    openInvite : function(component, event, helper) {
        component.set("v.isInvite", true);
    },
    ClosePopUp: function(component, event, helper) {
        component.set("v.isInvite", false);
    }
})