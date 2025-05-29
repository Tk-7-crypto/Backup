({
    hasEditPermission: function(component){
        var action = component.get("c.hasEditPermission");
        action.setParams({
            field : component.get("v.field")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if(response.getReturnValue() == true)
                    component.set("v.canManaged",true);
            } else if(state === "ERROR") {
                var errors = response.getError();
            }
        });
        $A.enqueueAction(action);
    },
    getData: function(component){
        component.set("v.isLoading", true);
        var action = component.get("c.getData");
        action.setParams({
            profile : component.get("v.Profile"),
            field : component.get("v.field"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var allNews =response.getReturnValue();
                if(Object.keys(allNews).length<1){
                    component.set("v.noData",true);
                }else{
                    component.set("v.csmNewsObject",allNews[0]);
                }
            } else if(state === "ERROR") {
                var errors = response.getError();
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },
})