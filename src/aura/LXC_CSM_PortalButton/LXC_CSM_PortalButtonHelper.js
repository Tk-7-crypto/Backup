({
	getUserContact: function(component){
        var action = component.get("c.getUserContact");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var contact = response.getReturnValue()[0];
                if (contact){
                    var portal_case_type = contact.Portal_Case_Type__c.split(';');
                    if (component.get("v.visibleFor") != undefined){
                    	var visibleFor = component.get("v.visibleFor");
                    	 if(visibleFor === "All" || portal_case_type.length > 1)component.set("v.isVisible",true);
                    	 else if (visibleFor ===  portal_case_type[0])component.set("v.isVisible",true);
                    	 else component.set("v.isVisible",false);
                    }
                }
            } else if(state === "ERROR") {
                console.log("LXC_CSM_PortalFile] ERROR " + JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
    }
})