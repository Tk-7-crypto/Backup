({
    stopNonAdminUsertoCreateAGR: function (component, event, helper) {
        var action = component.get("c.checkAdminUser");
        action.setCallback(this, function (response){
            if(response.getState() === 'SUCCESS') {
                if (response.getReturnValue() === true) {
                    this.createAgreement(component,event);
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Attention!",
                        "type" : "Error",
		    	        "mode" : "sticky",
                        "message": "The use of this 'New' button to create agreements is deprecated. Please launch the workflow using the 'Create New Agreement' action button from the Opportunity or Account details."
                    });
                    toastEvent.fire();	
                    var homeEvent = $A.get("e.force:navigateToObjectHome");
                    homeEvent.setParams({
                        "scope": "IQVIA_Agreement__c"
                    });
                    homeEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    createAgreement: function (component, event) {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "IQVIA_Agreement__c",
            "recordTypeId": '',
        });
        createRecordEvent.fire();
    }
})