({
    recordIsFollowed: function (component) {
        var action = component.get("c.recordIsFollowed");
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isFollowed", response.getReturnValue())
            }
            else if (state === "ERROR") {
                console.log('Problem ' + JSON.stringify(response.getError()[0]));
            }
        });
        $A.enqueueAction(action);

    },

    followRecord: function (component) {
        var action = component.get("c.followRecord");
        action.setParams({
            "recordId": component.get("v.recordId"),
            "isFollowed": component.get("v.isFollowed")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isFollowed", response.getReturnValue())
            }
            else if (state === "ERROR") {
                console.log('Problem ' + JSON.stringify(response.getError()[0]));
            }
        });
        $A.enqueueAction(action);
    }
})