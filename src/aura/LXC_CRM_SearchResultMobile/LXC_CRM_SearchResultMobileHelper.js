({
    xDown :null,
    yDown :null,
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
                var appEvent = $A.get("e.c:LXE_CRM_SpinnerEvent");
                appEvent.setParams({"action" : "stop"});
                appEvent.fire();
            }
        })
        $A.enqueueAction(action);
    },
    
    itemChangeHelper : function(component, event, helper) {
        var appEvent = $A.get("e.c:LXE_CRM_SpinnerEvent");
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
                var name = resultWrapper[i]["productRecord"]["Name"];
                var code = resultWrapper[i]["productRecord"]["ProductCode"];
                var billingSystem = resultWrapper[i]["productRecord"]["Billing_System__c"];
                var productid = resultWrapper[i]["productRecord"]["Id"];
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
                    productName : name,
                    productCode : code,
                    productBillingSystem : billingSystem,
                    productId : productid,
                    dataColumns : rowItems,
                    isFavorite : isFavoriteproduct,
                    isZREPProduct : isZREPProduct,
                    quantity : 1,
                    id : resultWrapper[i]["productRecord"]["Id"]
                });
            } 
        }
        component.set("v.resultObjectWrapper", resultObject);
        component.set("v.showResult", true);

        console.log(rowItems);
        var maxLength = 5;
        var resultObjectSmall = [];
        if(resultObject.length < 5){
            maxLength = resultObject.length;
        }
        for(var i = 0; i< maxLength; i++){
            resultObjectSmall.push(resultObject[i]);
        }
        component.set("v.resultObjectWrapperSmall", resultObjectSmall);
        component.set("v.divHeight", (resultObjectSmall.length+1)*20);
        
        var appEvent = $A.get("e.c:LXE_CRM_SpinnerEvent");
        appEvent.setParams({"action" : "stop"});
        appEvent.fire();
        if(resultObjectSmall.length == resultObject.length){
            component.set("v.showAllDataShownMessage", true);
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
    },
    
    loadMoreData : function(component, helper){
        
        var resultObject =  component.get("v.resultObjectWrapper");
        var resultObjectSmall =  component.get("v.resultObjectWrapperSmall");
        var newSize = resultObjectSmall.length;
        
        if(resultObjectSmall.length < resultObject.length){
            var remainingDataLength = resultObject.length - resultObjectSmall.length;
            if(remainingDataLength < 5){
                newSize = newSize + remainingDataLength;
            }else{
                newSize = newSize + 5;
            }
            var resultObjectSmall = [];
            for(var i = 0 ; i< newSize; i++){
                resultObjectSmall.push(resultObject[i]);
            }
            component.set("v.resultObjectWrapperSmall", resultObjectSmall);
            component.set("v.divHeight", resultObjectSmall.length*20);
            component.set("v.showAllDataShownMessage", false);
        }else{
            component.set("v.showAllDataShownMessage", true);
        }
        component.set("v.interval", 0);
        
    }
})