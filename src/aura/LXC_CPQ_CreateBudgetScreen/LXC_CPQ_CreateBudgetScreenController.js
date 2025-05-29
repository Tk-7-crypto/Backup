({
    initiateCall: function(component, event, helper) {
        component.set("v.showSpinner", true);
        helper.checkIsFieldAccessible(component, event, helper);
        var budgetTool = component.get("v.selectedBudgetTool");
        var isSFTool = false;
        var isInactive = false;
        if (component.get("v.quoteRecord") != null) {
            var action = component.get("c.setWrapper");
            action.setParams({
                "proposal":component.get("v.quoteRecord")
            });
            action.setCallback(this, function(actionResult) {
                var state = actionResult.getState();
                if (state === "SUCCESS") {
                    var result = actionResult.getReturnValue();	
                    component.set("v.quoteRecord", result);
                }
            });
            $A.enqueueAction(action);
            var existingQuote = component.get("v.quoteRecord");
            var isCreateFromBidHistory = component.get("v.isCreateFromBidHistory");
            var isCancelledPriamryQuoteByPass = component.get("v.isCancelledPriamryQuoteByPass");
            if (isCancelledPriamryQuoteByPass == false) {
                if (existingQuote.hasOwnProperty('Apttus_Proposal__Approval_Stage__c') == true && 
                   existingQuote.hasOwnProperty('Apttus_Proposal__Primary__c') == true){
                    if (existingQuote.Apttus_Proposal__Approval_Stage__c == "Cancelled" && existingQuote.Apttus_Proposal__Primary__c == true) {
                        component.set("v.isCancelledPriamryQuote",true);
                        component.set("v.showSpinner", false);
                    }
                } else {
                    if (existingQuote.approvalStage == "Cancelled" && existingQuote.isPrimary == true) {
                        component.set("v.isCancelledPriamryQuote",true);
                        component.set("v.showSpinner", false);
                    }
                }
            }
            var budgetTool = '';
            if (existingQuote.hasOwnProperty('Select_Pricing_Tool__c') == true) {
                budgetTool = existingQuote.Select_Pricing_Tool__c != null ? existingQuote.Select_Pricing_Tool__c : existingQuote.Budget_Tools__c;
            } else {
                budgetTool = existingQuote.pricingTool != null ? existingQuote.pricingTool : existingQuote.Budget_Tools__c;
            }
            if (existingQuote.hasOwnProperty('Select_Pricing_Tool__c') == true) {
            	component.set("v.selectedBudgetTool", existingQuote.Select_Pricing_Tool__c);
            } else {
                component.set("v.selectedBudgetTool", existingQuote.pricingTool);
            }
            if (existingQuote.hasOwnProperty('Select_Pricing_Tool__c') == true && 
               existingQuote.hasOwnProperty('Apttus_Proposal__Opportunity__c') == true && 
               existingQuote.hasOwnProperty('Name') == true) {
                component.set("v.budgetName", existingQuote.Select_Pricing_Tool__c != null ? existingQuote.Apttus_Proposal__Opportunity__r.Name : existingQuote.Name);
            } else {
                component.set("v.budgetName", existingQuote.pricingTool != null ? existingQuote.quoteName : existingQuote.budgetName);
            }
            if (existingQuote.hasOwnProperty('Apttus_Proposal__Opportunity__c') == true) {
            	component.set("v.oppId", existingQuote.Apttus_Proposal__Opportunity__c);
            } else {
            	component.set("v.oppId", existingQuote.oppId);
            }
            if (typeof existingQuote.Clinical_Bid__c !== "undefined") {
                component.set("v.clinicalBid", existingQuote.Clinical_Bid__c);
            }
            
            component.set("v.relatedQuoteId", existingQuote.Id);
            if (existingQuote.hasOwnProperty('RFP_Scenario__c') == true) {
            	component.set("v.parentScenario", existingQuote.RFP_Scenario__c);
            } else {
                component.set("v.parentScenario", existingQuote.scenario);
            }
            if (existingQuote.hasOwnProperty('Apttus_Proposal__Proposal_Category__c') == true) {
            	component.set("v.parentBudgetType", existingQuote.Apttus_Proposal__Proposal_Category__c);
            } else {
				component.set("v.parentBudgetType", existingQuote.budgetType);                
            }
            if (existingQuote.RFP_Scenario__c == "Inactive" || existingQuote.scenario == "Inactive") {
                component.set("v.isBudgetInactive", true);
                isInactive = true;
            }
        }
        if (component.get("v.relatedQuoteId") != null) {
            component.set("v.isRelatedQuoteExist", true);
        }
        if (!isInactive) {
            if (budgetTool == 'CPQ_UPT' || budgetTool == 'Unit Pricing Tool') {
                component.set("v.selectedPricingTool", "Unit Pricing Tool");
                isSFTool = true;
            } else if (budgetTool == 'GRA_UPT' || budgetTool == 'GRA UPT') {
                component.set("v.selectedPricingTool", 'GRA UPT');
                isSFTool = true;
            } else if (budgetTool == 'LCS_UPT' || budgetTool == 'LCS UPT') {
                component.set("v.selectedPricingTool", 'LCS UPT');
                isSFTool = true;
            } else {
                component.set("v.selectedPricingTool", component.get("v.selectedBudgetTool"));
            }
            if (isCreateFromBidHistory) {
                helper.getScenarioListPost(component, event, helper, 'Bid History', existingQuote.Record_Type_Developer_Name__c, existingQuote.Requested_Agreement_Type__c);
			} else if (component.get("v.isCreateQuoteFromOpportunity")) {
                helper.getScenarioList(component, event, helper, 'Clone_Quote_from_Opportunity');
            } else if (component.get("v.relatedQuoteId") != null) {
                helper.getScenarioList(component, event, helper, 'Clone_Quote_from_Existing_Quote');
            }
        }
        component.set("v.showSpinner", false);									  
    },
    
    clickCreate: function(component, event, helper) {
        component.set("v.showSpinner", true);
        if (component.get("v.isFieldAccessible")) {
            var budgetName = component.find("Name").get("v.value");
            var isCreateQuoteFromGenericContract = component.get("v.isCreateQuoteFromGenericContract");
            var isCreateQuoteFromOpportunity = component.get("v.isCreateQuoteFromOpportunity");
            if (isCreateQuoteFromGenericContract || isCreateQuoteFromOpportunity) {
                var budgetTool = component.find("nonSFPricingTool").get("v.value");  
            } else {
                var budgetTool = component.get("v.selectedBudgetTool");
            }
            var budgetId = component.get("v.relatedQuoteId");
            var budgetType = component.find("budgetType").get("v.value");
            var scenario = component.find("scenario").get("v.value");
            var scenarioDescription = component.find("scenarioDescription").get("v.value");
            var scenarioNumber = component.find("scenarioNumber").get("v.value");
            var budgetIteration;
            if (component.get("v.quoteRecord") != undefined && component.get("v.quoteRecord").budgetIteration != undefined) {
                budgetIteration = component.get("v.quoteRecord").budgetIteration;
            } else {
                budgetIteration =  component.get("v.budgetIteration");
            }
            var markAsPrimary = component.find("markAsPrimaryQuote").get("v.checked");
            var opportunityId = component.get("v.oppId");
            var contractId = component.get("v.contractId");
            var accountId = component.get("v.accountId");
            var clinicalBid = component.get("v.clinicalBid");
            var parentScenario = null;
            var parentBudgetType = null;
            if (budgetId != null) {
                parentScenario = component.get("v.parentScenario");
                parentBudgetType = component.get("v.parentBudgetType");
            }
            if (budgetName && budgetTool && budgetType && scenario && scenarioDescription && scenarioNumber && (scenarioNumber % 1 === 0)) {
                var action = component.get("c.createAnySobject");
                action.setParams({
                    "recordId" : clinicalBid,
                    "contractId" : contractId,
                    "budgetId": budgetId,
                    "name": budgetName,
                    "pricingTool": budgetTool,
                    "scenario": scenario,
                    "scenarioDescription": scenarioDescription,
                    "scenarioNumber": scenarioNumber,
                    "budgetIteration": budgetIteration,
                    "markAsPrimary": markAsPrimary,
                    "oppId": opportunityId,
                    "accId" :accountId,
                    "budgetType": budgetType,
                    "parentScenario" : parentScenario,
                    "parentBudgetType" : parentBudgetType
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        if (!response.getReturnValue().isSuccess) {
                			component.set("v.showSpinner", false);
                            helper.setToast(component, event, helper, response.getReturnValue().errorMsg, 'Error', 'Error!');
                            $A.get("e.force:closeQuickAction").fire();
                            $A.get('e.force:refreshView').fire();
                        } else {
                            var sObjectEvent = $A.get("e.force:navigateToSObject");
							sObjectEvent.setParams({
								"recordId": response.getReturnValue().budgetId,
								"slideDevName": "detail"
							});
							component.set("v.showSpinner", false);
							sObjectEvent.fire();
							if (budgetType == "Change Order") {
								var proposalId = response.getReturnValue().budgetId;
								window.open("/lightning/action/quick/Apttus_Proposal__Proposal__c.CNF_Linking_with_Change_Order?objectApiName&context=RECORD_DETAIL&recordId=" + proposalId + "&backgroundContext=%2Flightning%2Fr%2FApttus_Proposal__Proposal__c%2F" + proposalId + "%2Fview", "_self");
							}
						}
                    } else if (state === "ERROR") {
                        var errors = response.getError();
                        if (errors && errors[0] && errors[0].message) {
                            var errMessage = errors[0].message;
                            component.set("v.showSpinner", false);
                            helper.setToast(component, event, helper, errMessage, 'Error', 'Error!');
                            $A.get("e.force:closeQuickAction").fire();
                            $A.get('e.force:refreshView').fire();
                        }
                    }
                });
                $A.enqueueAction(action);
            } else {
                var errMessage = "Please fill all the mandatory fields."
                helper.setToast(component, event, helper, errMessage, 'Error', 'Error!');
                component.set("v.showSpinner", false);
            }
            
        } else {
            var errMessage = "You don't have permissions to edit these fields	!"
            helper.setToast(component, event, helper, errMessage, 'Error', 'Error!');
            $A.get("e.force:closeQuickAction").fire();
        }
    },
    handleNoConfirmation : function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
    handleYesConfirmation : function(component, event, helper) {
        component.set("v.isCancelledPriamryQuote",false);
        component.set("v.isCancelledPriamryQuoteByPass",true);
        var action = component.get('c.initiateCall');
        action.setParams({component: component,event: event,helper: helper});
        $A.enqueueAction(action);
    },
    handleBudgetTypeChange: function(component, event, helper) {
        helper.handleBudgetTypeChange(component, event, helper);
	}
})