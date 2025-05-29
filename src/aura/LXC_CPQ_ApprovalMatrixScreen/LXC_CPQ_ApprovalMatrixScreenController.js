({
	doInit : function(component, event, helper) {
		var action = component.get("c.getApproverGroups");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var returnValue = response.getReturnValue();
                console.log(returnValue)
                component.set("v.ApprovalMatrixWithKeyWrapper", returnValue);
            }
        });
        $A.enqueueAction(action);
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
                component.set("v.showSpinner", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The record has been updated successfully.",
                    "type" :"success"
                });
           	   toastEvent.fire();
               $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    changeHandler : function(component, event, helper) {
        var name = event.getSource().get("v.name");
        alert('test'+name);
        var selectedItemNew = document.getElementsByClassName(name);
        alert('selectedItemNew'+selectedItemNew);
        selectedItemNew.checked = true;
        selectedItemNew.value = true;

    }, addTab: function(component, event, helper) {
        component.set("v.openPopup", "true");
    }, closeModel : function(component, event, helper){
        component.set("v.openPopup", "false");
        component.set("v.openPopupForApprovalMatrix", "false");
    }, handleSuccess : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
    }, addAprovalMatrix : function(component, event, helper) {
        component.set("v.openPopupForApprovalMatrix", "true");
        var name = event.getSource().get("v.name");
        component.set("v.ApproverGroupId", name);
    }
})