({
	doInit: function(component, event, helper) {
        var isSystemDown = component.get('c.isSystemDown');
        var isCurrentUserAllowed = component.get('c.isCurrentUserAllowedOnSystemDown');
        var systemDownMessage = component.get('c.getSystemDownMessage');
        isSystemDown.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                console.log('response::'+response.getReturnValue());
                component.set("v.isPopupOpen", response.getReturnValue() != "PL");
                if(response.getReturnValue() == "TM") {
                    component.set("v.isShowFooter", response.getReturnValue());
                }
                else {
                	$A.enqueueAction(isCurrentUserAllowed);
                }
                $A.enqueueAction(systemDownMessage);
            }
        });
        isCurrentUserAllowed.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                component.set("v.isShowFooter", response.getReturnValue());
            }
        });
        systemDownMessage.setCallback(this, function(response) {
            var state = response.getState();
            if(component.isValid() && state === "SUCCESS") {
                component.set("v.systemDownMessageContent", response.getReturnValue());
            }
        });
        $A.enqueueAction(isSystemDown);
    },
    
    okClick: function(component, event, helper) {
		component.set("v.isPopupOpen", false);
	}
})