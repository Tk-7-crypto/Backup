({ 
    invoke : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        window.location.reload();
    }
})