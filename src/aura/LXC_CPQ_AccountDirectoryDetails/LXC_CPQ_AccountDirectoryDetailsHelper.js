({
    fetchPickListVal: function(component, fieldName, elementId) {
        var action;
        if(fieldName == 'Role__c'){
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
                    opts.push({
                        class: "optionClass",
                        label: "--None--",
                        value: "None"
                    });
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
    getAccountDirectoryList : function(component, event, helper) {
        component.set("v.showSpinner",true); 
        var action = component.get("c.getAccountDirectoryData");
        var role = component.find("role").get("v.value");
        var account = component.find("account").get("v.value");
        var customerName = component.find("customerName").get("v.value");
        action.setParams({
            role : role,
            account : account,
            customerName : customerName
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                
                var returnValue = response.getReturnValue();
                component.set("v.AccountDirectoryWrapperList", returnValue);   
                component.set("v.showSpinner",false);
                component.set("v.isDeleteButtonDisable",true);
                component.set("v.isSaveButtonDisable",true);
            }
        });
        $A.enqueueAction(action);
    }
})