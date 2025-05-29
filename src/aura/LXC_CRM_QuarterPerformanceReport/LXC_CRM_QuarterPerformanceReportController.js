({
     doInit : function(component, event, helper) {
        var myPageRef = component.get("v.pageReference");
        var reportName = myPageRef.state.c__ReportName;
        component.set("v.reportName", reportName);
    }
})