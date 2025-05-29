({
    loadRecipients : function(component) {
        var action = component.get("c.loadRecipientsDataForReminder");       
        var rId = (component.get("v.agrId") != undefined ? component.get("v.agrId") : component.get("v.recordId"));
        action.setParams({
            "agreementId": rId
        });
        
        // Register the callback function
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                //alert('success');                 
                component.set('v.recipientList', response.getReturnValue().recipientList);
                
            } else if (response.getState() === "ERROR") {                
                $A.log("Errors", response.getError());
            }
        });
        // Invoke the service
        $A.enqueueAction(action);
    },
})