({
    checkVisibility : function(component) {
        var action = component.get("c.checkComponentVisibility");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                              
                var isComponentVisible = response.getReturnValue();
                component.set("v.isComponentVisible", isComponentVisible);             
            }
            else if(state === "ERROR") {
                var errors = response.getError();
                this.handleErrors(errors);
            }
        });
        $A.enqueueAction(action);
    },
    
    loadPicklistValues : function(component) {
        var action = component.get("c.getPickListValues");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                              
                var result = response.getReturnValue();
                var correctiveFieldsMap = JSON.parse(result);
                component.set("v.correctiveFieldsMap", correctiveFieldsMap);             
            }
            else if(state === "ERROR") {
                var errors = response.getError();
                this.handleErrors(errors);
            }
        });
        $A.enqueueAction(action);
    },
    
    handleErrors : function(errors) {
        var toastParams = {
            title: "Error",
            message: "Unknown error", 
            type: "error"
        };
        if (errors && Array.isArray(errors) && errors.length > 0) {
            toastParams.message = errors[0].message;
        }
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
    }
})