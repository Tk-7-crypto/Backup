({
    getUserProfileId: function (component) {
        var action = component.get("c.getUserProfileId");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                if (response.getReturnValue() === "00e6A000001GAaPQAW"
                    || response.getReturnValue() === "00e6A000000u6z1QAA"
                    || response.getReturnValue() === "00e2K000000S5I3QAK"
                    || response.getReturnValue() === "00e2K000000S5I4QAK"
                    || response.getReturnValue() === "00e2K000000S5I5QAK"
                    || response.getReturnValue() === "00e2K000000S5I1QAK"
                )
                    component.set("v.canManaged", true);
            } else if (state === "ERROR") {
                var errors = response.getError();
            }
        });
        $A.enqueueAction(action);
    },

    getUserPermissionSets: function (component) {
        var action = component.get("c.getUserPermissionSets");
        action.setCallback(this, function (response) {
            var state = response.getState();
            
            if (state === "SUCCESS") {
                var permissionSets = response.getReturnValue();
                console.log(JSON.stringify(permissionSets));
                for (var i = 0; i < permissionSets.length; i++) {
                    var ps = permissionSets[i];
                    if (ps.Name === 'CSM_DATA_CREATE_Service_Record_Type_Fields_access') {
                        console.log('ok');
                        component.set("v.canManaged", true);
                        break; 
                    }
                }
                
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.error('Error in getUserPermissionSets:', errors);
            }
        });
        $A.enqueueAction(action);
    },
    

    getCSMNews: function (component) {
        component.set("v.isLoading", true);
        var action = component.get("c.getCSMNews");
        action.setParams({
            module: component.get("v.module"),
            type: component.get("v.type")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var allNews = response.getReturnValue();
                if (Object.keys(allNews).length < 1) {
                    component.set("v.noNews", true);
                } else {
                    var CSMNews;
                    for (var i = 0; i < Object.keys(allNews).length; i++) {
                        if (allNews[i].Mode__c == 'Published') {
                            CSMNews = allNews[i];
                            break;
                        }
                    }
                    if (CSMNews == undefined) CSMNews = allNews[0];
                    component.set("v.csmNewsObject", CSMNews);
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
            }
            component.set("v.isLoading", false);
        });
        $A.enqueueAction(action);
    },

    openModal: function (component, modalId) {
        $A.util.removeClass(component.find(modalId), "slds-fade-in-hide");
        $A.util.addClass(component.find(modalId), "slds-fade-in-open");
        $A.util.removeClass(component.find("backdrop"), "slds-backdrop--hide");
        $A.util.addClass(component.find("backdrop"), "slds-backdrop--open");

    },

    closeModal: function (component, modalId) {
        $A.util.addClass(component.find(modalId), "slds-fade-in-hide");
        $A.util.removeClass(component.find(modalId), "slds-fade-in-open");
        $A.util.addClass(component.find("backdrop"), "slds-backdrop--hide");
        $A.util.removeClass(component.find("backdrop"), "slds-backdrop--open");
    },

    navigateToHome: function (component, event, helper) {
        var urlEvent = $A.get('e.force:navigateToURL');
        urlEvent.setParams({
            "url": "/lightning/page/home"
        });
        urlEvent.fire();
    },
})