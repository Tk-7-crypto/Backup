({   
    redirectAdminUser: function (component, event, helper) {
        var recId = component.get("v.pageReference").state.recordTypeId;
        if(recId == undefined || recId == '' ) {
            recId = component.get("v.recordTypeId");
        }
        var clmRecordTypeIdsMVP = component.get("v.clmRecordTypeIds");
        if(clmRecordTypeIdsMVP != null && clmRecordTypeIdsMVP.length > 0 
            && clmRecordTypeIdsMVP.indexOf(recId) >= 0 && clmRecordTypeIdsMVP[3] === recId){
            this.redirectUser(component, event);
        } else {
            var action = component.get("c.checkAdminUser");
            action.setCallback(this, function (response){
                if(response.getState() === 'SUCCESS') {
                    if (response.getReturnValue() === true) {
                        this.redirectUser(component, event);
                    } else {
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Attention!",
                            "type" : "Error",
		    	            "mode" : "sticky",
                            "message": "The use of this 'New' button to create agreements is deprecated. Please launch the workflow using the 'Create New Agreement' action button from the Opportunity, Account or Other Related Object details"
                        });
                        toastEvent.fire();	
                        var homeEvent = $A.get("e.force:navigateToObjectHome");
                        homeEvent.setParams({
                            "scope": "Apttus__APTS_Agreement__c"
                        });
                        homeEvent.fire();
                    }
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    redirectUser : function(component,event)
    {
        var recId = component.get("v.pageReference").state.recordTypeId;
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
            if(clmRecordTypeIdsMVP[2] === recId) { //Vendor_Agreement
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
            if(clmRecordTypeIdsMVP[3] === recId) { //OSA
                this.createRecord(component, event, recId);
            }
        }
        else
        {
            this.createRecord(component, event, recId);
        }        
        return 'NoRedirect';
    },
    
    createRecord:function(component, event,recordTypeIdVar)
    {
        var clmRecordTypeIdsMVP = component.get("v.clmRecordTypeIds");
        var recId = component.get("v.pageReference").state.recordTypeId;
        if(clmRecordTypeIdsMVP !=  null){
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
        var action = component.get("c.getDefaultLegalEntityValuesForMSA"); 
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result) {
                    var combinedLegalEntityIds = result['QUINC'] + ',' + result['QUTHV']
                    + ',' + result['QULSG'];
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
    },
    
    getAccessibleRecordTypeId : function(component, event) {
        var action = component.get("c.getAccessibleRecordTypeId");
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
                component.set("v.recordTypeId", actionResult.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
})