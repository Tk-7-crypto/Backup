({
    doInit : function(component, event, helper) {
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "start"}).fire();
        helper.getRevenueSchedules(component, event, helper);
    },
    establish : function(component, event, helper) {
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "start"}).fire();
        helper.establishRevenueSchedules(component, event, helper);
    },
})