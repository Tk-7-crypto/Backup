({
	publishAnnouncement : function(component, event, helper) {
        //console.log(component.get("{!v.recordId}"));
        var action = component.get("c.publishAnnouncements");
        action.setParams({
            announcementId: component.get("{!v.recordId}")
        });
        action.setCallback(this, function(data) {
            var state = data.getState();
            if(state === "SUCCESS") {
                if(data.getReturnValue().length == 0) {
                    component.set("{!v.status}", "Cannot publish this announcement. No target users available for the selected filters.");
                	setTimeout(function() {
                        $A.get('e.force:refreshView').fire();
                        $A.get("e.force:closeQuickAction").fire();
                     });
                }
                else {
                	component.set("{!v.status}", "Annnouncement published");
                    setTimeout(function() {
                        $A.get('e.force:refreshView').fire();
                        $A.get("e.force:closeQuickAction").fire();
                    }, 1500);
                }
            }
            else {
                component.set("{!v.status}", "An error has occurred: \n" + JSON.parse(JSON.stringify(data.getError()))[0].message);
                setTimeout(function() {
                    $A.get('e.force:refreshView').fire();
                    $A.get("e.force:closeQuickAction").fire();
                }, 1000000);
            }
            console.log(state);
        });
        $A.enqueueAction(action);
	}
})