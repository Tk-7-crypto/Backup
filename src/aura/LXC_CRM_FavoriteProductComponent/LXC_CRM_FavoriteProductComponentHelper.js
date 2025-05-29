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
                if(!component.isReloadEvent) {
                    component.set("v.quantityWrapper", null);
                }
                var pbeWrapperList = response.getReturnValue();
                component.set("v.favoriteResultWrapper", pbeWrapperList);
                helper.itemChangeHelper(component, event, helper);
                var scrollEvent = $A.get("e.c:LXE_CRM_GotoButtomEvent");
                scrollEvent.fire();
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
    
    modifyFavoriteProduct : function(component, event, helper) {
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "start"}).fire();
        var productId = component.get("v.favProductSelected");
        var comment = component.get("v.favProductComment");
        var category = component.get("v.favProductCategory");
        var favoriteProductList = [{
            "product__c" : productId,
            "User_Comment__c" : comment,
            "Category__c" : category
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
        var resultObject = [];
        var favoriteProductList = [];
        var quantityMap = component.get("v.quantityWrapper");
        if(quantityMap == null) {
            quantityMap = new Map();
        }
        var resultWrapper = component.get("v.favoriteResultWrapper");
        var headerApiList = component.get("v.headerApiList");
        component.set("v.showResult", false);
        if(resultWrapper == null || resultWrapper.length == 0) {
            var addButtonComp = component.set("v.isAddProduct", true);
        } else {
            var addButtonComp = component.set("v.isAddProduct", false);
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
                var isZREPProduct = false;
                var materialType = resultWrapper[i]["productRecord"]["Material_Type__c"];
                if(materialType == 'ZREP'){
                    isZREPProduct = true;
                }
                resultObject.push({
                    dataColumns : rowItems,
                    isFavorite : true,
                    isZREPProduct : isZREPProduct,
                    quantity : helper.getQuantity(component, event, helper, resultWrapper[i]["productRecord"]["Id"], quantityMap),
                    id : resultWrapper[i]["productRecord"]["Id"],
                    Name : resultWrapper[i]["productRecord"]["Name"],
                    Billing_System__c : resultWrapper[i]["productRecord"]["Billing_System__c"],
                    favProductComment : resultWrapper[i]["favRecord"]["User_Comment__c"] ? resultWrapper[i]["favRecord"]["User_Comment__c"] : '',
                    favProductCategory: resultWrapper[i]["favRecord"]["Category__c"] ? resultWrapper[i]["favRecord"]["Category__c"] : '',
                    Description : resultWrapper[i]["productRecord"]["Description"] ? resultWrapper[i]["productRecord"]["Description"] : '',
                    ProductCode : resultWrapper[i]["productRecord"]["ProductCode"]
                });
            } 
        }
        
        component.set("v.totalPages", Math.ceil(resultObject.length/component.get("v.pageSize")));
        component.set("v.allData", resultObject);
        component.set("v.currentPageNumber",1);
        helper.buildData(component, helper,true);
        //component.set("v.resultObjectWrapper", resultObject);
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
    
    handleSort : function(component, event, helper,field) {
        var records = component.get("v.resultObjectWrapper");
        var sortAsc = component.get("v.sortAsc");
        sortAsc = !sortAsc;
        records.sort(function(a, b ) {
            if (sortAsc) {
                return a[field] > b[field] ? 1 : -1; 
            }else{
                return a[field] > b[field] ? -1 : 1; 
            }
        });
        component.set("v.resultObjectWrapper", records);
        component.set("v.sortAsc", sortAsc);
    },
    
    /*
     * this function will build table data
     * based on current page selection
     * */
    buildData : function(component, helper,genratePageList) {
        var data = [];
        var pageNumber = component.get("v.currentPageNumber");
        var pageSize = component.get("v.pageSize");
        var allData = component.get("v.allData");
        let x = (pageNumber-1)*pageSize;
        //creating data-table data
        for(x; x<(pageNumber)*pageSize; ++x){
            if(allData[x]){
                data.push(allData[x]);
            }
        }
        component.set("v.resultObjectWrapper", data);
        if(genratePageList === true){
            helper.generatePageList(component, pageNumber);
        }
    },
    
    /*
     * this function generate page Navigation Number list at the bottom
     * */
    generatePageList : function(component, pageNumber){
        pageNumber = parseInt(pageNumber);
        var pageList = [];
        var pageSize = component.get("v.pageSize");
        var allData = component.get("v.allData");
        var x = allData.length / pageSize;
        var totalPages = component.get("v.totalPages");
        if(allData.length <= pageSize){
            component.set("v.ismultiplelist", false);
        }else{
            component.set("v.ismultiplelist", true);
            var counter = 2;
            for(; counter < x; counter++){
                pageList.push(counter);
            }
        }
        component.set("v.pageList", pageList);
    },
})