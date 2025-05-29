({
    getAppLauncherForCurrentUser: function (component) {
        component.set("v.isLoading", true);
        var action = component.get("c.getAppLauncherForCurrentUser");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var appLinks = response.getReturnValue();
                if (appLinks) {
                    console.log(appLinks);
                    component.set("v.appLinks", appLinks);
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.log(JSON.stringify(errors));
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    }
})