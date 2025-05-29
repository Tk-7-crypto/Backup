({
    
    
    createRecord : function(component, event, helper) {
        var oppID =  component.get("v.selectedOppId");
        var recordTypeId = component.get("v.pageReference").state.recordTypeId;
        var OpportunityId = component.get("v.selectedOppId");
        var ligValidatedState = '';
        var recordTypeName = component.get("c.getRecorTypeName");
        var nonRFPBidRecordId='';
        var actionGetRecordTypeId = component.get("c.getRecordTypeId");
        actionGetRecordTypeId.setParams({
            "recordTypeName" : "Non_RFP_Bid",
        });
        actionGetRecordTypeId.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
                nonRFPBidRecordId = actionResult.getReturnValue();    
            }
        });
        $A.enqueueAction(actionGetRecordTypeId);
        
        if(OpportunityId=="")
        {
            var actionValidateRecordType = component.get("c.validateRecordType");
            actionValidateRecordType.setParams({
                "recordTypeId" : recordTypeId,
            });
            actionValidateRecordType.setCallback(this, function(actionResult) {
                var state = actionResult.getState();
                if (state === "SUCCESS") {
                    if(actionResult.getReturnValue())
                    {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Error!",
                            "message": "Opportunity cannot be blank for this record type."
                        });
                        toastEvent.fire();  
                    }
                    else
                    {
                        var createRecordEvent = $A.get("e.force:createRecord");
                        createRecordEvent.setParams({
                            "entityApiName": "Bid_History__c",
                            "recordTypeId": recordTypeId,
                            "panelOnDestroyCallback": function(event) {
                            }
                        });
                        createRecordEvent.fire();  
                    }
                    
                }
            });
            $A.enqueueAction(actionValidateRecordType);
        }
        else
        {
            var tAction = component.get("c.validateLIGForClinicalAgreement");
            tAction.setParams({
                "opportunityId" : oppID,
                "recordTypeId" : recordTypeId
            });
            	tAction.setCallback(this, function(actionResult) {
                ligValidatedState = tAction.getState();
                if(ligValidatedState === "SUCCESS")
                {
                    
                    var validateAction = component.get("c.validateOpportunity");
                    var recordTypeName = component.get("c.getRecorTypeName");
                    var action = component.get("c.getDefaultFieldValues");
                    recordTypeName.setParams({
                        "recordTypeId" : recordTypeId,
                    });
                    action.setCallback(this, function(actionResult) {
                        var state = actionResult.getState();
                        if (state === "SUCCESS") {
                            component.set("v.defaultValues",actionResult.getReturnValue());
                            console.log(component.get("v.defaultValues")); 
                            var defaultVal = component.get("v.defaultValues") ;
                            if(nonRFPBidRecordId == recordTypeId){
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    title : '',
                                    message: ' Non-RFP records should not be used for Early Engagement, Rebids or Post Award.',
                                    duration:' 5000',
                                    type: 'Warning'
                                });
                                toastEvent.fire();      
                            }
                            var createRecordEvent = $A.get("e.force:createRecord");
                            createRecordEvent.setParams({
                                "entityApiName": "Bid_History__c",
                                "recordTypeId": recordTypeId,
                                "defaultFieldValues": JSON.parse(defaultVal),
                                "panelOnDestroyCallback": function(event) {
                                    var navEvt = $A.get("e.force:navigateToSObject");
                                    navEvt.setParams({
                                        "recordId": oppID,
                                    });
                                    navEvt.fire();
                                }
                            });
                            createRecordEvent.fire();
                        }
                    });
                    recordTypeName.setCallback(this, function(actionResult) {
                        var state = actionResult.getState();
                        if (state === "SUCCESS") {
                            recordTypeId = actionResult.getReturnValue();
                            validateAction.setParams({
                                "opportunityId" : OpportunityId,
                                "recordTypeId" : recordTypeId,
                            });      
                            $A.enqueueAction(validateAction);  
                        }
                    });
                    validateAction.setCallback(this, function(actionResult) {
                        var state = actionResult.getState();
                        if (state === "SUCCESS") {
                            var hasError =actionResult.getReturnValue();
                            if(hasError == false)
                            {
                                action.setParams({
                                    "opportunityId" : OpportunityId,
                                    "recordTypeId": recordTypeId,
                                });
                                $A.enqueueAction(action);
                            }
                            else
                            {
                                if(hasError == true) {
                                    var toastEvent = $A.get("e.force:showToast");
                                    toastEvent.setParams({
                                        "title": "Error!",
                                        "message": "This bid is not allowed to be created on the current stage of Opportunity"
                                    });
                                    toastEvent.fire();
                                } 
                            }
                        }
                    });            
                    $A.enqueueAction(recordTypeName);  
                }
                else if (ligValidatedState === "ERROR") 
                {
                    var errors = actionResult.getError();
                    console.log(errors);	
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Validate Opportunity/Line Item Group',
                        message: errors[0].message,
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'Error',
                        mode: 'sticky'
                    });
                    toastEvent.fire();
                }
                
            });
            $A.enqueueAction(tAction);
        }
    } ,
    closeRecord : function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/006/o"
        });
        urlEvent.fire();
        
    },
    doInit : function(component, event, helper){ 
    }
})