({
    showHide : function(component) {
        var editForm = component.find("editForm");
        $A.util.toggleClass(editForm, "slds-hide");
        var viewForm = component.find("viewForm");
		$A.util.toggleClass(viewForm, "slds-hide");
    },
    
    autoPopulateFields: function(component, event, helper) {
        var action = component.get("c.autoPopulateFields");
        action.setParams({
            projectId : component.get("v.RecId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                console.log(result);
                console.log('Account-->'+result.account);
                console.log('Project Code-->'+result.projectCode);
                component.set("v.account", result.account);
                component.set("v.projectCode", result.projectCode);
            }
            else if(state === "ERROR")
            { 
                var errors = response.getError();
                console.log("Error message: " + JSON.stringify(errors)); 
            }
       
        });
        $A.enqueueAction(action);
    },
    populateDateFields: function(component, event, helper) {
        var action = component.get("c.populatePublishDateFields");
        action.setParams({
            hrId : component.get("v.RecId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                console.log('Result Dates: '+result);
                component.set("v.datePublishedOnWebsite", result.datePublishedOnWebsiteResult);
                component.set("v.dueDate", result.dueDateResult);
            }
            else if(state === "ERROR")
            { 
                var errors = response.getError();
                console.log("Error message: " + JSON.stringify(errors)); 
            }
       
        });
        $A.enqueueAction(action);
    },
    
    
    checkPermissionForSDRunNew: function(component, event, helper) {
        var action = component.get("c.hasHAPermissionCreate");
        action.setParams({
            projectID : component.get("v.RecId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.hasPermission", result);
            }
        });
        $A.enqueueAction(action);
    },
    
    checkPermissionForSDRunEdit: function(component, event, helper) {
        var action = component.get("c.hasHAPermissionEdit");
        action.setParams({
            hawrId : component.get("v.RecId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.hasEditPermission", result);
            }
        });
        $A.enqueueAction(action);
    },
    
    getProjectIdForSDRunEdit: function(component, event, helper) {
        var action = component.get("c.haGetProjectId");
        action.setParams({
            hawrId : component.get("v.RecId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": result,
                    "slideDevName": "related"	        
                });	        
                navEvt.fire();
                
            }
        });
        $A.enqueueAction(action);
    },
    
    
    populateDate: function(component, event, helper) {
        var action = component.get("c.populateDate");
        action.setParams({
            dueDate : component.get("v.datePublishedOnWebsite")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                var data_in = component.get("v.datePublishedOnWebsite");
                var data_out = new Date(data_in);
                data_out.setDate(data_out.getDate() + 15);
                console.log('date '+data_out);
                component.set("v.dueDate",result);
                console.log('updated date'+component.get("v.dueDate"));
            }
        });
        $A.enqueueAction(action);
    },
    
    populateCountries: function(component, event, helper) {
        var action = component.get("c.populateCountries");
        console.log('target id: '+component.get("v.targetId"));
        console.log('record id: '+component.get("v.RecId"));
        var pId = ''+component.get("v.targetId");
        action.setParams({
            targetId : pId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.countries",result);
                console.log('countries'+component.get("v.countries"));
            }
            else if(state == "ERROR"){
                var errors = response.getError();                       
                console.log('Error: '+errors[0].message);
                           
           }
        });
        $A.enqueueAction(action);
    },
    getTargetForProject: function(component, event, helper) {
        var action = component.get("c.getTargetRecords");
        action.setParams({ "projectID" : component.get("v.RecId") });
        console.log('v.RecId- '+component.get("v.RecId"));
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.targetList', result);
            }
            else if (state === "ERROR") {
                console.log('Error :: ',response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    getTargetsInEditMode: function(component, event, helper) {
        var action = component.get("c.getTargetRecords");
        var result = component.find("editProjectId").get("v.value");
        action.setParams({ "projectID" : result });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.targetList', result);
            }
            else if (state === "ERROR") {
                console.log('Error :: ',response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    checkDeletePermission: function(component, event, helper) {
        var action = component.get("c.hasRDSAdminPermission");
        action.setParams({
            hrId : component.get("v.RecId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.hasDeletePermission", result);
            }
        });
        $A.enqueueAction(action);
    }
})
