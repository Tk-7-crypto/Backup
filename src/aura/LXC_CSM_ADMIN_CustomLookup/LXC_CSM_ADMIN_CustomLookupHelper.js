({
	searchHelper : function(component,event,getInputkeyWord) {
	  // call the apex class method 
     var action = component.get("c.fetchLookUpValues");
      // set param to method  
        action.setParams({
            'searchKeyWord': getInputkeyWord
          });
      // set a callBack    
        action.setCallback(this, function(response) {
          $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
              // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                // set searchResult list with return value from server.
                component.set("v.listOfSearchRecords", storeResponse);
            }
 
        });
      // enqueue the Action  
        $A.enqueueAction(action);
    
	},
    callServer : function(component,method,callback,params) {
        var action = component.get(method);
        if (params) {
            action.setParams(params);
        }
        
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                // pass returned value to callback function
                callback.call(this,response.getReturnValue());   
            } else if (state === "ERROR") {
                // generic error handler
                var errors = response.getError();
                if (errors) {
                    console.log("Errors", errors);
                    if (errors[0] && errors[0].message) {
                        throw new Error("Error" + errors[0].message);
                    }
                } else {
                    throw new Error("Unknown Error");
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    
    errorMessage : function(cmp,title,severity,message){
        
        $A.createComponents([
            ["ui:message",{"title" : title,"severity" : severity,"closable" : "true","click":"{!c.handleClick}"}],
            ["ui:outputText",{"value" : message}]
        ],function(components, status, errorMessage){
           if (status === "SUCCESS") {
               var message = components[0];
               var outputText = components[1];
               message.set("v.body", outputText);
               cmp.set("v.message", components); 
               //var message = components[0];
                //var outputText = components[1];
                // set the body of the ui:message to be the ui:outputText
                //message.set("v.body", outputText);
                //var div1 = cmp.find("div1");
                // Replace div body with the dynamic component
               // div1.set("v.body", message);
            }else if (status === "INCOMPLETE") {
               console.log("No response from server or client is offline.")
               // Show offline error
            }else if (status === "ERROR") {
              console.log("Error: " + errorMessage);
              // Show error message
            }
            });
    },
    
    showToastmsg: function(cmp,title,variant,message){
        cmp.find('notifLib').showToast({
            "title": title,
            "variant":variant,         
            "message": message
        });
    }
})