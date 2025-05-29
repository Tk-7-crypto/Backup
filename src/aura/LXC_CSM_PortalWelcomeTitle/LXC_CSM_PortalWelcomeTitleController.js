({
    doInit: function(component, event, helper) {
        helper.getCurrentUser(component);
        helper.getLastLogin(component);
    },
})