({
    getAllOpportunityRelatedAgreements: function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var budgetTool = component.get("v.simpleRecord").Budget_Tools__c;
        var oppId = component.get("v.simpleRecord").Bid_History_Related_Opportunity__c;
        var action = component.get("c.getAllRelatedBudgets");
        action.setParams({
            "opportunityId": oppId,
            "pricingTool": component.get("v.selectedBudgetTool")
        });
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
                var result = actionResult.getReturnValue();
                component.set("v.allDetailsObj", result);
                var records = result.budgetWrapperList;
                records.forEach(function(record) {
                    record.BudgetLink = '/' + record.Id;
                });
                component.set("v.budgetList", records);
                var isBudgetToolEmpty = false;
                if (budgetTool == null) {
                    component.set("v.isBudgetToolEmpty", true);
                    isBudgetToolEmpty =true;
                }
                if (records.length > 0) {
                    component.set("v.BudgetExist", true);
                } else if (!isBudgetToolEmpty) {
                    component.set("v.showCreateBudget", true);
                    var childCmp = component.find("childComp")
                    childCmp.initiateCall();
                }
                this.setColumns(component);
            } else if (state === "ERROR") {
                var errors = actionResult.getError();
                if (errors && errors[0] && errors[0].message) {
                    var errorMsg = errors[0].message;
                    this.setToast(component, event, helper, errorMsg, "error", "Error!");
                }
            }
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);
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
    },
    setColumns: function(component) {
        var budgetTool = component.get("v.simpleRecord").Budget_Tools__c;
        component.set('v.columns', 
            [{label: 'Record Type', fieldName: 'recordType', type: 'text', initialWidth: 120, cellAttributes: { alignment: 'right' }},
            {label: 'Mark as Primary', fieldName: 'isPrimary', type: 'boolean', initialWidth: 120, cellAttributes: { alignment: 'right' }},
            {label: 'Name', fieldName: 'BudgetLink', type: 'url', initialWidth: 120, typeAttributes: {label: { fieldName: 'name' }, target: '_blank', cellAttributes: { alignment: 'right' }}},
            (budgetTool == 'LCS UPT' || budgetTool == 'GRA UPT' || budgetTool == 'Unit Pricing Tool') ? 
            {label: 'Total Value', fieldName: 'totalBidValue', type: 'number', initialWidth: 120, cellAttributes: { alignment: 'right' }} : 
            {label: 'Total Quote Value', fieldName: 'totalQuoteValue', type: 'number', initialWidth: 120, cellAttributes: { alignment: 'right' }},
            {label: 'Scenario Number', fieldName: 'scenarioNumber', type: 'number', initialWidth: 140, cellAttributes: { alignment: 'right' }},
            {label: 'Scenario', fieldName: 'scenario', type: 'text', initialWidth: 100, cellAttributes: { alignment: 'right' }},
            {label: 'Scenario Description', fieldName: 'scenarioDes', type: 'text', initialWidth: 140, cellAttributes: { alignment: 'right' }},
            {label: 'Budget Iteration', fieldName: 'budgetIteration', type: 'number', initialWidth: 140, cellAttributes: { alignment: 'right' }},
            {label: 'Bid Sent Date', fieldName: 'bidSentDate', type: 'date', initialWidth: 130, cellAttributes: { alignment: 'right' }}]);
    },
    
    showErrorAndCloseWindow: function(component, event, helper) {
    	helper.setToast(component, event, helper, "You cannot create a Quote record with the selected Budget tool.", "error", "Error!");
    	$A.get("e.force:closeQuickAction").fire();
    }
})