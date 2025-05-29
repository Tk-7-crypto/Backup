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
        var action = component.get("c.hasTOIPermissionEdit");
        action.setParams({
            toiId : component.get("v.RecId")
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
    checkDeletePermission: function(component, event, helper) {
        var action = component.get("c.hasRDSAdminPermission");
        action.setParams({
            toiId : component.get("v.RecId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.hasDeletePermission", result);
            }
        });
        $A.enqueueAction(action);
    },
    getProjectIdForSDRunEdit: function(component, event, helper) {
        var action = component.get("c.haGetProjectId");
        action.setParams({
            toiId : component.get("v.RecId")
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
    
    
    populateTOIStatus: function(component, event, helper) {
        var action = component.get("c.populateStatus");
        action.setParams({
            startedDate : component.get("v.dateStarted"),
            stoppedDate : component.get("v.dateStopped")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                console.log('new value: '+result);
                component.set("v.toiStatus",result);
            }
        });
        $A.enqueueAction(action);
    },
    getTargetForProject: function(component, event, helper) {
        var action = component.get("c.getTargetRecords");
        action.setParams({ "projectID" : component.get("v.RecId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.targetList', result);
                
                var tgtIdNameMap = new Map();
            	result.forEach(function(item, index, array) {
                       tgtIdNameMap.set(item.Id, item.Name);
							})
                component.set("v.tgtIdNameMap", tgtIdNameMap);
            }
            else if (state === "ERROR") {
                console.log('Error :: ',response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    getTargetsInEditMode: function(component, event, helper) {
        var action = component.get("c.getTargetRecords");
        var result = component.find("editProjId").get("v.value");
        action.setParams({ "projectID" : result });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.targetList', result);
                // display selected products
            	var tgtIdNameMap = new Map();
            	result.forEach(function(item, index, array) {
                       tgtIdNameMap.set(item.Id, item.Name);
						})
                component.set("v.tgtIdNameMap", tgtIdNameMap);
            }
            else if (state === "ERROR") {
                console.log('Error :: ',response.getError());
            }
        });
        $A.enqueueAction(action);
    }
})
