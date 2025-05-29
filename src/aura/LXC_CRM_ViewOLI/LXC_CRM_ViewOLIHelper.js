({
    getOliItems : function(component, event, helper) {
        var resultObject = []; 
        var fieldList = component.get("v.headerApiList");
        var finalFieldList = [];
        for(var x = 0; x < fieldList.length; x++) {
            finalFieldList.push(fieldList[x]);
        }
        var otherFieldList = ["Number_of_License__c", "Therapy_Area__c", "Hierarchy_Level__c", "Product_SalesLead__c", "SalesEngineer__c", "Id", "OpportunityId", "CurrencyISOCode", "Product2.Name", "PricebookEntryId", "Product2.Offering_Segment__c", 
                              "Product2.Territory__c", "Product2.Offering_Group__c", "Product2.Offering_Type__c", "Product2.COE_Name__c","Delivery_Media__c","Proj_Rpt_Frequency__c","Billing_Frequency__c","Project_Manager__c", 
                              "Product2.Product_Group__c", "Product2.Unit_Name__c", "Product2.Hierarchy_Level__c", "Product2.CanUseRevenueSchedule", "Product2.Delivery_Type__c","Product2.Therapy_Class__c"];
        
        if(component.get("v.source") == 'Quote__c'){
            var hdList = ["Product Name","Final Price","Delivery Country","Revenue Type","Sale Type","Revenue Start Date"];
            component.set("v.headerList",hdList);
        }
        for(var index = 0; index < otherFieldList.length; index++) {
            finalFieldList.push(otherFieldList[index]);
        }
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "start"}).fire();
        var action = "";
        if(component.get("v.source") == 'Quote__c'){
            action = component.get("c.getListOfQLI");
            var id = component.get("v.recordId");
            action.setParams({ 
                opportunityId : id
            });
        }else{
            action = component.get("c.getListOfOLI");
            var id = component.get("v.recordId");
            action.setParams({ 
                opportunityId : id, 
                oliFields : finalFieldList
            });
        }
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(component.get("v.source") == 'Quote__c'){
                    var oppWrapperList = response.getReturnValue();
                    var resultWrapper = oppWrapperList;
                    component.set("v.listOfOli", oppWrapperList);
                	var headerApiList = ["bundleProductName","netPrice","country","revenueType","salesType","startDate","bundleProductHierarchyLevel"];
                    if(resultWrapper == null || resultWrapper.length == 0) {
                        component.set("v.isAddProduct", true);
                    } else {
                        component.set("v.isAddProduct", false);
                        for(var i = 0; i < resultWrapper.length; i++ ) {
                            var rowItems = [];
                            for(var j = 0; j < headerApiList.length-1; j++ ) {
                                var dataValue = resultWrapper[i][headerApiList[j]];
                                if(headerApiList[j] == "bundleProductName") {
                                    dataValue = resultWrapper[i]["bundleProductName"];
                                }
                                if(dataValue == undefined) {
                                    dataValue = "";
                                }
                                rowItems.push({
                                    api : headerApiList[j],
                                    data : dataValue
                                });
                            }
                            var isNonMaterialProduct = false;
                            resultObject.push({
                                dataColumns : rowItems,
                                isNonMaterialProduct : isNonMaterialProduct,
                            });
                        } 
                    }
                    component.set("v.resultObjectWrapper", resultObject);
                }else{ 
                var oppWrapperList = response.getReturnValue();
                var oliWrapperList = oppWrapperList[0]["oliWrapperList"];
                component.set("v.listOfOli", oliWrapperList);
                var resultWrapper = oliWrapperList;
                var headerApiList = component.get("v.headerApiList");
                if(resultWrapper == null || resultWrapper.length == 0) {
                    component.set("v.isAddProduct", true);
                } else {
                    component.set("v.isAddProduct", false);
                    for(var i = 0; i < resultWrapper.length; i++ ) {
                        var rowItems = [];
                        for(var j = 0; j < headerApiList.length-1; j++ ) {
                            var dataValue = resultWrapper[i]["oliRecord"][headerApiList[j]];
                            if(headerApiList[j] == "Name") {
                                dataValue = resultWrapper[i]["oliRecord"]["Product2"]["Name"];
                            }
                            if(headerApiList[j] == "UnitPrice") {
                                dataValue = dataValue.toFixed(2);
                            }
                            if(dataValue == undefined) {
                                dataValue = "";
                            }
                            rowItems.push({
                                api : headerApiList[j],
                                data : dataValue
                            });
                        }
                        var isNonMaterialProduct = false;
                        if(resultWrapper[i]["oliRecord"]["Hierarchy_Level__c"] != undefined && resultWrapper[i]["oliRecord"]["Hierarchy_Level__c"] != "Material") {
                            isNonMaterialProduct = true;
                        }
                        resultObject.push({
                            dataColumns : rowItems,
                            isNonMaterialProduct : isNonMaterialProduct,
                        });
                    } 
                }
                component.set("v.resultObjectWrapper", resultObject);
                }
            } else {
                var errors = response.getError();
                if (errors[0] && errors[0].message) {
                    var err = JSON.parse(errors[0].message).errorList;
                    helper.setToast(component, event, helper, err, "error", "Error!");
                }
            }
            $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
        });
        $A.enqueueAction(action);
    },
    
    resolveLineItem : function(component, event, helper, actionType) {
        var currentId = event.getSource().get("v.name");
        var listOfOli = component.get("v.listOfOli");
        var actionLabel = "Resolve Products";
        if(actionType == "change") {
            actionLabel = "Change Products";
        } 
        helper.setSelectorTab(component, event, helper, "resolveProducts", actionLabel);
        if(currentId >=0 && currentId < listOfOli.length) {
            $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "start"}).fire();
            var resolveProductEvent = $A.get("e.c:LXE_CRM_ResolveProductEvent");
            resolveProductEvent.setParams({
                "resolveLineItem" :  listOfOli[currentId]["oliRecord"],
                "action" : "search",
                "actionType" : actionType,
                "screen" : "OpportunityDetail"
            });
            resolveProductEvent.fire();
        }  
    },
    
    setSelectorTab : function(component, event, helper, activeTabId, actionLabel) {
        var tabEvent = $A.get("e.c:LXE_CRM_SetActiveTabEvent");
        tabEvent.setParams({
            "activeTabId" : activeTabId,
            "actionLabel" : actionLabel
        });
        tabEvent.fire();
    },
    
    editRecord : function(component, event, helper) {
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "start"}).fire();
        var currentRecordList = [];
        var currentId = event.getSource().get("v.name");
        var listOfOli = component.get("v.listOfOli");
        var oli;
        for(var i = 0; i < listOfOli.length; i++) {
            if(i == currentId) {
                currentRecordList.push(listOfOli[i]);
                //Event Call
                var addOrEditProduct = $A.get("e.c:LXE_CRM_AddOrEditProductEvent");
                addOrEditProduct.setParams({
                    "title" : "Edit Product Page",
                    "selectedList" : currentRecordList,
                    "isFadeIn" : true,
                    "operationType" : "edit",
                    "fieldsToShow" : "Name,UnitPrice,Delivery_Country__c,Hierarchy_Level__c,Revenue_Type__c,Sale_Type__c,Product_Start_Date__c,Product_End_Date__c,Description,Number_of_License__c,Delivery_Media__c,Proj_Rpt_Frequency__c,Billing_Frequency__c,Project_Manager__c,Id",
                    "fieldsToDisable" : "Hierarchy_Level__c"
                });
                addOrEditProduct.fire();
                break;
            }
        }
    },
    
    cloneRecord : function(component, event, helper) {
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "start"}).fire();
        var currentRecordList = [];
        var currentId = event.currentTarget.id
        var listOfOli = component.get("v.listOfOli");
        var oli;
        for(var i = 0; i < listOfOli.length; i++) {
            if(i == currentId) {
                //listOfOli[i][Id] = null;
                console.log(listOfOli[i]);
                currentRecordList.push(listOfOli[i]);
                //Event Call
                var addOrEditProduct = $A.get("e.c:LXE_CRM_AddOrEditProductEvent");
                addOrEditProduct.setParams({
                    "title" : "Clone Product(s) Page",
                    "selectedList" : currentRecordList,
                    "isFadeIn" : true,
                    "operationType" : "clone",
                    "fieldsToShow" : "UnitPrice,Revenue_Type__c,Sale_Type__c,Delivery_Country__c,Therapy_Area__c,Product_Start_Date__c,Product_End_Date__c,Product_SalesLead__c,Project_Manager__c",
                    "fieldsToDisable" : ""
                });
                addOrEditProduct.fire();
                break;
            }
        }
    },
    
    editAllRecord : function(component, event, helper) {
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "start"}).fire();
        if(component.get("v.source") == 'Quote__c'){
            var navService = component.find("navService");
            var currentId = component.get("v.recordId");
            console.log('currentId' + currentId);
            var pageReference = {
                type: "standard__component",
                attributes: {
                    componentName : "c__LXC_CPQ_UpdateQLI"
            },
                state:{
                    c__recordId:currentId
                }
            };
            navService.navigate(pageReference);
        }else{
            var currentRecordList = [];
            var currentId = event.target.getAttribute("data-id");
            var listOfOli = component.get("v.listOfOli");
            var addOrEditProduct = $A.get("e.c:LXE_CRM_AddOrEditProductEvent");
            var oliList = [];
            for(var count = 0; count < listOfOli.length; count++) {
                //oliList.push(listOfOli[count]["oliList.push(listOfOli[count]["oliRecord"]);"]);
                oliList.push(listOfOli[count]);
            }
            addOrEditProduct.setParams({
                "title" : "Edit Product Page",
                "selectedList" : listOfOli,
                "isFadeIn" : true,
                "operationType" : "edit",
                "fieldsToShow" : "Name,UnitPrice,Delivery_Country__c,Hierarchy_Level__c,Revenue_Type__c,Sale_Type__c,Product_Start_Date__c,Product_End_Date__c,Description,Number_of_License__c,Delivery_Media__c,Proj_Rpt_Frequency__c,Billing_Frequency__c,Project_Manager__c,Id",
                "fieldsToDisable" : "Hierarchy_Level__c"
            });
            addOrEditProduct.fire();
        }
        
    }, 
    
    deleteRecord : function(component, event, helper) {
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "start"}).fire();
        var currentRecordList = [];
        var currentId = event.getSource().get("v.name");
        var listOfOli = component.get("v.listOfOli");
        for(var i = 0; i < listOfOli.length; i++) {
            if(i == currentId) {
                currentRecordList.push({
                    oliRecord : listOfOli[i]["oliRecord"],
                    operationType : "Delete"
                });
                break;
            }
        }
        var action = component.get("c.crudOliRecord");
        action.setParams({ 
            recordJSON : JSON.stringify(currentRecordList),
            action : "Delete",
            recordToDelete : null
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var appEvent = $A.get("e.c:LXE_CRM_ReloadEvent");
                appEvent.setParams({
                        eventFor : "reload"
                    });
                appEvent.fire();
            } else if (state === "INCOMPLETE") {
                console.log("INCOMPLETE");
                $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var err = JSON.parse(errors[0].message).errorList;
                        helper.setToast(component, event, helper, err, "error", "Error!");
                    }
                }
                $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
            }
            
        });
        $A.enqueueAction(action);  
    }, 
    
    navigateToRecord : function(component, event, helper) {
        var dataId = event.target.getAttribute("data-id");
        var listOfOli = component.get("v.listOfOli");
        var recordId;
        for(var i = 0; i < listOfOli.length; i++) {
            if(i == dataId) {
                if(component.get("v.source") == "Quote__c"){
                    recordId = listOfOli[i]["recordId"];
                }else{
                    recordId = listOfOli[i]["oliRecord"]["Id"];
                }
            }
        }
        var url = "/" + recordId;
        window.open(url);
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
                    if(componentList[index].isValid()) {
                        componentTempList.push(componentList[index]);
                    }
                }
            }
            componentList = componentTempList;
            componentsMap.set(cmpIds[cmpIndex], componentList);
        }
        return componentsMap;
    },
    
    togglePopOver : function(component, event, helper, isShowPopup) {
        var popoverName = event.currentTarget.id;
        var index = popoverName.split("_")[1];
        var cmpIds = ["popoversection"];
        var componentsMap = helper.findComponentByAuraIds(component, event, cmpIds);
        var popSectionComp = componentsMap.get(cmpIds[0]);
        if(isShowPopup) {
            $A.util.removeClass(popSectionComp[index], 'slds-hide');
        } else {
            $A.util.addClass(popSectionComp[index], 'slds-hide');
        } 
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
    }
})