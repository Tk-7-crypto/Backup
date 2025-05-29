({    
    createRecord:function(component, event,recordTypeIdVar)
    {
        var clmRecordTypeIdsMVP = component.get("v.clmRecordTypeIds");
        var recordTypeId = component.get("v.pageReference").state.recordTypeId;
        var recId = component.get("v.recordTypeId");
        if(recordTypeId != null){
            recId = recordTypeId;
        }
        if((recId != clmRecordTypeIdsMVP[1]) && (recId != clmRecordTypeIdsMVP[3])){
            var createRecordEvent = $A.get("e.force:createRecord");
                        createRecordEvent.setParams({
                            "entityApiName": "Apttus__APTS_Agreement__c",
                            "recordTypeId": recId
                        });
       createRecordEvent.fire(); 
        }
    },

    createRecordCLMForMVP:function(component, event,recordTypeIdVar) {
        var recordTypeId = component.get("v.pageReference").state.recordTypeId;
        var defaultTermMonth =  60;
        var legalEntityIds = component.get("v.defaultLegalEntityIds");
        var firstLegalEntity = null;
        var secondLegalEntity = null;
        var thirdLegalEntity = null;
        if(legalEntityIds) {
            var legalEntityId = legalEntityIds.split(",");
            if(legalEntityId[0] !== null && legalEntityId[0] !== 'undefined') {
                firstLegalEntity = legalEntityId[0];
            }
            if(legalEntityId[1] !== null && legalEntityId[1] !== 'undefined') {
                secondLegalEntity = legalEntityId[1];
            }
            if(legalEntityId[2] !== null && legalEntityId[2] !== 'undefined') {
                thirdLegalEntity = legalEntityId[2];
            }
        }
        var base64Context = component.get("v.pageReference").state.inContextOfRef;
        if(base64Context != null && base64Context.startsWith("1\.")) {
            base64Context = base64Context.substring(2);
        }
        var addressableContext = JSON.parse(window.atob(base64Context));
        var contextRefRecordId = null; 
        var contextRefObject = addressableContext.attributes.objectApiName;
        if(contextRefObject != null && contextRefObject != 'undefined' && contextRefObject == 'Account') {  
            contextRefRecordId = addressableContext.attributes.recordId;
        }
        this.getAccountCurrency(component, contextRefRecordId);
        var createRecordEvent = $A.get("e.force:createRecord");
                        createRecordEvent.setParams({
                            "entityApiName": "Apttus__APTS_Agreement__c",
                            "recordTypeId": recordTypeId,
                            "defaultFieldValues": {
                                'Apttus__Term_Months__c' : defaultTermMonth,
                                'Services__c' : component.get("v.agreementServicesOptions"),
                                'CurrencyIsoCode' : component.get("v.accountCurrency"),
                                'Legal_Entity_1__c' : firstLegalEntity,
                                'Legal_Entity_2__c' : secondLegalEntity,
                                'Legal_Entity_3__c' : thirdLegalEntity,
                                'Apttus__Account__c' : contextRefRecordId 
                            }
                        });
       createRecordEvent.fire(); 
    },
    
    createRecordCLMForOSA:function(component, event,recordTypeIdVar) {
        var recordTypeId = component.get("v.pageReference").state.recordTypeId;
        var base64Context = component.get("v.pageReference").state.inContextOfRef;
        if(base64Context != null && base64Context.startsWith("1\.")) {
            base64Context = base64Context.substring(2);
        }
        var addressableContext = JSON.parse(window.atob(base64Context));
        var contextRefRecordId = null; 
        var contextRefObject = addressableContext.attributes.objectApiName;
        if(contextRefObject != null && contextRefObject != 'undefined' && contextRefObject == 'Account') {  
            contextRefRecordId = addressableContext.attributes.recordId;
        }
        var createRecordEvent = $A.get("e.force:createRecord");
                        createRecordEvent.setParams({
                            "entityApiName": "Apttus__APTS_Agreement__c",
                            "recordTypeId": recordTypeId,
                            "defaultFieldValues": {
                                'Apttus__Account__c' : contextRefRecordId 
                            }
                        });
       createRecordEvent.fire(); 
    },
    
    redirectUser : function(component,event)
    {
        var redirectUser = component.get("c.redirectUserOnRTSelection");
        var recordTypeId = component.get("v.pageReference").state.recordTypeId;
        var recId = component.get("v.recordTypeId");
        if(recordTypeId != null){
            recId = recordTypeId;
        }
        redirectUser.setParams({
                    "recordTypeId" : recId,
                });

        redirectUser.setCallback(this, function(actionResult) {
            if(actionResult.getReturnValue()==='OpportunitySelection')
            {
                var evt = $A.get("e.force:navigateToComponent");
        		evt.setParams({
            	componentDef  : "c:LXC_OWF_overrideAgreementCreation" ,
            	componentAttributes : {
                	recordTypeId : recordTypeId,
                    pageReference : component.get("v.pageReference")
            					}
        					});
        		evt.fire(); 
            } else {
                var clmRecordTypeIdsMVP = component.get("v.clmRecordTypeIds");
                if(clmRecordTypeIdsMVP != null && clmRecordTypeIdsMVP.length > 0 && clmRecordTypeIdsMVP.indexOf(recId) >= 0)
                {
                    if(clmRecordTypeIdsMVP[0] === recId) { //MSA
                        this.getAgreementServicesOptions(component);
                        this.setDefaultLegalEntityForMSA(component);
                        this.createRecordCLMForMVP(component, event, recId);
                    }
                    if(clmRecordTypeIdsMVP[1] === recId) { //AMA
                        var base64Context = component.get("v.pageReference").state.inContextOfRef;
                        if(base64Context != null && base64Context.startsWith("1\.")) {
                            base64Context = base64Context.substring(2);
        			    }
                        var addressableContext = JSON.parse(window.atob(base64Context));
                        var contextRefObject = addressableContext.attributes.objectApiName;
                        var contextRefRecordId = null;       
                        if(contextRefObject != null && contextRefObject != 'undefined' && contextRefObject == 'Account') {  
                        contextRefRecordId = addressableContext.attributes.recordId;
                        }
                    
                        component.set("v.isOpen", true);
                        var flow = component.find("flowData");
                        if(contextRefRecordId != null) {
                            var inputVariables = [
                                    {
                                        name : "recordId",
                                        type : "String",
                                        value : contextRefRecordId 
                                    }
                                ];
                                flow.startFlow("CLM_AMA_Agreement", inputVariables);
                        }
                        else{
                            flow.startFlow("CLM_AMA_Agreement");
                        }   
                    }
                    if(clmRecordTypeIdsMVP[2] === recId) { //OSA
                        this.createRecordCLMForOSA(component, event, recId);
                    }
                    if(clmRecordTypeIdsMVP[3] === recId) { //Vendor_Agreement
                        var base64Context = component.get("v.pageReference").state.inContextOfRef;
                        if(base64Context != null && base64Context.startsWith("1\.")) {
                            base64Context = base64Context.substring(2);
        			    }
                        var addressableContext = JSON.parse(window.atob(base64Context));
                        var contextRefObject = addressableContext.attributes.objectApiName;
                        var contextRefRecordId = null;       
                        if(contextRefObject != null && contextRefObject != 'undefined' && contextRefObject == 'Account') {  
                        contextRefRecordId = addressableContext.attributes.recordId;
                        }
                    
                        component.set("v.isOpen", true);
                        var flow = component.find("flowData");
                        if(contextRefRecordId != null) {
                            var inputVariables = [
                                    {
                                        name : "recordId",
                                        type : "String",
                                        value : contextRefRecordId 
                                    }
                                ];
                                flow.startFlow("CLM_Create_Vendor_ScreenFlow", inputVariables);
                        }
                        else{
                            flow.startFlow("CLM_Create_Vendor_ScreenFlow");
                        }
                    }
                }
                else
                {
                    this.createRecord(component, event, recId);
                }
            }

      });
        $A.enqueueAction(redirectUser);
        
        return 'NoRedirect';
    },

    showToast : function(component, event,title,message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message
        });
        toastEvent.fire();
    },

    getCLMRecordTypeIdsForMVP : function(component, event) {
        var action = component.get("c.getCLMRecordTypeIdsForMVP");
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
                var records = actionResult.getReturnValue();
                if(records.length > 0) {
                    component.set("v.clmRecordTypeIds", records);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    getCLMRecordTypeIdsOfAvailableUsers : function(component, event){
        var action = component.get("c.getCLMRecordTypeIdsOfAvailableUsers");
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
                var records = actionResult.getReturnValue();
                component.set("v.recordTypeId", records[0]);
            }
        });
        $A.enqueueAction(action);
    },

    getAgreementServicesOptions : function(component) {
        var action = component.get('c.getAgreementServicesOptions'); 
        action.setCallback(this, function(a) {
            var state = a.getState();
            if(state == 'SUCCESS') {
                component.set("v.agreementServicesOptions", a.getReturnValue());
            } else if(state === "INCOMPLETE") {
                console.log("Error message: Incomplete");
            } else if (state === "ERROR") {
                this.handleErrors(a.getError());
            }
        });
        $A.enqueueAction(action);
    },
   
    setDefaultLegalEntityForMSA : function(component) {
        var action = component.get("c.setDefaultLegalEntityValuesForMSA"); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result) {
                    var combinedLegalEntityIds = result['IQVIA LTD'] + ',' + result['IQVIA RDS Inc.']
                    + ',' + result['IQVIA RDS East Asia Pte. Ltd.'];
                    component.set("v.defaultLegalEntityIds", combinedLegalEntityIds);
                }
            } 
            else if(state === "INCOMPLETE") {
                console.log("Error message: Incomplete");
            } 
            else if (state === "ERROR") {
                this.handleErrors(response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    getAccountCurrency : function(component, accountId) {
        var action = component.get('c.getAccountCurrency'); 
        action.setParams({
            "accountId" : accountId,
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if(state == 'SUCCESS') {
                component.set("v.accountCurrency", a.getReturnValue());
            } else if(state === "INCOMPLETE") {
                console.log("Error message: Incomplete");
            } else if (state === "ERROR") {
                this.handleErrors(a.getError());
            }
        });
        $A.enqueueAction(action);
    }
})