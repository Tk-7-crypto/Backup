({
	isCurrentUserEligibleforCreatingQuoteOrAgreement : function(component, event) {
        
        var actionName = component.get("v.actionName");
        if(actionName != ''){
			var action = component.get("c.canCurrentUserCreateQuoteOrAgreement");
            action.setParams({
                "bidId": component.get("v.recordId"),
                "actionName": actionName
            });
            action.setCallback(this, function(actionResult) {
                var state = actionResult.getState();
                if (state === "SUCCESS") {
                    var result = actionResult.getReturnValue();
                    component.set("v.showSpinner", false); 
                    component.set("v.showError", !result);
                }
                else if (state === "ERROR") {
                    component.set("v.showSpinner", false); 
                    var errors = actionResult.getError();
                    if (errors && errors[0] && errors[0].message) {
                        var errorMsg = errors[0].message;
                        this.setToast(component, event, helper, errorMsg, "error", "Error!");
                    } 
                }
            });
            $A.enqueueAction(action);
        }
		
	},
    
    setToast: function (component, event, helper, message, type, title) {
        var errorMsg = message;
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            type: type,
            message: errorMsg
        });
        toastEvent.fire();
    }
    
   
})