({
    doInit : function(component, event, helper) {
        component.set("v.showSpinner", false);
    },
    closePopup : function(component, event, helper) {
        var parentPopUp = component.get("v.parent");
        parentPopUp.set("v.isInactivate",false);
    },
    saveData : function(component, event, helper) {
        component.set("v.showSpinner", true);
        if(component.find("reason").get('v.value'))
        {
            var reason = component.get("v.reason");
            var action = component.get("c.saveQuoteRecord");
            action.setParams({
                'proposalId' : component.get("v.recordId"),
                'reason' : reason
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                	component.set("v.showSpinner", false);
                    var parentPopUp = component.get("v.parent");
                    parentPopUp.set("v.isInactivate",false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": '',
                        "message": 'Budget has been marked as Inactive',
                        "type": 'success'
                    });
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                } 
                else {
                    console.log(state + 'error');
                }
            });
            $A.enqueueAction(action);
        }
        else
        {
            component.find("reason").reportValidity();
        }
    }
})