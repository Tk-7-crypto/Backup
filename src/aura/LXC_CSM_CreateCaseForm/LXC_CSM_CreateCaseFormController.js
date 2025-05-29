({
    doInit: function(component, event, helper) { 
        component.set("v.Spinner", true);
        var contactId = component.get('v.recordId');
        component.set("v.contactId", contactId);
        helper.getRecordTypes(component, event);
        helper.getAccount(component);
    },
     
    handleCreateRecord: function(component, event, helper) { 
        helper.openCreateRecordForm(component, event);
    },
    
    handleClose: function(component, event, helper) { 
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
})