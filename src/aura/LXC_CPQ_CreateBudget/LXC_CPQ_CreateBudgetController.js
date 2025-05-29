({
    doInit: function(component, event, helper) {
        var action = component.get("c.checkPostAward");
        var budgetTool;
        action.setParams({
            'recordId' : component.get("v.recordId")
        });
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
                var result = actionResult.getReturnValue();
                if (!result.isSuccess) {
                    component.set("v.showSpinner", false);
                    helper.setToast(component, event, helper, result.errorMsg, 'Error', 'Error!');
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();
                } else {
                    if ((component.get("v.simpleRecord").Record_Type_Developer_Name__c) == 'Contract_Post_Award' || (component.get("v.simpleRecord").Record_Type_Developer_Name__c) == 'Clinical_Bid') {
                        component.set("v.isPostAwardBid", true);
                    }
                    budgetTool = component.get("v.simpleRecord").Budget_Tools__c;
                    if(budgetTool != null && result == true && component.get("v.simpleRecord").Record_Type_Developer_Name__c == 'Clinical_Bid') {
                        if(budgetTool != 'LCS UPT' && budgetTool != 'GRA UPT' && budgetTool != 'Unit Pricing Tool') {
                            helper.showErrorAndCloseWindow(component, event, helper);
                        }
                    }
                    component.set("v.clinicalBidId", component.get("v.recordId"));
                    component.set("v.oppId", component.get("v.simpleRecord").Bid_History_Related_Opportunity__c);
                    component.set("v.selectedBudgetTool", budgetTool);
                    component.set("v.name", component.get("v.simpleRecord").Name);
                    helper.getAllOpportunityRelatedAgreements(component, event, helper);
                    if (budgetTool != 'LCS UPT' && budgetTool != 'GRA UPT' && budgetTool != 'Unit Pricing Tool') {
                        var a = component.get('c.cloneBudget');
                        $A.enqueueAction(a);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    setBudgetToBeClonedId: function(component, event, helper) {
        var rows = event.getParam('selectedRows');
        component.set("v.selectedBudgetRecord", rows[0]);
    },
    cloneBudget: function(component, event, helper) {
        var budgetTool = component.get("v.simpleRecord").Budget_Tools__c;
        var selectedBudget = component.get("v.selectedBudgetRecord");
        if (selectedBudget == null && !(budgetTool != 'LCS UPT' && budgetTool != 'GRA UPT' && budgetTool != 'Unit Pricing Tool')) {
            helper.setToast(component, event, helper, "Please select Budget to Clone to continue.", "error", "Error!");
		 
        } else {
            component.set("v.showCreateBudget", true);
            var childCmp = component.find("childComp")
            childCmp.initiateCall();
        }
    }
})
