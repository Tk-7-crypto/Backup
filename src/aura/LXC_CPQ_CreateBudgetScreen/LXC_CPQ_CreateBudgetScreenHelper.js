({
    getScenarioList: function(component, event, helper, developerName) {
        var proposalObjectName = 'Apttus_Proposal__Proposal__c';
        var scenario = 'RFP_Scenario__c';
        var opportunityId = component.get("v.oppId");
        var action = component.get("c.getPicklistvalues");
        action.setParams({
            "objectName": proposalObjectName,
            "field_apiname": scenario,
            "developerName":developerName,
            "opportunityId" : opportunityId
        });
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
                var result = actionResult.getReturnValue();
                component.set("v.budgetTypeList", result.budgetTypes);
                component.set("v.scenarioByBudgetMap", result.scenarioByBudgetTypeMap);
            }
        });
        $A.enqueueAction(action);
    },
    getScenarioListPost: function(component, event, helper, quoteCreatedFrom, bidRecordType, reqAgmtType, opportunityId) {
        var proposalObjectName = 'Apttus_Proposal__Proposal__c';
        var scenario = 'RFP_Scenario__c';
        var opportunityId = component.get("v.oppId");
        var action = component.get("c.getBudgetTypesValues");
        action.setParams({
            "objectName": proposalObjectName,
            "field_apiname": scenario,          
            "bidRecordType":bidRecordType,
            "quoteCreatedFrom":quoteCreatedFrom,
            "reqAgmtType" :reqAgmtType,
            "opportunityId":opportunityId
        });
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
                var result = actionResult.getReturnValue();
                component.set("v.budgetTypeList", result.budgetTypes);
                component.set("v.scenarioByBudgetMap", result.scenarioByBudgetTypeMap);
            }
        });
        $A.enqueueAction(action);
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
    },
    checkIsFieldAccessible: function(component, event, helper) {
        var budgetTool = component.get("v.selectedBudgetTool");
        var action = component.get("c.isFieldAccessible");
        action.setParams({
            "pricingTool": budgetTool
        });
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
                var result = actionResult.getReturnValue();
                component.set("v.isFieldAccessible", result);
            }
        });
    },
    handleBudgetTypeChange: function(component, event, helper) {
        var budgetType = component.find("budgetType").get("v.value");
        if(budgetType == '-- None --') {
            component.set("v.scenarioList", null);
        } else if(budgetType != null) {
			component.set("v.scenarioList", component.get("v.scenarioByBudgetMap")[budgetType]);
        }
	}
})