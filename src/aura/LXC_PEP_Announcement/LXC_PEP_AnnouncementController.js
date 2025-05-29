({
	doInit: function(component, event, helper) {
        var action;

        if(component.get("v.homePage")){
            action = component.get("c.getAnnouncementForHome");
        }else{
            action = component.get("c.getAnnouncement");
        }

        action.setCallback(this, function(data) {
            var state = data.getState();
            console.log(state);
            if (state === "SUCCESS") {
                component.set("v.announcementList", data.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        
    }
})