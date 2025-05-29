({
    doInit : function(component, event, helper) {
        component.set("v.showSpinner", true);
        var myPageRef = component.get("v.pageReference");
        var recordId = myPageRef.state.c__recordId;
        component.set("v.recordId", recordId);
        component.set("v.showSpinner", false);
    },
    
    handlePageReferenceChange: function(component, event, helper) {
        component.set("v.recordId", "");
        component.set("v.showSpinner", true);
        var myPageRef = component.get("v.pageReference");
        var recordId = myPageRef.state.c__recordId;
        component.set("v.recordId", recordId);
        component.set("v.showSpinner", false);
    }
})