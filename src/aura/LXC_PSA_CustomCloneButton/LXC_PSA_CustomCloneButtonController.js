({
    handleSave : function(component, event, helper) {
        component.find('lwc_psa_filteredDetailsTab').saveRecord(event)
    },
    handleCancel : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})