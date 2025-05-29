({
    doInit: function (component, event, helper) {
        let currentUser = $A.get("$SObjectType.CurrentUser.Id");
        if (currentUser)
            component.set("v.userId", currentUser.substring(0, 15));
        helper.getProductCommunityTopics(component);
    },

    openTopic: function (component, event, helper) {
        var ct = event.currentTarget;
        var c = ct.dataset.name;
        var navService = component.find("navService");
        event.preventDefault();
        var pageReference = {
            type: "standard__namedPage",
            attributes: {
                pageName: 'doc'
            },
            state: {
                name: c
            }
        };
        sessionStorage.setItem('localTransfer', JSON.stringify(pageReference.state));
        navService.navigate(pageReference);
    }
})