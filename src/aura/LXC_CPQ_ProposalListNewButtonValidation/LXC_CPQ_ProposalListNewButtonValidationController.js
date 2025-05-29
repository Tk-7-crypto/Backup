({
    init : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Attention!",
            "type" : "Error",
			"mode" : "sticky",
            "message": "You cannot create Quote using this button."
        });
        toastEvent.fire();	
        var homeEvent = $A.get("e.force:navigateToObjectHome");
        homeEvent.setParams({
            "scope": "Apttus_Proposal__Proposal__c"
        });
        homeEvent.fire();
    }
})