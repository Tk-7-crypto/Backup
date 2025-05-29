({
    getDetails: function (component) {
        component.set("v.spinner", true);
        var action = component.get("c.getCollaborationConfigCartURL");
        var recordId = component.get("v.recordId");
        action.setParams({
            'recordId': recordId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue().split('&');
                component.set("v.flowName", result[0]);
                if (result[1] == 'true') {
                    component.set("v.isOwner", true);
                } else {
                    component.set("v.isOwner", false);
                }
                component.set("v.spinner", false);
                $A.get('e.force:refreshView').fire();
            } else {
                component.set("v.spinner", false);
                this.showToast('Error', 'An Error Occurred, Something Went Wrong', 'error');
            }
        });
        $A.enqueueAction(action);
    },

    configureProducts: function (component) {
        component.set("v.spinner", true);
        var recordId = component.get("v.recordId");
        var flowName = component.get("v.flowName");
        if (flowName != null) {
            window.open("/apex/Apttus_Config2__CollabRequestInline?id=" + recordId + "&flow=" + flowName, "_self");
        }
    },

    showToast: function (title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    }
})
