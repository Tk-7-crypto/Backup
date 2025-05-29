({
    doInit : function(component, event, helper) {
        if (!component.get("v.platformEvtHandlerEnabled")) {
            helper.subscribe(component, event, helper);
        }
        
        helper.bannerShow(component, event, helper);
    }
})