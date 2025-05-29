({
	fetchRecordTypesHelper : function(component, event, helper) {
		var action = component.get("c.fetchRecordTypes");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                component.set("v.RecordTypeList",returnValue);
            }else if(state === "ERROR") {
                
            }
        });
        $A.enqueueAction(action);
	},
    getContractFieldSetHelper : function(component, event, helper) {
		var action = component.get("c.getContractFieldSet");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                component.set("v.FieldSet",returnValue);
            }else if(state === "ERROR") {
                
            }
        });
        $A.enqueueAction(action);
	},
    getContractFromIdHelper : function(component, event, helper) {
		var action = component.get("c.getContractFromId");
        var recordIds = component.get("v.recordId");
        action.setParams({
            recordId : recordIds
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                component.set("v.ContractRecord",returnValue);
            }else if(state === "ERROR") {
            }
        });
        $A.enqueueAction(action);
	}
})