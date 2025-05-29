({
    getCaseRecord : function(component) {
        var action = component.get("c.getRecord");
        this.loadDependentPicklistValues(component, 'CSM_QI_CAPA__c', 'Resolution_Code_Option__c', 'Root_Cause_Option__c');
        action.setParams({ 
            "caseId": component.get("v.caseId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var caseWrapper = JSON.parse(result);
                component.set("v.caseWrapper", caseWrapper);
                if(caseWrapper.isSubType3Exist ) {
                    component.set("v.isSubType3Found", caseWrapper.isSubType3Matching);
                    if(caseWrapper.caseRecord.Query_Type_Area__c != null && caseWrapper.caseRecord.Query_Type_Area__c != '' && caseWrapper.caseRecord.Query_Type_Area__c != 'Please Specify'){
                        component.set("v.caseWrapper.queryTypeArea", caseWrapper.caseRecord.Query_Type_Area__c);
                        this.onQueryTypeChange(component);
                    }
                    if(caseWrapper.caseRecord.ResolutionCode__c != null && caseWrapper.caseRecord.ResolutionCode__c != '' && caseWrapper.caseRecord.ResolutionCode__c != 'Please Specify'){
                        component.set("v.caseWrapper.resolutionCode", caseWrapper.caseRecord.ResolutionCode__c);
                        this.onResolutionCodeChange(component);
                    }
                    if(caseWrapper.caseRecord.Corrective_Action__c != null && caseWrapper.caseRecord.Corrective_Action__c != '' && caseWrapper.caseRecord.Corrective_Action__c != 'Please Specify'){
                        component.set("v.caseWrapper.correctiveAction", caseWrapper.caseRecord.Corrective_Action__c);
                    }
                    if(caseWrapper.caseRecord.RootCause__c != null && caseWrapper.caseRecord.RootCause__c != '' && caseWrapper.caseRecord.RootCause__c != 'Please Specify'){
                        component.set("v.caseWrapper.rootCause", caseWrapper.caseRecord.RootCause__c);
                        this.onResolutionCodeChange(component);
                    }
                    if(caseWrapper.caseRecord.Status != 'Closed') {
                        component.set("v.caseWrapper.caseRecord.SubStatus__c", '');
                        caseWrapper.caseRecord.Status = 'Closed';
                    }
                    var condition = " WHERE Sub_Type_3__c ='" + caseWrapper.caseRecord.SubType3__c + "'";
                    this.loadDependentCAPAPicklistValues(component, 'Query_Type_Area__c', condition);
                    this.loadDependentPicklistValues(component, 'Case', 'Status', 'SubStatus__c');
                    this.loadDependentPicklistValues(component, 'CSM_QI_CAPA__c', 'Resolution_Code_Option__c', 'Root_Cause_Option__c');
                    
                    if(!caseWrapper.isSubType3Matching) {
                        this.loadDependentCAPAPicklistValues(component, 'Resolution_Code__c', '');
                        component.set("v.isResolutionCodeDisable", false);
                    }
                    component.set("v.Spinner", false);
                }
                else{
                    component.set("v.showMessage", true);
                    component.set("v.pageMessage", 'Please fill Sub-Type3 value in Categorization Form');
                }
                component.set("v.caseWrapper", caseWrapper);
                component.set("v.isLoadedFirstTime", false);
            }
            else if(state === "ERROR") {
                var errors = response.getError();
                this.handleErrors(errors);
            }
        });
        $A.enqueueAction(action);
    },
    
    checkIfAllFieldsRequired : function(component) {
        var action = component.get("c.checkFieldRequirement");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                              
                var allFieldsRequired = response.getReturnValue();
                component.set("v.allFieldsRequired", allFieldsRequired);
            }
            else if(state === "ERROR") {
                var errors = response.getError();
                this.handleErrors(errors);
            }
        });
        $A.enqueueAction(action);
    },
    
    checkUserPermissions : function(component) {
        var action = component.get("c.checkPermission");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                              
                var checkPermission = response.getReturnValue();
                component.set("v.checkUserPermission", checkPermission);
            }
            else if(state === "ERROR") {
                var errors = response.getError();
                this.handleErrors(errors);
            }
        });
        $A.enqueueAction(action);
    },
    
    onQueryTypeChange : function(component) {
        var subtype3Condition = " WHERE Sub_Type_3__c ='" + component.get("v.caseWrapper.caseRecord.SubType3__c") + "'";
        var queryTypeCondition = subtype3Condition + " AND Query_Type_Area__c ='" + component.get("v.caseWrapper.queryTypeArea") + "'";
        var caseWrapper = component.get("v.caseWrapper");
        if(caseWrapper.queryTypeArea == 'Please Specify' || caseWrapper.queryTypeArea == '' || caseWrapper.queryTypeArea == null) {
            component.set("v.isResolutionCodeDisable", true);
            component.set("v.isCorrectiveActionDisable", true);
            component.set("v.isRootCauseDisable", true);
            component.set("v.caseWrapper.resolutionCode", '');
            component.set('v.caseWrapper.correctiveAction', '');
            component.set('v.caseWrapper.rootCause', '');
            component.set('v.picklistWrapper.resolutionCodes', []);
            component.set('v.picklistWrapper.correctiveActions', []);
            component.set("v.picklistWrapper.rootCauses", []);
        } else {
            this.loadDependentCAPAPicklistValues(component, 'Resolution_Code__c', queryTypeCondition);
            component.set("v.isResolutionCodeDisable", false);
            component.set("v.caseWrapper.resolutionCode", '');
            this.onResolutionCodeChange(component);
        }
    },
    
    onResolutionCodeChange : function(component, isCalledOnLoad) {
        var caseWrapper = component.get("v.caseWrapper");
        var resolutionCodeCondition;
        if(caseWrapper.isSubType3Matching) {
            var subtype3Condition = " WHERE Sub_Type_3__c ='" + component.get("v.caseWrapper.caseRecord.SubType3__c") + "'";
            var queryTypeCondition = subtype3Condition + " AND Query_Type_Area__c ='" + component.get("v.caseWrapper.queryTypeArea") + "'";
            resolutionCodeCondition = queryTypeCondition + " AND Resolution_Code__c ='" + component.get("v.caseWrapper.resolutionCode") + "'";
            if(caseWrapper.resolutionCode == 'Please Specify' || caseWrapper.resolutionCode == '' || caseWrapper.resolutionCode == null) {
                component.set("v.isRootCauseDisable", true);
                component.set("v.isCorrectiveActionDisable", true);
                component.set('v.caseWrapper.correctiveAction', '');
                component.set('v.caseWrapper.rootCause', '');
                component.set('v.picklistWrapper.correctiveActions', []);
                component.set("v.picklistWrapper.rootCauses", []);
            } else {
                this.loadDependentCAPAPicklistValues(component, 'Corrective_Action__c', resolutionCodeCondition);
                if(!component.get("v.isLoadedFirstTime")) {
                    component.set('v.caseWrapper.correctiveAction', '');
                    component.set('v.caseWrapper.rootCause', '');
                }
                var contrFieldValue = component.get("v.caseWrapper.resolutionCode");
                var dependentRootCauseValues = component.get("v.dependentRootCauseValues");
                var picklistWrapper = component.get("v.picklistWrapper");
                var dependentPicklistValues = dependentRootCauseValues[contrFieldValue];
                if(dependentPicklistValues != undefined) {
                    for (var i = 0; i < dependentPicklistValues.length; i++) {
                        if (dependentPicklistValues[i].label === "Please Specify") {
                            dependentPicklistValues.unshift(dependentPicklistValues[i]);
                            dependentPicklistValues.splice(i + 1, 1);
                        }
                    }
                    component.set("v.picklistWrapper.rootCauses", dependentPicklistValues);
                    var isRootCauseDisable = dependentPicklistValues.length == 0 ? true : false;
                    component.set("v.isRootCauseDisable", isRootCauseDisable);
                }
            }
        }
    },
    
    loadPicklistValues : function(component) {
        var action = component.get("c.getPickListValues");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                              
                var result = response.getReturnValue();
                var picklistWrapperInstance = JSON.parse(result);
                var picklistWrapper = component.get("v.picklistWrapper"); 
                picklistWrapper.statusValues = JSON.parse(picklistWrapperInstance.statusValues);
                picklistWrapper.countries = JSON.parse(picklistWrapperInstance.countries);
                component.set("v.picklistWrapper",picklistWrapper);
            }
            else if(state === "ERROR") {
                var errors = response.getError();
                this.handleErrors(errors);
            }
        });
        $A.enqueueAction(action);
    },
    
    loadDependentPicklistValues : function(component, objectName, contrfieldApiName, depfieldApiName) {
        var action = component.get("c.getDependentPicklistMap");
        action.setParams({ 
            "objectName": objectName,
            "contrfieldApiName" : contrfieldApiName,
            "depfieldApiName" : depfieldApiName
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                              
                var result = response.getReturnValue();
                var dependentPicklistMap = JSON.parse(result);
                var picklistWrapper = component.get("v.picklistWrapper");
                var caseWrapper = component.get("v.caseWrapper");
                var contrFieldValue;
                if(contrfieldApiName == 'Status') {
                    contrFieldValue = caseWrapper.caseRecord.Status;
                    component.set("v.dependentSubstatusValues", dependentPicklistMap);
                    component.set("v.picklistWrapper.subStatusValues", dependentPicklistMap[contrFieldValue]);
                } else if(contrfieldApiName == 'Resolution_Code_Option__c') {
                    component.set("v.dependentRootCauseValues", dependentPicklistMap);
                }
                component.set("v.picklistWrapper", picklistWrapper);
            }
            else if(state === "ERROR") {
                var errors = response.getError();
                this.handleErrors(errors);
            }
        });
        $A.enqueueAction(action);
    },
    
    loadDependentCAPAPicklistValues: function(component, dependentField, condition) {
        var dependentPicklistValues = [];
        var query = '';
        query = 'SELECT '+dependentField +' FROM CSM_QI_CAPA__c '+condition+' Group By '+dependentField;
        var action = component.get("c.getCAPAValuesWithAggregate");
        action.setParams({ 
            "query": query
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {                              
                var CAPApicklist = response.getReturnValue();
                var dependentValue;
                if(CAPApicklist.length > 0){
                    for (var i = 0; i < Object.keys(CAPApicklist).length; i++) {
                        dependentValue = CAPApicklist[i][dependentField];
                        if (dependentValue != undefined) {
                            dependentPicklistValues.push(dependentValue);
                        }
                        else {
                            dependentPicklistValues.push("Please Specify");
                        }
                    }
                    for (var i = 0; i < dependentPicklistValues.length; i++) {
                        if (dependentPicklistValues[i] === "Please Specify") {
                            dependentPicklistValues.unshift(dependentPicklistValues[i]);
                            dependentPicklistValues.splice(i + 1, 1);
                        }
                    }
                    
                    var caseWrapper = component.get("v.caseWrapper");
                    if(dependentField == 'Query_Type_Area__c') {
                        component.set('v.picklistWrapper.queryTypeAreas', dependentPicklistValues);
                        component.set("v.isQueryTypeDisable", false);
                    } else if(dependentField == 'Resolution_Code__c') {
                        component.set('v.picklistWrapper.resolutionCodes', dependentPicklistValues);
                    } else if(dependentField == 'Corrective_Action__c') {
                        component.set('v.picklistWrapper.correctiveActions', dependentPicklistValues);
                        var isCorrectiveActionDisable = dependentPicklistValues.length == 0 ? true: false;
                        component.set("v.isCorrectiveActionDisable", isCorrectiveActionDisable);
                    } 
                    var picklistWrapper = component.get("v.picklistWrapper");
                }
            }
            else if(state === "ERROR") {
                var errors = response.getError();
                this.handleErrors(errors);
            }
        });
        $A.enqueueAction(action);
    },
    
    save : function(component) {
        var caseWrapper = component.get("v.caseWrapper");
        caseWrapper.caseRecord.SubStatus__c = component.get("v.subStatus") == 'Please Specify' ? '' : component.get("v.subStatus");
        var action = component.get("c.saveRecord");
        action.setParams({ 
            "caseWrapperJSON": JSON.stringify(caseWrapper)
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {  
                if(component.get("v.allFieldsRequired")) {
                    component.set("v.allFieldsRequired", false);
                }
                var newCaseWrapper = {'caseRecord': {}, 'isSubType3Exist': caseWrapper.isSubType3Exist,
                                      'isSubType3Matching': caseWrapper.isSubType3Matching
                                     };
                component.set("v.caseWrapper", newCaseWrapper); 
                component.set("v.Spinner", false);
                this.showMessage("Success", "Case updated successfully!!", "success");
                $A.get('e.force:refreshView').fire();
            }
            else if(state === "ERROR") {
                var errors = response.getError();
                this.handleErrors(errors);
            }
        });
        $A.enqueueAction(action);
    },
    
    checkValidityForPicklist: function(component) {
        var isSubType3Matching = component.set("v.caseWrapper.isSubType3Matching");
        var isValid = component.find('selectCmp').reduce(function (validSoFar, inputCmp) {
            var inputCmpName = inputCmp.get('v.name');
            var inputCmpValue = inputCmp.get('v.value');
            if(inputCmpName != undefined  && inputCmpName != 'subStatus'  && (inputCmpValue == null || inputCmpValue == '' || inputCmpValue == 'Please Specify')) {
                inputCmp.set('v.validity', {valid:false});
                if(!isSubType3Matching && (inputCmpName == 'queryTypeArea' || inputCmpName == 'correctiveAction' || inputCmpName == 'rootCause')) {
                    inputCmp.set('v.validity', {valid:true});
                }
            }
            inputCmp.showHelpMessageIfInvalid();
            return validSoFar && inputCmp.get('v.validity').valid;
        }, true);
        return isValid;
    },
    
    checkValidityForInputCmp : function(component, name) {
        var isValid = component.find('inputCmp').reduce(function (validSoFar, inputCmp) {
            var inputCmpName = inputCmp.get('v.name');
            var inputCmpValue = inputCmp.get('v.value');
            var isValid =  true;
            var allFieldsRequired = component.get("v.allFieldsRequired");
            if(allFieldsRequired) {
                if(inputCmpName != undefined && (inputCmpName == 'responseToClient' || inputCmpName == 'resolution') && (inputCmpValue == '' || inputCmpValue == null)) {
                    inputCmp.set('v.validity', {valid:false});
                    isValid = false;
                }
            }
            if(!allFieldsRequired) {
                inputCmp.showHelpMessageIfInvalid();
                
            }
            return validSoFar && inputCmp.get('v.validity').valid && isValid;
        }, true);
        return isValid;
    },
    
    showMessage : function(title, message, type) {
        var toastParams = {
            title: title,
            message: message, 
            type: type
        };
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
    },
    
    handleErrors : function(errors) {
        var toastParams = {
            title: "Error",
            message: "Unknown error", 
            type: "error"
        };
        if (errors && Array.isArray(errors) && errors.length > 0) {
            toastParams.message = errors[0].message.split(',')[1].split(':')[0];
        }
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams(toastParams);
        toastEvent.fire();
    }
})
