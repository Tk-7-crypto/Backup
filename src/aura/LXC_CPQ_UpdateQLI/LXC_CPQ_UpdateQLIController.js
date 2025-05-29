({
    doInit : function(component, event, helper) {
        var pageReference = component.get("v.pageReference");
        var recordId = pageReference.state.c__recordId;
        component.set("v.recordId", recordId);
    }
})