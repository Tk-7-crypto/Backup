({
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
    
    
    
    /*getsdRunFieldData: function(component, event, helper) {
        var action = component.get("c.sdRunFieldData");
        action.setParams({
            projectID : component.get("v.RecId"),
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.sdrunid", result);
            }
        });
        $A.enqueueAction(action);
    },*/
    
    checkPermissionForSDRunNew: function(component, event, helper) {
        var action = component.get("c.hasSDRunPermissionCreate");
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
    
    /*checkEditPermission: function(component, event, helper) {
        var action = component.get("c.hasEditPermission");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                console.log('has edit permission',response.getReturnValue());
                var result = response.getReturnValue();
                component.set("v.editPermission", result);
            }
        });
        $A.enqueueAction(action);
    },
    */
    
    checkPermissionForSDRunEdit: function(component, event, helper) {
        var action = component.get("c.hasSDRunPermissionView");
        action.setParams({
            sdRunID : component.get("v.RecId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                //component.set("v.hasPermission", result);
                component.set("v.editPermission", result);
            }
        });
        $A.enqueueAction(action);
    },
    
    getProjectIdForSDRunEdit: function(component, event, helper) {
        var action = component.get("c.sDRunProjectIDView");
        action.setParams({
            sdRunID : component.get("v.RecId")
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
    getAutoPopulatedFieldDataEdit: function(component, event, helper) {
        var action = component.get("c.sDRunProjectIDView");
        action.setParams({
            sdRunID : component.get("v.RecId")
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
                        var stateSecond = responseSecond.getState();
                        if (stateSecond === "SUCCESS"){
                            var resultSecond = responseSecond.getReturnValue();
                            if(resultSecond.serviceLineLead == null){
                                component.set("v.serviceLineLead", null);
                            }
                            else{
                                component.set("v.serviceLineLead", resultSecond.serviceLineLead);
                            }
                        }
                        else if(stateSecond === "ERROR")
                        { 
                            var errors = response.getError();
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
        var result = component.find("editProjId").get("v.value");
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
            sdRunID : component.get("v.RecId")
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
    
    cloneSdRunRec: function(component, event, helper) {
        var action = component.get("c.cloneSDRec");
        console.log('component.get("v.SdRecClonedMap")',component.get("v.SdRecClonedMap"));
        action.setParams({
            sdRunID : component.get("v.RecId"),
            cloneValsMap : component.get("v.SdRecClonedMap")
        });
        //var result = component.find("v.cloneeditProjId").get("v.value");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                console.log('Cloned successfully');
                component.set("v.cloneSdRunRec", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Record cloned successfully.",
                    "type": "success"
                });
				toastEvent.fire();
                var result = component.get("v.clonedProjID");
                window.open('/lightning/r/SD_Runs__c/' + result +'/related/SD_Runs__r/view',"_self");
            }else if(state === "ERROR"){
                console.log('in err');
                if(action){
                    var errors = action.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.find('clonemsg').setError(errors[0].message);
                    }
                }
                }
                
            }
        });
        $A.enqueueAction(action);
    },
    getFreqDtForSDRunClone: function(component, event, helper) {
        var action = component.get("c.getFreqDtForSDRunClone");
        action.setParams({
            recId : component.get("v.RecId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                console.log('resiuoiui',result);
                component.set("v.freqToClone", result.Frequency);
                component.set("v.rvwEndDtToClone",result.ReviewEndDate);
                component.set("v.clonedAccID", result.Account);
                component.set("v.clonedProjectID", result.ProjectCd);
                component.set("v.clonedProdID", result.Product);
                component.set("v.clonedProjID",result.Project);
                var recFreq = component.get("v.freqToClone");
        		var recEndDate = component.get("v.rvwEndDtToClone");
        
                if(recFreq != null && recEndDate != null){
                    
                    var clonedStartdate = new Date(recEndDate);
                    var clonedEnddate = new Date(recEndDate);
                    var clonedSDRunDueDt = new Date(recEndDate);
                    console.log('Inside date loop',recEndDate);
                    //dateValidation.setDate(dateValidation.getDate() + 30);
                    if(recFreq == 'Weekly'){
                        clonedStartdate.setDate(clonedStartdate.getDate() + 1);
                        clonedEnddate.setDate(clonedEnddate.getDate() + 7);
                        clonedSDRunDueDt.setDate(clonedSDRunDueDt.getDate() + 7 + 30);
                    } else if(recFreq == 'Bi-Weekly'){
                        clonedStartdate.setDate(clonedStartdate.getDate() + 1);
                        clonedEnddate.setDate(clonedEnddate.getDate() + 14);
                        clonedSDRunDueDt.setDate(clonedSDRunDueDt.getDate() + 14 + 30);
                    } else if(recFreq == 'Monthly'){
                        clonedStartdate.setDate(clonedStartdate.getDate() + 1);
                        clonedEnddate.setDate(clonedEnddate.getDate() + 30);
                        clonedSDRunDueDt.setDate(clonedSDRunDueDt.getDate() + 30 + 30);
                    } else if(recFreq == 'Quarterly'){
                        console.log('Inside quarterly');
                        clonedStartdate.setDate(clonedStartdate.getDate() + 1);
                        clonedEnddate.setDate(clonedEnddate.getDate() + 90);
                        clonedSDRunDueDt.setDate(clonedSDRunDueDt.getDate() + 90 + 30);
                        console.log('Inside quarterly',clonedEnddate);
                    } else if(recFreq == 'Bi-Monthly'){
                        clonedStartdate.setDate(clonedStartdate.getDate() + 1);
                        clonedEnddate.setDate(clonedEnddate.getDate() + 60);
                        clonedSDRunDueDt.setDate(clonedSDRunDueDt.getDate() + 60 + 30);
                    } else if(recFreq == 'Six-Monthly'){
                        clonedStartdate.setDate(clonedStartdate.getDate() + 1);
                        clonedEnddate.setDate(clonedEnddate.getDate() + 180);
                        clonedSDRunDueDt.setDate(clonedSDRunDueDt.getDate() + 180 + 30);
                    } else if(recFreq == 'Yearly'){
                        clonedStartdate.setDate(clonedStartdate.getDate() + 1);
                        clonedEnddate.setDate(clonedEnddate.getDate() + 365);
                        clonedSDRunDueDt.setDate(clonedSDRunDueDt.getDate() + 365 + 30);
                    } 
                    //var status = 'Not Yet Started';
                    component.set("v.rvwEndDtCloned",clonedEnddate.toISOString());
                    component.set("v.rvwStartDtCloned",clonedStartdate.toISOString());
                    component.set("v.clonedSDRunDueDt", clonedSDRunDueDt.toISOString());
                    
                    if(recFreq == 'Ad-Hoc'){
                        component.set("v.rvwEndDtCloned",null);
                        component.set("v.rvwStartDtCloned",null);
                        component.set("v.clonedSDRunDueDt", null);
                    } 
        		}
                var status = 'Not Yet Started';
                component.set("v.statusCloned", status);
            }
        });
        $A.enqueueAction(action);
    }
})
