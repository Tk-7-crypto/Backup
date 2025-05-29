({
	getCurrentUser: function(component){
		console.log("[LXC_CSM_PortalWelcomeTitle] Get Current User ...");
		var action = component.get("c.getCurrentUser");
		action.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") {
				component.set("v.user",response.getReturnValue()[0]);
			}else{
				console.log("[LXC_CSM_PortalWelcomeTitle] Get Current User Error");
			}
		});
		$A.enqueueAction(action);
	},
    
    getLastLogin: function(component) {
        var action = component.get("c.getLastLogin");
        action.setCallback(this, function(response){
            var state = response.getState();          			
            if (state === "SUCCESS") {
                var check = response.getReturnValue(); 
            }
        });
        $A.enqueueAction(action);
        
    },

})