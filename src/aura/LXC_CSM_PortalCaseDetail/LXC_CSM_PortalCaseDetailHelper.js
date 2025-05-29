({
	getCurrentUserLoginDetails : function(component) {
		var action = component.get("c.updateLastLogin");
        action.setCallback(this, function(response){
            var state = response.getState();          			
            if (state === "SUCCESS") {
                var check = response.getReturnValue(); 
            }
        });
        $A.enqueueAction(action);
	}
})