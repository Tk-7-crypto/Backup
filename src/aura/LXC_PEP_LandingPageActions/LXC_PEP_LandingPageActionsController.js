({
	gotoLMS : function(component, event, helper) {
        helper.gotoURL(component, component.get("v.learning_url"));
	},
    
    gotoResources : function(component, event, helper) {
        helper.gotoURL(component, component.get("v.resources_url"));
	},
    
    gotoFAQ : function(component, event, helper) {
        helper.gotoURL(component, component.get("v.faq_url"));
	},

    gotoAcc : function(component, event, helper) {
        helper.gotoURL(component, component.get("v.acc_url"));
    },
	
	gotoForums : function(component, event, helper) {
        helper.gotoURL(component, component.get("v.forums_url"));
    },

    createLead : function (component, event, helper) {
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Lead"
        });
        createRecordEvent.fire();
    },
    createCase : function (component, event, helper){
        helper.gotoURL(component, component.get("v.create_case_url"));
    }

})