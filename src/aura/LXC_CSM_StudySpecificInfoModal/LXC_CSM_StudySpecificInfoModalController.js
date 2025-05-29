({
    doInit: function(component, event, helper) {
        var caseId = component.get("v.recordId");
        var action = component.get("c.showAlertForRND");
        action.setParams({
            caseId: caseId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS") {
                var caseAlertWrapperJSON = response.getReturnValue();
                var caseAlertWrapper = JSON.parse(caseAlertWrapperJSON);
                var isShowAlert = caseAlertWrapper.isShowAlert;
                if(isShowAlert) {
                    component.set("v.caseNumber", caseAlertWrapper.caseRecord.CaseNumber);
                    $A.util.removeClass(component.find("modaldialog"), "slds-fade-in-hide");
                    $A.util.addClass(component.find("modaldialog"), "slds-fade-in-open");
                    $A.util.removeClass(component.find("backdrop"), "slds-backdrop--hide");
                    $A.util.addClass(component.find("backdrop"), "slds-backdrop--open");
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    closeModel: function(component, event, helper) {
        $A.util.addClass(component.find("modaldialog"), "slds-fade-in-hide");
        $A.util.removeClass(component.find("modaldialog"), "slds-fade-in-open");
        $A.util.addClass(component.find("backdrop"), "slds-backdrop--hide");
        $A.util.removeClass(component.find("backdrop"), "slds-backdrop--open");
        $A.get('e.force:refreshView').fire();
    },
})