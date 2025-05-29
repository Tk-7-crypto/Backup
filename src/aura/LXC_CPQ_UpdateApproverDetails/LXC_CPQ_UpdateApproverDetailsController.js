({
    doInit : function(component, event, helper) {
        var approverGroupName = component.get("v.approverGroupName");
        helper.fetchPickListVal(component, 'Opportunity_Type__c', 'myOpportunityType');
        if(approverGroupName == 'tssu'){
            helper.fetchPickListVal(component, 'Therapy_Area__c', 'therapyArea');
            helper.fetchPickListVal(component, 'Region__c', 'region');
        }
        else if (approverGroupName=='sales'){
            helper.fetchPickListVal(component, 'Region__c', 'region');
            helper.fetchPickListVal(component, 'Sales__c', 'sales');
            helper.fetchPickListVal(component, 'MD__c', 'md');
        }
        else if (approverGroupName == 'plCustomer'){
            helper.fetchPickListVal(component, 'Therapy_Area__c', 'therapyArea');
            helper.fetchPickListVal(component, 'Customer__c', 'customer');
        }
        else{
            helper.fetchPickListVal(component, 'Therapy_Area__c', 'therapyArea');
            helper.fetchPickListVal(component, 'Global_Project_Unit__c', 'globalProjectUnit');
        }
    },
    
    handleClick: function(component, event, helper){
        helper.fetchApprovalMatrixData(component, event, helper);
    },
    
    handleCancelClick: function(component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:LXC_CPQ_SelectApproverGroup",
            componentAttributes: {
            }
        });
        evt.fire();
    }, 
    
    saveMap : function(component, event, helper) {
        component.set("v.showSpinner",true);
        var action = component.get("c.updateApprovalMatrix");
        action.setParams({
            approvalMatrixData : JSON.stringify(component.get("v.ApprovalMatrixWithKeyWrapper"))
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.showSpinner",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The record has been updated successfully.",
                    "type" :"success"
                });
                toastEvent.fire();
                helper.fetchApprovalMatrixData(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    }, 
    
    deleteMap : function(component, event, helper) {
        component.set("v.showSpinner",true);
        var action = component.get("c.deleteApprovalMatrix");
        action.setParams({
            approvalMatrixData : JSON.stringify(component.get("v.ApprovalMatrixWithKeyWrapper"))
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.showSpinner",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Delete",
                    "message": "The record has been deleted successfully.",
                    "type" :"success"
                });
                toastEvent.fire();
                helper.fetchApprovalMatrixData(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },

    addAprovalMatrix : function(component, event, helper) {
        component.set("v.openPopupForApprovalMatrix", "true");
        var name = event.getSource().get("v.name");
        component.set("v.ApproverGroupId", name);
        var approverGroupName = component.get("v.approverGroupName");
        var opportunityType = component.find("myOpportunityType").get("v.value");
        var role = component.find("myRole").get("v.value");
        helper.fetchPickListVal(component, 'Opportunity_Type__c', 'myOpportunityType2');
        component.find("myOpportunityType2").set("v.value", opportunityType);
        component.find("myRole2").set("v.value", role);
        if(approverGroupName == 'tssu'){
            var therapyArea = component.find("therapyArea").get("v.value");
            var region = component.find("region").get("v.value");
            helper.fetchPickListVal(component, 'Therapy_Area__c', 'therapyArea2');
            helper.fetchPickListVal(component, 'Region__c', 'region2');
            component.find("therapyArea2").set("v.value", therapyArea);
            component.find("region2").set("v.value", region);
        }
        else if (approverGroupName=='sales'){
			var region = component.find("region").get("v.value");
            var sales = component.find("sales").get("v.value");
            var md = component.find("md").get("v.value");
            helper.fetchPickListVal(component, 'Region__c', 'region2');
            helper.fetchPickListVal(component, 'Sales__c', 'sales2');
            helper.fetchPickListVal(component, 'MD__c', 'md2');
        	component.find("region2").set("v.value", region);
        	component.find("sales2").set("v.value", sales);
        	component.find("md2").set("v.value", md);
            helper.fetchOptionValueSet(component, 'accountCountrySales');
        }
        else if (approverGroupName == 'plCustomer'){
            var therapyArea = component.find("therapyArea").get("v.value");
            var customer = component.find("customer").get("v.value");
            helper.fetchPickListVal(component, 'Therapy_Area__c', 'therapyArea2');
            helper.fetchPickListVal(component, 'Customer__c', 'customer2');
            component.find("therapyArea2").set("v.value", therapyArea);
            component.find("customer2").set("v.value", customer);
        }
        else{
            var therapyArea = component.find("therapyArea").get("v.value");
            var globalProjectUnit= component.find("globalProjectUnit").get("v.value");
            helper.fetchPickListVal(component, 'Therapy_Area__c', 'therapyArea2');
            helper.fetchPickListVal(component, 'Global_Project_Unit__c', 'globalProjectUnit2');
            component.find("therapyArea2").set("v.value", therapyArea);
            component.find("globalProjectUnit2").set("v.value", globalProjectUnit);
        }
    },
    closeModel : function(component, event, helper){
        component.set("v.openPopupForApprovalMatrix", "false");
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
    
    createRecord  : function(component, event, helper) {
        var newRecordDetails = component.get("v.objInfo");
        var id = component.get("v.ApproverGroupId");
        var role = component.find("myRole2").get("v.value");
        var action =component.get("c.createApprovalMatrix");
        action.setParams({
            approvalRecord : newRecordDetails,
            approvalGroupId : id,
            role : role
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.showSpinner",false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The record has been saved successfully.",
                    "type" :"success"
                });
                toastEvent.fire();
                component.set("v.openPopupForApprovalMatrix", "false");
                component.set("v.ApprovalMatrixWithKeyWrapper", "");
                helper.fetchApprovalMatrixData(component, event, helper);
            }
        });
        $A.enqueueAction(action);
    },
    onSaleOrRoleChange : function(component, event, helper) {
        helper.fetchOptionValueSet(component, 'accountCountrySales'); 
    },
    onAccountOrCountrySalesChanges : function(component, event, helper) {
      helper.onCustomerChanges(component); 
    }
 })