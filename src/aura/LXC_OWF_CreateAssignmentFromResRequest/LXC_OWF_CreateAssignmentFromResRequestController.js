({
    doInit : function(component, event, helper) {
        var sURLVariables = window.location.search.substring(1).split('&'); 
        var sParameterName;
        var resourceRequestId;
        
        for (var i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('='); //to split the key from the value.
        
            if (sParameterName[0].toLowerCase() === 'id') {
                resourceRequestId = sParameterName[1] === undefined ? 'Not found' : sParameterName[1];
            }
        }
        helper.getSuggestedFTE(component, resourceRequestId);
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
    assignResourceRec : function (component, event, helper) {
        component.set("v.Likedisable",true);
        component.set("v.Spinner", true); 
        component.set("v.isError" , false); 
        component.set("v.errorMessage", '');
        
        var resourceId = component.get("v.selectedResourceId");
        var resReqId =  component.get("v.resReqId");
        var errorMsg;
        if(resourceId == undefined || resourceId == '' || resourceId == null) {
            errorMsg = 'Please select a Resource!';
            component.set("v.isError" , true); 
            component.set("v.errorMessage", errorMsg);
            component.set("v.Likedisable",false);
            component.set("v.Spinner", false);
        }else if(resReqId == undefined) {
            errorMsg = 'You are accessing from wrong window, please access by Resource Request!';
            component.set("v.isError" , true); 
            component.set("v.errorMessage", errorMsg);
            component.set("v.Likedisable",false);
            component.set("v.Spinner", false);
        } else {
            var action = component.get('c.assignResourceAndCreateAssignment');
        	action.setParams({ 
                "resRequestId" : component.get("v.resReqId"),  
                "resourceId" : component.get("v.selectedResourceId")
            });
        	action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var responseVal = response.getReturnValue();
                    if(responseVal.trim() === 'success') {
                        alert("Resource is assigned Successfully.");
						window.location.href = "/"+resReqId;
                    }else {
                        component.set("v.isError" , true); 
                        component.set("v.errorMessage", responseVal);
                    }
                }
                else if (state === "INCOMPLETE") {
                    // do something
                    component.set("v.Spinner", false);
                    component.set("v.Likedisable",false);
                }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                     errors[0].message);
                            component.set("v.isError" , true); 
            				component.set("v.errorMessage", errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                    component.set("v.isError" , true); 
                    component.set("v.errorMessage", "Error in calling server side action");
                    component.set("v.Spinner", false);
                    component.set("v.Likedisable",false);
                }
            });
            $A.enqueueAction(action);
		}
    },
    
    returnToResourceRequest : function(component) {
        component.set("v.Spinner", true); 
        var resReqId =  component.get("v.resReqId");
        window.location.href = "/"+resReqId;
    }
})