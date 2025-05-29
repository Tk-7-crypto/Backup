({
    validateForExsistingProxyObjects : function(component, event, helper) {
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "start"}).fire();
        var action = component.get("c.validateProxyObjectRecords");
        var OpportunityId = component.get("v.OpportunityId");
        action.setParams({ 
            "opportunityId" : OpportunityId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var oppRecord = component.get("v.targetOpp");
                if(oppRecord.StageName == '6. Received ATP/LOI' || oppRecord.StageName == '7a. Closed Won' || oppRecord.StageName == '7b. Closed Lost' || oppRecord.StageName == 'In-Hand') {
                    var changeBtnComp = component.find("changeBtn");
                    var errorList = [];
                    errorList.push('Opportunities that are in Stage '+oppRecord.StageName+' cannot have the currency changed.'); 
                    component.set("v.errors", errorList);
                    component.set("v.HasProxyObject", true);
                    $A.util.addClass(changeBtnComp, "slds-hide");
                }
                else if(oppRecord.In_Hand_Stage_Entry__c != null) {
                    var changeBtnComp = component.find("changeBtn");
                    var errorList = [];
                    errorList.push('Currency cannot be modified since this Opportunity passed through "In Hand" Stage.'); 
                    component.set("v.errors", errorList);
                    component.set("v.HasProxyObject", true);
                    $A.util.addClass(changeBtnComp, "slds-hide");
                }
                else {
                    var errorMsg = response.getReturnValue();
                    if(errorMsg.length > 0) {
                        var changeBtnComp = component.find("changeBtn");
                        var errorList = [];
                        errorList.push(errorMsg); 
                        component.set("v.errors", errorList);
                        component.set("v.HasProxyObject", true);
                        $A.util.addClass(changeBtnComp, "slds-hide");
                    }
                }
                helper.getCurrencyIsoCodeFieldValues(component, event, helper); 
            }
            else if(state === "ERROR") {
                $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var errorMsgList = JSON.parse(errors[0].message).errorList;
                        component.set("v.errors", errorMsgList);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    getCurrencyIsoCodeFieldValues : function(component, event, helper) {
        var action = component.get("c.getSobjectFieldDetail");
        var fieldList = ["CurrencyIsoCode"];
        action.setParams({ 
            objectName : "Opportunity",
            fieldList : fieldList
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var objectFieldsWrapperList = response.getReturnValue();
                if(objectFieldsWrapperList.length > 0) {
                    var pickListFieldsMap = {};
                    var currencyValuesMap = {};
                    for(var count in objectFieldsWrapperList) {
                        var fieldWrapper = objectFieldsWrapperList[count];
                        if(fieldWrapper.fieldDataType =="PICKLIST") {
                            if(fieldWrapper.fieldApiName == "currencyisocode") {
                                var fieldValuesMap = fieldWrapper.fieldValuesMap;
                                component.set("v.RequestedCurrencyIsoCode", "--None--");
                                component.set("v.CurrencyMap", fieldValuesMap);
                                var fieldListOptions = [];
                                var CurrentCurrency;
                                var targetObject = component.get("v.targetOpp");
                                for (var keyValue in fieldValuesMap) {
                                   fieldListOptions.push(fieldValuesMap[keyValue]);
                                }
                                component.set("v.CurrencyISOList", fieldListOptions);
                                component.set("v.CurrentCurrency", fieldValuesMap[targetObject.CurrencyIsoCode]);
                            }
                        }
                    }               
                }
                $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
            }
            else if(state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var errorMsgList = JSON.parse(errors[0].message).errorList;
                        component.set("v.errors", errorMsgList);
                    }
                }
                $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    changeCurrency : function(component, event, helper) {
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "start"}).fire();
        var isAllCorrect = helper.validateFields(component, event, helper);
        if(!isAllCorrect) {
            $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
            return;
        }
        var action = component.get("c.changeCurrencyOfOpportunity");
        var OpportunityId = component.get("v.OpportunityId");
        var currencyMap = component.get("v.CurrencyMap");
        var requestedCurrencyIsoCode ;
        for (var keyValue in currencyMap) {
            if(currencyMap[keyValue] == component.get("v.RequestedCurrencyIsoCode")){
            	requestedCurrencyIsoCode = keyValue;
            }
        }
        action.setParams({
            "opportunityId" : OpportunityId,
            "requestedCurrencyType" : requestedCurrencyIsoCode 
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                $A.get("e.force:closeQuickAction").fire();
                window.location.href = "/" + OpportunityId;
                $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
            }
            else if(state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log('errors2'+errors[0].message);
                        var errorMsgList = JSON.parse(errors[0].message).errorList;
                        component.set("v.errors", errorMsgList);
                    }
                }
                $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
            }
            
        });
        $A.enqueueAction(action);
    },
    
    validateFields : function(component, event, helper) {
        var currentISOCode = component.get("v.targetOpp.CurrencyIsoCode");
        var errorList =[];
        var isAllCorrect = true;
        var requestedCurrencyComp = component.find("requestedCurrency");
        var requestCurrencyType = component.get("v.RequestedCurrencyIsoCode") ;
        var currencyMap = component.get("v.CurrencyMap");
        for (var keyValue in currencyMap) {
            if(currencyMap[keyValue] == component.get("v.RequestedCurrencyIsoCode")){
            	requestCurrencyType = keyValue;
            }
        }
        if(requestCurrencyType == undefined || requestCurrencyType == null || requestCurrencyType == '--None--' ) {
            $A.util.addClass(requestedCurrencyComp, "slds-has-error");
            $A.util.removeClass(requestedCurrencyComp, "hide-error-message");
            isAllCorrect = false;
            errorList.push("Please make sure a currency is selected.");
        } 
        else if(requestCurrencyType == currentISOCode) {
            $A.util.addClass(requestedCurrencyComp, "slds-has-error");
            $A.util.removeClass(requestedCurrencyComp, "hide-error-message");
            isAllCorrect = false;
            errorList.push("Please choose a different currency is selected than the current currency.");
        } else {
            $A.util.removeClass(requestedCurrencyComp, "slds-has-error");
            $A.util.addClass(requestedCurrencyComp, "hide-error-message");
            component.set("v.errors", []);
        }
        if(errorList.length > 0) {
            component.set("v.errors", errorList);
        }
        return isAllCorrect;
    },   
})