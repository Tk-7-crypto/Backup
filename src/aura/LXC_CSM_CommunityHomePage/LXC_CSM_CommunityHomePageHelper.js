({
    getUserContact: function (component) {
        var action = component.get("c.getUser");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var user = response.getReturnValue()[0];
                if (user) {
                    component.set("v.user", user);
                }
            } else if (state === "ERROR") {
                console.log("ERROR: " + JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
    }
})