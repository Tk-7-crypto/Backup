({
    openCSATInternal : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function(enclosingTabId) {
            workspaceAPI.openSubtab({
                parentTabId: enclosingTabId,
                pageReference: {
                    "type": "standard__component",
                    "attributes": {
                        "componentName": "c__LXC_CSM_CSATInternal"
                    },
                    "state": {
                        "uid": "1",
                        "c__recordId": component.get("v.recordId")
                    }
                }
            }).then(function(subtabId) {
                workspaceAPI.setTabIcon({
                    tabId: subtabId,
                    icon: "utility:like",
                    iconAlt: "Comment Rating"
                });
                workspaceAPI.setTabLabel({
                    tabId: subtabId,
                    label: "Comment Rating"
                });
            }).catch(function(error) {
                console.log("error");
            });
        });

    }
})