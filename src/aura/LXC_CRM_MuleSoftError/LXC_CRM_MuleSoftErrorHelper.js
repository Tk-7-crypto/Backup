({
	getMulesoftOpportunitySyncByOppId : function(component, event, helper) {
        var oppIdList = [];
        oppIdList.push(component.get("v.recordId"));
        var errorField = component.get("v.errorType");
        var action = component.get("c.getMulesoftOpportunitySyncByOppIds");
        action.setParams({
            "oppIdList" : oppIdList
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var mulesoftOppSync = response.getReturnValue();
                var errorMessage = mulesoftOppSync[0][errorField];
                if(errorMessage == undefined) {
                    errorMessage = null;
                }
                var errorLabel = "Legacy IMS MuleSoft Error : ";
                if(errorField == "LQ_Mulesoft_Error_Message__c") {
                    errorLabel = "Legacy Quintiles MuleSoft Error : "; 
                }
                component.set("v.mulesoftOppSync", mulesoftOppSync[0]);
                component.set("v.errorMessage", errorMessage);
                component.set("v.errorLabel", errorLabel);
            } else if(state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var errorMsg = JSON.parse(errors[0].message).errorList;
                        console.log(errorMsg);
                    }
                }
            }
        });
        $A.enqueueAction(action);
	}
})