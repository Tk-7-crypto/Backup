({
    doInit :function (component, event, helper) {
        component.set("v.Spinner", true); 
        
        var selecteResourceId = component.get("v.resourceId");
        var selectedResReqId = component.get("v.resReqId");
        var action = component.get('c.assignResourceAndCreateAssignment');
        action.setParams({ 
            "resRequestId" : selectedResReqId,  
            "resourceId" : selecteResourceId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var responseVal = response.getReturnValue();
                if(responseVal.trim() === 'success') {
                    alert("Resource is assigned Successfully.");
                    component.set("v.Spinner", false);
                    window.location.href = "/"+selectedResReqId;
                }else if(responseVal.trim() === 'Assignment for this RR already exists'){
                    component.set("v.isError" , true); 
                    component.set("v.errorMessage", responseVal);
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                   if (errors[0] && errors[0].message) {
                        console.log("Error message: " +errors[0].message);
                        component.set("v.isError" , true);
                        component.set("v.errorMessage", errors[0].message['first error']);
                    }
                } else {
                    component.set("v.isError" , true); 
            	    component.set("v.errorMessage", "Unknown Error");
                }
               
               component.set("v.isError" , true); 
               component.set("v.errorMessage", "Error in calling server side action");
               component.set("v.Spinner", false);
           }
       });
       $A.enqueueAction(action);
    },
    
    showSpinner: function(component, event, helper) {
       // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    
 	// this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
     // make Spinner attribute to false for hide loading spinner    
       component.set("v.Spinner", false);
    },
    
    returnToResourceRequest : function(component) {
        component.set("v.Spinner", true); 
        var selectedResReqId = component.get("v.resReqId");
        window.location.href = "/"+selectedResReqId;
    },
})