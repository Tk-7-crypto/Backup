({
    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
            console.log("Record is loaded successfully.");
            component.set("v.isLoading", false);
        } else if(eventParams.changeType === "CHANGED") {
        } else if(eventParams.changeType === "REMOVED") {
        } else if(eventParams.changeType === "ERROR") {
            component.set("v.isLoading", false);
        }
    },
    
    doInit: function(component, event, helper) {
        helper.getCurrentUserLoginDetails(component);
    }
})