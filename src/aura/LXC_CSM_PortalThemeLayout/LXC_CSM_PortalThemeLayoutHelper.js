({
    getUserContact: function(component){
        var action = component.get("c.getUserContact");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var contact = response.getReturnValue()[0];
                if (contact){
                    component.set("v.contact", contact);
                    this.getMajorIncidents(component);
                    var portal_case_type = contact.Portal_Case_Type__c.split(';');
                    for (var i=1; i<6; i++){
                        if (component.get("v.menu"+i+"VisibleFor") != undefined){
                            if(component.get("v.menu"+i+"VisibleFor") === "All")component.set("v.menu"+i+"isVisible",true);
                            else if (component.get("v.menu"+i+"VisibleFor") ===  portal_case_type[0])component.set("v.menu"+i+"isVisible",true);
                            else component.set("v.menu"+i+".isVisible",false);
                        }
                    }
                }
            } else if(state === "ERROR") {
                console.log("LXC_CSM_PortalTemplateLayout] ERROR " + JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
    },

    getMajorIncidents: function(component){
        var action = component.get("c.getMajorIncidents");
        action.setParams({
            'accountId':  component.get("v.contact").AccountId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var majorIncident = response.getReturnValue()[0];
                if(majorIncident){
                    if(majorIncident.Status__c =="Resolved")component.set("v.alertTheme","slds-theme_success");
                    else component.set("v.alertTheme","slds-theme_error");
                }
                component.set("v.majorIncident",majorIncident);
            } else if(state === "ERROR") {
                console.log("LXC_CSM_PortalTemplateLayout] ERROR " + JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
    },
    
    getTPAAccess : function(component){
        var action = component.get("c.checkTPAPermissionSetsAssigned");
        action.setParams({
            'pmSetTPA':  component.get("v.tpaAppPermissionSets")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.isTPAAccess",response.getReturnValue());
            } else if(state === "ERROR") {
                console.log("LXC_CSM_PortalTemplateLayout] ERROR " + JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
    }

})