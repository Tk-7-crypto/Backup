({
    gotoURL : function (component, event, helper) {       
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": $A.get("$Label.c.PendingChatAlertPageUrl")
        });
        urlEvent.fire();
    }
})