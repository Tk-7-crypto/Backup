({
    getOpportunityRecord: function(component, event, helper) {
        var action = component.get("c.getOpportunityDetails");
        var fieldList = [];
        fieldList.push("Id");
        fieldList.push("Name");
        fieldList.push("AccountId");
        fieldList.push("Account.Name");
        fieldList.push("CloseDate");
        fieldList.push("Amount");
        fieldList.push("Owner.Name");
        fieldList.push("OwnerId");
        fieldList.push("CurrencyISOCode");
        action.setParams({
            oppId: component.get("v.recordId"),
            oppFields: fieldList
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.OpportunityRecord", response.getReturnValue());
                if(response.getReturnValue().Amount != null){
                    var oppAmount = parseFloat(response.getReturnValue().Amount);
                    component.set("v.OpportunityAmount", oppAmount.toFixed(2));                
                }
            } else if(state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var errorMsg = JSON.parse(errors[0].message).errorList;
                        helper.setToast(component, event, helper, errorMsg, "error", "Error!");
                    }
                }
            }
            $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
        });
        $A.enqueueAction(action);
    },
    
	getQuoteRecord: function(component, event, helper) {
        var action = component.get("c.getQuoteDetails");
        var fieldList = [];
        fieldList.push("Id");
        fieldList.push("Name");
        fieldList.push("CurrencyISOCode");
        action.setParams({
            quoteId: component.get("v.recordId"),
            quoteFields: fieldList
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.QuoteRecord", response.getReturnValue());
            } else if(state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var errorMsg = JSON.parse(errors[0].message).errorList;
                        helper.setToast(component, event, helper, errorMsg, "error", "Error!");
                    }
                }
            }
            $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
        });
        $A.enqueueAction(action);
    },
    
    scrollEventCall : function() {
        var header = document.getElementById("headerDiv");
        var detailSection = document.getElementById("oppDetailSection");
        var image = document.getElementById("oppImage");
        var OppHeaderTitle = document.getElementById("OppHeaderTitle");
        var scrollTop = document.documentElement.scrollTop;
        if(scrollTop > 30) {
            $A.util.addClass(header, "changeHeader");
            $A.util.addClass(detailSection, "slds-hide");
            $A.util.addClass(image, "imageChange");
            $A.util.addClass(OppHeaderTitle, "slds-hide");
        } else {
            $A.util.removeClass(header, "changeHeader");
            $A.util.removeClass(detailSection, "slds-hide");
            $A.util.removeClass(image, "imageChange");
            $A.util.removeClass(OppHeaderTitle, "slds-hide");
        }
    }
})