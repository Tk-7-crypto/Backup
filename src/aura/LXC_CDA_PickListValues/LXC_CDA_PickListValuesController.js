({
	doInit : function(component, event, helper) {
		var action = component.get("c.getPicklistValues");
        action.setParams({
            "objectType" : component.get("v.sObjectName"),
            "selectedField" : component.get("v.fieldName")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == "SUCCESS") {
                component.set("v.picklistValues", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
	}
})