({
	getCurrentUser: function(component){
		var action = component.get("c.getQulatricSurveyURL");
        action.setParams({
            "url": component.get("v.btnHref"),
            "fieldName" : component.get("v.embeddedData")
        }); 
		action.setCallback(this, function(response){
			var state = response.getState();
			if (state === "SUCCESS") {
				component.set("v.redirectURL",response.getReturnValue());
			}else{
				console.log("[LXC_CSM_Qualtrics_Survey] Get Current User Error");
			}
		});
		$A.enqueueAction(action);
	},
    

})