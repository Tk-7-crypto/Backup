({
    
    /**
     * To Call the Server method
     * @param {Object} component     Root Component
     * @param {String} actionName    Apex Controller Method name to be called
     * @param {Object} param         Parameters to be passed in Apex Controller Method
     * @param {Object} callback      Function which should call after Server Action
     */
    callServerAction: function(component, actionName, param, callback){
        var action = component.get(actionName);
        if(param)
            action.setParams(param);
        action.setCallback(this, callback);
        $A.enqueueAction(action);
    },

    /**
     * To show the toast notification
     * 
     * @param {String} mode      pester | sticky  | dismissible      Default is dismissible
     * @param {String} type      error  | warning | success | info   Default is other
     * @param {String} title     Title of Toast Notification
     * @param {String} message   Message to be shown on Toast
     */
    showToast: function(mode, type, title, message){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: message,
            duration:'5000',
            type: type,
            mode: mode
        });
        toastEvent.fire();
    }
})