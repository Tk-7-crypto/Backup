({
    searchfilterProducts : function(component, event, helper) {
        let searchButton = component.find("searchButton");
        if(searchButton != undefined && searchButton != null){
            searchButton.focus();
        }
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "start"}).fire();
        var pbeWrapper = {};
        var productObj = {};
        var pbeObj = {};
        pbeWrapper["productRecord"] = productObj;
        pbeWrapper["pbeRecord"] = pbeObj;
        var productFilterObj = component.get("v.defaultProductFilterObj");
        var fieldsAPIList = component.get("v.fieldsAPIList");
        var productFilterFieldList = [];
        var fieldValue = '';
        for(var count in fieldsAPIList) {
            if(fieldsAPIList[count] == 'Hierarchy_Global_Code_Description__c') {
                fieldValue = productFilterObj["Df_" + fieldsAPIList[count]];
            } else {
                fieldValue = productFilterObj["Default_" + fieldsAPIList[count]];
            }
            if(fieldValue != undefined && fieldValue != "" && fieldValue != "--None--" && (fieldValue != "Global" || fieldsAPIList[count] != 'Territory__c')) {
                productFilterFieldList.push(fieldsAPIList[count]);
                productObj[fieldsAPIList[count]] = fieldValue;
            }
            if(fieldsAPIList[count] == 'PSA_PROJECT_REQUIRED__c') {
                if(pbeWrapper.productRecord.PSA_PROJECT_REQUIRED__c == 'YES'){
                    pbeWrapper.productRecord.PSA_PROJECT_REQUIRED__c = true;
                }else if(pbeWrapper.productRecord.PSA_PROJECT_REQUIRED__c == 'NO'){
                    pbeWrapper.productRecord.PSA_PROJECT_REQUIRED__c = false;    
                }
            }
        }
        if(component.get("v.source") == 'Opportunity'){
        	var opportunityRecord = component.get("v.opportunityRecord");
        	pbeObj["CurrencyIsoCode"] = opportunityRecord.CurrencyIsoCode;
        } else if(component.get("v.source") == 'Quote__c'){
            var quoteRecord = component.get("v.quoteRecord");
        	pbeObj["CurrencyIsoCode"] = quoteRecord.CurrencyIsoCode;
        }
        var pbeFieldList = component.get("v.pbeFieldList");
        var pbeFilterFieldList = component.get("v.pbeFilterFieldList");
        var action = component.get("c.getPriceBookEntriesBySearchFilter");
        action.setParams({
            "pbeWrapperJson" : JSON.stringify(pbeWrapper),
            "pbeFieldList" :  pbeFieldList,
            "productFilterFieldList" : productFilterFieldList,
            "pbeFilterFieldList" : pbeFilterFieldList,
            "recordLimit" : 200,
            "andOrCondition" : component.get("v.andORLogic")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var pbeWrapperList = response.getReturnValue();
                var pbeWrapperList = pbeWrapperList;
                var territory;
                if(pbeWrapper.productRecord.Territory__c != undefined) {
                    territory = pbeWrapper.productRecord.Territory__c;
                }
                var isResolvedProductSearch = component.get("v.isResolvedProductSearch");
                // Create event
                if(!isResolvedProductSearch) {
                    var appEvent = $A.get("e.c:LXE_CRM_SearchResultEvent");
                    appEvent.setParams({
                        "pbeWrapperList" : pbeWrapperList,
                        "territory" : territory,
                        "searchresult" : true
                    });
                    appEvent.fire();
                    helper.setSelectorTab(component, event, helper, "search");
                } else {
                    var resolveProductEvent = $A.get("e.c:LXE_CRM_ResolveProductEvent");
                    var resolveLineItem = component.get("v.resolveLineItem");
                    resolveProductEvent.setParams({
                        "pbeWrapperList" :  pbeWrapperList,
                        "resolveLineItem" : resolveLineItem,
                        "action" : "searchResult",
                        "actionType" : component.get("v.actionType"),
                        "screen" : component.get("v.resolveScreen")
                    });
                    resolveProductEvent.fire();
                    $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
                }
            } else if(state === "ERROR") {
                var errors = response.getError();
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
    getProductSearchInitData : function(component, event, helper) {
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "start"}).fire();
        var fieldsAPIList = component.get("v.fieldsAPIList");
        var oppFieldList = ["Id", "Name", "CurrencyIsoCode"];
        var defaultProductfieldList = component.get("v.fieldsAPIList");
        var defaultFieldsAPIList = [];
        for(var i = 2; i < defaultProductfieldList.length; i++) {
            if(defaultProductfieldList[i] == 'Hierarchy_Global_Code_Description__c') {
                defaultFieldsAPIList.push("Df_" + defaultProductfieldList[i]);
            } else {
                defaultFieldsAPIList.push("Default_" + defaultProductfieldList[i]);
            } 
        }
        defaultFieldsAPIList.push("User__c");
        var action = component.get("c.getProductSearchInitData");
        action.setParams({ 
            objectName : "Product2",
            fieldAPINameList : fieldsAPIList,
            opportunityId : component.get("v.recordId"),
            oppFieldList : oppFieldList,
            defaultProductfieldList : defaultFieldsAPIList,
            source : component.get("v.source"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var opportunityWrapperList = response.getReturnValue();
                if(opportunityWrapperList.length > 0) {
                    var opportunityWrapper = opportunityWrapperList[0];
                    var defaultProductSearch = opportunityWrapper.defaultProductSearch;
                    var objectFieldsWrapperList = opportunityWrapper.objectFieldsWrapperList;
                    helper.createPickListFieldsMap(component, event, helper, opportunityWrapper.objectFieldsWrapperList);
                    defaultProductSearch["Default_" + defaultProductfieldList[0]] = "";
                    defaultProductSearch["Default_" + defaultProductfieldList[1]] = "";
                    defaultProductSearch["Default_Hierarchy_Level__c"] = "Material";
                    component.set("v.defaultProductFilterObj", defaultProductSearch);
					if(component.get("v.source") == 'Opportunity'){
                    	component.set("v.opportunityRecord", opportunityWrapper.opportunityRecord);
                    } else if(component.get("v.source") == 'Quote__c'){
                    	component.set("v.quoteRecord", opportunityWrapper.quoteRecord);
                    } 
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
    createPickListFieldsMap : function(component, event, helper, objectFieldsWrapperList) {
        var pickListFieldsMap = {};
        for(var count in objectFieldsWrapperList) {
            var fieldWrapper = objectFieldsWrapperList[count];
            if(fieldWrapper.fieldDataType =="PICKLIST") {
                var fieldValueList = [];
                if(fieldWrapper.fieldApiName == "territory__c") {
                    fieldValueList.push("--None--");
                    fieldValueList.push("Global");
                    fieldWrapper.fieldValues.splice(0, 1);
                }
                for(var fieldvalue in fieldWrapper.fieldValues) {
                    fieldValueList.push(fieldWrapper.fieldValues[fieldvalue]);
                }
                pickListFieldsMap[fieldWrapper.fieldApiName] = fieldValueList;
            }else if(fieldWrapper.fieldApiName == "us_practice__c") {
                helper.getTextValues(component, event, helper,fieldWrapper.fieldApiName,pickListFieldsMap);
            }else if(fieldWrapper.fieldDataType == "BOOLEAN") {
                var fieldValueList = [];
                fieldValueList.push("--None--");
                fieldValueList.push("YES");
                fieldValueList.push("NO");
                pickListFieldsMap[fieldWrapper.fieldApiName] = fieldValueList;
            }
        }
        component.set("v.pickListFieldsMap", pickListFieldsMap);
    },
    getTextValues : function(component, event, helper,fieldApiName, pickListFieldsMap){
        var fieldValueList = [];
        var action = component.get("c.getTextFieldValues");
        action.setParams({
            "fieldApiName":fieldApiName
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnMap = response.getReturnValue();
                component.set("v.Sales_with_BNF",JSON.parse(returnMap['Sales_with_BNF']));
                var fieldPicklistValues = JSON.parse(returnMap[fieldApiName]);
                fieldValueList.push("--None--");
                for(let i =0 ; i<fieldPicklistValues.length; i++){
                    fieldValueList.push(fieldPicklistValues[i]);
                }
                pickListFieldsMap[fieldApiName] = fieldValueList;
                component.set("v.pickListFieldsMap", pickListFieldsMap);
            }else if(state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var errorMsg = JSON.parse(errors[0].message).errorList;
                        helper.setToast(component, event, helper, errorMsg, "error", "Error!");
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    clearDefaultFilter : function(component, event, helper) {
        var fieldsAPIList = component.get("v.fieldsAPIList");
        var defaultProductFilterObj = component.get("v.defaultProductFilterObj");
        for(var count in fieldsAPIList) {
            if(fieldsAPIList[count] == 'Hierarchy_Global_Code_Description__c') {
                defaultProductFilterObj["Df_" + fieldsAPIList[count]] = "";
            } else {
                defaultProductFilterObj["Default_" + fieldsAPIList[count]] = "";
            }
        }
        defaultProductFilterObj["Default_Hierarchy_Level__c"] = "Material";
        component.set("v.defaultProductFilterObj", defaultProductFilterObj);
    },
    saveDefaultFilter : function(component, event, helper) {
        var appEvent = $A.get("e.c:LXE_CRM_SpinnerEvent");
        appEvent.setParams({"action" : "start"});
        appEvent.fire();
        var defaultProductFilterObj = component.get("v.defaultProductFilterObj");
        for(var filterField in defaultProductFilterObj) {
            if(defaultProductFilterObj[filterField] === "--None--") {
                defaultProductFilterObj[filterField] = "";
            } 
        }
        var action = component.get("c.updateDefaultProductSearchFilter");
        action.setParams({
            "defaultFilterObjString" : JSON.stringify(defaultProductFilterObj)
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var msg = [];
                msg.push("Your default search setting has been saved");
                helper.setToast(component, event, helper, msg, "success", "Success!");
            } else if(state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var errorMsg = JSON.parse(errors[0].message).errorList;
                        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
                        helper.setToast(component, event, helper, errorMsg, "error", "Error!");
                    }
                }
            }
            var appEvent = $A.get("e.c:LXE_CRM_SpinnerEvent");
            appEvent.setParams({"action" : "stop"});
            appEvent.fire();
        });
        $A.enqueueAction(action);
    },
    getDefaultProductSearchFilter : function(component, event, helper) {
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "start"}).fire();
        var defaultProductfieldList = component.get("v.fieldsAPIList");
        var defaultFieldsAPIList = [];
        for(var i = 2; i < defaultProductfieldList.length; i++) {
            if(defaultProductfieldList[i] == 'Hierarchy_Global_Code_Description__c') {
                defaultFieldsAPIList.push("Df_" + defaultProductfieldList[i]);
            } else {
                defaultFieldsAPIList.push("Default_" + defaultProductfieldList[i]);
            }
        }
        defaultFieldsAPIList.push("User__c");
        var action = component.get("c.getDefaultProductSearchFilter");
        action.setParams({
            "defaultProductfieldList" : defaultFieldsAPIList
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                returnValue["Default_" + defaultProductfieldList[0]] = "";
                returnValue["Default_" + defaultProductfieldList[1]] = "";
                component.set("v.defaultProductFilterObj", returnValue);
                $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
            } else if(state === "ERROR") {
                var errors = response.getError();
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
    
    
    searchResolvedProduct : function(component, event, helper, params) {
        var resolveLineItem = params.resolveLineItem;
        var actionType = params.actionType;
        var fieldsAPIList = component.get("v.fieldsAPIList");
        var defaultProductFilterObj = {};
        if(actionType == "resolve") {
            for(var i = 2; i < fieldsAPIList.length; i++) {
                var fieldValue = resolveLineItem["Product2"][fieldsAPIList[i]];
                if(fieldValue == undefined) {
                    fieldValue = null;
                }
                if(fieldsAPIList[i] == 'Hierarchy_Global_Code_Description__c') {
                    defaultProductFilterObj["Df_" + fieldsAPIList[i]] = fieldValue;
                } else {
                    defaultProductFilterObj["Default_" + fieldsAPIList[i]] = fieldValue;
                }
            }
            defaultProductFilterObj["Default_Hierarchy_Level__c"] = "Material";
            component.set("v.defaultProductFilterObj", defaultProductFilterObj);
        }
        component.set("v.resolveLineItem", resolveLineItem);
        component.set("v.actionType", actionType);
        component.set("v.resolveScreen", params.screen);
        component.set("v.isResolvedProductSearch", true);
        if(actionType == "resolve") {
            helper.searchfilterProducts(component, event, helper);
        } else {
            $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
        }
    },
    
    hideResolveProduct : function(component, event, helper) {
        helper.clearDefaultFilter(component, event, helper);
        component.set("v.isResolvedProductSearch", false);
    },
    
    setSelectorTab : function(component, event, helper, activeTabId) {
        var tabEvent = $A.get("e.c:LXE_CRM_SetActiveTabEvent");
        tabEvent.setParams({"activeTabId" : activeTabId});
        tabEvent.fire(); 
    },
    
    setToast : function(component, event, helper, message, type, title) {
        var errorMsg = message;
        var msg = "";
        for(var x = 0; x < errorMsg.length; x++) {
            msg = msg + errorMsg[x] + "\n";
        }
        var mode;
        if(type == "success") {
            mode = "dismissible";
        } else {
            mode = "sticky";
        }
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            type : type,
            message : msg,
            mode : mode
        });
        toastEvent.fire();
    },
})