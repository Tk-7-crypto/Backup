({
    handleCancel : function(component, event, helper) {
        //closes the modal or popover from the component
        var appEvent = $A.get("e.c:AddRevenueScheduleConfirmEvent");
        appEvent.setParams({
            "message" : "Cancel",
        	"eventType" : component.get("v.eventType1")
        });
        appEvent.fire();
        component.find("overlayLib").notifyClose();
    },
    handleOK : function(component, event, helper) {
        //do something
        var appEvent = $A.get("e.c:AddRevenueScheduleConfirmEvent");
        appEvent.setParams({
            "message" : "Ok",
            "eventType" : component.get("v.eventType1")
        });
        appEvent.fire();
        component.find("overlayLib").notifyClose();
    }
})