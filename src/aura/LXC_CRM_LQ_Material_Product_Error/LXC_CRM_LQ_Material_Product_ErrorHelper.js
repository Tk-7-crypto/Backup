({
	getErrorLQMaterialProduct : function(component, event, helper) {
        var action = component.get("c.getErrorIfLQMaterialProducts");
        action.setParams({
            "oppId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var errorMessageURL = response.getReturnValue();
                if(errorMessageURL.length == 0) {
                    component.set("v.errorMessageURL", null);
                    component.set("v.errorMessage1", null);
                    component.set("v.errorMessage2", null);
                } else {
                    var errorMessage1 = "You can\'t update stage of this opportunity as mandatory fields need to be completed in legacy Quintiles org. Please click ";
                    var errorMessage2 = " to enter required details";
                    component.set("v.errorMessageURL", errorMessageURL);
                    component.set("v.errorMessage1", errorMessage1);
                    component.set("v.errorMessage2", errorMessage2);
                }
            } else if(state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log(errors[0].message);
                    }
                }
            }
        });
        $A.enqueueAction(action);
	}
})