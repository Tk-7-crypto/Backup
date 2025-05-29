({
    updateContentDocumentLinkVisibility : function(component,contentDocumentId,visibility) {
        var action = component.get("c.updateContentDocumentLinkVisibility");
        action.setParams({
            "contentDocumentId" : contentDocumentId,
            "linkedEntityId" : component.get("v.recordId"),
            "visibility" : visibility
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                $A.get('e.force:refreshView').fire();
            } else if(state === "ERROR") {
                if(response.getError()[0].pageErrors[0].message.includes("Case Type Is Mandatory")){
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "type": "ERROR",
                        "title": " Action Denied",
                        "message": "Case type is mandatory to make public visible"
                    });
                    resultsToast.fire();
                    console.log("ERROR: " + JSON.stringify(response.getError()));
                }
                //console.log("ERROR: "+JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
    },

    getCountAttachment: function(component){
        component.set("v.isLoading", true);
        var startLetter = component.get("v.recordId").substring(0,1);
        if(startLetter == 'k'){
            component.set("v.knowledge", true);
        }
        else
        {
            component.set("v.knowledge", false);
        }
        var action = component.get("c.countAttachment");
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.countAttachments", response.getReturnValue());
            }
            else if (state === "ERROR") {
                console.log("LXC_CSM_PortalFile] ERROR " + JSON.stringify(response.getError()));
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);

    },
})