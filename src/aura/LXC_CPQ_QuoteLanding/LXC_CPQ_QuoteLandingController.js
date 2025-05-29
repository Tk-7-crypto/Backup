({
	doInIt : function(component, event, helper) {
        component.set("v.showSpinner", true);
        var action = component.get("c.getAvaiableRecordTypes");
        action.setParams({
            'opportunityId' : component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                var quoteRecordTypes = response.getReturnValue();
                if(quoteRecordTypes){
                    if (quoteRecordTypes.length == 0) {
                        component.set("v.showSpinner", false);
                        component.set("v.showRecordTypeSelection", true);
                        component.set("v.isDisplayRecordTypes", false);
                        component.set("v.showError", true);
                    }else{
                        component.set("v.quoteRecordTypes", quoteRecordTypes);
                        
                        // For only one record type, bypass record type selection UI and create proposal based on that record type
                        if (quoteRecordTypes.length == 1) {
                            component.set("v.showRecordTypeSelection", false);
                            component.set("v.selectedRecordType" , quoteRecordTypes[0].value);
                            if(quoteRecordTypes[0].label == 'RDS Budget') {
                                helper.checkClinicalBid(component);
                            }
                            else {
                                if(quoteRecordTypes[0].label == 'Tech Solution' && quoteRecordTypes[0].associatedTools.length == 1) {
                                    component.set("v.selectedpricingTool", quoteRecordTypes[0].associatedTools[0]);
                                    helper.redirectToQuoteCreatePage(component);
                                }
                                else if(quoteRecordTypes[0].label == 'Tech Solution' && quoteRecordTypes[0].associatedTools.length > 1){
                                    var optionValues = [];
                                    for(var j=0; j<quoteRecordTypes[0].associatedTools.length; j++){
                                        optionValues.push({'label':quoteRecordTypes[0].associatedTools[j],'value':quoteRecordTypes[0].associatedTools[j]});
                                    }
                                    component.set("v.pricingToolsOptions",optionValues);
                                    component.set("v.showSpinner", false);
                                    component.set("v.showPricingTools", true);
                                    component.set("v.showButtons", true);
                                }
                            }
                        
                        }else{
                            // For more than one record type, display record type selection UI
                            component.set("v.showRecordTypeSelection", true);
                            component.set("v.showButtons", true);
                            component.set("v.showSpinner", false);
                        }
                    }
                } else {
                    helper.setToast(component, event, helper, 'Due to inactive status of the Account selected on the Opportunity, the Quote cannot be created.', 'Error', 'Error!');
                    component.set("v.showSpinner", false);
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();
                }
            }
        });
        $A.enqueueAction(action);
	},
    
    redirectToQuoteCreatePageAction : function(component, event, helper){
        var pricingTool = component.get('v.selectedpricingTool');
        if (pricingTool == undefined) {
            var errorMsg = 'Please select a pricing tool!';
            helper.setToast(component, event, helper, errorMsg, 'Error', 'Error!');
        }else {
            component.set("v.showSpinner", true);
            helper.redirectToQuoteCreatePage(component);
        }
    },

    closeQuickAction : function(component, event, helper) {
        component.set("v.showSpinner", true);
        $A.get("e.force:closeQuickAction").fire();
    },
    handleSelectedRecordType: function(component, event, helper) {
        component.set("v.showSpinner", true);
        var recordType = component.get('v.selectedRecordType');
        if (recordType == undefined) {
            component.set("v.showSpinner",false);
            var errorMsg = 'Please select a record type!';
            helper.setToast(component, event, helper, errorMsg, 'Error', 'Error!');
        } else {
            component.set("v.showRecordTypeSelection", false);
            var recordTypeList = component.get('v.quoteRecordTypes');
            var isRDSBudget = false;
            Object.values(recordTypeList).forEach(val => {
                if(val.value == recordType && val.label == 'RDS Budget') {
                isRDSBudget = true;        
                }
            });
            if (isRDSBudget) {
                component.set("v.showButtons", false);
                helper.checkClinicalBid(component);
            } else {
                var pricingTools;
                for(var temp in recordTypeList) {
                    if(recordType == recordTypeList[temp].value) {
                        pricingTools = recordTypeList[temp].associatedTools;
                    }
                }
                if(pricingTools != null) {
                    var optionValues = [];
                    for(var j=0; j<pricingTools.length; j++){
                        optionValues.push({'label':pricingTools[j],'value':pricingTools[j]});
                    }
                    if(pricingTools.length == 1) {
                        component.set("v.showButtons", false);
                        component.set("v.selectedpricingTool", optionValues[0].value);
                        helper.redirectToQuoteCreatePage(component);
                    } else {
                        component.set("v.pricingToolsOptions",optionValues);
                        component.set("v.showPricingTools", true);
                        component.set("v.showSpinner", false);
                    }
                }
            }
        }
    }
})
