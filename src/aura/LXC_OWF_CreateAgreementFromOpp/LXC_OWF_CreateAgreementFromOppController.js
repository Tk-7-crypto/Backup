({
    doInit : function(component, event, helper) {

        helper.getRecordTypes(component, event, helper);
        component.set("v.isBidSelected", false);
        helper.getOppDetails(component, event, helper);
        helper.usingMap(component, event, helper);
    },
    onRadioSelect : function(component, event, helper){
        var recId = event.getSource().get("v.value");
        console.log('recId '+recId);
        var recTypeName = event.getSource().get("v.label");   
        component.set("v.selectedBidTypeOnRadio" , recId);
        component.set("v.selectedBidTypeNameOnRadio" , recTypeName); 
        component.set("v.isBidSelected", false);
        var errorMsg = '';
            component.set("v.isError" , false); 
            component.set("v.errorMessage", errorMsg);
        var action = component.get("c.getDefaultFieldValues");
        var OpportunityId = component.get("v.recordId");
        action.setParams({
            "opportunityId" : OpportunityId,
            "recordTypeId": recId,
        });
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
                component.set("v.defaultValues",actionResult.getReturnValue());
                console.log(component.get("v.defaultValues")); 
            }
        });
        $A.enqueueAction(action);
    },
    onSuccess : function(component, event, helper) {
        alert('The record has been saved successfully!');
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Success Message',
            message: 'The record has been saved successfully!',
            duration:' 5000',
            key: 'info_alt',
            type: 'success',
            mode: 'pester'
        });
        toastEvent.fire();
    },
    onError : function(component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : 'Error',
            message: 'Error!',
            duration:' 5000',
            key: 'info_alt',
            type: 'error',
            mode: 'pester'
        });
        toastEvent.fire();
    },
    showRecordForm : function(component, event, helper) {
        
        var recId = component.get("v.selectedBidTypeOnRadio");
        var recTypeName = component.get("v.selectedBidTypeNameOnRadio");
        component.set("v.selectedBidType" , recId);
        component.set("v.selectedBidTypeName" , recTypeName);        
        component.set("v.isBidSelected", true);   
    },
    closeQuickAction : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },
    handleOnload : function(component, event, helper) {
        var oppID =  component.get("v.recordId");
        
        // requires inputFields to have aura:id
        component.find("agrOppty").set("v.value", oppID);
        //component.find("departmentText").set("v.value", "Accounting");
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
                        
        createRecord : function (component, event, helper) {
            helper.createRecord_helper(component, event, helper);
                    }
                    
})