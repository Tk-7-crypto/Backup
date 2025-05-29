({
    getProductCommunityTopics: function (component) {
        component.set("v.isLoading", true);
        var action = action = component.get("c.getProductCommunityTopics");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.communityTopics", response.getReturnValue());
            } else if (state === "ERROR") {
                console.log("ERROR: " + JSON.stringify(response.getError()));
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },

})