({
    createSearchResultWrapper : function(component, event, helper, resolveProducts,isViewFav) {
        component.set("v.showResult", false);
        var resultObject = [];
        if(isViewFav){
            var headerApiList = component.get("v.headerViewFavApiList");
        }else{
            var headerApiList = component.get("v.headerApiList");  
        }
        for(var i = 0; i < resolveProducts.length; i++) {
            var rowItems = [];
            for(var j = 0; j < headerApiList.length; j++) {
                var dataValue = resolveProducts[i]["productRecord"][headerApiList[j]];
                if(dataValue == undefined) {
                    dataValue = "";
                }
                rowItems.push({
                    data : dataValue
                });
            }
            resultObject.push({
                dataColumns : rowItems,
                quantity : 1,
                id : resolveProducts[i]["productRecord"]["Id"]
            });
        }
        component.set("v.resultObjectWrapper", resultObject); 
        component.set("v.showResult", true);
    },
    
    addProducts : function(component, event, helper) {
        var selectedProductIdMap = new Map();
        var selectedValues = [];
        var checkboxCompList = component.find("checkbox-input");
        var quantityCompList = component.find("quantity");
        if (checkboxCompList != undefined && checkboxCompList != null && checkboxCompList.length == undefined) {
            var checkboxCompArr = [];
            checkboxCompArr.push(checkboxCompList);
            checkboxCompList = checkboxCompArr;
        }
        if(quantityCompList != undefined && quantityCompList != null && quantityCompList.length == undefined) {
            var quantityCompArr = [];
            quantityCompArr.push(quantityCompList);
            quantityCompList = quantityCompArr;
        }
        for(var i = 0; i < checkboxCompList.length; i++) {
            var checkBoxComp = checkboxCompList[i].getElements()[0];
            if(checkboxCompList[i].isRendered() && checkBoxComp.checked) {
                var quantityVal = quantityCompList[i].get("v.value");
                if(quantityVal == undefined) {
                    quantityVal = 1;
                } else if(quantityVal <= 0 || quantityVal > 15) {
                    var toastMessage = [];
                    toastMessage.push("Please input quantity between 1 - 15");
                    helper.setToast(component, event, helper, toastMessage, "error", "Error!");
                    var appEvent = $A.get("e.c:LXE_CRM_SpinnerEvent");
                    appEvent.setParams({"action" : "stop"});
                    appEvent.fire();
                    return;
                }
                var selectedId = checkBoxComp.id.split("-")[0];
                selectedProductIdMap.set(selectedId, quantityVal);
            }
        }
        
        if(selectedProductIdMap.size == 0) {
            var toastMessage = [];
            toastMessage.push("Please Select atleast one Product");
            helper.setToast(component, event, helper, toastMessage, "error", "Error!");
            var appEvent = $A.get("e.c:LXE_CRM_SpinnerEvent");
            appEvent.setParams({"action" : "stop"});
            appEvent.fire();
            return;
        }
        var resultWrapper = component.get("v.resolveProducts");
        for(var i = 0; i < resultWrapper.length; i++) {
            if(selectedProductIdMap.has(resultWrapper[i]["productRecord"]["Id"])) {
                for(var j = 0; j < selectedProductIdMap.get(resultWrapper[i]["productRecord"]["Id"]); j++) {
                    selectedValues.push(resultWrapper[i]);
                }
            }
        }
        var addOrEditProduct = $A.get("e.c:LXE_CRM_AddOrEditProductEvent");
        addOrEditProduct.setParams({
            "fieldsToDisable" : "",
            "fieldsToShow" : "UnitPrice,Revenue_Type__c,Sale_Type__c,Delivery_Country__c,Therapy_Area__c,Product_Start_Date__c,Product_End_Date__c,Product_SalesLead__c,Project_Manager__c",
            "title" : "Add Product Page",
            "selectedList" : selectedValues,
            "isFadeIn" : true,
            "operationType" : "create"
        });
        addOrEditProduct.fire();
        var resolveProductEvent = $A.get("e.c:LXE_CRM_ResolveProductEvent");
        var resolveLineItem = component.get("v.resolveLineItem");
        resolveProductEvent.setParams({
            "resolveLineItem" : resolveLineItem,
            "action" : "resolve",
            "actionType" : component.get("v.actionType"),
            "screen" : component.get("v.resolveScreen")
        });
        resolveProductEvent.fire();
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
    
    getFavoriteProduct : function(component, event, helper) {
        var action = component.get("c.getFavoriteProducts");
        action.setParams({
            "oppId" : component.get("v.recordId"),
            "source" : component.get("v.source")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var pbeWrapperList = response.getReturnValue();
                component.set("v.resolveProducts", pbeWrapperList);
                component.set("v.actionType", "change");
                component.set("v.showFavoriteProduct", true);
                helper.createSearchResultWrapper(component, event, helper, pbeWrapperList,true);
            } else if(state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var err = JSON.parse(errors[0].message).errorList;
                        helper.setToast(component, event, helper, err, "error", "Error!");
                    }
                }
            }
        })
        $A.enqueueAction(action);
    },
    
    getFavoriteProducts : function(component, event, helper) {
        var action = component.get("c.getFavoriteProducts");
        action.setParams({
            "oppId" : component.get("v.recordId"),
            "source" : component.get("v.source")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.displaytoast", false);
                var params = event.getParams();
                component.set("v.territory", params.territory);
                component.set("v.displaytoast", params.searchresult);
                var pbeWrapperList = response.getReturnValue();
                component.set("v.favoriteResultWrapper", pbeWrapperList);
                if(!component.isReloadEvent) {
                    component.set("v.SearchResultWrapper", params.pbeWrapperList);
                    component.set("v.quantityWrapper", null);
                    var scrollEvent = $A.get("e.c:LXE_CRM_GotoButtomEvent");
                    scrollEvent.fire();
                }
                helper.itemChangeHelper(component, event, helper);
            } else if(state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var err = JSON.parse(errors[0].message).errorList;
                        helper.setToast(component, event, helper, err, "error", "Error!");
                    }
                }
                $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
            }
        })
        $A.enqueueAction(action);
    },
    
    modifyFavoriteProduct : function(component, event, helper) {
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "start"}).fire();
        var productId = component.get("v.favProductSelected");
        var comment = component.get("v.favProductComment");
        var category = component.get("v.favProductCategory");
        var favoriteProductList = [{
            "product__c" : productId,
            "User_Comment__c" : comment,
            "Category__c": category
        }];
        var action = component.get("c.crudFavoriteProductRecord");
        action.setParams({
            "action" : component.action,
            "recordJSON" : JSON.stringify(favoriteProductList)
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.isReloadEvent = true;
                helper.getFavoriteProducts(component, event, helper);
            } else if(state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var err = JSON.parse(errors[0].message).errorList;
                        helper.setToast(component, event, helper, err, "error", "Error!");
                    }
                }
                $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
            }
            component.set("v.isCommentModalOpen", false);
            component.set("v.favProductSelected","");
            component.set("v.favProductComment","");
            component.set("v.favProductCategory","");
        })
        $A.enqueueAction(action);
    },
    
    
    closeCommentModel: function(component, event, helper) {
        component.set("v.isCommentModalOpen", false);
        component.set("v.favProductSelected","");
        component.set("v.favProductComment","");
        component.set("v.favProductCategory","");
    },
    
    itemChangeHelper : function(component, event, helper) {
        var appEvent = $A.get("e.c:LXE_CRM_SpinnerEvent");
        var quantityMap = component.get("v.quantityWrapper");
        if(quantityMap == null) {
            quantityMap = new Map();
        }
        appEvent.setParams({"action" : "start"});
        appEvent.fire();
        var resultObject = [];
        var favoriteProductList = [];
        var resultWrapper = component.get("v.SearchResultWrapper");
        var headerApiList = component.get("v.headerApiList");
        var favoriteProductList = component.get("v.favoriteResultWrapper");
        component.set("v.showResult", false);
        if(resultWrapper == null || resultWrapper.length == 0) {
            component.set("v.isAddProduct", true);
        } else {
            component.set("v.isAddProduct", false);
            for(var i = 0; i < resultWrapper.length; i++) {
                var rowItems = [];
                for(var j = 0; j < headerApiList.length; j++) {
                    var dataValue = resultWrapper[i]["productRecord"][headerApiList[j]];
                    if(dataValue == undefined) {
                        dataValue = "";
                    }
                    rowItems.push({
                        data : dataValue
                    });
                }
                var isFavoriteproduct = false;
                for(var k = 0; k < favoriteProductList.length; k++) {
                    if(resultWrapper[i]["productRecord"]["Id"] == favoriteProductList[k]["productRecord"]["Id"]) {
                        isFavoriteproduct = true;
                        break;
                    }
                }
                var isZREPProduct = false;
                var materialType = resultWrapper[i]["productRecord"]["Material_Type__c"];
                if(materialType == 'ZREP'){
                    isZREPProduct = true;
                }
                resultObject.push({
                    dataColumns : rowItems,
                    isFavorite : isFavoriteproduct,
                    isZREPProduct : isZREPProduct,
                    quantity : helper.getQuantity(component, event, helper, resultWrapper[i]["productRecord"]["Id"], quantityMap),
                    id : resultWrapper[i]["productRecord"]["Id"]
                });
            } 
        }
        component.set("v.resultObjectWrapper", resultObject);
        component.set("v.quantityWrapper", quantityMap);
        component.set("v.showResult", true);
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
    },
    getQuantity : function(component, event, helper, productId, quantityMap) {
        var quantity = 0;
        if(quantityMap != null && quantityMap.has(productId)) {
            quantity = quantityMap.get(productId);
        } else {
            quantityMap.set(productId, 1);
            quantity = 1;
        }
        return quantity;
    },
    
})