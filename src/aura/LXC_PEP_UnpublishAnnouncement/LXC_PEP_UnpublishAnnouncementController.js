({
	unPublishAnnouncement : function(component, event, helper) {
        var action = component.get("c.unPublishAnnouncements");
        action.setParams({
            announcementId: component.get("{!v.recordId}")
        });
        action.setCallback(this, function(data) {
            var state = data.getState();
            if(state === "SUCCESS") {
                component.set("{!v.status}", "Annnouncement unPublished");
                setTimeout(function() {
                    $A.get('e.force:refreshView').fire();
                	$A.get("e.force:closeQuickAction").fire();
                }, 2000);
            }
            else {
                component.set("{!v.status}", JSON.parse(JSON.stringify(data.getError()))[0].pageErrors[0].message);
                setTimeout(function() {
                    $A.get('e.force:refreshView').fire();
                    $A.get("e.force:closeQuickAction").fire();
                }, 3000);
            }
            console.log(state);
        });
        $A.enqueueAction(action);
	}
})