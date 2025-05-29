({
	processESignatureStatus : function(component,helper) {
		var recordId=component.get("v.recordId");
        var action = component.get("c.addDocuSignRecipient");
        action.setParams({           
            agreementId: recordId
        });
        action.setCallback(this, function (response) {
            var eSResult = response.getReturnValue();
            if (eSResult.status == 'SUCCESS') { 
                if((eSResult.batchId == '' || eSResult.batchId == 'undefined')) {
             	    component.set('v.hasDataError', false);
                    window.open('/lightning/r/Apttus__APTS_Agreement__c/' + recordId + '/view', '_top');           
                }                
                else if(eSResult.isFieldEmpty){
                    var labelData = $A.get("$Label.c.CLM_CL0008_Agreement_EmptyField_Error");
                    component.set("v.errorMessage", labelData);
                    component.set('v.hasDataError', true);
                }
                component.set('v.jobId', eSResult.batchId);
                helper.getBatchStatus(component, helper);
            } else {
                var errors = response.getError();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "Error",
                    "mode": 'dismissible',
                    "message": eSResult.message
                });
                toastEvent.fire();
                $A.log("Errors", response.getError());
            }
        });
        // Invoke the service
        $A.enqueueAction(action);
	},
    
    getBatchStatus: function (component, helper) {
        var jobId = component.get("v.jobId");
        var recordId=component.get("v.recordId");
        if(jobId != '' && jobId != null){
           
           helper.getBatchCurrentStatus(component, helper);
        } else {
            var rId=component.get("v.recordId");
            var element = document.getElementById("batchJobStatusDiv");
            element.classList.remove("errorO");
            element.classList.add("successO");
            component.set("v.batchJobStatus", " Success - redirecting to agreement record.");
            if(component.get('v.hasDataError')== false){
                window.open('/lightning/r/Apttus__APTS_Agreement__c/' + rId + '/view', '_top');
            }
            
        }
    },
    
    getBatchCurrentStatus: function (component, helper) {
        var rId=component.get("v.recordId");
        var action = component.get("c.getBatchCurrentStatus");
        var batchId = component.get('v.jobId');
        action.setParams({
            "batchId": batchId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.batchJobStatus", result.status);
                if (result.status == 'Completed') {
                    var noe = result.numberOfErrors;
                    if (noe >= 1) {
                        var element = document.getElementById("batchJobStatusDiv");
                        element.classList.remove("successO");
                        element.classList.add("errorO");
                        component.set("v.batchJobStatus", " Failed - " + result.extendedStatus);
                    }else {
                        if(component.get("v.hasDataError")) {
                            clearTimeout(id);
                        }
                        else{
                            var element = document.getElementById("batchJobStatusDiv");
                            element.classList.remove("errorO");
                            element.classList.add("successO");
                            component.set("v.batchJobStatus", " Success - redirecting to agreement record.");
                            window.open('/lightning/r/Apttus__APTS_Agreement__c/' + rId + '/view', '_top');
                        }
                    }
                } else if (result.status == 'Failed') {
                    var element = document.getElementById("batchJobStatusDiv");
                    element.classList.remove("successO");
                    element.classList.add("errorO");
                    component.set("v.batchJobStatus", " Failed - " + result.extendedStatus);
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": "Error",
                    "mode": 'dismissible',
                    "message": JSON.stringify(errors)
                });
                toastEvent.fire();
                $A.log("Errors", response.getError());
        	}
        });
        $A.enqueueAction(action);
        const id = window.setTimeout(
            $A.getCallback(function () {
                helper.getBatchCurrentStatus(component, helper);
            }), 5000);
    },
})