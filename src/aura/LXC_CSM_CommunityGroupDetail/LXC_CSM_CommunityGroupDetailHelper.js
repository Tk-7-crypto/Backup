({
    getGroupDetails : function(component) {
        var action = component.get("c.getGroupDetails");
        action.setParams({
            "groupId": component.get('v.groupId')            
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var data = [];
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result != null) {
                    var group = result;
                    component.set('v.group', group);
                } 
            } else {
                console.log("LXC_CSM_CommunityGroupDetail] ERROR " + JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
    },
})