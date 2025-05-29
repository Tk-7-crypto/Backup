({
	doInit : function(component, event, helper) {
        helper.getOliWithScheduleDetails(component, event, helper);
    },
    
    updateCloseDate : function(component, event, helper) {
        helper.updateCloseDate(component, event, helper);
    },
    
    handleChange : function (component, event, helper) {
        $A.get("e.c:LXE_CRM_SpinnerEvent").setParams({"action" : "start"}).fire();
        var changeValue = event.getParam("value");
        component.set("v.isUpdateSchedule", changeValue);
        if(changeValue != 'option2') {
            component.set("v.isShowconfirmationMsg", false);
            component.set("v.confirmationMsg", '');
        }
        helper.updateCloseDate(component, event, helper);
    },
    
    onSave : function(component, event, helper) {
        helper.updateCloseDateOfOpportunity(component, event, helper);
    },
    
    onCancel : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        helper.navigateToOpp(component, event, helper, recordId);
    },
})