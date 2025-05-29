({
    submitForm : function(component, event, helper) {
    var action = component.get('c.updateContactInfo');  
        action.setParams({
			newContactInfo : component.get("v.contactRecord")
        });
      action.setCallback(this, function(response) {
        //store state of response
        var state = response.getState();
        if (state === "SUCCESS") {
            component.set('v.contactRecord', response.getReturnValue());
            var editContactInfo = false;
            component.set('v.editContactInfo', editContactInfo);
        }  else if(state === "ERROR"){
                var errors = response.getError();
                var result = true;
                component.set("v.showErrors",true);
                component.set("v.errorMessage",errors[0].message);
            }
      });
        $A.enqueueAction(action);   
	},
    cancel : function(component, event, helper) {
        var cancelUpdate = true;
        component.set('v.cancelAll', cancelUpdate);
    }
})