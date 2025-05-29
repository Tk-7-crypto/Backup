({
    toggleSpinner : function(component,event,helper) {
        var params = event.getParams();
        if(params.action === "start") {
            component.set("v.Spinner", true);
        }
        if(params.action === "stop") {
            component.set("v.Spinner", false);
        }
    }
})