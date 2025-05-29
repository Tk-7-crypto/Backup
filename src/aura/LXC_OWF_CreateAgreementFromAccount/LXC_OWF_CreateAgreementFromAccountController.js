({
	doInit : function(component, event, helper) {
        //helper.getRecordTypes(component, event, helper);
        var action = component.get("c.showAvailableAgrRecordTypeForAccount");
        var accountId = component.get("v.recordId");
        action.setParams({
            "accountId" : accountId,
        });
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
                component.set("v.bidTypes",actionResult.getReturnValue());                 
                var recordTypeId = component.get("v.text");
                var recordTypeName = component.get("v.label");
                component.set("v.selectedBidType", recordTypeId);
                component.set("v.selectedBidTypeName", recordTypeName);
        
            }
       });
       $A.enqueueAction(action);
    },
     showSpinner: function(component, event, helper) {
       // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
   },
    
 	// this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
     // make Spinner attribute to false for hide loading spinner    
       component.set("v.Spinner", false);
    },
    closeQuickAction : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    createRecord : function (component, event, helper) {
        var selectedRadioOption = component.find("recdTypeId");
        var selectedRecordTypeId;
        selectedRecordTypeId = selectedRadioOption.get("v.value")
        console.log('selectedRadioOption'+selectedRadioOption);
        var accountID =  component.get("v.recordId");
        console.log('accountID: '+accountID);
    	var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Bid_History__c",
            "recordTypeId": selectedRecordTypeId,
            "defaultFieldValues": {
            Bid_History_Account__c : accountID    
            },
            "panelOnDestroyCallback": function(event) {
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                  "recordId": accountID,
                });
                navEvt.fire();
    		}
    });
    createRecordEvent.fire();
}
})