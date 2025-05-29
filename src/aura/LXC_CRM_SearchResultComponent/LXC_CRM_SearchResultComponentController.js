({
    addProduct : function(component, event, helper) {
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "start"}).fire();
        var selectedProductIdMap = new Map();
        var selectedValues = [];
        var checkboxCompList = component.find("checkbox-input");
        var quantityCompList = component.find("quantity");
        if (checkboxCompList != undefined && checkboxCompList.length == undefined) {
            var checkboxCompArr = [];
            checkboxCompArr.push(checkboxCompList);
            checkboxCompList = checkboxCompArr;
        }
        if(quantityCompList != undefined && quantityCompList.length == undefined) {
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
                    $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
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
            $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
            return;
        }
        var resultWrapper = component.get("v.SearchResultWrapper");
        var jsonData  = [];
        for(var i = 0; i < resultWrapper.length; i++) {
            if(selectedProductIdMap.has(resultWrapper[i]["productRecord"]["Id"])) {
                for(var j = 0; j < selectedProductIdMap.get(resultWrapper[i]["productRecord"]["Id"]); j++) {
            		selectedValues.push(resultWrapper[i]);
            		var temp = resultWrapper[i].productRecord;
            		temp["ProductId"] = resultWrapper[i]["productRecord"]["Id"];
            		temp["Currency"] = resultWrapper[i].pbeRecord.CurrencyIsoCode;
            		jsonData.push(temp);
                }
            }
        }
        jsonData.forEach(obj => {
            obj["Path"] = "Manual";
            obj["Quote"] = component.get("v.recordId");
            obj["Qty"] = 1;
            obj["Tool"] = component.get("v.pricingtool");
        })
    	component.set("v.selectedValues", selectedValues);
        var para = JSON.stringify(jsonData);
       
        if(component.get("v.source") == 'Opportunity'){
        var addOrEditProduct = $A.get("e.c:LXE_CRM_AddOrEditProductEvent");
        addOrEditProduct.setParams({
            "fieldsToDisable" : "",
            "fieldsToShow" : "UnitPrice,Revenue_Type__c,Sale_Type__c,Delivery_Country__c,Therapy_Area__c,Product_Start_Date__c,Product_End_Date__c,Product_SalesLead__c,Number_of_License__c,Project_Manager__c",
            "title" : "Add Product Page",
            "selectedList" : component.get("v.selectedValues"),
            "isFadeIn" : true,
            "operationType" : "create",
            "territory" : component.get("v.territory")
        });
        addOrEditProduct.fire();
        }else if(component.get("v.source") == 'Quote__c'){
            var action = component.get('c.createQuoteLineItems');
    		var featureSetting = {};
            featureSetting["partialSave"] = false;
            featureSetting["internalCall"] = false;
            action.setParams({
                "productDataJson" : para,
 				"featureSettings" : JSON.stringify(featureSetting)
            });
            action.setCallback(this, function(response){
                var state = response.getState(); // get the response state
                if(state == 'SUCCESS') {
                    var result = response.getReturnValue();
                    if(result.isSuccess){
                        var toastMessage = [];
                        toastMessage.push("Successfully created line items.");
                    	helper.setToast(component, event, helper, toastMessage, "success", "Success!");
                        window.setTimeout(
                            $A.getCallback(function() {
                        var appEventReload = $A.get("e.c:LXE_CRM_ReloadEvent");
                        appEventReload.setParams({
                            eventFor : "deSelectProducts"
                        })
                        appEventReload.fire();
                            }), 500
                        );
                        
                        window.setTimeout(
                            $A.getCallback(function() {
                                var tabEvent = $A.get("e.c:LXE_CRM_SetActiveTabEvent");
                                tabEvent.setParams({"activeTabId":"viewOli",
                                                    "actionLabel":"Added to Quote"
                                                   });
                                tabEvent.fire();
                            }), 500
                        );
                    }else{
                       var toastMessage = [];
                       toastMessage.push(result.errorMsg);
                       helper.setToast(component, event, helper, toastMessage, "error", "Error!"); 
                    }
                     $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
                }else if(state === "ERROR") {
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
        }
    },
    
    onNext : function(component, event, helper) {        
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber+1);
        helper.buildData(component, helper,false);
    },
    
    onPrev : function(component, event, helper) {        
        var pageNumber = component.get("v.currentPageNumber");
        component.set("v.currentPageNumber", pageNumber-1);
        helper.buildData(component, helper,false);
    },
    
    processMe : function(component, event, helper) {
        component.set("v.currentPageNumber", parseInt(event.target.name));
        helper.buildData(component, helper,false);
    },
    
    onFirst : function(component, event, helper) {        
        component.set("v.currentPageNumber", 1);
        helper.buildData(component, helper,false);
    },
    
    onLast : function(component, event, helper) {        
        component.set("v.currentPageNumber", component.get("v.totalPages"));
        helper.buildData(component, helper,false);
    },
    callEvent : function(component, event, helper) {
        component.set("v.timeStamp", new Date().getTime());
        component.isReloadEvent = false;
        helper.getFavoriteProducts(component, event, helper);
    },
    
    callReloadEvent : function(component, event, helper) {
        var eventFor = event.getParams().eventFor;
        if(eventFor == "deSelectProducts") {
            var checkboxCompList = component.find("checkbox-input");
            var quantityCompList = component.find("quantity");
            if (checkboxCompList != undefined && checkboxCompList.length == undefined) {
                var checkboxCompArr = [];
                checkboxCompArr.push(checkboxCompList);
                checkboxCompList = checkboxCompArr;
            }
            if (quantityCompList != undefined && quantityCompList.length == undefined) {
                var quantityCompArr = [];
                quantityCompArr.push(quantityCompList);
                quantityCompList = quantityCompArr;
            }
            if(checkboxCompList != undefined && checkboxCompList != null) {
                for(var i = 0; i < checkboxCompList.length; i++) {
                    var checkBoxComp = checkboxCompList[i].getElements()[0];
                    if(checkboxCompList[i].isRendered())
                        checkBoxComp.checked = false;
                } 
            }
            if(quantityCompList != undefined && quantityCompList != null) {
                for(var i = 0; i < quantityCompList.length; i++) {
                    if(quantityCompList[i].isRendered())
                        quantityCompList[i].set("v.value", 1);
                } 
            }
        } else if(eventFor == "searchResultFavoriteProduct") {
            component.isReloadEvent = true;
            helper.getFavoriteProducts(component, event, helper);
        }
    },
    
    addFavoriteProduct : function(component, event, helper) {
        component.action = "create";
        helper.modifyFavoriteProduct(component, event, helper);
        helper.closeCommentModel(component, event, helper);
    },
    
    deleteFavoriteProduct : function(component, event, helper) {
        component.action = "Delete";
        var productId = event.getSource().get("v.value");
        component.set("v.favProductSelected", productId);
        helper.modifyFavoriteProduct(component, event, helper);
    },
    
    setQuantityValue : function(component, event, helper) {
        var quantity = event.getSource().get("v.value");
        var productId = event.getSource().get("v.label");
        var quantityMap = component.get("v.quantityWrapper");
        quantityMap.set(productId, quantity);
    },
    openCommentModel: function(component, event, helper) {
        var productId = event.getSource().get("v.value");
        component.set("v.favProductSelected", productId);
        component.set("v.isCommentModalOpen", true);
    },
    
    closeCommentModel: function(component, event, helper) {
        helper.closeCommentModel(component, event, helper);
    },
    handleMouseHover: function(component, event, helper) {
        var productId = event.srcElement.id;
        helper.getMiniLayout(component, event, helper,productId);
    },
    handleMouseOut: function(component, event, helper) {
        component.set("v.hoverRow",-1);
        component.set("v.togglehover",false);
    },
    
    setToast : function(component, event, helper, message, type, title) {
        var errorMsg = message;
        var msg = message;
        for(var x = 0; x < errorMsg.length; x++) {
            msg = msg + errorMsg[x] ;
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
});