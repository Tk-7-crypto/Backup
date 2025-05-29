({
    doInit: function(component, event, helper) {
        helper.getUserContact(component);
        helper.getTPAAccess(component);
    },
    openIncidentDetails: function(component, event, helper) {
        component.find("cPrompt").show();
    }
})