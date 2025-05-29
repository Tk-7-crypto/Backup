({
    init: function (component, event, helper) {
        helper.fetchPickListVal(component, 'Sale_Type__c', 'saleType',true);
        helper.fetchPickListVal(component, 'Country_Sales__c', 'countrySale',true);
        helper.fetchPickListVal(component, 'Approver_Name__c', 'customerName',true);
    },
    
    handleClick : function (component, event, helper) {
        helper.getCountrySalesHeadList(component, event, helper);
    },
    
    handleCancelClick: function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:LXC_CPQ_SelectApproverGroup",
        });
        evt.fire();
    },
    
    addRecord : function(component, event, helper) {
        component.set("v.openPopupForAddRecord", "true");
    },
    closeModel : function(component, event, helper){
        component.set("v.showSpinner",false);
        component.set("v.openPopupForAddRecord", "false");
    },
    isEditable : function(component, event, helper) {
        
        var saveButton = component.find("saveButtonId");
        var checkBoxes = component.find("editCheckbox");
        
        var canEdit = false;
        
        if (checkBoxes.length > 1) {
            for (var i = 0; i < checkBoxes.length; i++)
                if(checkBoxes[i].get("v.checked") == true){
                    canEdit = true;
                    break;
                }
        }
        else if(event.getSource().get('v.checked') == true){
            canEdit = true;
        }
        
        if(canEdit == true){
            component.set("v.isSaveButtonDisable",false);
        }
        else{
            component.set("v.isSaveButtonDisable",true);
        }
    },
    
    isDeleteable : function(component, event, helper) {
        
        var deleteButton = component.find('deleteButtonId');
        var checkBoxes = component.find("deleteCheckbox");
        var canDelete = false;
        
        if (checkBoxes.length > 1) {
            for (var i = 0; i < checkBoxes.length; i++)
                if(checkBoxes[i].get("v.checked") == true){
                    canDelete = true;
                    break;
                }
        }
        else if(event.getSource().get("v.checked") == true){
            canDelete = true;
        }
        
        if(canDelete == true)
            component.set("v.isDeleteButtonDisable",false);
        else
            component.set("v.isDeleteButtonDisable",true);
    },
    handleSuccess: function(component, event, helper) {
        component.set("v.openPopupForAddRecord", "false");
        component.set("v.showSpinner",false);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "The record has been Created successfully.",
            "type" :"success"
        });
        toastEvent.fire();
        component.set("v.openPopupForAddRecord", "false");
        helper.getCountrySalesHeadList(component, event, helper);
        helper.fetchPickListVal(component, 'Country_Sales__c', 'countrySale',true);
        helper.fetchPickListVal(component, 'Approver_Name__c', 'customerName',true);
    },
    handleError : function(component, event, helper) {
        var errorMessage = "Somthing went Wrong and The record has been not Created.";
        if(event.getParam("detail"))
            errorMessage = event.getParam("detail");
        component.set("v.showSpinner",false);
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "message": errorMessage,
            "type" :"error"
        });
        toastEvent.fire();
    },
    saveMap : function(component, event, helper) {
        component.set("v.showSpinner",true);
        var action = component.get("c.updateCountrySalesHead");
        action.setParams({
            countrySalesHeadData : JSON.stringify(component.get("v.CountrySalesHeadWrapperList"))
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var toastEvent = $A.get("e.force:showToast");
            if (state === "SUCCESS"){
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The record has been updated successfully.",
                    "type" :"success"
                });
                toastEvent.fire();
                helper.getCountrySalesHeadList(component, event, helper);
                helper.fetchPickListVal(component, 'Country_Sales__c', 'countrySale',true);
                helper.fetchPickListVal(component, 'Approver_Name__c', 'customerName',true);
            }else{
                var errorMessage = "Somthing went Wrong and The record has been not Updated.";
                if(response.getError()[0].pageErrors[0].message)
                    errorMessage = response.getError()[0].pageErrors[0].message;
                toastEvent.setParams({
                    "title": "Error!",
                    "message": errorMessage,
                    "type" :"Error"
                });
                toastEvent.fire();
            }
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action);
    },
    
    deleteMap : function(component, event, helper) {
        component.set("v.showSpinner",true);
        var action = component.get("c.deleteCountrySalesHead");
        action.setParams({
            countrySalesHeadData : JSON.stringify(component.get("v.CountrySalesHeadWrapperList"))
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            var toastEvent = $A.get("e.force:showToast");
            if (state === "SUCCESS") {
                toastEvent.setParams({
                    "title": "Delete",
                    "message": "The record has been deleted successfully.",
                    "type" :"success"
                });
                toastEvent.fire();
                helper.getCountrySalesHeadList(component, event, helper);
                helper.fetchPickListVal(component, 'Country_Sales__c', 'countrySale',true);
                helper.fetchPickListVal(component, 'Approver_Name__c', 'customerName',true);
            }else{
                var errorMessage = "Somthing went Wrong and The record has been not Deleted.";
                if(response.getError()[0].pageErrors[0].message)
                    errorMessage = response.getError()[0].pageErrors[0].message;
                toastEvent.setParams({
                    "title": "Error",
                    "message": errorMessage,
                    "type" :"Error"
                });
                toastEvent.fire();
            }
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action);
    },
})