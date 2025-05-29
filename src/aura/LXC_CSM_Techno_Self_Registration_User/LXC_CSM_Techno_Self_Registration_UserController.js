({
    cancel : function(component, event, helper) {
        var cancelUpdate = true;
        component.set('v.cancelAll', cancelUpdate);
    },
    editContact : function(component, event, helper) {
        var editContract = true;
        component.set('v.editContactInfo', editContract);
    },
    createUser : function(component, event, helper) { 
        var action = component.get('c.createCommunityUser');  
        action.setParams({
            newContactInfo : component.get("v.contactRecord"),
            caseId : component.get("v.caseId")
        });
        action.setCallback(this, function(response) {
            //store state of response
            var state = response.getState();
            if (state === "SUCCESS") {
                var UserCreated = true;
                var userid = response.getReturnValue();
                component.set('v.UserCreated', UserCreated); 
                component.set('v.userId', userid);
                helper.sendResetPassword(component, event);
            } else if(state === "ERROR"){
                var errors = response.getError();
                var result = true;
                component.set("v.showErrors",true);
                component.set("v.errorMessage",errors[0].message);
            }
        });
        $A.enqueueAction(action);   
    }  
})