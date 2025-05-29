({
	doInit : function(component, event, helper) {
        var action = component.get("c.getBidHistoryDetailsAndValidate");
        action.setParams({
            "recordId" : component.get("v.recordId"),
        });
        
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
                
            }
            else
                {
				    var errors = actionResult.getError();	
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Please Note:',
                        message: errors[0].message,
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'Success',
                        mode: 'sticky'
                    });
                    toastEvent.fire();                    
                }
        });
        $A.enqueueAction(action);
	}
})