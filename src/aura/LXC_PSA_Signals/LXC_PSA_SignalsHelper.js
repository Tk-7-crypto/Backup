({
	helperMethod : function() {
		
	},
    showHide : function(component) {
        var editForm = component.find("editForm");
        $A.util.toggleClass(editForm, "slds-hide");
        var viewForm = component.find("viewForm");
		$A.util.toggleClass(viewForm, "slds-hide");
    },
    
    getAutoPopulatedFieldData: function(component, event, helper) {
        var action = component.get("c.autoPopulatedFieldData");
        action.setParams({
            projectID : component.get("v.RecId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                console.log(result);
                console.log(result.account);
                console.log(result.projectCode);
                component.set("v.account", result.account);
                component.set("v.projectCode", result.projectCode);
                component.set("v.serviceLineLead", result.serviceLineLead);
            }
            else if(state === "ERROR")
            { 
                var errors = response.getError();
                console.log("Error message: " + JSON.stringify(errors)); 
            }
       
        });
        $A.enqueueAction(action);
    },
    
    checkPermissionForSignalsNew: function(component, event, helper) {
        var action = component.get("c.hasSignalPermissionCreate");
        action.setParams({
            projectID : component.get("v.RecId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.hasPermission", result);
                if(result == false){
                    component.set("v.NoSignalManagementRecord", 'This is a Signal Management object and you do not have permissions or you are not on SM project to create the record.');
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    checkPermissionForSignalsEdit: function(component, event, helper) {
        var action = component.get("c.hasSignalPermissionView");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                console.log('edit permission signal',result);
                component.set("v.hasEditPermission", result);
            }
        });
        $A.enqueueAction(action);
    },
    
    getProjectIdForSignalEdit: function(component, event, helper) {
        var action = component.get("c.signalGetProjectId");
        action.setParams({
            signalId : component.get("v.RecId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                console.log('getProjectIdForSignalEdit',result);
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
    
    getAutoPopulatedFieldDataEdit: function(component, event, helper) {
        var action = component.get("c.signalGetProjectId");
        action.setParams({
            signalId : component.get("v.RecId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                
                var actionSecond = component.get("c.autoPopulatedFieldData");
                actionSecond.setParams({
                    projectID : result
                });
                actionSecond.setCallback(this, function(responseSecond) {
                    var statesecond = responseSecond.getState();
                    
                    if (statesecond === "SUCCESS"){
                        var resultsecond = responseSecond.getReturnValue();
                        if(resultsecond.serviceLineLead == null){
                            component.set("v.serviceLineLead", null);
                        }
                        else{
                           component.set("v.serviceLineLead", resultsecond.serviceLineLead);
                        }
                    }
                    else if(statesecond === "ERROR")
                    { 
                        var errors = responseSecond.getError();
                        console.log("Error message: " + JSON.stringify(errors)); 
                    }
               
                });
                $A.enqueueAction(actionSecond);
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
    populateEvaluationDueDate: function(component, event, helper) {
        var action = component.get("c.populateEvalDueDate");
        action.setParams({
            signalPriorCategory : component.get("v.signalPrioritizationCategory"),
            signalValidationDate : component.get("v.validationDate")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                if( result ){
                    component.set("v.evaluationDueDate",result.isReadable);
                    if(result.evalDate){
                        component.set("v.evalDueDate",result.evalDate);
                    }else{
                        component.set("v.evalDueDate",null);
                    }
                }
            }
        });
        $A.enqueueAction(action);
    },
    checkDeletePermission: function(component, event, helper) {
        var action = component.get("c.hasRDSAdminPermission");
        action.setParams({
            signalId : component.get("v.RecId")
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
    populateSignalStatus: function(component, event, helper) {
        var action = component.get("c.populateSignalStatusValue");
        action.setParams({
            dateClosedEvaluationValue : component.get("v.dateClosedEvaluation"),
            validationOutcomeValue : component.get("v.validationOutcome")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.signalStatus",result);
                console.log('updated signal status'+component.get("v.signalStatus"));
            }
        });
        $A.enqueueAction(action);
    }
})
