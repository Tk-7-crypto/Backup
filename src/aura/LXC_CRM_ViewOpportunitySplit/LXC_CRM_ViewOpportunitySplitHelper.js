({
    getOpportunitySplitRecordList : function(component, event, helper) {
        var action = component.get("c.getOpportunitySplitRecords");
        var splitType = component.get("v.splitType");
        var fieldList = component.get("v.fieldsToShow");
        var recordId = component.get("v.recordId");
        action.setParams({
            "opportinityId" : recordId,
            "splitType" : splitType,
            "fieldList" : fieldList
        });
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
                helper.hasEditOppSplitPermission(component, event, helper);
                component.set("v.opportunitySplitRecords", actionResult.getReturnValue());
            } else if(state === "ERROR") {
                var errors = actionResult.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var errorMsg = JSON.parse(errors[0].message).errorList;
                        helper.setToast(component, event, helper, errorMsg, "error", "Error!");
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    hasEditOppSplitPermission : function(component, event, helper) {
        var action = component.get("c.hasEditSplitPermission");
        action.setParams({
            "permissionApiName" : "Edit_Split",
        });
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
                component.set("v.hasSplitVisible", actionResult.getReturnValue());
            } else if(state === "ERROR") {
                var errors = actionResult.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        var errorMsg = JSON.parse(errors[0].message).errorList;
                        helper.setToast(component, event, helper, errorMsg, "error", "Error!");
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    openOppSplitComp : function(component, event, helper, componentDef) { 
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : componentDef,
            componentAttributes : {
                "recordId" : component.get("v.recordId")
            },
            isredirect : false
        });
        evt.fire();
    },
    
    setToast : function(component, event, helper, message, type, title) {
        var errorMsg = message;
        var msg = "";
        for(var x = 0; x < errorMsg.length; x++) {
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