({
    doInit: function(component, event, helper) {
        if (component.get("v.paramTopics4all")!= undefined)helper.getTopics4all(component);
        helper.getTopics(component);
    },
})