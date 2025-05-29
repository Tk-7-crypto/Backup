({
    doInit : function(component, event, helper) {
        var pageReference = component.get("v.pageReference");
        var action = component.get("c.hasCustomPermission");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.checkCustomPermission",response.getReturnValue());
                var recordId = pageReference.state.c__recordId;
                component.set("v.recordId", recordId);
                if (!component.get("v.checkCustomPermission")) {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": "You don't have the required permissions to perform this action. Please raise a VIA ticket to upgrade your permission.",
                        "type": 'error'
                    });
                    toastEvent.fire();
                    if (!component.get("v.checkCustomPermission")) {
                        window.setTimeout(function (self) {
                            window.open('/' + component.get("v.recordId"), '_self');
                        }, 2000, this);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    closeModal: function (component, event, helper) {
    	window.open('/' + component.get("v.recordId"), '_self');
	}
})