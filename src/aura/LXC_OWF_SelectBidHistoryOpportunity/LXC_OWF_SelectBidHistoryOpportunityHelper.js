({
    redirectUser : function(component,event)
    {
        var recordTypeId = component.get("v.pageReference").state.recordTypeId;
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef  : "c:LXC_OWF_overrideAgreementCreation" ,
            componentAttributes : {
                recordTypeId : recordTypeId,
                pageReference : component.get("v.pageReference")
            }
        });
        evt.fire(); 
    }
})