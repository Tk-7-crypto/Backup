({
	handlePageChange : function(component, event, helper) {
		component.set("v.NoSignalManagementRecord",'');
        component.set("v.hasPermission",false);
        var pageRef = component.get("v.pageReference");
        component.set("v.url", window.location.origin);
        var state = pageRef.state;
        
        console.log(pageRef.type);
        if(pageRef.type == 'standard__objectPage'){
            if(state.inContextOfRef){
                var base64Context = state.inContextOfRef;
            if (base64Context.startsWith("1\.")) {
                base64Context = base64Context.substring(2);	
                console.log('base64Context = '+base64Context);
            }
            var addressableContext = JSON.parse(window.atob(base64Context));
            console.log('addressableContext = '+JSON.stringify(addressableContext));
            component.set("v.RecId", addressableContext.attributes.recordId);
            component.set("v.targetName",'Product');
            helper.checkPermissionForSignalsNew(component, event);
            helper.getAutoPopulatedFieldData(component, event);
            } else {
                console.log('Alt approach', state);
                component.set('v.isLinkedToSDRun',true);
                component.set("v.RecId",state.c__Project);
                component.set("v.rltdSDRunId",state.c__SDRunID);
                //component.set("v.targetName",'Product');
            	helper.checkPermissionForSignalsNew(component, event);
            	helper.getAutoPopulatedFieldData(component, event);
            }
            /*var base64Context = state.inContextOfRef;
            if (base64Context.startsWith("1\.")) {
                base64Context = base64Context.substring(2);	
                console.log('base64Context = '+base64Context);
            }
            var addressableContext = JSON.parse(window.atob(base64Context));
            console.log('addressableContext = '+JSON.stringify(addressableContext));
            component.set("v.RecId", addressableContext.attributes.recordId);
            component.set("v.targetName",'Product');
            helper.checkPermissionForSignalsNew(component, event);
            helper.getAutoPopulatedFieldData(component, event);*/
        }
        if(pageRef.type == 'standard__recordPage'){
            var attributes = pageRef.attributes;
            var recordID = attributes.recordId;
            console.log(recordID);
            component.set("v.RecId", recordID);
            component.set("v.hasPermission", true);
            helper.checkPermissionForSignalsEdit(component, event);
            helper.getAutoPopulatedFieldDataEdit(component, event); 
            helper.checkDeletePermission(component,event);         
        }
        /*if(pageRef.type == 'standard__objectPage'){
            var state = pageRef.state;
            console.log('Alt approach', state);
        }*/
	},
        
    doInit : function(component,event,helper){
        component.set("v.NoSignalManagementRecord",'');
        component.set("v.hasPermission",false);
        var pageRef = component.get("v.pageReference");
        component.set("v.url", window.location.origin);
        console.log('window.location.origin',window.location.origin);
        var state = pageRef.state;
        
        console.log(pageRef.type);
        if(pageRef.type == 'standard__objectPage'){
            if(state.inContextOfRef){
                var base64Context = state.inContextOfRef;
            if (base64Context.startsWith("1\.")) {
                base64Context = base64Context.substring(2);	
                console.log('base64Context = '+base64Context);
            }
            var addressableContext = JSON.parse(window.atob(base64Context));
            console.log('addressableContext = '+JSON.stringify(addressableContext));
            component.set("v.RecId", addressableContext.attributes.recordId);
            component.set("v.targetName",'Product');
            helper.checkPermissionForSignalsNew(component, event);
            helper.getAutoPopulatedFieldData(component, event);
            } else {
                var state = pageRef.state;
                console.log('Alt approach', state);
                component.set('v.isDirectedFromSDRun',true);
                if(state.c__SDRunID){                   
                    component.set("v.RecId",state.c__Project);
                    component.set("v.rltdSDRunId",state.c__SDRunID);
                    component.set("v.uniqueName",'   '+state.c__UniqueName);
                    component.set("v.rltdSDRunProduct",state.c__Product);
                    component.set("v.targetId",state.c__Product);
                    component.set('v.isProdFieldDisabled',true);
                }else{
                    component.set("v.RecId",state.c__Project);
                    component.set('v.isProdFieldDisabled',false);
                    component.set("v.targetName",'Product');
                }
                
            	helper.checkPermissionForSignalsNew(component, event);
            	helper.getAutoPopulatedFieldData(component, event);
            }
            /*var base64Context = state.inContextOfRef;
            if (base64Context.startsWith("1\.")) {
                base64Context = base64Context.substring(2);	
                console.log('base64Context = '+base64Context);
            }
            var addressableContext = JSON.parse(window.atob(base64Context));
            console.log('addressableContext = '+JSON.stringify(addressableContext));
            component.set("v.RecId", addressableContext.attributes.recordId);
            component.set("v.targetName",'Product');
            helper.checkPermissionForSignalsNew(component, event);
            helper.getAutoPopulatedFieldData(component, event);*/
        }
        if(pageRef.type == 'standard__recordPage'){
            var attributes = pageRef.attributes;
            var recordID = attributes.recordId;
            console.log(recordID);
            component.set("v.RecId", recordID);
            component.set("v.hasPermission", true);
            helper.checkPermissionForSignalsEdit(component, event);
            helper.getAutoPopulatedFieldDataEdit(component, event); 
            helper.checkDeletePermission(component,event);         
        }
    },
    
    handleChange : function(component,event,helper) {
        var optionSelected = component.get("v.selectedValue");
        if(optionSelected === "Yes"){
            window.open(component.get("v.url") + '/lightning/r/SD_Runs__c/' + component.get("v.RecId") +'/related/SD_Runs__r/view',"_self");
            }else{
            console.log('No selected');
            component.set("v.isOpen", false);
        }
    },
    // New
    handleOnLoad : function(component, event, helper) {
        component.set("v.Spinner", false); 
        if(component.get('v.isDirectedFromSDRun') == true){
            component.set("v.isOpen", false);
        } else {
            component.set("v.isOpen", true);
        }
        
    },
    // Edit
    handleOnEditLoad : function(component, event, helper) {
        var actionSignal = component.get("c.getSignalRecord");
       actionSignal.setParams({
             signalID   : component.get("v.recordId")
       });
       actionSignal.setCallback(this, function(response) {
           var state = response.getState();
           if (state === "SUCCESS"){
               var result = response.getReturnValue();
               component.set("v.validationDate", result.Validation_Date__c);
               component.set("v.evalDueDate", result.Evaluation_Due_Date__c);
               component.set("v.dateClosedEvaluation", result.Date_Closed_Evaluation_Completed__c);
               component.set("v.signalPrioritizationCategory", result.Signal_Prioritization_Category__c);
               let signalPriorCategory = result.Signal_Prioritization_Category__c;
               if(signalPriorCategory){
                   if(signalPriorCategory == 'Low' || signalPriorCategory == 'Medium' || signalPriorCategory == 'High'){
                       component.set("v.evaluationDueDate",true); 
                   }else{
                       component.set("v.evaluationDueDate",false); 
                   } 
               }
           }
       });
       $A.enqueueAction(actionSignal);
        
        if(component.find('editSdRunId')){
            console.log('In edit load if part');
            var sigSDIDVal = component.find('editSdRunId').get('v.value');
            if(sigSDIDVal){
                component.set('v.isEditFormProdFieldDisabled',true);
                console.log('Prod field disabled');
            } else if(component.find('editSignalStatus')){
            	var sigStatusVal = component.find('editSignalStatus').get('v.value');
                if(sigStatusVal === 'Closed'){
                    component.set('v.isEditFormProdFieldDisabled',true);
                }else{
                    component.set('v.isEditFormProdFieldDisabled',false);
                }
        }
        }
        
    },
    
    handleOnSubmit : function(component, event, helper) {
        event.preventDefault(); 
        //component.set("v.Spinner", true);
        var eventFields = event.getParam("fields"); 
        eventFields["Project__c"] = component.get("v.RecId");        
        eventFields["Product__c"] = component.get("v.targetId");
        component.find('signalForm').submit(eventFields);
        //var action = component.get('c.showSpinner');
        //$A.enqueueAction(action);
        console.log('On Submit !!');
    },
    handleOnSuccess : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
        component.set("v.Spinner", false);
        var payload = event.getParams().response;
        console.log(payload.id);
        
        var relatedListEvent = $A.get("e.force:navigateToRelatedList");
        relatedListEvent.setParams({
            "relatedListId": "Signals__r",
            "parentRecordId": component.get("v.RecId")
        });
        relatedListEvent.fire();
        console.log('On Success !!'); 
    },
    handleOnError : function(component, event, helper) {
        component.set("v.Spinner", false);
    },
    handleOnCancel : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
        event.preventDefault();
        var relatedListEvent = $A.get("e.force:navigateToRelatedList");
        relatedListEvent.setParams({
            "relatedListId": "Signals__r",
            "parentRecordId": component.get("v.RecId")
        });
        relatedListEvent.fire();
    },
    
    handleEditSubmit : function(component, event, helper) {
        var eventFields = event.getParam("fields");
        eventFields["Product__c"] = component.get("v.targetId");
        var scrollOptions = {
            left: 0,
            top: 0,
            behavior: 'smooth'
        }
        window.scrollTo(scrollOptions);
		console.log('handleEditSubmit');        
    },
    handleSuccess : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": "Record updated successfully !",
            "type": "success"
        });
        toastEvent.fire();
        helper.showHide(component);
    },
    editRecord : function(component, event, helper) {
        component.set("v.targetName",'Product');
        helper.showHide(component);
    },
    backToProject : function(component, event, helper) {
        helper.getProjectIdForSignalEdit(component, event);
    },
    handleCancel : function(component, event, helper) {
        helper.showHide(component);
        event.preventDefault();
    },
    showSpinner: function(component, event, helper) {
        component.set("v.Spinner", true); 
    },
    openProductModel: function(component, event, helper){
        helper.getTargetForProject(component, event);
        component.set("v.isTargetModelOpen", true);
    },
    closeProductModel: function(component, event, helper) {
        component.set("v.isTargetModelOpen", false);
    },
    addProduct: function(component, event, helper) {
        var target = event.getSource().get("v.value");
        var targetName = event.getSource().get("v.label");
        console.log('target: '+target);
        component.set("v.targetId",target);
        component.set("v.targetName",targetName);
        component.set("v.isTargetModelOpen", false);
    },
    openProductModelInEditMode: function(component, event, helper){
        helper.getTargetsInEditMode(component, event);
        component.set("v.isTargetModelOpen", true);
    },
    dateDetectedChanged: function(component, event, helper){
        var date1 = component.get("v.dateDetectedNew")
        var dateValidation = new Date(date1);
        dateValidation.setDate(dateValidation.getDate() + 30);
        component.set("v.validationDueDateNew",dateValidation.toISOString());
    },
    editDateDetectedChanged: function(component, event, helper){
        if(component.find("editDtDetected")){
            var date2 = component.find("editDtDetected").get("v.value"); 
            var dateValidation = new Date(date2);
            dateValidation.setDate(dateValidation.getDate() + 30);
            if(component.find("editValidnDueDt")){
                component.find("editValidnDueDt").set("v.value",dateValidation.toISOString());
            }
        }
    },
    showAuditLogs: function(component, event, helper) {
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
              "url": "/lightning/n/Audit_Logs?c__recordId="+component.get("v.RecId")
            });
            urlEvent.fire();
        	$A.get('e.force:refreshView').fire();
	},
    handleOnChangeCategory : function(component, event, helper) {
        helper.populateEvaluationDueDate(component, event);
    },
    handleValidationOutcomeChange: function(component, event, helper) {
        helper.populateSignalStatus(component, event);
    },
    update : function (component, event, helper) {
            // Get the new location token from the event if needed
             window.location.reload();
	},
    confirmDeletion: function(component,event, helper) {
        component.set("v.isDeletionConfirmationOpen",true);
    },
    closeModel: function(component,event,helper){
        component.set("v.isDeletionConfirmationOpen",false);
    },
    handleDeleteRecord: function(component, event, helper) {        
        component.find("recordHandler").deleteRecord($A.getCallback(function(deleteResult) {
            // NOTE: If you want a specific behavior(an action or UI behavior) when this action is successful 
            // then handle that in a callback (generic logic when record is changed should be handled in recordUpdated event handler)
            if (deleteResult.state === "SUCCESS" || deleteResult.state === "DRAFT") {
                // record is deleted
                console.log("Record is deleted.");
            } else if (deleteResult.state === "INCOMPLETE") {
                console.log("User is offline, device doesn't support drafts.");
            } else if (deleteResult.state === "ERROR") {
                console.log('Problem deleting record, error: ' + JSON.stringify(deleteResult.error));
            } else {
                console.log('Unknown problem, state: ' + deleteResult.state + ', error: ' + JSON.stringify(deleteResult.error));
            }
        }));
    },

    /**
     * Control the component behavior here when record is changed (via any component)
     */
    handleRecordUpdated: function(component, event, helper) {
        var eventParams = event.getParams();
        if(eventParams.changeType === "CHANGED") {
           // record is changed
        } else if(eventParams.changeType === "LOADED") {
            // record is loaded in the cache
        } else if(eventParams.changeType === "REMOVED") {
            // record is deleted, show a toast UI message
            var resultsToast = $A.get("e.force:showToast");
            resultsToast.setParams({
                "title": "Deleted",
                "message": "The record was deleted."
            });
            resultsToast.fire();
            console.log(JSON.stringify(component.get("v.signalObject")));
            var projectIdValue = component.get("v.signalObject").Project__c;
            console.log('projectIdValue: '+projectIdValue);
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": projectIdValue,
                "slideDevName": "related"	        
            });	        
            navEvt.fire();
            
        } else if(eventParams.changeType === "ERROR") {
            // there’s an error while loading, saving, or deleting the record
        }
    }
})
