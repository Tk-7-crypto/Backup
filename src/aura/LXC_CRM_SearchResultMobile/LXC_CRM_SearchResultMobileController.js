({
    addProduct : function(component, event, helper) {
        var appEvent = $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "start"}).fire();
        var selectedId = event.getSource().get("v.value");
        var selectedValues = []; 
        if(selectedId == null) {
            var toastMessage = [];
            toastMessage.push("Please Select atleast one Product");
            helper.setToast(component, event, helper, toastMessage, "error", "Error!");
            var appEvent = $A.get("e.c:LXE_CRM_SpinnerEvent");
            appEvent.setParams({"action" : "stop"});
            appEvent.fire();
            return;
        }
        
        var resultWrapper = component.get("v.SearchResultWrapper");
        for(var i = 0; i < resultWrapper.length; i++) {
            if(selectedId == resultWrapper[i]["productRecord"]["Id"]) {
                selectedValues.push(resultWrapper[i]);
            }
        }
        component.set("v.selectedValues", selectedValues);
        var addOrEditProduct = $A.get("e.c:LXE_CRM_AddOrEditProductEvent");
        addOrEditProduct.setParams({
            "fieldsToDisable" : "",
            "fieldsToShow" : "UnitPrice,Revenue_Type__c,Sale_Type__c,Delivery_Country__c,Therapy_Area__c,Product_Start_Date__c,Product_End_Date__c,Product_SalesLead__c,Project_Manager__c",
            "title" : "Add Product Page",
            "selectedList" : component.get("v.selectedValues"),
            "isFadeIn" : true,
            "operationType" : "create",
            "territory" : component.get("v.territory")
        });
        addOrEditProduct.fire();
    },
    
    callEvent : function(component, event, helper) {
        component.set("v.timeStamp", new Date().getTime());
        component.isReloadEvent = false;
        helper.getFavoriteProducts(component, event, helper);
    },
    
    handleTouchStart : function(component, event, helper){
        var firstTouch = event.touches || event.originalEvent.touches;
        helper.xDown = firstTouch[0].clientX;                                      
        helper.yDown = firstTouch[0].clientY;
    },
    
    loadMoreData : function(component, event, helper){
        var loadData ;
        if ( ! helper.xDown || ! helper.yDown ) {
            return;
        }
        var xUp = event.touches[0].clientX;                                    
        var yUp = event.touches[0].clientY;
        
        var xDiff = helper.xDown - xUp;
        var yDiff = helper.yDown - yUp;
        
        if ( Math.abs( xDiff ) > Math.abs( yDiff ) ) {/*most significant*/
            if ( xDiff > 0 ) {
            }                       
        } else {
            if ( yDiff > 0 ) {
                loadData = true;
            } else { 
                loadData = false;
            }                                                                 
        }
        /* reset values */
        helper.xDown = null;
        helper.yDown = null; 
        var resultObject =  component.get("v.resultObjectWrapper");
        var resultObjectSmall =  component.get("v.resultObjectWrapperSmall");
        if(loadData){
            loadData = false;
            if(resultObject.length > 5){
                if(resultObjectSmall.length != resultObject.length){
                    component.set("v.showSpinner", true);
                    setTimeout($A.getCallback(function() {
                        component.set("v.showSpinner", false);
                        helper.loadMoreData(component, helper); 
                    }), 1000);  
                }
                if(resultObjectSmall.length == resultObject.length){
                    component.set("v.showAllDataShownMessage", true);
                }
            }
        }
    }
});