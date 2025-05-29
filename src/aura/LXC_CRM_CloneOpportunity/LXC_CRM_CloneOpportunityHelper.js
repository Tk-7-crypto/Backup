({
    getStageFieldValues : function(component, event, helper) {
        var action = component.get("c.getSobjectFieldDetail");
        var fieldList = ["StageName", "CurrencyIsoCode"];
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
                    for(var count in objectFieldsWrapperList) {
                        var fieldWrapper = objectFieldsWrapperList[count];
                        if(fieldWrapper.fieldDataType =="PICKLIST") {
                            if(fieldWrapper.fieldApiName == "stagename") {
                                var fieldValues = fieldWrapper.fieldValues;
                                var stageValues = [];
                                for(var stageValue in fieldValues) {
                                    if(fieldValues[stageValue].includes("--None--") || fieldValues[stageValue].includes("5") || fieldValues[stageValue].includes("6") || fieldValues[stageValue].includes("7") || fieldValues[stageValue].includes("In-Hand")) {
                                        
                                    } else {
                                        stageValues.push(fieldValues[stageValue]);
                                    }
                                }
                                pickListFieldsMap[fieldWrapper.fieldApiName] = stageValues;
                            } else if(fieldWrapper.fieldApiName == "currencyisocode"){
                                var fieldMap = fieldWrapper.fieldValuesMap;
                                var currencyCode = [];
                                var AscCurrencyCode = fieldWrapper.fieldValues.sort();
                                for(let i=0; i<AscCurrencyCode.length; i++){
                                    let value = AscCurrencyCode[i];
                                    let label = value + ' - ' + fieldWrapper.fieldValuesMap[value];
                                    if(label === "--None--" || value === "--None--"){
                                    }else{
                                        currencyCode.push({'label':label,'value':value});
                                    }
                                }
                                pickListFieldsMap[fieldWrapper.fieldApiName] = currencyCode;
                            } else {
                                pickListFieldsMap[fieldWrapper.fieldApiName] = fieldWrapper.fieldValues;
                            }
                        }
                    }
                    component.set("v.pickListFieldsMap", pickListFieldsMap);
                    helper.changeStageValue(component, event, helper);
                }
            }
            else if(state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var errorMsgList = JSON.parse(errors[0].message).errorList;
                        console.log(errorMsgList);
                        component.set("v.errors", errorMsgList);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    changeStageValue : function(component, event, helper) {
        var clonedOpp = component.get("v.clonedOpp");
        component.set("v.OpportunityName", clonedOpp["Name"]);
        var stageName = clonedOpp["StageName"];
        var pickListFieldsMap = component.get("v.pickListFieldsMap");
        var isStageFound = false;
        for(var stageValue in pickListFieldsMap["stagename"]) {
            if(stageName === pickListFieldsMap["stagename"][stageValue]) {
                isStageFound = true;
                break;
            }
        }
        if(!isStageFound) {
            clonedOpp["StageName"] =  pickListFieldsMap["stagename"][0];
            component.set("v.clonedOpp", clonedOpp);
        }
    },
    
    doCloneOpportunity : function(component, event, helper) {
        var clonedOpp = component.get("v.clonedOpp");
        var OpportunityId = component.get("v.OpportunityId");
        var selectedContactRoleOptions =  component.get("v.selectedContactRoleOptions");
        var selectedDrugProductOptions =  component.get("v.selectedDrugProductOptions");
        var selectedIQVIAQuoteOptions =  component.get("v.selectedIQVIAQuoteOptions");
        var RevenueDateShift =  component.get("v.RevenueDateShift");
        var PriceChangePercent =  component.get("v.PriceChangePercent");
        var selectedCloneOption =  component.get("v.selectedCloneOption");
        var isRoundUp =  component.get("v.isRoundUp");
        var isCloneProducts = false;
        if(selectedCloneOption == "Clone with Products") {
            isCloneProducts = true;
        }
        var isCloneContactRoles = false;
        if(selectedContactRoleOptions == "Clone with Contact Roles") {
            isCloneContactRoles = true;
        }
        var isCloneDrugProduct = false;
        if(selectedDrugProductOptions == "Clone with Drug Products") {
            isCloneDrugProduct = true;
        }
        var isCloneIqviaQuote = false;
        if(selectedIQVIAQuoteOptions == "Clone with IQVIA Quotes") {
            isCloneIqviaQuote = true;
        }
        var isRenewalOptions =  component.get("v.isRenewalOptions");
        var action = component.get("c.cloneOpportunityProducts");
        var mapTofieldValue = {};
        mapTofieldValue["CloseDate"] = clonedOpp["CloseDate"];
        mapTofieldValue["Name"] = clonedOpp["Name"];
        mapTofieldValue["StageName"] = clonedOpp["StageName"];
        mapTofieldValue["CurrencyIsoCode"] = clonedOpp["CurrencyIsoCode"];
        mapTofieldValue["Round_Up__c"] = isRoundUp; 
        var objectTypeToIsCloneMap = {};
        objectTypeToIsCloneMap["Product2"] = isCloneProducts;
        objectTypeToIsCloneMap["OpportunityContactRole"] = isCloneContactRoles;
        objectTypeToIsCloneMap["OpportunityDrugProduct"] = isCloneDrugProduct;
        objectTypeToIsCloneMap["IqviaQuote"] = isCloneIqviaQuote;
        objectTypeToIsCloneMap["RenewalOptions"] = isRenewalOptions;

        action.setParams({
            "opportunityId" : OpportunityId,
            "mapTofieldValue" : mapTofieldValue,
            "pricePercentAdjustment" : PriceChangePercent,
            "monthMoved" : RevenueDateShift,
            "objectTypeToIsCloneMap" : objectTypeToIsCloneMap
        });
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if(state === "SUCCESS") {
            	$A.get("e.force:closeQuickAction").fire();
                var createdOppId = actionResult.getReturnValue();
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": createdOppId,
                    "isredirect" : false
                });
                navEvt.fire();
            }
            else if(state === "ERROR") {
                var errors = actionResult.getError();
                console.log(errors);
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
    
    validateFields : function(component, event, helper) {
        var isAllCorrect = true;
        var oppNameComp = component.find("oppName");
        var oppName = oppNameComp.get("v.value");      
        
        var oppCloseDateComp = component.find("oppCloseDate");
        var oppCloseDate = oppCloseDateComp.get("v.value");
        
        var oppCurrencyCodeComp = component.find("oppCurrencyCode");
        var pricechangepercentComp = component.find("pricechangepercent");
        
        var isRenewalOptions = component.get("v.isRenewalOptions");
        var errorList = [];
        var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
        component.set("v.errors", null);
        var selectedCloneOption =  component.get("v.selectedCloneOption");
        var clonedOpp = component.get("v.clonedOpp");
        if(selectedCloneOption == "Clone without Products" && clonedOpp["StageName"] == "5. Finalizing Deal") {
            $A.util.addClass(oppNameComp, "slds-has-error");
            $A.util.removeClass(oppNameComp, "hide-error-message");
            isAllCorrect = false;
            errorList.push("You cannot create an Opportunity at the Stage Finalizing Deal, Received ATP/LOI, Closed Won or Closed Lost. Please review and revise.");
        }
        if(oppName == undefined || oppName == null || oppName == '' ) {
            $A.util.addClass(oppNameComp, "slds-has-error");
            $A.util.removeClass(oppNameComp, "hide-error-message");
            isAllCorrect = false;
            errorList.push("Please Enter Opportunity Name");
        } else {
            $A.util.removeClass(oppNameComp, "slds-has-error");
            $A.util.addClass(oppNameComp, "hide-error-message");
        }
        if(oppCloseDate == undefined || oppCloseDate == null || oppCloseDate == "") {
            $A.util.addClass(oppCloseDateComp, "sldsRedError");
            $A.util.removeClass(oppCloseDateComp, "hide-error-message");
            isAllCorrect = false;
            errorList.push("Please Enter Opportunity Close Date");
        } else if(oppCloseDateComp.get("v.value") < today) {
            $A.util.addClass(oppCloseDateComp, "sldsRedError");
            $A.util.removeClass(oppCloseDateComp, "hide-error-message");
            isAllCorrect = false;
            errorList.push("You cannot input past date at Close Date. Please input future date at Close Date.");
        } else {
            $A.util.removeClass(oppCloseDateComp, "sldsRedError");
            $A.util.addClass(oppCloseDateComp, "hide-error-message");
        }
        if(clonedOpp["CurrencyIsoCode"] == undefined || clonedOpp["CurrencyIsoCode"] == null || clonedOpp["CurrencyIsoCode"] == ''){
            $A.util.addClass(oppCurrencyCodeComp, "sldsRedError");
            $A.util.removeClass(oppCurrencyCodeComp, "hide-error-message");
            isAllCorrect = false;
            errorList.push("Please Select Opportunity Currency");
        }else {
            $A.util.removeClass(oppCurrencyCodeComp, "sldsRedError");
            $A.util.addClass(oppCurrencyCodeComp, "hide-error-message");
        }
        
        if(isRenewalOptions) {
            if(pricechangepercentComp.get("v.value") == undefined || pricechangepercentComp.get("v.value") == null 
               || pricechangepercentComp.get("v.value") < -999 || pricechangepercentComp.get("v.value") > 999) {
                $A.util.addClass(pricechangepercentComp, "slds-has-error");
                $A.util.removeClass(pricechangepercentComp, "hide-error-message");
                isAllCorrect = false;
                errorList.push("Please Enter price change percent between -999 to 999");
            } else {
                $A.util.removeClass(pricechangepercentComp, "slds-has-error");
                $A.util.addClass(pricechangepercentComp, "hide-error-message");
            }
        }
        if(errorList.length > 0) {
            component.set("v.errors", errorList);
        }
        return isAllCorrect;
    },
    
    openInactiveProductScreen : function(component, event, helper) {
        
        var isAllCorrect = helper.validateFields(component, event, helper);
        if(!isAllCorrect) {
            return;
        }
        
        var OpportunityId = component.get("v.OpportunityId");
        var cloneOppWithProduct = component.get("v.isRenewalOptions");
        if(cloneOppWithProduct == true){            
            var action = component.get("c.getInactiveOpportunityProducts");
            action.setParams({
                "opportunityId" : OpportunityId
            });
            
            action.setCallback(this, function(actionResult) {
                var state = actionResult.getState();
                if(state === "SUCCESS") {
                    if(actionResult.getReturnValue().length > 0){
                        component.set("v.recordList",actionResult.getReturnValue());
                        component.set("v.CloneScreen", false);
                        component.set("v.InactiveProductScreen", true);
                    } else{
                        console.log('No In-active Product.')
                        helper.doCloneOpportunity(component, event, helper);
                    }              
                    
                }
                else if(state === "ERROR") {
                    var errors = actionResult.getError();
                    console.log(errors);
                }            
            });
            $A.enqueueAction(action);            
        }else{
            helper.doCloneOpportunity(component, event, helper);
        }
    },
    checkEmeaOpportunity : function(component, event, helper) {
        var OpportunityId = component.get("v.OpportunityId");
        var action = component.get("c.checkNonEMEAOpportunity");
        action.setParams({
            "OpportunityId" : OpportunityId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var isNonEmeaOpp = response.getReturnValue();
                component.set("v.IsNonEmeaOpportunity", isNonEmeaOpp);
            }
            else if(state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var errorMsgList = JSON.parse(errors[0].message).errorList;
                        console.log(errorMsgList);
                        component.set("v.errors", errorMsgList);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    }
})