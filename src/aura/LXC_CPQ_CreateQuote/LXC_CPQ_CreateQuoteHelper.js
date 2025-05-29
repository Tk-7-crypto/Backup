({
    getOpportunityRelatedQuotesDetails: function(component, event, helper) {
        var action = component.get("c.getRelatedQuotesDetails");
        action.setParams({
            "isCreateQuoteFromOpportunity": component.get("v.isCreateQuoteFromOpportunity"),
            "contractId": component.get("v.recordId")
        });
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            var sobjectName = "Apttus_Proposal__Proposal__c";
            if (state === "SUCCESS") {
                var result = actionResult.getReturnValue();
                component.set("v.allQuoteDetailsObj", result);
                component.set("v.showSpinner", false);
                if (!result.isStatusClosedForInternalPurposes && (result.isOpportunityExist)) {
                    this.callChildFunction(component, event);
                }
            } else if (state === "ERROR") {
                var errors = actionResult.getError();
                if (errors && errors[0] && errors[0].message) {
                    var errorMsg = errors[0].message;
                    this.setToast(component, event, helper, errorMsg, "error", "Error!");
                }
                component.set("v.showSpinner", false);
            }
        });
        $A.enqueueAction(action);
    },
    callChildFunction : function (component, event) {
        var childCmp = component.find("childComp");
        childCmp.initiateCall();
    },
    setToast: function(component, event, helper, message, type, title) {
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
