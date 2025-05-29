({
	handlePageChange : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
        component.set('v.NoRecord', '');
        component.set('v.NoSignalManagementRecord', ''); 
        component.set('v.hasEditAccess', false);
        component.set('v.isSignalManagement',false); 
        component.set('v.pssfStatus', '');
        component.set('v.versionPage',false); 
        
        
        var pageRef = component.get("v.pageReference");
        console.log(JSON.stringify(pageRef));
        console.log(JSON.stringify(pageRef.state));
        if(pageRef.type == 'standard__objectPage'){
            var state = pageRef.state;
            component.set("v.RecId", state.c__Project);
            helper.hasPSSFRecordOnProject(component,event);
            helper.hasEditPermission(component, event);
            helper.checkPermissionForVisibility(component, event);
            //helper.getVersionOfPFFS(component, event);
        }
        if(pageRef.type == 'standard__recordPage'){
            component.set('v.hasEditAccess', false);
            component.set('v.isSignalManagement', true);
            
            var action2 = component.get("c.getParentPssfIfChild");
            action2.setParams({ "pssfId" : pageRef.attributes.recordId });
            action2.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    component.set('v.parRecordId', result);
                    helper.fetchRelatedRecords(component, event);
            		helper.getProjectId(component,event);
                }
                else if (state === "ERROR") {
                    console.log('Error :: ',response.getError());
                }
            });
            $A.enqueueAction(action2);
            
            //component.set('v.parRecordId', pageRef.attributes.recordId);
            //helper.fetchRelatedRecords(component, event);
            //helper.getProjectId(component,event);
            component.set('v.versionPage',true);
        }
	}, 
    
    doInit : function(component, event, helper) {
        component.set('v.NoRecord', '');
        component.set('v.NoSignalManagementRecord', ''); 
        component.set('v.hasEditAccess', false);
        component.set('v.isSignalManagement',false);
        component.set('v.pssfStatus', '');
        component.set('v.versionPage',false); 
        
        var pageRef = component.get("v.pageReference");
        console.log(JSON.stringify(pageRef));
        console.log(JSON.stringify(pageRef.state));
        if(pageRef.type == 'standard__objectPage'){
            var state = pageRef.state;
            component.set("v.RecId", state.c__Project);
            helper.hasPSSFRecordOnProject(component,event);
            helper.hasEditPermission(component, event);
            helper.checkPermissionForVisibility(component, event);
            //helper.getVersionOfPFFS(component, event);
        }
        if(pageRef.type == 'standard__recordPage'){
            component.set('v.hasEditAccess', false);
            component.set('v.isSignalManagement', true);
            //helper.checkPSSFRecordId(component,event);
            console.log('shyam',JSON.stringify(pageRef));
            console.log('shyam',JSON.stringify(pageRef.state));
            
            
            var action2 = component.get("c.getParentPssfIfChild");
            action2.setParams({ "pssfId" : pageRef.attributes.recordId });
            action2.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    component.set('v.parRecordId', result);
                    helper.fetchRelatedRecords(component, event);
                    helper.getProjectId(component,event);
                    console.log(result);
                }
                else if (state === "ERROR") {
                    console.log('Error :: ',response.getError());
                }
            });
            $A.enqueueAction(action2);
            
            //component.set('v.parRecordId', pageRef.attributes.recordId);
            //console.log(pageRef.attributes.recordId);
            //helper.fetchRelatedRecords(component, event);
            //helper.getProjectId(component,event);
            component.set('v.versionPage',true); 
        }
    },
    // New
    handleOnLoad : function(component, event, helper) {
        component.set("v.Spinner", false);
        //component.set("v.pssfVersion", "Draft");
        helper.getAutoPopulatedFields(component, event);
		helper.fetchFocusFields(component, event);
    },
    
    handleOnSubmit : function(component, event, helper) {
        event.preventDefault(); //Prevent default submit
        var eventFields = event.getParam("fields"); //get the fields
        eventFields["Project_Name__c"] = component.get("v.RecId");
        eventFields["PSSF_Status__c"] = 'Draft';
        component.find('pssfForm').submit(eventFields); //Submit Form
    },
    handleOnSuccess : function(component, event, helper) {
        var payload = event.getParams().response;
        component.find("compSafeDbPSSFPar").set("v.value", payload.id);
        component.find("compSafeDbPSSFName").set("v.value", "Company Safety Database");
        component.find("compSafeDbPSSF_Status").set("v.value", 'Draft Child');
        component.find('compSafeDbForm').submit();
        component.find("clinTrialDbPSSFPar").set("v.value", payload.id);
        component.find("clinTrialDbPSSFName").set("v.value", "Clinical Trial Database");
        component.find("clinTrialDbPSSF_Status").set("v.value", 'Draft Child');
        component.find('clinTrialDbForm').submit();
        
        component.find("literaturePSSFPar").set("v.value", payload.id);
        component.find("literaturePSSFName").set("v.value", "Literature");
        component.find("literaturePSSF_Status").set("v.value", 'Draft Child');
        component.find('literatureForm').submit();
        
        component.find("healthAuthWebPSSFPar").set("v.value", payload.id);
        component.find("healthAuthWebPSSFName").set("v.value", "Health Authority Websites");
        component.find("healthAuthWebPSSF_Status").set("v.value",  'Draft Child');
        component.find('healthAuthWebForm').submit();
        
        component.find("eudravigPSSFPar").set("v.value", payload.id);
        component.find("eudravigPSSFName").set("v.value", "Eudravigilance");
        component.find("eudravigPSSF_Status").set("v.value",  'Draft Child');
        component.find('eudravigForm').submit();
        
        component.find("faersPSSFPar").set("v.value", payload.id);
        component.find("faersPSSFName").set("v.value", "FAERS");
        component.find("faersPSSF_Status").set("v.value",  'Draft Child');
        component.find('faersForm').submit();
        
        component.find("vaersPSSFPar").set("v.value", payload.id);
        component.find("vaersPSSFName").set("v.value", "VAERS");
        component.find("vaersPSSF_Status").set("v.value",  'Draft Child');
        component.find('vaersForm').submit();
        
        component.find("compRSAPSSFPar").set("v.value", payload.id);
        component.find("compRSAPSSFName").set("v.value", "Competitors RSI");
        component.find("compRSAPSSF_Status").set("v.value",  'Draft Child');
        component.find('compRSAForm').submit();
        
        component.find("others1PSSFPar").set("v.value", payload.id);
        component.find("others1PSSFName").set("v.value", "Others1");
        component.find("others1PSSF_Status").set("v.value", 'Draft Child');
        component.find('others1Form').submit();
        
        component.find("other2PSSFPar").set("v.value", payload.id);
        component.find("other2PSSFName").set("v.value", "Others2");
        component.find("other2PSSF_Status").set("v.value",  'Draft Child');
        component.find('other2Form').submit();
        
        component.find("others3PSSFPar").set("v.value", payload.id);
        component.find("others3PSSFName").set("v.value", "Others3");
        component.find("others3PSSF_Status").set("v.value", 'Draft Child');
        component.find('others3Form').submit();
        
        component.find("others4PSSFPar").set("v.value", payload.id);
        component.find("others4PSSFName").set("v.value", "Others4");
        component.find("others4PSSF_Status").set("v.value",  'Draft Child');
        component.find('others4Form').submit();
        
        var row = component.get("v.historyRow");
        console.log(row.length);
        if(row.length>0){
            component.find("History0parent").set("v.value", payload.id);
            component.find("History0Status").set("v.value",  'Draft Child');
            component.find("History0HCR").set("v.value",  true);
            component.find("History0Name").set("v.value",  'History Record 0');
            component.find('History0').submit();
        }
        if(row.length>1){
            component.find("History1parent").set("v.value", payload.id);
            component.find("History1Status").set("v.value",  'Draft Child');
            component.find("History1HCR").set("v.value",  true);
            component.find("History1Name").set("v.value",  'History Record 1');
            component.find('History1').submit();
        }
        if(row.length>2){
            component.find("History2parent").set("v.value", payload.id);
            component.find("History2Status").set("v.value",  'Draft Child');
            component.find("History2HCR").set("v.value",  true);
            component.find("History2Name").set("v.value",  'History Record 2');
            component.find('History2').submit();
        }
        if(row.length>3){
            component.find("History3parent").set("v.value", payload.id);
            component.find("History3Status").set("v.value",  'Draft Child');
            component.find("History3HCR").set("v.value",  true);
            component.find("History3Name").set("v.value",  'History Record 3');
            component.find('History3').submit();
        }
        if(row.length>4){
            component.find("History4parent").set("v.value", payload.id);
            component.find("History4Status").set("v.value",  'Draft Child');
            component.find("History4HCR").set("v.value",  true);
            component.find("History4Name").set("v.value",  'History Record 4');
            component.find('History4').submit();
        }
        if(row.length>5){
            component.find("History5parent").set("v.value", payload.id);
            component.find("History5Status").set("v.value",  'Draft Child');
            component.find("History5HCR").set("v.value",  true);
            component.find("History5Name").set("v.value",  'History Record 5');
            component.find('History5').submit();
        }
        if(row.length>6){
            component.find("History6parent").set("v.value", payload.id);
            component.find("History6Status").set("v.value",  'Draft Child');
            component.find("History6HCR").set("v.value",  true);
            component.find("History6Name").set("v.value",  'History Record 6');
            component.find('History6').submit();
        }
        if(row.length>7){
            component.find("History7parent").set("v.value", payload.id);
            component.find("History7Status").set("v.value",  'Draft Child');
            component.find("History7HCR").set("v.value",  true);
            component.find("History7Name").set("v.value",  'History Record 7');
            component.find('History7').submit();
        }
        if(row.length>8){
            component.find("History8parent").set("v.value", payload.id);
            component.find("History8Status").set("v.value",  'Draft Child');
            component.find("History8HCR").set("v.value",  true);
            component.find("History8Name").set("v.value",  'History Record 8');
            component.find('History8').submit();
        }
        if(row.length>9){
            component.find("History9parent").set("v.value", payload.id);
            component.find("History9Status").set("v.value",  'Draft Child');
            component.find("History9HCR").set("v.value",  true);
            component.find("History9Name").set("v.value",  'History Record 9');
            component.find('History9').submit();
        }
        if(row.length>10){
            component.find("History10parent").set("v.value", payload.id);
            component.find("History10Status").set("v.value",  'Draft Child');
            component.find("History10HCR").set("v.value",  true);
            component.find("History10Name").set("v.value",  'History Record 10');
            component.find('History10').submit();
        }
        if(row.length>11){
            component.find("History11parent").set("v.value", payload.id);
            component.find("History11Status").set("v.value",  'Draft Child');
            component.find("History11HCR").set("v.value",  true);
            component.find("History11Name").set("v.value",  'History Record 11');
            component.find('History11').submit();
        }
        if(row.length>12){
            component.find("History12parent").set("v.value", payload.id);
            component.find("History12Status").set("v.value",  'Draft Child');
            component.find("History12HCR").set("v.value",  true);
            component.find("History12Name").set("v.value",  'History Record 12');
            component.find('History12').submit();
        }
        if(row.length>13){
            component.find("History13parent").set("v.value", payload.id);
            component.find("History13Status").set("v.value",  'Draft Child');
            component.find("History13HCR").set("v.value",  true);
            component.find("History13Name").set("v.value",  'History Record 13');
            component.find('History13').submit();
        }
        if(row.length>14){
            component.find("History14parent").set("v.value", payload.id);
            component.find("History14Status").set("v.value",  'Draft Child');
            component.find("History14HCR").set("v.value",  true);
            component.find("History14Name").set("v.value",  'History Record 14');
            component.find('History14').submit();
        }
        if(row.length>15){
            component.find("History15parent").set("v.value", payload.id);
            component.find("History15Status").set("v.value",  'Draft Child');
            component.find("History15HCR").set("v.value",  true);
            component.find("History15Name").set("v.value",  'History Record 15');
            component.find('History15').submit();
        }
        
        
        var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			"title": "Success!",
			"message": "Record created successfully.",
			"type": "success"
		});
		toastEvent.fire();
        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.RecId"),
            "slideDevName": "related"	        
        });	        
        navEvt.fire();
    },
    handleOnError : function(component, event, helper) {
          
    },
    
    handleOnCancel : function(component, event, helper) {
        $A.get('e.force:refreshView').fire();
        event.preventDefault();
       var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.RecId")
        });	        
        navEvt.fire();
    },
    
    handleOnEvaluate : function(component, event, helper) {
    },
    handleOnCreateTOI : function(component, event, helper) {
    },
    
    handleOnEditSubmit : function(component, event, helper) {
        event.preventDefault();        
        component.find("pssfStatusField").set("v.value", 'Draft');
        component.find("editCompSafeDbPSSF_Status").set("v.value", 'Draft Child');
        component.find("editClinTrialDbPSSF_Status").set("v.value", 'Draft Child');
        component.find("editLiteraturePSSF_Status").set("v.value", 'Draft Child');
        component.find("editHealthAuthWebPSSF_Status").set("v.value", 'Draft Child');
        component.find("editEudravigPSSF_Status").set("v.value", 'Draft Child');
        component.find("editFaersPSSF_Status").set("v.value", 'Draft Child');
        component.find("editVaersPSSF_Status").set("v.value", 'Draft Child');
        component.find("editCompRSAPSSF_Status").set("v.value", 'Draft Child');
        component.find("editOthers1PSSF_Status").set("v.value", 'Draft Child');
        component.find("editOther2PSSF_Status").set("v.value", 'Draft Child');
        component.find("editOthers3PSSF_Status").set("v.value", 'Draft Child');
        component.find("editOthers4PSSF_Status").set("v.value", 'Draft Child');
        
        
        component.find('pssfEditForm').submit();
        
        /*component.find('compSafeDbEditForm').submit();
        component.find('clinTrialDbEditForm').submit();
        component.find('literatureEditForm').submit();
        component.find('healthAuthWebEditForm').submit();
        component.find('eudravigEditForm').submit();
        component.find('faersEditForm').submit();
        component.find('compRSAEditForm').submit();
        component.find('others1EditForm').submit();
        component.find('other2EditForm').submit();
        component.find('others3EditForm').submit();
        component.find('others4EditForm').submit();
        */
        
        /*
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.RecId"),
            "slideDevName": "related"	        
        });	        
        navEvt.fire();
        */
    },
    
    
    handleOnEditLoad : function(component, event, helper) {
        component.set("v.Spinner", false);
    },
    
    handleOnEditSuccess : function(component, event, helper) {
        var payload = event.getParams().response;
        console.log(payload);
        component.find('compSafeDbEditForm').submit();
        component.find('clinTrialDbEditForm').submit();
        component.find('literatureEditForm').submit();
        component.find('healthAuthWebEditForm').submit();
        component.find('eudravigEditForm').submit();
        component.find('faersEditForm').submit();
        component.find('vaersEditForm').submit();
        component.find('compRSAEditForm').submit();
        component.find('others1EditForm').submit();
        component.find('other2EditForm').submit();
        component.find('others3EditForm').submit();
        component.find('others4EditForm').submit();
        
        var row = component.get("v.historyRow");
        console.log(row.length);
        var History0CheckboxEditCheckCmp = component.find("History0CheckboxEdit");
        var History1CheckboxEditCheckCmp = component.find("History1CheckboxEdit");
        var History2CheckboxEditCheckCmp = component.find("History2CheckboxEdit");
        var History3CheckboxEditCheckCmp = component.find("History3CheckboxEdit");
        var History4CheckboxEditCheckCmp = component.find("History4CheckboxEdit");
        var History5CheckboxEditCheckCmp = component.find("History5CheckboxEdit");
        var History6CheckboxEditCheckCmp = component.find("History6CheckboxEdit");
        var History7CheckboxEditCheckCmp = component.find("History7CheckboxEdit");
        var History8CheckboxEditCheckCmp = component.find("History8CheckboxEdit");
        var History9CheckboxEditCheckCmp = component.find("History9CheckboxEdit");
        var History10CheckboxEditCheckCmp = component.find("History10CheckboxEdit");
        var History11CheckboxEditCheckCmp = component.find("History11CheckboxEdit");
        var History12CheckboxEditCheckCmp = component.find("History12CheckboxEdit");
        var History13CheckboxEditCheckCmp = component.find("History13CheckboxEdit");
        var History14CheckboxEditCheckCmp = component.find("History14CheckboxEdit");
        var History15CheckboxEditCheckCmp = component.find("History15CheckboxEdit");
                
        var deleteRowList = component.get("v.historyDeleteRow");
        var History0CheckboxEditFlag= deleteRowList.includes(History0CheckboxEditCheckCmp.get("v.value"));
        var History1CheckboxEditFlag= deleteRowList.includes(History1CheckboxEditCheckCmp.get("v.value"));
        var History2CheckboxEditFlag= deleteRowList.includes(History2CheckboxEditCheckCmp.get("v.value"));
        var History3CheckboxEditFlag= deleteRowList.includes(History3CheckboxEditCheckCmp.get("v.value"));
        var History4CheckboxEditFlag= deleteRowList.includes(History4CheckboxEditCheckCmp.get("v.value"));
        var History5CheckboxEditFlag= deleteRowList.includes(History5CheckboxEditCheckCmp.get("v.value"));
        var History6CheckboxEditFlag= deleteRowList.includes(History6CheckboxEditCheckCmp.get("v.value"));
        var History7CheckboxEditFlag= deleteRowList.includes(History7CheckboxEditCheckCmp.get("v.value"));
        var History8CheckboxEditFlag= deleteRowList.includes(History8CheckboxEditCheckCmp.get("v.value"));
        var History9CheckboxEditFlag= deleteRowList.includes(History9CheckboxEditCheckCmp.get("v.value"));
        var History10CheckboxEditFlag= deleteRowList.includes(History10CheckboxEditCheckCmp.get("v.value"));
        var History11CheckboxEditFlag= deleteRowList.includes(History11CheckboxEditCheckCmp.get("v.value"));
        var History12CheckboxEditFlag= deleteRowList.includes(History12CheckboxEditCheckCmp.get("v.value"));
        var History13CheckboxEditFlag= deleteRowList.includes(History13CheckboxEditCheckCmp.get("v.value"));
        var History14CheckboxEditFlag= deleteRowList.includes(History14CheckboxEditCheckCmp.get("v.value"));
        var History15CheckboxEditFlag= deleteRowList.includes(History15CheckboxEditCheckCmp.get("v.value"));
        
        if(row.length>0){
            if(component.get("v.History0RecordTypeEdit")){
                if(!History0CheckboxEditFlag){
                    component.find('History0EditForm').submit();
                }
            }
            else{
                component.find("History0parent").set("v.value", payload.id);
                component.find("History0Status").set("v.value",  'Draft Child');
                component.find("History0HCR").set("v.value",  true);
                component.find("History0Name").set("v.value",  'History Record 0');
                component.find('History0').submit();
            }
        }
        if(row.length>1){
            if(component.get("v.History1RecordTypeEdit")){
                if(!History1CheckboxEditFlag){
                component.find('History1EditForm').submit();
                }
            }
            else{
                component.find("History1parent").set("v.value", payload.id);
                component.find("History1Status").set("v.value",  'Draft Child');
                component.find("History1HCR").set("v.value",  true);
                component.find("History1Name").set("v.value",  'History Record 1');
                component.find('History1').submit();
            }
        }
        if(row.length>2){
            if(component.get("v.History2RecordTypeEdit")){
                if(!History2CheckboxEditFlag){
                component.find('History2EditForm').submit();
                }
            }
            else{
                component.find("History2parent").set("v.value", payload.id);
                component.find("History2Status").set("v.value",  'Draft Child');
                component.find("History2HCR").set("v.value",  true);
                component.find("History2Name").set("v.value",  'History Record 2');
                component.find('History2').submit();
            }
        }
        if(row.length>3){
            if(component.get("v.History3RecordTypeEdit")){
                if(!History3CheckboxEditFlag){
                component.find('History3EditForm').submit();
                }
            }
            else{
                component.find("History3parent").set("v.value", payload.id);
                component.find("History3Status").set("v.value",  'Draft Child');
                component.find("History3HCR").set("v.value",  true);
                component.find("History3Name").set("v.value",  'History Record 3');
                component.find('History3').submit();
            }
        }
        if(row.length>4){
            if(component.get("v.History4RecordTypeEdit")){
                if(!History4CheckboxEditFlag){
                component.find('History4EditForm').submit();
                }
            }
            else{
                component.find("History4parent").set("v.value", payload.id);
                component.find("History4Status").set("v.value",  'Draft Child');
                component.find("History4HCR").set("v.value",  true);
                component.find("History4Name").set("v.value",  'History Record 4');
                component.find('History4').submit();
            }
        }
        if(row.length>5){
            if(component.get("v.History5RecordTypeEdit")){
                if(!History5CheckboxEditFlag){
                component.find('History5EditForm').submit();
                }
            }
            else{
                component.find("History5parent").set("v.value", payload.id);
                component.find("History5Status").set("v.value",  'Draft Child');
                component.find("History5HCR").set("v.value",  true);
                component.find("History5Name").set("v.value",  'History Record 5');
                component.find('History5').submit();
            }
        }
        if(row.length>6){
            if(component.get("v.History6RecordTypeEdit")){
                if(!History6CheckboxEditFlag){
                component.find('History6EditForm').submit();
                }
            }
            else{
                component.find("History6parent").set("v.value", payload.id);
                component.find("History6Status").set("v.value",  'Draft Child');
                component.find("History6HCR").set("v.value",  true);
                component.find("History6Name").set("v.value",  'History Record 6');
                component.find('History6').submit();
            }
        }
        if(row.length>7){
            if(component.get("v.History7RecordTypeEdit")){
                if(!History7CheckboxEditFlag){
                component.find('History7EditForm').submit();
                }
            }
            else{
                component.find("History7parent").set("v.value", payload.id);
                component.find("History7Status").set("v.value",  'Draft Child');
                component.find("History7HCR").set("v.value",  true);
                component.find("History7Name").set("v.value",  'History Record 7');
                component.find('History7').submit();
            }
        }
        if(row.length>8){
            if(component.get("v.History8RecordTypeEdit")){
                if(!History8CheckboxEditFlag){
                component.find('History8EditForm').submit();
                }
            }
            else{
                component.find("History8parent").set("v.value", payload.id);
                component.find("History8Status").set("v.value",  'Draft Child');
                component.find("History8HCR").set("v.value",  true);
                component.find("History8Name").set("v.value",  'History Record 8');
                component.find('History8').submit();
            }
        }
        if(row.length>9){
            if(component.get("v.History9RecordTypeEdit")){
                if(!History9CheckboxEditFlag){
                component.find('History9EditForm').submit();
                }
            }
            else{
                component.find("History9parent").set("v.value", payload.id);
                component.find("History9Status").set("v.value",  'Draft Child');
                component.find("History9HCR").set("v.value",  true);
                component.find("History9Name").set("v.value",  'History Record 9');
                component.find('History9').submit();
            }
        }
        if(row.length>10){
            if(component.get("v.History10RecordTypeEdit")){
                if(!History10CheckboxEditFlag){
                component.find('History10EditForm').submit();
                }
            }
            else{
                component.find("History10parent").set("v.value", payload.id);
                component.find("History10Status").set("v.value",  'Draft Child');
                component.find("History10HCR").set("v.value",  true);
                component.find("History10Name").set("v.value",  'History Record 10');
                component.find('History10').submit();
            }
        }
        if(row.length>11){
            if(component.get("v.History11RecordTypeEdit")){
                if(!History11CheckboxEditFlag){
                component.find('History11EditForm').submit();
                }
            }
            else{
                component.find("History11parent").set("v.value", payload.id);
                component.find("History11Status").set("v.value",  'Draft Child');
                component.find("History11HCR").set("v.value",  true);
                component.find("History11Name").set("v.value",  'History Record 11');
                component.find('History11').submit();
            }
        }
        if(row.length>12){
            if(component.get("v.History12RecordTypeEdit")){
                if(!History12CheckboxEditFlag){
                component.find('History12EditForm').submit();
                }
            }
            else{
                component.find("History12parent").set("v.value", payload.id);
                component.find("History12Status").set("v.value",  'Draft Child');
                component.find("History12HCR").set("v.value",  true);
                component.find("History12Name").set("v.value",  'History Record 12');
                component.find('History12').submit();
            }
        }
        if(row.length>13){
            if(component.get("v.History13RecordTypeEdit")){
                if(!History13CheckboxEditFlag){
                component.find('History13EditForm').submit();
                }
            }
            else{
                component.find("History13parent").set("v.value", payload.id);
                component.find("History13Status").set("v.value",  'Draft Child');
                component.find("History13HCR").set("v.value",  true);
                component.find("History13Name").set("v.value",  'History Record 13');
                component.find('History13').submit();
            }
        }
        if(row.length>14){
            if(component.get("v.History14RecordTypeEdit")){
                if(!History14CheckboxEditFlag){
                component.find('History14EditForm').submit();
                }
            }
            else{
                component.find("History14parent").set("v.value", payload.id);
                component.find("History14Status").set("v.value",  'Draft Child');
                component.find("History14HCR").set("v.value",  true);
                component.find("History14Name").set("v.value",  'History Record 14');
                component.find('History14').submit();
            }
        }
        if(row.length>15){
            if(component.get("v.History15RecordTypeEdit")){
                if(!History15CheckboxEditFlag){
                component.find('History15EditForm').submit();
                }
            }
            else{
                component.find("History15parent").set("v.value", payload.id);
                component.find("History15Status").set("v.value",  'Draft Child');
                component.find("History15HCR").set("v.value",  true);
                component.find("History15Name").set("v.value",  'History Record 15');
                component.find('History15').submit();
            }
        }
        
        if(component.get("v.recordToDelete")){
            var action2 = component.get("c.deleteHistoryRecord");
            action2.setParams({ "recordToDeleteIDList" : component.get("v.historyDeleteRow"),
                               "pssfParentId" : component.get("v.parRecordId")});
            action2.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    console.log(result);
                }
            });
            $A.enqueueAction(action2);
        }        
        var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			"title": "Success!",
			"message": "Record updated successfully.",
			"type": "success"
		});
		toastEvent.fire();
        
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.RecId"),
            "slideDevName": "related"	        
        });	         
        navEvt.fire();
    },
    
    handleOnPublish: function(component, event, helper) {
        component.find("pssfStatusField").set("v.value", 'Published');
        component.find("editCompSafeDbPSSF_Status").set("v.value", 'Published Child');
        component.find("editClinTrialDbPSSF_Status").set("v.value", 'Published Child');
        component.find("editLiteraturePSSF_Status").set("v.value", 'Published Child');
        component.find("editHealthAuthWebPSSF_Status").set("v.value", 'Published Child');
        component.find("editEudravigPSSF_Status").set("v.value", 'Published Child');
        component.find("editFaersPSSF_Status").set("v.value", 'Published Child');
        component.find("editVaersPSSF_Status").set("v.value", 'Published Child');
        component.find("editCompRSAPSSF_Status").set("v.value", 'Published Child');
        component.find("editOthers1PSSF_Status").set("v.value", 'Published Child');
        component.find("editOther2PSSF_Status").set("v.value", 'Published Child');
        component.find("editOthers3PSSF_Status").set("v.value", 'Published Child');
        component.find("editOthers4PSSF_Status").set("v.value", 'Published Child');
        
        var row = component.get("v.historyRow");
        console.log(row.length);
        if(row.length>0){
            component.find("History0StatusEdit").set("v.value",  'Published Child');
        }
        if(row.length>1){
            component.find("History1StatusEdit").set("v.value",  'Published Child');
        }
        if(row.length>2){
            component.find("History2StatusEdit").set("v.value",  'Published Child');
        }
        if(row.length>3){
            component.find("History3StatusEdit").set("v.value",  'Published Child');
        }
        if(row.length>4){
            component.find("History4StatusEdit").set("v.value",  'Published Child');
        }
        if(row.length>5){
            component.find("History5StatusEdit").set("v.value",  'Published Child');
        }
        if(row.length>6){
            component.find("History6StatusEdit").set("v.value",  'Published Child');
        }
        if(row.length>7){
            component.find("History7StatusEdit").set("v.value",  'Published Child');
        }
        if(row.length>8){
            component.find("History8StatusEdit").set("v.value",  'Published Child');
        }
        if(row.length>9){
            component.find("History9StatusEdit").set("v.value",  'Published Child');
        }
        if(row.length>10){
            component.find("History10StatusEdit").set("v.value",  'Published Child');
        }
        if(row.length>11){
            component.find("History11StatusEdit").set("v.value",  'Published Child');
        }
        if(row.length>12){
            component.find("History12StatusEdit").set("v.value",  'Published Child');
        }
        if(row.length>13){
            component.find("History13StatusEdit").set("v.value",  'Published Child');
        }
        if(row.length>14){
            component.find("History14StatusEdit").set("v.value",  'Published Child');
        }
        if(row.length>15){
            component.find("History15StatusEdit").set("v.value",  'Published Child');
        }
        
        component.find('pssfEditForm').submit();
    },
    
    handleOnVersions: function(component, event, helper) {
        console.log('click on version');
        helper.getAllPSSFRecordForProject(component, event);
        helper.checkDeletePermission(component,event);         
        component.set("v.isOpen", true);
    },
    
    openVersion: function(component, event, helper){
        let targetId = event.target.dataset.targetId;
        console.log(targetId);
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": targetId,
            "slideDevName": "related",	
        });	         
        navEvt.fire();
    },
    
    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle" 
        if(component.get("v.isDeletionConfirmationOpen") == true) {
            component.set("v.isOpen", false);
            component.set("v.isDeletionConfirmationOpen", false);
        } 
        component.set("v.isOpen", false);
    },
    
    handleOnBack: function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": '/lightning/o/PSSF__c/new?c__Project=' + component.get('v.ProjectIdVersion')
        })
        urlEvent.fire();
    },
    
    handleHistoryOfChangesRow: function(component, event, helper) {
        component.set("v.isPublishEnabled", false);
        var row = component.get("v.historyRow");
        console.log(row);
        if(row.length < 17){
            row.push(row.length + 1);
            component.set("v.historyRow",row);
        }
    },
    
    handleOnDownload : function(component, event, helper){
        component.set("v.vfpageurl", '/apex/VFP_PSA_PSSF_PDF?pssfParent=' + component.get("v.parRecordId"));
        
        component.set("v.isOpenPDF", true);
        
    },
    handleOnDownloadWord : function(component, event, helper){
        component.set("v.vfpageurl", '/apex/VFP_PSA_PSSF_WORD?pssfParent=' + component.get("v.parRecordId"));
        component.set("v.isOpenPDF", true);
    },
    closePDFModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.isOpenPDF", false);
    },
    checkboxSelect: function(component, event, helper) {
        console.log(event.getSource().get('v.checked'));
        console.log(event.getSource().get('v.value'));
        if(event.getSource().get('v.checked') == true){
            var row = component.get("v.historyDeleteRow");
            row.push(event.getSource().get('v.value'));
            component.set("v.historyDeleteRow",row);
        }
        else{
            var row2 = component.get("v.historyDeleteRow");
            row2.push(event.getSource().get('v.value'));
            var newArray = row2.filter(e => e !== event.getSource().get('v.value'));
            component.set("v.historyDeleteRow",newArray);
        }
        console.log(component.get("v.historyDeleteRow"));
    },
    handleHistoryOfChangesDeleteRow: function(component, event, helper) {
        component.set("v.isPublishEnabled", false);
        component.set("v.recordToDelete",true);
        
        var History0CheckboxEditCheckCmp = component.find("History0CheckboxEdit");
        var History1CheckboxEditCheckCmp = component.find("History1CheckboxEdit");
        var History2CheckboxEditCheckCmp = component.find("History2CheckboxEdit");
        var History3CheckboxEditCheckCmp = component.find("History3CheckboxEdit");
        var History4CheckboxEditCheckCmp = component.find("History4CheckboxEdit");
        var History5CheckboxEditCheckCmp = component.find("History5CheckboxEdit");
        var History6CheckboxEditCheckCmp = component.find("History6CheckboxEdit");
        var History7CheckboxEditCheckCmp = component.find("History7CheckboxEdit");
        var History8CheckboxEditCheckCmp = component.find("History8CheckboxEdit");
        var History9CheckboxEditCheckCmp = component.find("History9CheckboxEdit");
        var History10CheckboxEditCheckCmp = component.find("History10CheckboxEdit");
        var History11CheckboxEditCheckCmp = component.find("History11CheckboxEdit");
        var History12CheckboxEditCheckCmp = component.find("History12CheckboxEdit");
        var History13CheckboxEditCheckCmp = component.find("History13CheckboxEdit");
        var History14CheckboxEditCheckCmp = component.find("History14CheckboxEdit");
        var History15CheckboxEditCheckCmp = component.find("History15CheckboxEdit");
        
        var deleteRowList = component.get("v.historyDeleteRow");
        var History0CheckboxEditFlag= deleteRowList.includes(History0CheckboxEditCheckCmp.get("v.value"));
        var History1CheckboxEditFlag= deleteRowList.includes(History1CheckboxEditCheckCmp.get("v.value"));
        var History2CheckboxEditFlag= deleteRowList.includes(History2CheckboxEditCheckCmp.get("v.value"));
        var History3CheckboxEditFlag= deleteRowList.includes(History3CheckboxEditCheckCmp.get("v.value"));
        var History4CheckboxEditFlag= deleteRowList.includes(History4CheckboxEditCheckCmp.get("v.value"));
        var History5CheckboxEditFlag= deleteRowList.includes(History5CheckboxEditCheckCmp.get("v.value"));
        var History6CheckboxEditFlag= deleteRowList.includes(History6CheckboxEditCheckCmp.get("v.value"));
        var History7CheckboxEditFlag= deleteRowList.includes(History7CheckboxEditCheckCmp.get("v.value"));
        var History8CheckboxEditFlag= deleteRowList.includes(History8CheckboxEditCheckCmp.get("v.value"));
        var History9CheckboxEditFlag= deleteRowList.includes(History9CheckboxEditCheckCmp.get("v.value"));
        var History10CheckboxEditFlag= deleteRowList.includes(History10CheckboxEditCheckCmp.get("v.value"));
        var History11CheckboxEditFlag= deleteRowList.includes(History11CheckboxEditCheckCmp.get("v.value"));
        var History12CheckboxEditFlag= deleteRowList.includes(History12CheckboxEditCheckCmp.get("v.value"));
        var History13CheckboxEditFlag= deleteRowList.includes(History13CheckboxEditCheckCmp.get("v.value"));
        var History14CheckboxEditFlag= deleteRowList.includes(History14CheckboxEditCheckCmp.get("v.value"));
        var History15CheckboxEditFlag= deleteRowList.includes(History15CheckboxEditCheckCmp.get("v.value"));
        
        if(History0CheckboxEditFlag)
        {
            component.set("v.History0RecordTypeEditCheckBox",false);
        }
        if(History0CheckboxEditFlag)
        {
            component.set("v.History0RecordTypeEditCheckBox",false);
        }
        if(History1CheckboxEditFlag)
        {
            component.set("v.History1RecordTypeEditCheckBox",false);
        }
        if(History2CheckboxEditFlag)
        {
            component.set("v.History2RecordTypeEditCheckBox",false);
        }
        if(History3CheckboxEditFlag)
        {
            component.set("v.History3RecordTypeEditCheckBox",false);
        }
        if(History4CheckboxEditFlag)
        {
            component.set("v.History4RecordTypeEditCheckBox",false);
        }
        if(History5CheckboxEditFlag)
        {
            component.set("v.History5RecordTypeEditCheckBox",false);
        }
        if(History6CheckboxEditFlag)
        {
            component.set("v.History6RecordTypeEditCheckBox",false);
        }
        if(History7CheckboxEditFlag)
        {
            component.set("v.History7RecordTypeEditCheckBox",false);
        }
        if(History8CheckboxEditFlag)
        {
            component.set("v.History8RecordTypeEditCheckBox",false);
        }
        if(History9CheckboxEditFlag)
        {
            component.set("v.History9RecordTypeEditCheckBox",false);
        }
        if(History10CheckboxEditFlag)
        {
            component.set("v.History10RecordTypeEditCheckBox",false);
        }
        if(History11CheckboxEditFlag)
        {
            component.set("v.History11RecordTypeEditCheckBox",false);
        }
        if(History12CheckboxEditFlag)
        {
            component.set("v.History12RecordTypeEditCheckBox",false);
        }
        if(History13CheckboxEditFlag)
        {
            component.set("v.History13RecordTypeEditCheckBox",false);
        }
        if(History14CheckboxEditFlag)
        {
            component.set("v.History14RecordTypeEditCheckBox",false);
        }
        if(History15CheckboxEditFlag)
        {
            component.set("v.History15RecordTypeEditCheckBox",false);
        }
    },
    showAuditLogs: function(component, event, helper) {
        	event.preventDefault();
            var urlEvent = $A.get("e.force:navigateToURL");
            if(event.getSource().getLocalId() == 'compSafeDbEditFormAudit') {
                urlEvent.setParams({
                    "url": "/lightning/n/Audit_Logs?c__recordId="+component.get("v.compSafeDbRecordId")
                });
            }
            else if(event.getSource().getLocalId() == 'clinTrialDbEditFormAudit') {
                urlEvent.setParams({
                    "url": "/lightning/n/Audit_Logs?c__recordId="+component.get("v.clinicalTrialRecordId")
                });
            }
            else if(event.getSource().getLocalId() == 'literatureEditFormAudit') {
                urlEvent.setParams({
                    "url": "/lightning/n/Audit_Logs?c__recordId="+component.get("v.litrRecordId")
                });
            }
            else if(event.getSource().getLocalId() == 'healthAuthWebEditFormAudit') {
                urlEvent.setParams({
                    "url": "/lightning/n/Audit_Logs?c__recordId="+component.get("v.healthAuthWebRecordId")
                });
            }
            else if(event.getSource().getLocalId() == 'eudravigEditFormAudit') {
                urlEvent.setParams({
                    "url": "/lightning/n/Audit_Logs?c__recordId="+component.get("v.eudravigRecordId")
                });
            }
            else if(event.getSource().getLocalId() == 'faersEditFormAudit') {
                urlEvent.setParams({
                    "url": "/lightning/n/Audit_Logs?c__recordId="+component.get("v.faersRecordId")
                });
            }
            else if(event.getSource().getLocalId() == 'vaersEditFormAudit') {
                urlEvent.setParams({
                    "url": "/lightning/n/Audit_Logs?c__recordId="+component.get("v.vaersRecordId")
                });
            }
            else if(event.getSource().getLocalId() == 'compRSAEditFormAudit') {
                urlEvent.setParams({
                    "url": "/lightning/n/Audit_Logs?c__recordId="+component.get("v.compRSARecordId")
                });
            }
            else if(event.getSource().getLocalId() == 'others1EditFormAudit') {
                urlEvent.setParams({
                    "url": "/lightning/n/Audit_Logs?c__recordId="+component.get("v.others1RecordId")
                });
            }
            
            else if(event.getSource().getLocalId() == 'other2EditFormAudit') {
                urlEvent.setParams({
                    "url": "/lightning/n/Audit_Logs?c__recordId="+component.get("v.other2RecordId")
                });
            }
            else if(event.getSource().getLocalId() == 'others3EditFormAudit') {
                urlEvent.setParams({
                    "url": "/lightning/n/Audit_Logs?c__recordId="+component.get("v.other3RecordId")
                });
            }
            else if(event.getSource().getLocalId() == 'others4EditFormAudit') {
                urlEvent.setParams({
                    "url": "/lightning/n/Audit_Logs?c__recordId="+component.get("v.other4RecordId")
                });
            }
            else urlEvent.setParams({
                "url": "/lightning/n/Audit_Logs?c__recordId="+component.get("v.parRecordId")
            });
            urlEvent.fire();
	},
    update : function (component, event, helper) {
            // Get the new location token from the event if needed
             window.location.reload();
	},
    setDeletingVersionId: function(component,event, helper) {
        var versionId = event.getSource().get("v.value");
        console.log('versionId: '+versionId);
        component.set("v.versionPssfId",versionId);
        component.set("v.isDeletionConfirmationOpen",true);
        component.find("recordHandler").reloadRecord();
    },
    handleDeleteRecord: function(component, event, helper) {  
        console.log('version pssf id: '+component.get("v.versionPssfId"));
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
            var pssfIdValue = component.get("v.parRecordId");
            console.log('pssfIdValue: '+pssfIdValue);
            var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
                "recordId": pssfIdValue,
                "slideDevName": "detail"	        
            });	        
            navEvt.fire();
            
        } else if(eventParams.changeType === "ERROR") {
            // there’s an error while loading, saving, or deleting the record
        }
    }
})
