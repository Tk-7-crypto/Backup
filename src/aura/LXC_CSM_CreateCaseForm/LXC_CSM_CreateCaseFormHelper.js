({
    getRecordTypes : function(component, event) {
        var action = component.get("c.getRecordTypeValues");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var recordTypes = result;
                var selectedRecordTypeId;
                for(var i = 0; i < recordTypes.length; i++) {
                    if(recordTypes[i].checked) {
                        selectedRecordTypeId = recordTypes[i].value;
                        break;
                    }
                }
                component.set("v.recordTypes", recordTypes);
                component.set("v.selectedRecordTypeId", selectedRecordTypeId);
            }
        });
        $A.enqueueAction(action);
    },
    
    getAccount : function(component) {
        var contactId = component.get('v.contactId');
        var action = component.get("c.getAccountByContact");
        action.setParams({ 
            "contactId": contactId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var accountId = result;
                component.set("v.accountId", accountId);
                component.set("v.Spinner", false);
                var recordTypes = component.get('v.recordTypes');
                if(recordTypes.length == 1) {
                    this.openCreateRecordForm(component, event);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    openCreateRecordForm: function(component, event) { 
        var selectedRecordTypeId = component.get("v.selectedRecordTypeId");
        var contactId = component.get('v.contactId');
        var accountId = component.get('v.accountId');
        var createEvent = $A.get("e.force:createRecord");
        createEvent.setParams({
            "entityApiName": "Case",
            "recordTypeId": selectedRecordTypeId,
            'defaultFieldValues' : {
                'ContactId': contactId,
                'AccountId': accountId
            },
            "navigationLocation" : "LOOKUP",
            "panelOnDestroyCallback": function(event) {
                var navigateEvent = $A.get("e.force:navigateToSObject");           
                navigateEvent.setParams({ "recordId": contactId});                
                navigateEvent.fire(); 
            }
        });  
        createEvent.fire();  
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
})