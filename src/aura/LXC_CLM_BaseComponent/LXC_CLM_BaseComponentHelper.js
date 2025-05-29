({
    /*
     * This method will call the server side action and will execute callback method
     * it will also show error if generated any
     * @param component (required) - Calling component
     * @param method (required) - Server side methos name
     * @param callback (required) - Callback function to be executed on server response
     * @param params (optional) - parameter values to pass to server
     * @param setStorable(optional) - if true, action response will be stored in cache
     * 
    */
    callServer : function(component, method, callback, params, setStorable) {
        var action = component.get(method);
  
        if (params) {
            action.setParams(params);
        }
        
        if(setStorable){
            action.setStorable();
        }
        
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                // pass returned value to callback function
                callback.call(this,response.getReturnValue()); 
            } else if (state === "ERROR") {
                component.set("v.showSpinner",false);
                // generic error handler
                this.handleErrors(response.getError());
            } else if(res.getState() == "INCOMPLETE") {
                console.log('Incomplete response from server call');
                component.set("v.showSpinner",false);
                this.handleErrors(null);
            } else {
                console.log('Unknown Error has occcured in server call');
                component.set("v.showSpinner",false);
                this.handleErrors(null);
            }
        });
        $A.enqueueAction(action);
        
    },

    /*
     * This method will call the server side action and will execute callback method
     * it will also show error if generated any
     * @param component (required) - Calling component
     * @param method (required) - Server side methos name
     * @param successCallback (required) - Callback function to be executed when State is Success on server response
     * @param params (optional) - parameter values to pass to server
     * @param setStorable(optional) - if true, action response will be stored in cache
     * @param errorCallback (optional) - Callback function to be executed when State is Success on server response
    */
    callServerWithCustomErrorHandling : function(component, method, successCallback, params, setStorable, errorCallback) {
        var action = component.get(method);
  
        if (params) {
            action.setParams(params);
        }
        
        if(setStorable){
            action.setStorable();
        }
        
        action.setCallback(this,function(response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                // pass returned value to callback function
                successCallback.call(this,response.getReturnValue()); 
            }
            else if (state === "ERROR") {
                if(errorCallback){
                    errorCallback.call(this, response.getError());
                }else{
                    component.set("v.showSpinner",false);
                    // generic error handler
                    this.handleErrors(response.getError());
                }
            }
            else if(res.getState() == "INCOMPLETE") {
                console.log('Incomplete response from server call');
                this.handleErrors(null);
            }
            else {
                console.log('Unknown Error has occcured in server call');
                this.handleErrors(null);
            }
            component.set("v.showSpinner",false);
        });
        $A.enqueueAction(action);
        
    },
    
    handleErrors : function(errors) {
        var errorMessage,userMessage ;
        if (errors && Array.isArray(errors) && errors.length > 0) {
            errorMessage = errors[0].message;
        }
        userMessage = $A.get("$Label.c.CLM_CL_0001_UnknownError");
        console.log('Error Message in backgroud - '+errorMessage);
        this.showToast("Error",userMessage,"Error","dismissible");
    },

    showToast : function(title,message,type,mode) {
        var toastEvent = $A.get("e.force:showToast");
        if(toastEvent){
            toastEvent.setParams({
                "type" : type,
                "title": title,
                "message": message,
                "mode" : mode
            });
            toastEvent.fire();
        }
        else{
            alert(message);
        }
    },

    doRefreshView: function() {
        $A.get('e.force:refreshView').fire();
    }
})