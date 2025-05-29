({
    getFieldDetails : function(component, event, helper) {
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "start"}).fire();
        var action = component.get("c.getOLIFieldDetail");
        var fieldsToShow = component.get("v.fieldsToShow");
        action.setParams({
            fieldData : fieldsToShow
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var fieldsToShowWrapper = [];
                var returnValue = response.getReturnValue();
                component.set("v.fieldsToShowWrapper", returnValue);
                helper.setoliWrapperDetails(component, event, helper);
                helper.getTherapyAreaByProduct(component, event, helper);
            } else if(state === "ERROR") {
                var errors = response.getError();
                var err = JSON.parse(errors[0].message).errorList;
                helper.setToast(component, event, helper, err, "error", "Error!");
                $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
            }
        })
        $A.enqueueAction(action);
    },
    
    getFieldDetailsHelper: function(component, event, helper){
        var operationType = component.get("v.operationType");
        var objectWrapper = component.get("v.fieldsToShowWrapper");
        var deliveryCountryValues = [];
        for(var i = 0; i < objectWrapper.length; i++) {
            if(objectWrapper[i].fieldApiName == 'delivery_country__c') {
                deliveryCountryValues = objectWrapper[i].fieldValues;
                break;
            }
        }
        if(operationType == "clone") {
            helper.setOppDetail(component, event, helper);
            helper.setTotalSum(component, event, helper);
            var oliWrapperList =  component.get("v.oliWrapperList");
            var oliId = oliWrapperList[0]["oliRecord"]["Id"];
            helper.getRevenueSchedules(component, event, helper, oliId);
        } else if(operationType == "create") {
            helper.setOppDetail(component, event, helper);
            helper.setDefaultUserCountry(component, event, helper, deliveryCountryValues);
        }
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
    },
    
    setoliWrapperDetails : function(component, event, helper) {
        var selectedList = component.get("v.selectedList");
        var operationType = component.get("v.operationType");
        var recordId = component.get("v.recordId");
        var oliWrapperList = [];
        if(operationType == "edit" || operationType == "clone") {
            component.set("v.oliWrapperList", selectedList);
        } else {
            for(var index in selectedList) {
                var deliveryCountry = '';
                var noOfLicense;
                if(selectedList[index]["oliRecord"] != undefined) {
                    deliveryCountry = selectedList[index]["oliRecord"]["Delivery_Country__c"];
                    noOfLicense =  selectedList[index]["oliRecord"]["Number_of_License__c"];
                }
                var Product2 = {
                    "Name" : selectedList[index]["productRecord"]["Name"],
                    "CanUseRevenueSchedule" : selectedList[index]["productRecord"]["CanUseRevenueSchedule"],
                    "Therapy_Class__c" : selectedList[index]["productRecord"]["Therapy_Class__c"],
                };
                var oliRecord = {
                    "UnitPrice" : 0.0,
                    "Delivery_Type__c" : selectedList[index]["productRecord"]["Delivery_Type__c"],
                    "OpportunityId" : recordId,
                    "CurrencyIsoCode" : selectedList[index]["pbeRecord"]["CurrencyIsoCode"],
                    "PricebookEntryId" : selectedList[index]["pbeRecord"]["Id"],
                    "Offering_Group_Code__c" : selectedList[index]["productRecord"]["Offering_Group_Code__c"],
                    "Material_Type__c" : selectedList[index]["productRecord"]["Material_Type__c"],
                    "Product2" : Product2,
                    "Offering_Type__c" : selectedList[index]["productRecord"]["Offering_Type__c"],
                    "Billing_System__c" : selectedList[index]["productRecord"]["Billing_System__c"],
                    "Delivery_Country__c" : deliveryCountry,
                    "Number_of_License__c" : noOfLicense
                };
                
                oliWrapperList.push({
                    "oliRecord" : oliRecord,
                    "operationType" : "create",
                    "revSchWrapperList" : [],
                });
            }
            component.set("v.oliWrapperList", oliWrapperList);
        
            if($A.get("$Browser.isPhone")){
                var oliWrapperValue = component.find("oliWrapperValue");
                var oliWrapperName = component.find("oliWrapperName");
                for(var index in oliWrapperValue){
                    $A.util.addClass(oliWrapperValue[index], "slds-p-top_none");
                }
                $A.util.addClass(oliWrapperName, "slds-p-top_none");
            }
        }  
    },
    
    fadeOutModel : function(component, event, helper) {
        var addProductComp = component.find("addProduct");
        var backDropComp = component.find("backdrop-addProduct");
        $A.util.removeClass(addProductComp, "slds-fade-in-open");
        $A.util.removeClass(backDropComp, "slds-backdrop--open");
        component.set("v.errors", null);
        component.set("v.fieldsToShowWrapper", []);
        component.set("v.selectedList", []);
        component.set("v.oliWrapperList", []);
        component.set("v.isFadeIn", false);
        component.set("v.totalsum", null);
        component.set("v.minLicenses", null);
        component.set("v.maxLicenses", null);
    },
    
    onSave : function(component, event, helper) {
        var auraIdList = ["picklist", "currency", "string", "date", "lookup", "double"];
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "start"}).fire();
        var componentsMap = helper.findComponentByAuraIds(component, event, auraIdList);
        var picklistCompList = componentsMap.get(auraIdList[0]);
        var currencyCompList = componentsMap.get(auraIdList[1]);
        var stringCompList = componentsMap.get(auraIdList[2]);
        var dateCompList = componentsMap.get(auraIdList[3]);
        var lookupCompList = componentsMap.get(auraIdList[4]);
        var doubleCompList = componentsMap.get(auraIdList[5]);
        var oliWrapperList = component.get("v.oliWrapperList");
        var fieldsToShowWrapper = component.get("v.fieldsToShowWrapper");
        var recordId = component.get("v.recordId");
        var operationType = component.get("v.operationType");
        var saveWrapper = [];
        var picklistIndex = 0;
        var currencyIndex = 0;
        var stringIndex = 0;
        var dateIndex = 0;
        var lookupIndex = 0;
        var doubleIndex = 0;
        var noOfPicklistInRow = (picklistCompList.length / oliWrapperList.length);
        var noOfCurrencyInRow = (currencyCompList.length / oliWrapperList.length);
        var noOfStringInRow = (stringCompList.length / oliWrapperList.length);
        var noOfDateInRow = (dateCompList.length / oliWrapperList.length);
        var noOfLookupInRow = (lookupCompList.length / oliWrapperList.length);
        var noOfDoubleInRow = (doubleCompList.length / oliWrapperList.length);
        var isError = false;
        var isBlankDeliveryCountry = false;
        var isBlankRevenueType = false;
        var isBlankSaleType = false;
        var isBlankTherapyArea = false;
        var isNumberOfLicenseNegative = false;
        for(var i = 0; i < currencyCompList.length; i++) {
            var currencyValue = currencyCompList[i].get("v.value");
            if(currencyValue == undefined || (typeof currencyValue == "string" && (currencyValue == null || currencyValue == ""))){
                $A.util.addClass(currencyCompList[i], "slds-has-error");
                isError = true;
            }
            else if(typeof currencyValue == "number" && currencyValue == null) {
                $A.util.addClass(currencyCompList[i], "slds-has-error");
                isError = true;
            }
        }
        var actionType = component.get("v.actionType");
        var isResolveProduct = false;
        if(actionType == "change" || actionType == "resolve") {
            isResolveProduct = true;
        }
        var resolveLineItem = component.get("v.resolveLineItem");
        for(var i = 0; i < oliWrapperList.length; i++) {
            var rowWrapper = {};
            var schedules = [];
            if(operationType == "edit") {
                rowWrapper["Id"] = oliWrapperList[i]["oliRecord"]["Id"];
                rowWrapper["opportunityId"] = recordId;
            } else if(operationType == "clone") {
                rowWrapper["Id"] = null;
                rowWrapper["opportunityId"] = recordId;
                rowWrapper["priceBookEntryId"] = oliWrapperList[i]["oliRecord"]["PricebookEntryId"];
                if(oliWrapperList[i].olisWrapper != undefined) {
                    schedules = oliWrapperList[i].olisWrapper;
                }
            } else {
                rowWrapper["priceBookEntryId"] = oliWrapperList[i]["oliRecord"]["PricebookEntryId"];
                rowWrapper["opportunityId"] = recordId;
                rowWrapper["Max_Licenses__c"] = component.get("v.maxLicenses");
                rowWrapper["Min_Licenses__c"] = component.get("v.minLicenses");
                if(isResolveProduct) {
                    rowWrapper["SalesEngineer__c"] = resolveLineItem["SalesEngineer__c"];
                }
                if(oliWrapperList[i].olisWrapper != undefined) {
                    schedules = oliWrapperList[i].olisWrapper;
                }
            }
            for(var k = 0; k < noOfPicklistInRow; k++) {
                var key = picklistCompList[picklistIndex].get("v.label");
                var value = picklistCompList[picklistIndex].get("v.value");
                if(value == "--None--" || value == "" || value == undefined) {
                    value = "";
                    if(key == 'delivery_country__c') {
                        $A.util.addClass(picklistCompList[picklistIndex], "slds-has-error");
                        isBlankDeliveryCountry = true;
                    } else if(key == 'revenue_type__c') {
                        $A.util.addClass(picklistCompList[picklistIndex], "slds-has-error");
                        isBlankRevenueType = true;
                    } else if(key == 'sale_type__c') {
                        $A.util.addClass(picklistCompList[picklistIndex], "slds-has-error");
                        isBlankSaleType = true;
                    } else if(key == 'therapy_area__c' && (oliWrapperList[i]["oliRecord"]["Material_Type__c"] == 'ZREP' || oliWrapperList[i]["oliRecord"]["Material_Type__c"] == 'ZPUB')) {
                        $A.util.addClass(picklistCompList[picklistIndex], "slds-has-error");
                        isBlankTherapyArea = true;
                    }
                }
                else  {
                    $A.util.removeClass(picklistCompList[picklistIndex], "slds-has-error");
                }
                rowWrapper[key] = value;
                picklistIndex++;
            }
            for(var k = 0; k < noOfCurrencyInRow; k++) {
                var key = currencyCompList[currencyIndex].get("v.label");
                var value = currencyCompList[currencyIndex].get("v.value");
                rowWrapper[key] = parseFloat(value).toFixed(2);
                var decimalPlace = component.get("v.decimalPlace");
                rowWrapper[key] = parseFloat(value).toFixed(decimalPlace);
                currencyIndex++;
            }
            for(var k = 0; k < noOfStringInRow; k++) {
                var key = stringCompList[stringIndex].get("v.label");
                var value = stringCompList[stringIndex].get("v.value");
                rowWrapper[key] = value;
                stringIndex++;
            }
            
            for(var k = 0; k < noOfDateInRow; k++) {
                var key = dateCompList[dateIndex].get("v.label");
                var value = dateCompList[dateIndex].get("v.value");
                if(value == "") {
                    value = null;
                }
                rowWrapper[key] = value;
                dateIndex++;
            }
            for(var k = 0; k < noOfLookupInRow; k++) {
                var key = lookupCompList[lookupIndex].get("v.label");
                var value = lookupCompList[lookupIndex].get("v.value");
                if(value == "") {
                    value = null;
                }
                if($A.get("$Browser.isPhone")){
                    value = component.get("v.selectedLookUpRecord").Id;
                }
                rowWrapper[key] = value;
                lookupIndex++;
            }
            for(var k = 0; k < noOfDoubleInRow; k++) {
                var key = doubleCompList[doubleIndex].get("v.label");
                var value = doubleCompList[doubleIndex].get("v.value");
                if(value == "") {
                    value = null;
                }
                if (value < 0) {
                    $A.util.addClass(doubleCompList[doubleIndex], "slds-has-error");
                    isNumberOfLicenseNegative = true;
                }
                rowWrapper[key] = value;
                doubleIndex++;
            }
            if(operationType == "clone") {
                operationType = "create";
            }
            saveWrapper.push({
                oliRecord : rowWrapper,
                operationType : operationType,
                revSchWrapperList : schedules
            });
        }
        if(isError || isBlankDeliveryCountry || isBlankRevenueType || isBlankSaleType || isNumberOfLicenseNegative || isBlankTherapyArea) {
            var errors = [];
            if(isError)
                errors.push("Please Enter Correct Sales Price.");
            if(isBlankDeliveryCountry)
                errors.push("Please Enter Delivery Country.");
            if(isBlankRevenueType)
                errors.push("Please Enter Revenue type.");
            if(isBlankSaleType)
                errors.push("Please Enter Sale Type.");
            if(isNumberOfLicenseNegative)
                errors.push("Number Of License shouldn't be negative");
            if(isBlankTherapyArea)
                errors.push("Please Enter Therapy Area.");
            component.set("v.errors", errors);
            var appEvent = $A.get("e.c:LXE_CRM_SpinnerEvent");
            appEvent.setParams({"action" : "stop"});
            appEvent.fire();
            return;
        }
        if(helper.validate(component, event, helper, saveWrapper)) {
            var appEvent = $A.get("e.c:LXE_CRM_SpinnerEvent");
            appEvent.setParams({"action" : "start"});
            appEvent.fire();
            var action = component.get("c.crudOliRecord");
            var resolveLineItem = component.get("v.resolveLineItem");
            if(resolveLineItem != undefined && resolveLineItem != null) {
                saveWrapper.push({
                    oliRecord : resolveLineItem,
                    operationType : 'Delete'
                });
            }
            action.setParams({ 
                recordJSON : JSON.stringify(saveWrapper)
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    if(resolveLineItem != null) {
                        component.set("v.resolveLineItem", null);
                        component.set("v.actionType", "");
                    }
                    var resolveScreen = component.get("v.resolveScreen");
                    if(resolveScreen == "ProductDetail") {
                        helper.navigatorToOppDetail(component, event, helper);
                    }
                    else {
                        if($A.get("$Browser.isPhone")){
                            var oliRecordId = response.getReturnValue();
                            var navEvt = $A.get("e.force:navigateToSObject");
                            navEvt.setParams({
                                "recordId": oliRecordId[0],
                                "isredirect" : true
                            });
                            navEvt.fire();
                        }else{
                        component.set("v.resolveScreen", null);
                        helper.fadeOutModel(component, event, helper);
                        $A.get("e.c:LXE_CRM_HideResolveTabEvent").fire();
                        helper.setSelectorTab(component, event, helper);
                        var paramValue;
                        if(component.get("v.operationType") == "create") {
                            paramValue = "deSelectProducts";
                        } else {
                            paramValue = "reload";
                        }
                        var appEvent = $A.get("e.c:LXE_CRM_ReloadEvent");
                        appEvent.setParams({
                            eventFor : paramValue
                        })
                        appEvent.fire();
                        var ldsScreenEvent = $A.get("e.c:LXE_CRM_RenderLDSScreen");
                        ldsScreenEvent.setParams({"needs" : "destroy"});
                        ldsScreenEvent.fire();
                    }
                    }
                } else if(state === "ERROR") {
                    component.set("v.errors", null);
                    var errors = response.getError();
                    var err = JSON.parse(errors[0].message).errorList;
                    helper.setToast(component, event, helper, err, "error", "Error!");
                }
                var appEvent = $A.get("e.c:LXE_CRM_SpinnerEvent");
                appEvent.setParams({"action" : "stop"});
                appEvent.fire();
            })
            $A.enqueueAction(action);
        } else {
            console.log("Client Side Validation");
        }
    },
    
    navigatorToOppDetail : function(component, event, helper) { 
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId"),
            "isredirect" : true
        });
        navEvt.fire();
    },
    
    validate : function(component, event, helper, saveWrapper) {
        var validate = true;
        for(var index = 0; index < saveWrapper.length; index++) {
            var oli = saveWrapper[index];
            if(!$A.util.isEmpty(oli["oliRecord"]["product_end_date__c"]) && !$A.util.isEmpty(oli["oliRecord"]["product_start_date__c"]) && oli["oliRecord"]["product_end_date__c"] < oli["oliRecord"]["product_start_date__c"]) {
                var err = [];
                err.push("Product Start date cannot be after end date");
                validate = false;
                helper.setToast(component, event, helper, err, "error", "Error!");
            }
            /*if(oli["oliRecord"]["unitprice"] < 0) {
                var err = [];
                err.push("Sales price is negative");
                validate = false;
                helper.setToast(component, event, helper, err, "error", "Error!");
            }*/
        }
        return validate;
    },
    
    setSelectorTab : function(component, event, helper) {
        var tabEvent = $A.get("e.c:LXE_CRM_SetActiveTabEvent");
        tabEvent.setParams({"activeTabId" : "viewOli"});
        tabEvent.fire(); 
    },
    
    setTotalSum : function(component, event, helper) {
        var sum = 0;
        var componentsMap = helper.findComponentByAuraIds(component, event, ["currency"]);
        var currencyCompList = componentsMap.get("currency");
        var operationType = component.get("v.operationType");
        var decimalPlace = component.get("v.decimalPlace");
        if(operationType != "edit") {
            for(var i = 0; i < currencyCompList.length; i++) {
                if(!(currencyCompList[i].get("v.value") == "" || currencyCompList[i].get("v.value") < 0 || currencyCompList[i].get("v.value") == null)) {
                    var value = parseFloat(currencyCompList[i].get("v.value"));
                    sum = sum + parseFloat(value.toFixed(decimalPlace));
                }
            } 
        }
        sum = parseFloat(sum.toFixed(decimalPlace));
        component.set("v.totalsum", sum);
    },
    
    setToast : function(component, event, helper, message, type, title) {
        var errorMsg = message;
        var msg = "";
        for(var x = 0; x < errorMsg.length; x++) {
            msg = msg + errorMsg[x] + "\n";
        }
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            type : type,
            message : msg,
            mode : "sticky"
        });
        toastEvent.fire();
    },
    
    setOppDetail : function(component, event, helper) {
        var action = component.get("c.getOpportunityDetails");
        var fieldsToShow = [];
        fieldsToShow.push("Id");
        fieldsToShow.push("CurrencyIsoCode");
        var oppId = component.get("v.recordId");
        action.setParams({ 
            oppId : oppId,
            oppFields : fieldsToShow,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                component.set("v.oppRecord", returnValue);
            } else if(state === "ERROR") {
                var errors = response.getError();
                var err = JSON.parse(errors[0].message).errorList;
                helper.setToast(component, event, helper, err, "error", "Error!");
            }
            var appEvent = $A.get("e.c:LXE_CRM_SpinnerEvent");
            appEvent.setParams({"action" : "stop"});
            appEvent.fire();
        })
        $A.enqueueAction(action);
    },
    
    setDefaultUserCountry : function(component, event, helper, deliveryCountryValues) {
        var territory = component.get("v.territory");
        if(territory != undefined && territory != null) {
            for(var i = 0; i < deliveryCountryValues.length; i++) {
                if(deliveryCountryValues[i] == territory) {
                    component.set("v.defaultUserCountry", territory);
                    break;
                }
            }
        }
        else {
            var action = component.get("c.getUserDetails");
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var returnValue = response.getReturnValue();
                    var userCountry = returnValue[0].User_Country__c;
                    
                    if(userCountry != undefined && userCountry != null) {
                        for(var i = 0; i < deliveryCountryValues.length; i++) {
                            if(deliveryCountryValues[i] == userCountry) {
                                component.set("v.defaultUserCountry", userCountry);
                                break;
                            }
                        }
                    }
                } else if(state === "ERROR") {
                    var errors = response.getError();
                    var err = JSON.parse(errors[0].message).errorList;
                    helper.setToast(component, event, helper, err, "error", "Error!");
                }
            });
            $A.enqueueAction(action);
        }
        
    },
    
    findComponentByAuraIds : function(component, event, cmpIds) {
        var componentsMap = new Map();
        for(var cmpIndex = 0; cmpIndex < cmpIds.length; cmpIndex++) {
            var componentList = [];
            componentList = component.find(cmpIds[cmpIndex]);
            var componentTempList = [];
            if(componentList !=  undefined && componentList.length ==  undefined) {
                componentTempList.push(componentList);
                componentList = componentTempList;
            }
            componentTempList = [];
            if(componentList != undefined) {
                for(var index = 0; index < componentList.length; index++) {
                    if(componentList[index].isValid() && componentList[index].get('v.label') != undefined) {
                        componentTempList.push(componentList[index]);
                    }
                }
            }
            componentList = componentTempList;
            componentsMap.set(cmpIds[cmpIndex], componentList);
        }
        return componentsMap;
    },
    
    openRevenueSchedule : function(component, event, helper) {
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "start"}).fire();
        var index = event.currentTarget.id;
        var oliWrapperList = component.get("v.oliWrapperList");
        oliWrapperList[index].index = index;
        var componentsMap = helper.findComponentByAuraIds(component, event, ["currency"]);
        var currencyCompList = componentsMap.get("currency");
        var price = currencyCompList[index].get("v.value");
        var establishSchedule = $A.get("e.c:LXE_CRM_OpenRevenueScheduleEvent");
        var oliRecord = {
            "Min_Licenses__c" : component.get("v.minLicenses"),
            "Max_Licenses__c" : component.get("v.maxLicenses"),
            "Delivery_Type__c" : oliWrapperList[index]["oliRecord"]["Delivery_Type__c"],
            "Material_Type__c" : oliWrapperList[index]["oliRecord"]["Material_Type__c"],
        };
        establishSchedule.setParams({
            "oliWrapper" : oliWrapperList[index],
            "origin" : "Add",
            "index" : index,
            "price" : price,
            "oliRecord" : oliRecord
        });
        establishSchedule.fire();
        var comp = component.find("addProduct-model");
        $A.util.addClass(comp, "slds-hide");
    },
    
    setSchedule : function(component, event, helper) {
        if(event.getParams().type == "save") {
            var oliWrapperList = component.get("v.oliWrapperList");
            var index = event.getParams().index;
            oliWrapperList[index].olisWrapper = event.getParams().olisWrapper;
            var oliRecord = event.getParams().oliRecord;
            if(oliRecord.Min_Licenses__c != undefined && oliRecord.Min_Licenses__c != null) {
                component.set("v.minLicenses", oliRecord.Min_Licenses__c);
            }
            if(oliRecord.Max_Licenses__c != undefined && oliRecord.Max_Licenses__c != null) {
                component.set("v.maxLicenses", oliRecord.Max_Licenses__c);
            }
            component.set("v.oliWrapperList", oliWrapperList);
            var componentsMap = helper.findComponentByAuraIds(component, event, ["currency"]);
            var currencyCompList = componentsMap.get("currency");
            var price = currencyCompList[index].set("v.value", event.getParams().price);
            helper.setTotalSum(component, event, helper);
        }
        var comp = component.find("addProduct-model");
        $A.util.removeClass(comp, "slds-hide");
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
    },
    
    setDefaultValues : function(component, event, helper) {
        var oliWrapperList = component.get("v.oliWrapperList");
        var auraIdList = ["picklist", "currency", "string", "date", "number", "lookup", "double"];
        var componentsMap = helper.findComponentByAuraIds(component, event, auraIdList);
        var picklistCompList = componentsMap.get(auraIdList[0]);
        var currencyCompList = componentsMap.get(auraIdList[1]);
        var stringCompList = componentsMap.get(auraIdList[2]);
        var dateCompList = componentsMap.get(auraIdList[3]);
        var numberCompList = componentsMap.get(auraIdList[4]);
        var lookupCompList = componentsMap.get(auraIdList[5]);
        var doubleCompList = componentsMap.get(auraIdList[6]);
        var fieldsToShowWrapper = component.get("v.fieldsToShowWrapper");
        var recordId = component.get("v.recordId");
        var picklistIndex = 0;
        var currencyIndex = 0;
        var stringIndex = 0;
        var dateIndex = 0;
        var numberIndex = 0;
        var lookupIndex = 0;
        var doubleIndex = 0;
        var noOfPicklistInRow = (picklistCompList.length / oliWrapperList.length);
        var noOfCurrencyInRow = (currencyCompList.length / oliWrapperList.length);
        var noOfStringInRow = (stringCompList.length / oliWrapperList.length);
        var noOfDateInRow = (dateCompList.length / oliWrapperList.length);
        var noOfNumberInRow = (numberCompList.length / oliWrapperList.length);
        var noOfLookupInRow = (lookupCompList.length / oliWrapperList.length);
        var noOfDoubleInRow = (doubleCompList.length / oliWrapperList.length);
        var operationType = component.get("v.operationType");
        var isResolveProduct = false;
        if(operationType == "create") {
            var resolveLineItem = component.get("v.resolveLineItem");
            var actionType = component.get("v.actionType");
            if(actionType == "change" || actionType == "resolve") {
                isResolveProduct = true;
            }
        }
        var fieldsToShow = component.get("v.fieldsToShow");
        var fieldsToDisableSet = new Set(component.get("v.fieldsToDisable").split(","));
        var fieldsToShowArr = fieldsToShow.split(",");
        fieldsToShow = fieldsToShow.toLowerCase().split(",");
        var fieldsToShowSet = new Set(fieldsToShow);
        for(var i = 0; i < oliWrapperList.length; i++) {
            if(operationType == 'clone' && i != oliWrapperList.length - 1) {
                picklistIndex += noOfPicklistInRow;
                currencyIndex += noOfCurrencyInRow;
                stringIndex += noOfStringInRow;
                dateIndex += noOfDateInRow;
                numberIndex += noOfNumberInRow;
                lookupIndex += noOfLookupInRow;
                continue;
            }
            for(var k = 0; k < noOfPicklistInRow; k++) {
                var fieldAPIName = picklistCompList[picklistIndex].get("v.label");
                var index = fieldsToShow.indexOf(fieldAPIName);
                var key = fieldsToShowArr[index];
                if(fieldsToDisableSet.has(key)) {
                    picklistCompList[picklistIndex].set("v.disabled", true);
                }
                var value = oliWrapperList[i]["oliRecord"][key];
                picklistCompList[picklistIndex].set("v.value", value);
                if(operationType == "create") {
                    if(fieldAPIName  == "delivery_country__c" && !component.get("v.createFromLDS")) {
                        picklistCompList[picklistIndex].set("v.value", component.get("v.defaultUserCountry"));
                    }
                    if(oliWrapperList[i]["oliRecord"]["Offering_Group_Code__c"] == "GPRDSX" || oliWrapperList[i]["oliRecord"]["Material_Type__c"] == "ZQUI") {
                        if(fieldAPIName  == "revenue_type__c") {
                            picklistCompList[picklistIndex].set("v.value", "Ad Hoc");
                        } else if(fieldAPIName  == "sale_type__c") {
                            picklistCompList[picklistIndex].set("v.value", "New");
                        }
                    }
                    if(oliWrapperList[i]["oliRecord"]["Offering_Type__c"] =="Commercial Engagement Services" && oliWrapperList[i]["oliRecord"]["Billing_System__c"] =="PeopleSoft") {
                        if(fieldAPIName  == "sale_type__c") {
                           picklistCompList[picklistIndex].set("v.value", "");
                       }
                   }
                }
                if(isResolveProduct) {
                    if(fieldAPIName  == "delivery_country__c") {
                        picklistCompList[picklistIndex].set("v.value", resolveLineItem["Delivery_Country__c"]);
                    } else if(fieldAPIName  == "sale_type__c") {
                        picklistCompList[picklistIndex].set("v.value", resolveLineItem["Sale_Type__c"]);
                    } else if(fieldAPIName  == "revenue_type__c") {
                        picklistCompList[picklistIndex].set("v.value", resolveLineItem["Revenue_Type__c"]);
                    } else if(fieldAPIName  == "therapy_area__c") {
                        picklistCompList[picklistIndex].set("v.value", resolveLineItem["Therapy_Area__c"]);
                    }  
                }
                picklistIndex++;
            }
            for(var k = 0; k < noOfCurrencyInRow; k++) {
                var fieldAPIName = currencyCompList[currencyIndex].get("v.label");
                var index = fieldsToShow.indexOf(fieldAPIName);
                var key = fieldsToShowArr[index];
                if(fieldsToDisableSet.has(key)) {
                    currencyCompList[currencyIndex].set("v.disabled", true);
                }
                var value = oliWrapperList[i]["oliRecord"][key];
                currencyCompList[currencyIndex].set("v.value", value);
                if(isResolveProduct) {
                    if(fieldAPIName  == "unitprice") {
                        currencyCompList[currencyIndex].set("v.value", resolveLineItem["UnitPrice"]);
                    }
                }
                currencyIndex++;
            }
            for(var k = 0; k < noOfStringInRow; k++) {
                var fieldAPIName = stringCompList[stringIndex].get("v.label");
                var index = fieldsToShow.indexOf(fieldAPIName);
                var key = fieldsToShowArr[index];
                if(fieldsToDisableSet.has(key)) {
                    stringCompList[stringIndex].set("v.disabled", true);
                }
                var value = oliWrapperList[i]["oliRecord"][key];
                stringCompList[stringIndex].set("v.value", value);
                stringIndex++;
            }
            for(var k = 0; k < noOfDateInRow; k++) {
                var fieldAPIName = dateCompList[dateIndex].get("v.label");
                var index = fieldsToShow.indexOf(fieldAPIName);
                var key = fieldsToShowArr[index];
                if(fieldsToDisableSet.has(key)) {
                    dateCompList[dateIndex].set("v.disabled", true);
                }
                var value = oliWrapperList[i]["oliRecord"][key];
                dateCompList[dateIndex].set("v.value", value);
                if(isResolveProduct) {
                    if(fieldAPIName  == "product_start_date__c") {
                        dateCompList[dateIndex].set("v.value", resolveLineItem["Product_Start_Date__c"]);
                    } else if(fieldAPIName  == "product_end_date__c") {
                        dateCompList[dateIndex].set("v.value", resolveLineItem["Product_End_Date__c"]);
                    }
                }
                dateIndex++;
            }
            for(var k = 0; k < noOfNumberInRow; k++) {
                var fieldAPIName = numberCompList[numberIndex].get("v.label");
                var index = fieldsToShow.indexOf(fieldAPIName);
                var key = fieldsToShowArr[index];
                var value = oliWrapperList[i]["oliRecord"][key];
                numberCompList[numberIndex].set("v.value", value);
                numberIndex++;
            }
            
            for(var k = 0; k < noOfLookupInRow; k++) {
                var fieldAPIName = lookupCompList[lookupIndex].get("v.label");
                if(isResolveProduct) {
                    if(fieldAPIName  == "product_saleslead__c") {
                        lookupCompList[lookupIndex].set("v.value", resolveLineItem["Product_SalesLead__c"]);
                    }
                }
                var index = fieldsToShow.indexOf(fieldAPIName);
                var key = fieldsToShowArr[index];
                var value = oliWrapperList[i]["oliRecord"][key];
                lookupCompList[lookupIndex].set("v.value", value);
                lookupIndex++;
            }
            for(var k = 0; k < noOfDoubleInRow; k++) {
                var fieldAPIName = doubleCompList[doubleIndex].get("v.label");
                var index = fieldsToShow.indexOf(fieldAPIName);
                var key = fieldsToShowArr[index];
                if(fieldsToDisableSet.has(key)) {
                    doubleCompList[doubleIndex].set("v.disabled", true);
                }
                var value = oliWrapperList[i]["oliRecord"][key];
                doubleCompList[doubleIndex].set("v.value", value);
                doubleIndex++;
            }
        }
        
        if(isResolveProduct && oliWrapperList.length == 1) {
            var resolveLineItem = component.get("v.resolveLineItem");
            if(oliWrapperList[0].oliRecord.Product2.CanUseRevenueSchedule == true) {
                helper.getRevenueSchedules(component, event, helper, resolveLineItem["Id"]);
            }
        }
        
        
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
    },
    
    getRevenueSchedules : function(component, event, helper, oliId) {
        var schFieldList = ["Id","OpportunityLineItemId","Type","Revenue","Quantity","Description","ScheduleDate","CurrencyIsoCode"];
        var oliFieldList = ["Id","TotalPrice"];
        var action = component.get("c.getOpportunityLineItemSchedule");
        action.setParams({
            "opportunityLineItemId" : oliId,
            "oliFields" : oliFieldList,
            "schFields" : schFieldList
        });
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
                var oppWrapper = actionResult.getReturnValue();
                var olisWrapper = oppWrapper.oliWrapperList[0].revSchWrapperList;
                for(var olisw in olisWrapper) {
                    olisWrapper[olisw]["operationType"] = "create";
                    olisWrapper[olisw]["schRecord"]["Id"] = null;
                }
                var oliWrapperList = component.get("v.oliWrapperList");
                oliWrapperList[0].olisWrapper = olisWrapper;
                component.set("v.oliWrapperList", oliWrapperList);
                helper.setTotalSum(component, event, helper);
            } else if(state === "ERROR") {
                var errors = actionResult.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var errorMsg = JSON.parse(errors[0].message).errorList;
                        helper.setToast(component, event, helper, errorMsg, "error", "Error!");
                    }
                }
                $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
            }
        });
        $A.enqueueAction(action);
    },
    fetchRecordTypeId : function(component, event, helper) {
        var action = component.get("c.fetchContactRecordTypeId");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                if(returnValue != null && returnValue != ''){
                    var recordTypeStr = ' Salesforce_User__c != null and RecordTypeId = \'' + returnValue + '\'';
                    component.set("v.recordTypeIdStr",recordTypeStr);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    getTherapyAreaByProduct : function(component, event, helper) {
        var oliWrapperList = component.get("v.oliWrapperList");
        var action = component.get("c.getTherapyAreaByProduct");
        action.setParams({
            "recordJSON" : JSON.stringify(oliWrapperList)
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                component.set("v.oliWrapperList", returnValue);
                helper.setDefaultValues(component, event, helper);
                helper.getFieldDetailsHelper(component, event, helper);
            }else if(state === "ERROR") {
                var errors = response.getError();
                var err = JSON.parse(errors[0].message).errorList;
                helper.setToast(component, event, helper, err, "error", "Error!");
            }
        });
        $A.enqueueAction(action);
    }
})