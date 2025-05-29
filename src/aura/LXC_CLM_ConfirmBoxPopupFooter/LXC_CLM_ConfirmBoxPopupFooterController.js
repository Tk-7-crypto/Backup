({
    handleCancel : function(component) {
        component.find("overlayLib").notifyClose();
    },
    
    handleYes : function(component,event, helper) {
        helper.deleteAgreement(component,helper);
    },

    handleYesForCancel : function(component,event, helper) {
        var homeEvent = $A.get("e.force:navigateToObjectHome");
        homeEvent.setParams({
            "scope": "Apttus__APTS_Agreement__c"
        });
        homeEvent.fire();
        component.find("overlayLib").notifyClose();
    }
})