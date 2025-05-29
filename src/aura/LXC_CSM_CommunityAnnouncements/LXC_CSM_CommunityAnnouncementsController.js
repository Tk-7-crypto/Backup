({
    doInit : function(component, event, helper) {
        var partnerURL = component.get('v.partnerURL');
        component.set("v.restricted", true);
        console.log('partner url  : : ' + partnerURL);
        //helper.getUserSessionId(component)
        var action = component.get("c.getUserSessionId");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var sessionId = response.getReturnValue();
                component.set('v.UserSessionId', sessionId);
                console.log('UserSessionId =:::', sessionId);
            } else {
                console.log("getSessionIDFail: " + JSON.stringify(response.getError()));
                component.set('v.UserSessionId', '');
            }
            if(partnerURL == true)
        {
            helper.getAnnouncementsForCurrentPRMUser(component);
            helper.getPrmOrgBaseUrl(component);
        }
        else
        {
            helper.getAnnouncementsForCurrentUser(component);
        }
        });
        $A.enqueueAction(action);
        
    },
    closeWebinar : function(component, event, helper){
        component.set("v.showWebinarAnouncement", false);
        document.cookie = 'ClosedFor' + "=" + escape(component.get('v.UserSessionId'))+ "; " +"path=/";
    },
    doNotRemind : function(component, event, helper){
        component.set("v.showWebinarAnouncement", false);
        document.cookie = 'ShowWebinarAnouncement' + "=" + escape('false')+ "; " +"path=/";
        document.cookie = 'LastUpdate' + "=" + escape(new Date().getTime())+ "; " +"path=/";
    },

    annoucementClick : function(component, event, helper) {
        var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.value;
        var announcements = [];
        announcements = component.get("v.announcements");
        component.set("v.headerContent", announcements[index].Subject__c);
        component.set("v.bodyContent", announcements[index].Description__c);
        component.set("v.partnerVideoId", announcements[index].PRM_Modal_Video_Id__c);
        component.set("v.announcementCreatedDate", announcements[index].CreatedDate);
        component.set("v.isModalOpen", true);
    },
   
    annoucementClickShowAll : function (component, event, helper) {
        component.set("v.restricted", false);
        helper.getAnnouncementsForCurrentPRMUser(component);      
    }
    
})