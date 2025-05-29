({
    handlePageChange : function(component, event, helper) {
        component.set("v.NoSignalManagementRecord",'');
        component.set("v.hasPermission",false);
        var pageRef = component.get("v.pageReference");
        component.set("v.url", window.location.origin);
        var state = pageRef.state;
        
        if(pageRef.type == 'standard__objectPage'){
            var base64Context = state.inContextOfRef;
            if (base64Context.startsWith("1\.")) {
                base64Context = base64Context.substring(2);
            }
            var addressableContext = JSON.parse(window.atob(base64Context));
            component.set("v.RecId", addressableContext.attributes.recordId);
            //component.set("v.parentProjRecId", addressableContext.attributes.recordId);            
            component.set("v.targetName",'Product');
            helper.checkPermissionForSDRunNew(component, event);
            helper.getAutoPopulatedFieldData(component, event);
            //helper.getsdRunFieldData(component, event);
        }
        if(pageRef.type == 'standard__recordPage'){
            var attributes = pageRef.attributes;
            var recordID = attributes.recordId;
            component.set("v.RecId", recordID);
            component.set("v.hasPermission", true);
            helper.checkPermissionForSDRunEdit(component, event);
            helper.getAutoPopulatedFieldDataEdit(component, event);
            helper.checkDeletePermission(component, event);
        }
    },
    
    doInit : function(component,event,helper){
        component.set("v.NoSignalManagementRecord",'');
        component.set("v.hasPermission",false);
        var pageRef = component.get("v.pageReference");
        component.set("v.url", window.location.origin);
        var state = pageRef.state;
        
        if(pageRef.type == 'standard__objectPage'){
            var base64Context = state.inContextOfRef;
            if (base64Context.startsWith("1\.")) {
                base64Context = base64Context.substring(2);
            }
            var addressableContext = JSON.parse(window.atob(base64Context));
            component.set("v.RecId", addressableContext.attributes.recordId);
            component.set("v.targetName",'Product');
            helper.checkPermissionForSDRunNew(component, event);
            helper.getAutoPopulatedFieldData(component, event);
            //helper.getsdRunFieldData(component, event);
        }
        if(pageRef.type == 'standard__recordPage'){
            var attributes = pageRef.attributes;
            var recordID = attributes.recordId;
            component.set("v.RecId", recordID);
            component.set("v.hasPermission", true);
            helper.checkPermissionForSDRunEdit(component, event);
            helper.getAutoPopulatedFieldDataEdit(component, event);
            helper.checkDeletePermission(component, event);
        }
    },
    
	// New
    handleOnLoad : function(component, event, helper) {
        component.set("v.Spinner", false);  
    },
    handleOnSubmit : function(component, event, helper) {
        event.preventDefault(); //Prevent default submit
        component.set("v.Spinner", true);
        component.set("v.isButtonActive", true);
        var eventFields = event.getParam("fields"); //get the fields
        eventFields["Project__c"] = component.get("v.RecId");
        //eventFields["Name"] = component.get("v.sdrunid");           
        eventFields["Product__c"] = component.get("v.targetId");
        var sdRunOutcomeFields = eventFields["SD_Run_Outcome__c"];
        if(sdRunOutcomeFields){
            var arrayField = sdRunOutcomeFields.split(';');
            if((arrayField.includes('Potential Signal') || arrayField.includes('Potential Emerging Safety Issue')) &&
              (!arrayField.includes('No Action') && !arrayField.includes('Other (specify)'))){
                alert('A valid signal detection has been selected, make sure a signal is created for this.');
            }
        }
        
        
        component.find('sdForm').submit(eventFields); //Submit Form
        var action = component.get('c.showSpinner');
        $A.enqueueAction(action);
        
    },
    handleOnSuccess : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
        component.set("v.Spinner", false);
        var relatedListEvent = $A.get("e.force:navigateToRelatedList");
        relatedListEvent.setParams({
            "relatedListId": "SD_Runs__r",
            "parentRecordId": component.get("v.RecId")
        });
        relatedListEvent.fire();
        
        /*
        var payload = event.getParams().response;
        var navService = component.find("navService");
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                "recordId": payload.id,
                "objectApiName": "SD_Runs__c",
                "actionName": "view"
            }
        }
        event.preventDefault();
        navService.navigate(pageReference);
        */
    },
    handleOnError : function(component, event, helper) {
        component.set("v.Spinner", false);
        component.set("v.isButtonActive", false);
    },
    handleOnCancel : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
        event.preventDefault();
        var relatedListEvent = $A.get("e.force:navigateToRelatedList");
        relatedListEvent.setParams({
            "relatedListId": "SD_Runs__r",
            "parentRecordId": component.get("v.RecId")
        });
        relatedListEvent.fire();
       /*
       var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.RecId"),
            "slideDevName": "related"	        
        });	        
        navEvt.fire(); 
        */
    },
    
    ////////////////////////////////////////////////////////////////////////
    
    // edit
    
    editRecord : function(component, event, helper) {        
        component.set("v.targetName",'Product');
        helper.showHide(component);
    },
    handleSuccess : function(component, event, helper) {
      $A.get('e.force:refreshView').fire();
      var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			"title": "Success!",
			"message": "Record updated successfully.",
			"type": "success"
		});
		toastEvent.fire();
        helper.showHide(component);
    },
    handleCancel : function(component, event, helper) {
        helper.showHide(component);
        event.preventDefault();
    },
    
    
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    
    backToProject : function(component, event, helper) {
        helper.getProjectIdForSDRunEdit(component, event);
    },
    
    handleOnEditSubmit : function(component, event, helper) {
        event.preventDefault(); //Prevent default submit
        component.set("v.Spinner", true);
        var eventFields = event.getParam("fields"); //get the fields
        eventFields["Product__c"] = component.get("v.targetId");
        var sdRunOutcomeFields = eventFields["SD_Run_Outcome__c"];
		if(sdRunOutcomeFields){
            var arrayField = sdRunOutcomeFields.split(';');
            if((arrayField.includes('Potential Signal') || arrayField.includes('Potential Emerging Safety Issue')) &&
              (!arrayField.includes('No Action') && !arrayField.includes('Other (specify)'))){
                alert('A valid signal detection has been selected, make sure a signal is created for this.');
            }
        }
        
        component.find('editForm').submit(eventFields); //Submit Form
        var action = component.get('c.showSpinner');
        $A.enqueueAction(action);
        
    },
    
    handleNewLastSDRunCeckbox: function(component, event, helper){
       var result = component.find("newLastSdRun").get("v.value");
        if(result !== null){
            if(!result){
                component.set("v.isOpen", true);
            }
        }
    },
    handleEditLastSDRunCeckbox: function(component, event, helper){
       var result = component.find("editLastSdRun").get("v.value");
        if(result !== null){
            if(!result){
                component.set("v.isOpen", true);
            }
        }
    },
    handleChange : function(component,event,helper) {
        var result;
        var optionSelected = component.get("v.selectedValue");
        if(optionSelected === "Yes"){
            component.set("v.isOpen", false);
            component.set("v.selectedValue",null);
            }else{
            component.set("v.isOpen", false);
                if(component.find("editProjId")){
                    result = component.find("editProjId").get("v.value");
                } else{
                    result = component.get("v.RecId");
                }
            $A.get('e.force:refreshView').fire();
            event.preventDefault();
            var relatedListEvent = $A.get("e.force:navigateToRelatedList");
            relatedListEvent.setParams({
                "relatedListId": "SD_Runs__r",
                "parentRecordId": result
            });
            relatedListEvent.fire();
        }
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
        component.set("v.targetId",target);
        component.set("v.targetName",targetName);
        component.set("v.isTargetModelOpen", false);
    },
    openProductModelInEditMode: function(component, event, helper){
        helper.getTargetsInEditMode(component, event);
        component.set("v.isTargetModelOpen", true);
    },
    createNewSignal: function(component, event, helper){
        event.preventDefault();
        var fieldName = component.find('editNm');
        if(!Array.isArray(fieldName)){
            
        if(component.find('editNm')){
            var associatedSdRunId = component.find('editNm').get("v.value");
            var abc = associatedSdRunId.match(new RegExp("blank\">" + "(.*)" + "<\/a>"));
            var abc2 = abc[1].substring(
    		abc[1].lastIndexOf(">") + 1
			);
            component.set("v.sdRunNameAssociatedWithSig",abc2);
        }
        component.set("v.isRltdTOSig", true);

        }        
    },
    viewRltdSignal: function(component, event, helper){
        event.preventDefault();
        var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
              "url": "/lightning/r/"+component.get("v.RecId")+"/related/Signals__r/view"
            });
            urlEvent.fire();
        	$A.get('e.force:refreshView').fire();
    },
    showAuditLogs: function(component, event, helper) {
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
              "url": "/lightning/n/Audit_Logs?c__recordId="+component.get("v.RecId")
            });
            urlEvent.fire();
        	$A.get('e.force:refreshView').fire();
	},
    onChangeCreateNewSignal:  function(component, event, helper){
        event.preventDefault();
        var optionSelected = component.get("v.selValue");
        if(optionSelected === "Yes"){
            var prodId ='';
            if(component.find('editProdId')){
                prodId = component.find('editProdId').get("v.value");
            }
            window.open(component.get("v.url") + '/lightning/o/Signal__c/new?c__Project=' + component.find("editProjId").get("v.value") +'&c__SDRunID='
                        + component.get("v.RecId") + '&c__Product='+prodId  + '&c__UniqueName='+component.get("v.sdRunNameAssociatedWithSig") ,"_self");
            }else{
            component.set("v.isOpen", false);
            window.open(component.get("v.url") + '/lightning/o/Signal__c/new?c__Project=' + component.find("editProjId").get("v.value") ,"_self");
            
        }
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
            var projectIdValue = component.get("v.sdRunObject").Project__c;
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": projectIdValue,
                "slideDevName": "related"	        
            });	        
            navEvt.fire();
            
        } else if(eventParams.changeType === "ERROR") {
            // there’s an error while loading, saving, or deleting the record
        }
    },
    cloneSdRun : function(component, event, helper) {
        event.preventDefault();
        component.set("v.cloneSdRunRec", true);
        helper.getFreqDtForSDRunClone(component, event);
        
    },
    closeCloneModal : function(component, event, helper) {
        component.set("v.cloneSdRunRec", false);
    },
    saveClonedRec : function(component, event, helper) {
        event.preventDefault();
        var eventFields = event.getParam("fields"); //get the fields
        eventFields["Project__c"] = component.get("v.clonedProjID");
        //component.set("v.clonedProjID",eventFields["Project__c"]);
        var fieldNames = Object.entries(eventFields);
        let map = new Map(fieldNames);
        var mapToSend = {}
        for (var key of map.keys()) {
            mapToSend[key] = map.get(key);
        }
        component.set("v.SdRecClonedMap",mapToSend);
        helper.cloneSdRunRec(component, event);
        
    },
    handleCloneLoad: function (component, event, helper) {
        
    }
})
