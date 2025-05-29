({
    disableOtherTabs : function(component, event, helper) {
        var searchComp = component.find("searchProducts");
        var favouriteComp = component.find("favourite"); 
        var viewOliComp = component.find("viewOli");
        $A.util.addClass(searchComp, "disabledTab");
        $A.util.addClass(favouriteComp, "disabledTab");
        viewOliComp.set("v.class", "disabledTab");
    },
    
    hideResolveTab : function(component, event, helper) {
        var resolveProductsComp = component.find("resolveProducts");
        var searchComp = component.find("searchProducts");
        var favouriteComp = component.find("favourite"); 
        var viewOliComp = component.find("viewOli");
        if(searchComp != undefined) {
            $A.util.removeClass(searchComp, "disabledTab");
        }
        if(favouriteComp != undefined) {
            $A.util.removeClass(favouriteComp, "disabledTab");
        }
        if(viewOliComp != undefined) {
            viewOliComp.set("v.class", ""); 
        }
        if(resolveProductsComp != undefined) {
            resolveProductsComp.set("v.class", "slds-hide");
        }
        component.set("v.activeTabId", "viewOli");
    },
    
    changeLineItem : function(component, event, helper, oliId) {
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "start"}).fire();
        var fieldList = ["Name","UnitPrice","Delivery_Country__c","Billing_System__c","Revenue_Type__c","Sale_Type__c","Product_Start_Date__c","Product_End_Date__c","Description","Id",
                         "Therapy_Area__c", "Hierarchy_Level__c", "Product_SalesLead__c", "SalesEngineer__c", "Id", "OpportunityId", "CurrencyISOCode", "Product2.Name", "PricebookEntryId", 
                         "Product2.Offering_Segment__c", "Product2.Territory__c", "Product2.Offering_Group__c", "Product2.Offering_Type__c", "Product2.COE_Name__c", 
                         "Product2.Product_Group__c", "Product2.Unit_Name__c", "Product2.Hierarchy_Level__c", "Product2.CanUseRevenueSchedule"];
        var action = component.get("c.getOpportunityLineItemsDetail");
        var oliId = component.get("v.oliId");
        var oliIdList = [oliId];
        action.setParams({ 
            oliIdList : oliIdList, 
            oliFieldList : fieldList
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var resolveProductsComp = component.find("resolveProducts");
                if(resolveProductsComp != undefined) {
                    resolveProductsComp.set("v.class", "");
                    var resolveLabel = resolveProductsComp.get("v.label");
                    resolveLabel[0].set("v.value", "Change Products");
                }
                
                var searchComp = component.find("searchProducts");
                var favouriteComp = component.find("favourite"); 
                var viewOliComp = component.find("viewOli");
                if(favouriteComp != undefined) {
                    $A.util.addClass(favouriteComp, "disabledTab");
                }
                if(viewOliComp != undefined) {
                    $A.util.addClass(viewOliComp, "disabledTab");
                }
                if(searchComp != undefined) {
                    searchComp.set("v.class", "disabledTab");
                }
                component.set("v.activeTabId", "resolveProducts");
                var oliList = response.getReturnValue();
                if(oliList.length > 0) {
                    var resolveProductEvent = $A.get("e.c:LXE_CRM_ResolveProductEvent");
                    resolveProductEvent.setParams({
                        "resolveLineItem" :  oliList[0],
                        "action" : "search",
                        "actionType" : "change",
                        "screen" : "ProductDetail"
                    });
                    resolveProductEvent.fire();
                }
                $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
            }else {
                var errors = response.getError();
                if (errors[0] && errors[0].message) {
                    var err = JSON.parse(errors[0].message).errorList;
                    console.log(err);
                }
                $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    addProducts : function(component, event, helper, productRecordJSON) {
        var productId = productRecordJSON.productId;
        var currencyIsoCode = productRecordJSON.currencyIsoCode;
        var countryLicenseList = productRecordJSON.countryAndLicense;
        var pbeWrapper = {};
        var productObj = {};
        var pbeObj = {};
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "start"}).fire();
        pbeWrapper["productRecord"] = productObj;
        pbeWrapper["pbeRecord"] = pbeObj;
        productObj['Id'] = productId;
        productObj['Hierarchy_Level__c'] = 'Material';
        pbeObj["CurrencyIsoCode"] = currencyIsoCode;
        var productFilterFieldList = ["Hierarchy_Level__c", "Id"];
        var pbeFilterFieldList = ["CurrencyIsoCode"];
        var pbeFieldList = ["Id","CurrencyIsoCode","Product2.Name","Product2.Hierarchy_Level__c","Product2.Description","Product2.ProductCode","Product2.CanUseRevenueSchedule","Product2.Material_Type__c","Product2.Billing_System__c","Product2.Offering_Group_Code__c","Product2.Delivery_Type__c"];
        var action = component.get("c.getPriceBookEntriesBySearchFilter");
        action.setParams({
            "pbeWrapperJson" : JSON.stringify(pbeWrapper),
            "pbeFieldList" :  pbeFieldList,
            "productFilterFieldList" : productFilterFieldList,
            "pbeFilterFieldList" : pbeFilterFieldList,
            "recordLimit" : 1,
            "andOrCondition" : "AND"
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var pbeWrapperList = response.getReturnValue();
                if(pbeWrapperList.length == 0) {
                    alert('Price Book Entry Not Found');
                    $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
                    var ldsComp = component.find("ldsScreen");
                    ldsComp.set("v.showModal", false);
                    component.set("v.isLDSVisible", false);
                    return;
                }
                var pbeList = [];
                for(var i = 0; i < countryLicenseList.length; i++) {
                    var pbeWrapper = JSON.parse(JSON.stringify(pbeWrapperList[0]));
                    pbeWrapper["oliRecord"] = countryLicenseList[i];
                    pbeList.push(pbeWrapper);
                }
                var addOrEditProduct = $A.get("e.c:LXE_CRM_AddOrEditProductEvent");
                addOrEditProduct.setParams({
                    "fieldsToDisable" : "",
                    "fieldsToShow" : "UnitPrice,Revenue_Type__c,Sale_Type__c,Delivery_Country__c,Therapy_Area__c,Product_Start_Date__c,Product_End_Date__c,Product_SalesLead__c,Number_of_License__c,Project_Manager__c",
                    "title" : "Add Product Page",
                    "selectedList" : pbeList,
                    "isFadeIn" : true,
                    "operationType" : "createFromLDS",
                });
                addOrEditProduct.fire();
                $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
            } else if(state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message && JSON.parse(errors[0].message).errorList) {
                        console.log(JSON.parse(errors[0].message).errorList);
                    } else {
                        console.log(errors);
                    }
                }
                $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    getRecentProducts : function(component,event,helper){
        var pbeWrapperJson = { "productRecord": { "Hierarchy_Level__c": "Material" }, "pbeRecord": { "CurrencyIsoCode": "USD" } };
        var pbeFieldList = ['Id', 'CurrencyIsoCode', 'Product2.Name', 'Product2.Hierarchy_Level__c', 'Product2.Description', 'Product2.ProductCode', 'Product2.CanUseRevenueSchedule', 'Product2.Material_Type__c', 'Product2.Billing_System__c', 'Product2.Offering_Group_Code__c', 'Product2.Delivery_Type__c', 'Product2.Offering_Type__c', 'Product2.Offering_Group__c', 'Product2.Offering_Segment__c', 'Product2.COE_Name__c', 'Product2.Product_Group__c', 'Product2.Unit_Name__c', 'Product2.ProductGroup__c', 'Product2.Territory__c','Product2.Excluded_From_Pricing_Assistant__c','Product2.Material_Group_1__c','Product2.Therapy_Class__c'];
        var productFilterFieldList = ['Hierarchy_Level__c'];
        var pbeFilterFieldList = ['CurrencyIsoCode'];
        
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "start"}).fire();
        var action = component.get("c.getRecentProductList");
        action.setParams({
            "pbeWrapperJson" : JSON.stringify(pbeWrapperJson),
            "pbeFieldList" :  pbeFieldList,
            "productFilterFieldList" : productFilterFieldList,
            "pbeFilterFieldList" : pbeFilterFieldList,
            "recordLimit": 50,
            "andOrCondition" : "AND"
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                $A.get("e.c:LXE_CRM_RecentProductResultEvent").setParams({"pbeWrapperList" : result}).fire();
            } else if(state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message && JSON.parse(errors[0].message).errorList) {
                        console.log(JSON.parse(errors[0].message).errorList);
                    } else {
                        console.log(errors);
                    }
                }
            }
            $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
        });
        $A.enqueueAction(action);
    }
})