({
    getCountrySalesHeadList : function(component, event, helper) {
        component.set("v.showSpinner",true); 
        var action = component.get("c.getCountrySalesHeadData");
        var saleType = component.find("saleType").get("v.value");
        var countrySale = component.find("countrySale").get("v.value");
        var customerName = component.find("customerName").get("v.value");
        action.setParams({
            saleType : saleType,
            countrySale : countrySale,
            customerName : customerName
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {	
                var returnValue = response.getReturnValue();
                component.set("v.CountrySalesHeadWrapperList", returnValue);
                component.set("v.hasData", true);
                component.set("v.showSpinner",false);
                component.set("v.isDeleteButtonDisable",true);
                component.set("v.isSaveButtonDisable",true);
            }
        });
        $A.enqueueAction(action);
    },
    fetchPickListVal: function(component, fieldName, elementId,addNone) {
        var action;
        if(fieldName == 'Sale_Type__c'){
            action = component.get("c.getSelectOptions");
        }
        else{
            action = component.get("c.getValueSet");
        }
        
        action.setParams({
            "objObject": component.get("v.objInfo"),
            "fieldName": fieldName
        });
        var opts = [];
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = response.getReturnValue();
                if (allValues != undefined && allValues.length > 0) {
                    if(addNone){
                        opts.push({
                            class: "optionClass",
                            label: "--None--",
                            value: "None"
                        });
                    }
                    for (var i = 0; i < allValues.length; i++) {
                        opts.push({
                            class: "optionClass",
                            label: allValues[i],
                            value: allValues[i]
                        });
                    }  
                }                
                component.find(elementId).set("v.options", opts);
            }
        });
        $A.enqueueAction(action);
    },
})