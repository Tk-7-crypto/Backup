({
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
    }, errorMessage : function(cmp,title,severity,message){
        
        $A.createComponents([
            ["ui:message",{
                "title" : title,
                "severity" : severity,
                "closable" : "true",
                "click":"{!c.handleClick}"
            }],
            ["ui:outputText",{
                "value" : message
            }]
        ],function(components, status, errorMessage){
           if (status === "SUCCESS") {
                var message = components[0];
                var outputText = components[1];
                // set the body of the ui:message to be the ui:outputText
                message.set("v.body", outputText);
                var div1 = cmp.find("div1");
                // Replace div body with the dynamic component
                div1.set("v.body", message);
            }else if (status === "INCOMPLETE") {
               console.log("No response from server or client is offline.")
               // Show offline error
            }else if (status === "ERROR") {
              console.log("Error: " + errorMessage);
              // Show error message
            }
            });
    },showToastmsg: function(cmp,title,variant,message){
        cmp.find('notifLib').showToast({
            "title": title,
            "variant":variant,         
            "message": message
        });
    },
    replaceCObjectName: function(name){
        return name.replace('__c','').split('_').join(' ');
    }
})