({
    getMikadoFolders: function(component){
        component.set("v.isLoading", true);
        var action = component.get("c.getMikadoFolders");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var mikadoFolders = response.getReturnValue();
                component.set("v.folders",mikadoFolders);
                component.set("v.filteredFolders",mikadoFolders);
            }else if (state === "ERROR") {
                console.log("LXC_CSM_Mikado] ERROR " + JSON.stringify(response.getError()));
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },
})