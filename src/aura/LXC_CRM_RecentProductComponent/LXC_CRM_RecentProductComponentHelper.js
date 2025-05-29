({
    getFavoriteProducts : function(component, event, helper) {
        var action = component.get("c.getFavoriteProducts");
        action.setParams({
            "oppId" : component.get("v.recordId"),
            "source" : component.get("v.source")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var params = event.getParams();
                component.set("v.territory", params.territory);
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
    
    closeCommentModel: function(component, event, helper) {
        component.set("v.isCommentModalOpen", false);
        component.set("v.favProductSelected","");
        component.set("v.favProductComment","");
        component.set("v.favProductCategory","");
    },
    getMiniLayout:function(component, event, helper,productId){
        var getRecords = component.get('v.SearchResultWrapper');
        for(var i=0;i<getRecords.length;i++){
            if(getRecords[i].productRecord.Id == productId){
                component.set('v.mouseHoverData', getRecords[i]);
                break;
            }
        }
        component.set("v.hoverRow", parseInt(event.target.dataset.index));
        component.set("v.togglehover",true);
    }
})