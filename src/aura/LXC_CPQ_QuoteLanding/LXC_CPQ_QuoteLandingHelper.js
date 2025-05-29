({
    redirectToQuoteCreatePage : function(component){
        var recordTypeId = component.get('v.selectedRecordType');
        var pricingTool = component.get('v.selectedpricingTool');
        var oppId = component.get("v.recordId");
        component.set("v.showSpinner", true);
        var action = component.get("c.createQuote");
        action.setParams({
            'pricingTool' : pricingTool,
            'recordTypeId' : recordTypeId,
            'opportunityId' : oppId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if((response.getReturnValue()) == 'AgreementExist'){
                this.setToast(component, event, helper, 'Quote/Proposal cannot be created as Agreement already present on the opportunity.', 'Error', 'Error!');
                component.set("v.showSpinner", false);
                $A.get("e.force:closeQuickAction").fire();
                $A.get('e.force:refreshView').fire();
            } else {
                if (state === "SUCCESS") {
                    component.set("v.showSpinner", false);
                    this.setToast(component, event, helper, 'Quote Created Successfully!!!', 'Success', 'Success');
                    var sObjectEvent;
                    sObjectEvent = $A.get("e.force:navigateToSObject");
                    sObjectEvent.setParams({
                        "recordId": response.getReturnValue(),
                        "slideDevName": "detail"
                    });
                    sObjectEvent.fire();
                }
                else if (state === "ERROR") {
                    component.set("v.showSpinner", false);
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        var errMessage = errors[0].message;
                        this.setToast(component, event, helper, errMessage, 'Error', 'Error!');
                        $A.get("e.force:closeQuickAction").fire();
                        $A.get('e.force:refreshView').fire();
                    }
                }
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
    
	
    checkClinicalBid : function(component, event, helper) {
        var oppId = component.get("v.recordId");
        var lineOfBusiness = component.get("v.simpleRecord").Line_of_Business__c; 
        if (lineOfBusiness != "Clinical") {
            var errMessage = "You cannot create Quote from this line of business.";
            this.setToast(component, event, helper, errMessage, 'Error', 'Error!');
            $A.get("e.force:closeQuickAction").fire();  
        } else {
            var action = component.get("c.validClinicalBid");
            action.setParams({
                'opportunityId' : oppId
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.showSpinner", false);
                    if (!response.getReturnValue()) {
                        var errMessage = "You cannot create Quote from this Opportunity as Bid History record exists";
                        this.setToast(component, event, helper, errMessage, 'Error', 'Error!');
                        $A.get("e.force:closeQuickAction").fire();
                    } else {
                        component.set("v.showSpinner", false);
                        component.set("v.showCreateBudgetScreenForRDS", true);
                    }
                } else if (state === "ERROR") {
                    component.set("v.showSpinner", false);
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                    var errMessage = errors[0].message;
                    this.setToast(component, event, helper, errMessage, 'Error', 'Error!');
                    $A.get('e.force:refreshView').fire();
                    }
                }
            });
            $A.enqueueAction(action);
            }
    }
})
