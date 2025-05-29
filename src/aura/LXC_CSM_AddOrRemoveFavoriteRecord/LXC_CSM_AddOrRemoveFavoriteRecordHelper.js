({
    getIsFavorite: function (component) {
        var action = component.get("c.isFavorite");
        action.setParams({
            "genericRecord": component.get("v.record")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isFavorite", response.getReturnValue());
            } else {
                console.log("Error", response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    addOrRemoveFavorite: function (component) {
        component.set("v.isFavorite", !component.get("v.isFavorite"));
        var action = component.get("c.addOrRemoveFavorite");
        action.setParams({
            "genericRecord": component.get("v.record"),
            "isFavorite": component.get("v.isFavorite")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                $A.util.toggleClass(component.find("favorite"), "toggleFavorite");
                var toastEvent = $A.get("e.force:showToast");
                if (component.get("v.isFavorite")) {
                    toastEvent.setParams({
                        "message": $A.get("$Label.c.It_is_added_to_your_bookmarks"),
                        "type": "success"
                    });
                } else {
                    toastEvent.setParams({
                        "message": $A.get("$Label.c.It_is_removed_from_your_bookmarks"),
                        "type": "success"
                    });
                }
                toastEvent.fire();
            } else {
                console.log("Error", response.getError());
            }
        });
        $A.enqueueAction(action);
    }
})