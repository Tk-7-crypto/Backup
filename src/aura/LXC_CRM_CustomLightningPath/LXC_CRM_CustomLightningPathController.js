({
    recordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED" || eventParams.changeType === "CHANGED") {
            var stepName = component.get("{!v.OppRecord.StageName}");
            if(component.get("v.oldStageName") != stepName){
                component.set("v.reRender", false);
                component.set("v.stageName", stepName);
                component.set("v.oldStageName", stepName);
                component.set("v.reRender", true);
            }
        }
    },
    handleSelect : function (component, event, helper) {
        var stepName = event.getParam("detail").value;
        component.set("v.stageName", stepName);
    },
    
    toggleVisibility: function(component, event, helper) {
        var toggle = component.get("v.showDetail");
        if(toggle){
            component.set("v.icon","utility:chevronright");
            component.set("v.showDetail", false);
            component.set("v.toggleStatus", "Show More");
        }
        else{
            component.set("v.icon","utility:chevrondown");
            component.set("v.showDetail", true);
            component.set("v.toggleStatus", "Show Less");
        }
    }
})