({
	getSuggestedFTE : function(component, resourceRequestId) {
        component.set("v.isError2",false);
        component.set("v.errorMessage2",'');
		var action = component.get("c.getSuggestedFTEFromResRequest");
        action.setParams({
            "resRequestId" : resourceRequestId
        });
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS" && actionResult.getReturnValue() !== '') {
                if(actionResult.getReturnValue() == 'Assignment already exists'){
                    component.set("v.isError2",true);
                    component.set("v.errorMessage2",'Assignment for this RR already exists');
                }else{
                	component.set("v.resSuggestedFTE", actionResult.getReturnValue());                 
                }
                
            }
       });
       $A.enqueueAction(action);
   }
})