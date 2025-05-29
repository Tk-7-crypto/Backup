({   
    handlePageChange : function(component, event, helper) {
        var pageRef = component.get("v.pageReference");
        var state = pageRef.state;
        
        if(pageRef.type == 'standard__objectPage'){
            var base64Context = state.inContextOfRef;
            if (base64Context.startsWith("1\.")) {
                base64Context = base64Context.substring(2);	
                console.log('base64Context = '+base64Context);
            }
            var addressableContext = JSON.parse(window.atob(base64Context));
            component.set("v.RecId", addressableContext.attributes.recordId);
            component.set("v.targetName",'Product');
            helper.checkPermissionForSDRunNew(component, event);
            helper.autoPopulateFields(component, event);
        }
        if(pageRef.type == 'standard__recordPage'){
            var attributes = pageRef.attributes;
            var recordID = attributes.recordId;
            console.log(recordID);
            component.set("v.RecId", recordID);
            component.set("v.hasPermission", true);
            helper.checkPermissionForSDRunEdit(component, event);
            helper.checkDeletePermission(component,event);
        }
    },
  
    doInit : function(component,event,helper){
        var pageRef = component.get("v.pageReference");
        console.log(JSON.stringify(pageRef));
        var state = pageRef.state;
        
        console.log(pageRef.type);
        if(pageRef.type == 'standard__objectPage'){
            //console.log('state = '+JSON.stringify(state));
            var base64Context = state.inContextOfRef;
            //console.log('base64Context = '+base64Context);
            if (base64Context.startsWith("1\.")) {
                base64Context = base64Context.substring(2);	
                console.log('base64Context = '+base64Context);
            }
            var addressableContext = JSON.parse(window.atob(base64Context));
            console.log('addressableContext = '+JSON.stringify(addressableContext));
            component.set("v.RecId", addressableContext.attributes.recordId);
            component.set("v.targetName",'Product');
            helper.checkPermissionForSDRunNew(component, event);
            helper.autoPopulateFields(component, event);
        }
        if(pageRef.type == 'standard__recordPage'){
            var attributes = pageRef.attributes;
            var recordID = attributes.recordId;
            console.log(recordID);
            console.log('Init--');
            component.set("v.RecId", recordID);
            helper.checkPermissionForSDRunEdit(component, event);   
            helper.checkDeletePermission(component,event);         
        }
    },
    
	// New
    handleOnLoad : function(component, event, helper) {
        component.set("v.Spinner", false);  
    },
    handleOnSubmit : function(component, event, helper) {
        event.preventDefault(); 
        //component.set("v.Spinner", true);
        var eventFields = event.getParam("fields"); 
        eventFields["Project__c"] = component.get("v.RecId");
        eventFields["Product__c"] = component.get("v.targetId");
        component.find('sdForm').submit(eventFields);
        //var action = component.get('c.showSpinner');
        //$A.enqueueAction(action);
        console.log('On Submit !!');
    },
    handleOnSuccess : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
        component.set("v.Spinner", false);
        var relatedListEvent = $A.get("e.force:navigateToRelatedList");
        relatedListEvent.setParams({
            "relatedListId": "HA_Websites_Reviews__r",
            "parentRecordId": component.get("v.RecId")
        });
        relatedListEvent.fire();
    },
    handleOnError : function(component, event, helper) {
          
    },
    handleOnCancel : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
        event.preventDefault();
        var relatedListEvent = $A.get("e.force:navigateToRelatedList");
        relatedListEvent.setParams({
            "relatedListId": "HA_Websites_Reviews__r",
            "parentRecordId": component.get("v.RecId")
        });
        relatedListEvent.fire();
    },
    
    editRecord : function(component, event, helper) {
        component.set("v.targetName",'Product');
        helper.populateDateFields(component, event);
        helper.showHide(component);
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
    handleCancel : function(component, event, helper) {
        helper.showHide(component);
        event.preventDefault();
    },
    
    
    showSpinner: function(component, event, helper) {
        component.set("v.Spinner", true); 
    },
    
    backToProject : function(component, event, helper) {
        helper.getProjectIdForSDRunEdit(component, event);
    },
    
    handleOnChange : function(component, event, helper) {
        helper.populateDate(component, event);
    },
    handleProductChange : function(component, event, helper) {
        helper.populateCountries(component, event);
    },
    openProductModel: function(component, event, helper){
        helper.getTargetForProject(component, event);
        component.set("v.isOpen", true);
    },
    closeProductModel: function(component, event, helper) {
        component.set("v.isOpen", false);
    },
    addProduct: function(component, event, helper) {
        var target = event.getSource().get("v.value");
        var targetName = event.getSource().get("v.label");
        console.log('target: '+target);
        component.set("v.targetId",target);
        component.set("v.targetName",targetName);
        helper.populateCountries(component, event);
        component.set("v.isOpen", false);
    },
    openProductModelInEditMode: function(component, event, helper){
        helper.getTargetsInEditMode(component, event);
        component.set("v.isOpen", true);
    },
    showAuditLogs: function(component, event, helper) {
            var urlEvent = $A.get("e.force:navigateToURL");
            urlEvent.setParams({
              "url": "/lightning/n/Audit_Logs?c__recordId="+component.get("v.RecId")
            });
            urlEvent.fire();
        	$A.get('e.force:refreshView').fire();
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
            console.log(JSON.stringify(component.get("v.hawrObject")));
            var projectIdValue = component.get("v.hawrObject").Project__c;
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
