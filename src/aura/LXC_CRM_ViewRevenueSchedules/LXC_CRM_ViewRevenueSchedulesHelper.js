({
    getRevenueSchedules : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var schFileds = component.get("v.schFieldList");
        var oliFileds = component.get("v.oliFieldList");
        var action = component.get("c.getOpportunityLineItemSchedule");
        action.setParams({
            "opportunityLineItemId" : recordId,
            "oliFields" : oliFileds,
            "schFields" : schFileds
        });
        action.setCallback(this, function(actionResult) {
            component.set('v.establishButton', 'Establish');
            var state = actionResult.getState();
            if (state === "SUCCESS" && actionResult.getReturnValue().oliWrapperList.length > 0) {
                var oppWrapper = actionResult.getReturnValue();
                var oliWrapper = oppWrapper.oliWrapperList[0];
                var olisWrapper = oppWrapper.oliWrapperList[0].revSchWrapperList;
                component.set("v.oliWrapper", oliWrapper);
                component.set("v.olisWrapper", olisWrapper);
                component.set("v.decimalPlace", oppWrapper.decimalPlace);
                component.set("v.decimalPlaceStep", oppWrapper.decimalPlaceStep);
                var canUseRevenueSchedule = !(oliWrapper.oliRecord.Product2.CanUseRevenueSchedule);
                component.set("v.canUseRevenueSchedule", canUseRevenueSchedule);
                if(olisWrapper != undefined && olisWrapper.length > 0) {
                    component.set('v.establishButton', 'Re Establish');
                }
            } else if(state === "ERROR") {
                var errors = actionResult.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var errorMsg = JSON.parse(errors[0].message).errorList;
                        helper.setToast(component, event, helper, errorMsg, "error", "Error!");
                    }
                }
            }
            $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "stop"}).fire();
        });
        $A.enqueueAction(action);
    },
    establishRevenueSchedules : function(component, event, helper) {
        var oliWrapper = component.get("v.oliWrapper");
        var establishSchedule = $A.get("e.c:LXE_CRM_OpenRevenueScheduleEvent");
        establishSchedule.setParams({
            "oliWrapper" : oliWrapper[0],
            "origin" : "Detail"
        });
        establishSchedule.fire();
    },
    setToast : function(component, event, helper, message, type, title) {
        var errorMsg = message;
        var msg = "";
        for(var x in errorMsg) {
            msg = msg + errorMsg[x] + "\n";
        }
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            type : type,
            message : msg,
            mode : "sticky"
        });
        toastEvent.fire();
    },
})