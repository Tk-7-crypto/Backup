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
            helper.checkPermissionForSDRunNew(component, event);
            helper.autoPopulateFields(component, event);
        }
        if(pageRef.type == 'standard__recordPage'){
            var attributes = pageRef.attributes;
            var recordID = attributes.recordId;
            console.log(recordID);
            component.set("v.RecId", recordID);
            component.set("v.hasPermission", true);
            helper.checkDeletePermission(component,event);
            helper.checkPermissionForSDRunEdit(component, event);
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
            helper.checkPermissionForSDRunNew(component, event);
            helper.autoPopulateFields(component, event);
            helper.populateTOIStatus(component,event);
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
        var eventFields = event.getParam("fields"); 
        //clone record for selected target records
        var targetIDArray = [];
        targetIDArray = component.get("v.targetIdList");
        if(targetIDArray.length>0){
            
            //add new TOI records using controller
            eventFields["Project__c"] = component.get("v.RecId");
            var fieldNames = Object.entries(eventFields);
            let map = new Map(fieldNames);
            var mapToSend = {}
            for (var key of map.keys()) {
                mapToSend[key] = map.get(key);
            }
            event.preventDefault();
            var action = component.get("c.createTOIRecord");
            action.setParams({
                productId: component.get("v.targetIdList"),
                cloneValsMap : mapToSend
            });
            action.setCallback(this, function(response) {            
                var state = response.getState();
                if (state === "SUCCESS"){
                    $A.get('e.force:refreshView').fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Record created successfully !",
                        "type": "success"
                    });
                    toastEvent.fire();  
                    var result = component.get("v.RecId");
                	window.open('/lightning/r/Topic_of_Interest__c/' + result +'/related/Topic_of_Interest__r/view',"_self");
                    }
                else if(state === "ERROR")
                { 
                    var errors = response.getError();
                    //console.log("Error message: " + JSON.stringify(errors)); 
                    //alert(JSON.stringify(errors));
                    console.log('Errors',JSON.stringify(errors));
                    console.log('Errors',errors[0].pageErrors[0].message);
                    if (errors[0] && errors[0].pageErrors[0]) {
                        component.find('createNotifMsg').setError(errors[0].pageErrors[0].message);
                    }
                }
                
            });
            $A.enqueueAction(action);
        }
        else{
            eventFields["Project__c"] = component.get("v.RecId");
            component.find('sdForm').submit(eventFields);
        }
        console.log('On Submit !!');
    },
    handleOnSuccess : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
        component.set("v.Spinner", false);
        var payload = event.getParams().response;
		console.log(payload.id);

        var relatedListEvent = $A.get("e.force:navigateToRelatedList");
        relatedListEvent.setParams({
            "relatedListId": "Topic_of_Interest__r",
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
            "relatedListId": "Topic_of_Interest__r",
            "parentRecordId": component.get("v.RecId")
        });
        relatedListEvent.fire();
    },
    
    editRecord : function(component, event, helper) {
        helper.populateTOIStatus(component,event);
        helper.showHide(component);
    },
    cloneRecord : function(component, event, helper) {
        helper.populateTOIStatus(component,event);
        //helper.showHide(component);
        component.set("v.targetNameLst",'');
        component.set("v.isCloneRecord", true);
        component.set("v.isCloneRecordButtonClicked", true);
        
    },
    handleEditSubmit : function(component, event, helper) {
       var eventFields = event.getParam("fields");
        if(component.get("v.isCloneRecordButtonClicked") == true){
            var fieldNames = Object.entries(eventFields);
            let map = new Map(fieldNames);
            var mapToSend = {}
            for (var key of map.keys()) {
                mapToSend[key] = map.get(key);
            }
            console.log('Objectentries',fieldNames);
        	component.set("v.clonedProjectIDVal",eventFields["Project__c"]);
            console.log('record clone',component.get("v.targetIdList"));
            event.preventDefault();
            console.log('products' ,component.get("v.editedProduct"));
            var action = component.get("c.cloneTOIRecord");
            action.setParams({
                toiId : component.get("v.RecId"),
                productId: component.get("v.targetIdList"),
                cloneValsMap : mapToSend
            });
            action.setCallback(this, function(response) {            
                var state = response.getState();
                if (state === "SUCCESS"){
                    $A.get('e.force:refreshView').fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Record updated successfully !",
                        "type": "success"
                    });
                    toastEvent.fire();  
                    var result = component.get("v.clonedProjectIDVal");
                	window.open('/lightning/r/Topic_of_Interest__c/' + result +'/related/Topic_of_Interest__r/view',"_self");
                }
                else if(state === "ERROR")
                { 
                    var errors = response.getError();
                    //console.log("Error message: " + JSON.stringify(errors)); 
                    //alert(JSON.stringify(errors));
                    console.log('Errors',JSON.stringify(errors));
                    console.log('Errors',errors[0].pageErrors[0].message);
                    if (errors[0] && errors[0].pageErrors[0]) {
                        component.find('clonedMsg').setError(errors[0].pageErrors[0].message);
                    }
                }
                
            });
            $A.enqueueAction(action);
            component.set("v.recordToBeCloned", false);
            //helper.getProjectIdForSDRunEdit(component, event);
        }
        else{
            event.preventDefault(); 
            component.set("v.Spinner", true);
            var selProd = '';
            selProd = component.get("v.editedProduct");
            if(selProd){
                eventFields["Product__c"] = selProd;
            }
            component.find('editForm').submit(eventFields);
            var scrollOptions = {
                left: 0,
                top: 0,
                behavior: 'smooth'
            }
            window.scrollTo(scrollOptions);
        }
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
        component.set("v.targetNameLst",'');
        component.set("v.recordToBeCloned", false);
        if(component.get("v.isCloneRecordButtonClicked") == true){
            component.set("v.isCloneRecord", false);
            component.set("v.isCloneRecordButtonClicked", false);
        }
        else{
            helper.showHide(component);
        }
        
        event.preventDefault();
    },    
    
    showSpinner: function(component, event, helper) {
        component.set("v.Spinner", true); 
    },
    
    backToProject : function(component, event, helper) {
        helper.getProjectIdForSDRunEdit(component, event);
    },
    
    handleOnChange : function(component, event, helper) {
        helper.populateTOIStatus(component,event);
    },
    handleProductChange : function(component, event, helper) {
        helper.populateCountries(component, event);
    },
    openProductModel: function(component, event, helper){
        //on opening, set the array blank
        var targetIDArray = [];
        component.set("v.targetIdList", targetIDArray);
        component.set("v.targetNameLst",'');
        component.set("v.isOpen", true);
        
        if(component.get("v.isCloneRecordButtonClicked") == true){
            var action = component.get("c.haGetProjectId");
            action.setParams({
                toiId : component.get("v.RecId")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS"){
                    var result = response.getReturnValue();
                    var action = component.get("c.getTargetRecords");
                    action.setParams({ "projectID" : result });
                    action.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state === "SUCCESS") {
                            var resultis = response.getReturnValue();
                            component.set('v.targetList', resultis);
                            
                            // display selected products
            				var tgtIdNameMap = new Map();
            				resultis.forEach(function(item, index, array) {
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
            });
            $A.enqueueAction(action);
            //component.set("v.isCloneRecord", false);
        }
        else{
            helper.getTargetForProject(component, event);
        }
        
        
        
        
        
    },
    closeProductModel: function(component, event, helper) {
        var targetIDArray = [];
        component.set("v.targetIdList", targetIDArray);
        component.set("v.isOpen", false);
        if(component.get("v.isCloneRecordButtonClicked") == true){
            component.set("v.isCloneRecord", true);
        }
    },
    addProduct: function(component, event, helper) {
        component.set("v.isOpen", false);
        if(component.get("v.isCloneRecordButtonClicked") == true){
            component.set("v.isCloneRecord", true);
        }
    },
    checkboxSelect: function(component, event, helper) {
        console.log(event.getSource().get('v.checked'));
        console.log(event.getSource().get('v.value'));
        
        var targetIDArray = [];
        targetIDArray = component.get("v.targetIdList");
        if(event.getSource().get('v.checked') == true){
            targetIDArray.push(event.getSource().get('v.value'));
            component.set("v.targetIdList", targetIDArray);
            console.log(component.get("v.targetIdList"));
        }
        if(event.getSource().get('v.checked') == false){
            var index = targetIDArray.indexOf(event.getSource().get('v.value'));
            if (index > -1) {
                targetIDArray.splice(index, 1);
            }
            component.set("v.targetIdList", targetIDArray);
            console.log(component.get("v.targetIdList"));
        }
        
        //display sel prods
        	var tgtNmMap = component.get("v.tgtIdNameMap");
            var selProdList = [];
            var selProdString = '';
            targetIDArray.forEach(function(item, index, array) {
                selProdList.push(tgtNmMap.get(item));
							})
            selProdString = selProdList.join();
            component.set("v.targetNameLst",selProdString);
    },
            
    openEditProductModel: function(component, event, helper){
        helper.getTargetsInEditMode(component, event);
        component.set("v.isEditProduct", true);
    },
        
    closeEditProductModel: function(component, event, helper) {
        var existingProdVal = component.find('editProdId').get("v.value");
        component.set("v.editedProduct",existingProdVal);
        component.set("v.isEditProduct", false);
    },
    addEditProduct: function(component, event, helper) {
        component.set("v.isEditProduct", false);
    },
    editCheckboxSelect: function(component, event, helper) {
        var availableCheckboxes = component.find('rowSelectionCheckboxId');
        var resetCheckboxValue  = false;
        if (Array.isArray(availableCheckboxes)) {
            //If more than one checkbox available then individually resets each checkbox
            availableCheckboxes.forEach(function(checkbox) {
                checkbox.set('v.value', resetCheckboxValue);
            }); 
        } else {
            //if only one checkbox available then it will be unchecked
            availableCheckboxes.set('v.value', resetCheckboxValue);
        }
        //mark the current checkbox selection as checked
        event.getSource().set("v.value",true);
        var selectedProduct = event.getSource().get("v.text");
        component.set("v.editedProduct", selectedProduct);
        
        //to display selected products in list form
        var tgtNmMap = component.get("v.tgtIdNameMap");
        var selProd = tgtNmMap.get(selectedProduct);
        component.set("v.targetNameLst",selProd);
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
            console.log(JSON.stringify(component.get("v.toiObject")));
            var projectIdValue = component.get("v.toiObject").Project__c;
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
    },
    closeClone : function(component, event, helper) {
        component.set("v.isCloneRecord", false);
        component.set("v.isCloneRecordButtonClicked", false);
    },
})
