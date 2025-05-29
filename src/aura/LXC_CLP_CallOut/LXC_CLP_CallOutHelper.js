({
    callout : function(component, event, helper) {
        var action = component.get("c.getAgreementValues");
        action.setParams({
            recId : component.get('v.recordId')
        });
        action.setCallback(this, function(response){
            var state = response.getState();
                if (state === "SUCCESS") {
                    var responseValue = JSON.parse(response.getReturnValue());
                    if(responseValue.statusCode == 200){
                        $A.get('e.force:refreshView').fire();
                    }
                    helper.showToast(component, event, responseValue.message, responseValue.type, responseValue.type);
                }else{
                    helper.showToast(component, event, 'Request failed', 'error', 'Failed!');
                }
        })
        $A.enqueueAction(action);
    },
    showToast : function(component, event, message, type, title) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type" : type,
            "message": message
        });
        toastEvent.fire();
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
})