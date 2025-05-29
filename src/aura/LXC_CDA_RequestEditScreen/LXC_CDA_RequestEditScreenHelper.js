({
    setRequestEditDefaults: function(component) {
        console.log('LXC_CDA_RequestEditScreen: js helper: setRequestEditDefaults start');        
        
        component.set("v.isNextButtonDisabled", true);
        
        console.log('recordId: ' + component.get("v.recordId"));
        var action = component.get("c.getRequestEditDefaultValues");
        
        action.setParams({
            "cdaRequestId": component.get("v.recordId")
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('getRequestEditDefaultValues callback state: ' + state);
            if(state == "SUCCESS") {
                
                var requestEditWrapper = response.getReturnValue();
                if(requestEditWrapper.cdaRequest != null && requestEditWrapper.cdaRequest.CDA_Effective_Date__c != null){
                	requestEditWrapper.cdaRequest.CDA_Effective_Date__c = $A.localizationService.formatDate(requestEditWrapper.cdaRequest.CDA_Effective_Date__c.toString(), 'MM/dd/yyyy');
                }
                component.set("v.requestEditWrapper", requestEditWrapper);
                console.log("v.requestEditWrapper: " + JSON.stringify(requestEditWrapper));                
                
                var tempMap = new Map();
                for(var key in requestEditWrapper.cdaRequestFieldsDetailMap) {
                    tempMap[key] = requestEditWrapper.cdaRequestFieldsDetailMap[key];
                    component.set("v." + key , tempMap[key]);
                }
                component.set("v.cdaRequestFieldsDetailMap", tempMap);
                
                component.set("v.cdaTypedepnedentFieldMap", requestEditWrapper.iqviaBusinessCdaTypeDependencyMap);
                this.setControllerPicklistValues(component, requestEditWrapper.iqviaBusinessCdaTypeDependencyMap, "iqviaBusinessPicklistValues");
                
                component.set("v.disclosurePeriodDepnedentFieldMap", requestEditWrapper.iqviaBusinessDisclosurePeriodDependencyMap);
                this.setControllerPicklistValues(component, requestEditWrapper.iqviaBusinessDisclosurePeriodDependencyMap, "disclosurePeriodPicklistValues");
            
                component.set("v.cdaLangDepnedentFieldMap", requestEditWrapper.cdaTypeCdaLanguageDependencyMap);
                this.setControllerPicklistValues(component, requestEditWrapper.cdaTypeCdaLanguageDependencyMap, "cdaTypePicklistValues");
                
                component.set("v.competContractCapDepFieldMap", requestEditWrapper.cdaTypeCompetContractCapDependencyMap);
                this.setControllerPicklistValues(component, requestEditWrapper.cdaTypeCompetContractCapDependencyMap, "cdaTypePicklistValues");
                
                component.set("v.studySponSituDepFieldMap", requestEditWrapper.competContractStudySponDependencyMap);
                this.setControllerPicklistValues(component, requestEditWrapper.competContractStudySponDependencyMap, "competContractCapValues");
                
                component.set("v.customerEntityStateDepnedentFieldMap", requestEditWrapper.custLegalEntityCountryStateDependencyMap);
                this.setControllerPicklistValues(component, requestEditWrapper.custLegalEntityCountryStateDependencyMap, "customerLegalEntityCountryValues");
                
                component.set("v.recipientAccountStateDepnedentFieldMap", requestEditWrapper.recipientAccCountryStateDependencyMap);
                this.setControllerPicklistValues(component, requestEditWrapper.recipientAccCountryStateDependencyMap, "recipientAccountCountryValues");
                
                component.set("v.loggedInUserType", requestEditWrapper.loggedInUserType);
                console.log("requestEditWrapper.loggedInUserType: " + requestEditWrapper.loggedInUserType);
                
                if(requestEditWrapper.loggedInUserType == "Negotiator" || requestEditWrapper.loggedInUserType == "System Admin") {
                    component.set("v.beforeIntervalType", "years");
                    component.set("v.beforeInterval", 1);
                    component.set("v.afterIntervalType", "days");
                    component.set("v.afterInterval", 90);
                    component.set("v.dateRangeErrorMessage", $A.get("$Label.c.You_cannot_select_date_1_year_prior_or_90_days_after_the_current_date"));
                }
                else {
                    component.set("v.beforeIntervalType", "days");
                    component.set("v.beforeInterval", 60);
                    component.set("v.afterIntervalType", "days");
                    component.set("v.afterInterval", 90);
                    component.set("v.dateRangeErrorMessage", $A.get("$Label.c.You_cannot_select_date_60_days_prior_or_90_days_after_the_current_date"));
                }
                
                component.set("v.cdaSetting", requestEditWrapper.cdaSettingValues);
                // console.log("cdaSetting", JSON.stringify(requestEditWrapper.cdaSettingValues));
                
                var cdaRequest = requestEditWrapper.cdaRequest;
                component.set("v.simpleRequestObject", cdaRequest);
                console.log("simpleRequestObject: " + JSON.stringify(cdaRequest));
                console.log("simpleRequestObject: IsSiteSignatorySameAsSiteContact__c------> " + cdaRequest.IsSiteSignatorySameAsSiteContact__c);
                console.log("simpleRequestObject: Disclosure_Period__c------> " + cdaRequest.Disclosure_Period__c);
                if(component.get("v.recordId") == null) {
                    //component.set("v.simpleRequestObject.Requestor_Carbon_Copies__c", true);
                    cdaRequest.Requestor_Carbon_Copies__c = true;
                }else {
                    console.log("Status: " + component.get("v.simpleRequestObject.Status__c"));
                    console.log("Location_of_Governing_Law__c: " + cdaRequest.Location_of_Governing_Law__c);
                    if(cdaRequest.Status__c == 'Contract Executed') {
                        this.openPopup(component, event, "executedRequestPopup");
                    }
                    
                    if(cdaRequest.QuintilesIMS_Business__c != null) {
                        this.iqviaBusiDependencyChange(component, cdaRequest.QuintilesIMS_Business__c);
                        component.set("v.qiLegalEntityFilter", "IQVIA_Business_Area__c = '" + cdaRequest.QuintilesIMS_Business__c + "' and Is_Active__c = true");
                    }
                    if(cdaRequest.CDA_Type__c != null) { 
                        this.cdaTypeDependencyChange(component, cdaRequest.CDA_Type__c);
                    } 
                    
                    console.log("CDA_Effective_Date__c: " + component.get("v.simpleRequestObject.CDA_Effective_Date__c"));
                    var cdaDatePicker = component.find("datePicker");
                    if(component.get("v.simpleRequestObject.CDA_Effective_Date__c") != null) {
                        cdaDatePicker.setDateValue();
                    }                    
                    
                    if(cdaRequest.Competitor_Contracting_Capacity__c != null 
                       && cdaRequest.Competitor_Contracting_Capacity__c != '') {
                        this.competitorContractCapacityDepChange(component, cdaRequest.Competitor_Contracting_Capacity__c);
                    }
                    
                    if(cdaRequest.Customer_Legal_Entity_Country_Other_PL__c != null 
                       && cdaRequest.Customer_Legal_Entity_Country_Other_PL__c != '') {
                        this.customerLegalEntityDepChange(component, cdaRequest.Customer_Legal_Entity_Country_Other_PL__c);
                    }
                    
                    if(cdaRequest.Recipient_Account_Country_Other_PL__c != null 
                       && cdaRequest.Recipient_Account_Country_Other_PL__c != '') {
                        this.recipientAccountDependencyChange(component, cdaRequest.Recipient_Account_Country_Other_PL__c);
                    }
                    
                    if (cdaRequest.Additional_Contact_Flag__c == 'Yes' && cdaRequest.Additional_Contact_Details__c != null) {
                        component.set("v.contactList", requestEditWrapper.cdaAdditionalContactWrapperList);
                    } else {
                        cdaRequest.Additional_Contact_Flag__c = 'No';
                    }
                    
                    if(cdaRequest.CDA_Type__c == 'Auditor'){
                        if(cdaRequest.QuintilesIMS_Business__c == $A.get("$Label.c.CDA_Research_Development_Solutions_RDS_Legacy_Quintiles")){
                            component.set("v.isAuditTypeDisabled", true);
                            component.set("v.isProjectSpeIndiDisabled", true);
                        }
                    }
                }
                component.set("v.simpleRequestObject", cdaRequest);
                var businessArea = component.get("v.simpleRequestObject.QuintilesIMS_Business__c");
                this.setIsPrivilegedBusinessAreaSelected(component, businessArea);
                this.setDefaults(component);
                console.log("QuintilesIMS_Business__c3: " + component.get("v.simpleRequestObject.QuintilesIMS_Business__c"));
                    
                this.hideSpinner(component);
                component.set("v.isNextButtonDisabled", false);
            }
        });
        $A.enqueueAction(action); 
        
        console.log('LXC_CDA_RequestEditScreen: js helper: setRequestEditDefaults End');
    },

    //setting flag for Privileged Business Area to enable a Requestor to select Legal entity
    setIsPrivilegedBusinessAreaSelected: function (component, businessArea) {
        var cdaSettingValue = component.get("v.cdaSetting");
        console.log('inside LXC_CDA_RequestEditScreenHelper.setIsPrivilegedBusinessAreaSelected Privileged_Business_Areas__c: ' + cdaSettingValue.Privileged_Business_Areas__c);

        if (cdaSettingValue.Privileged_Business_Areas__c != null && cdaSettingValue.Privileged_Business_Areas__c.includes(businessArea)) {
            component.set("v.isPrivilegedBusinessAreaSelected", true);
        }
        else {
            component.set("v.isPrivilegedBusinessAreaSelected", false);
        }
    },
    
    setControllerPicklistValues: function(component, depnedentFieldMap, contPicklistValuesList) {
        console.log('LXC_CDA_RequestEditScreen: js helper: setControllerPicklistValues start');
        console.log('contPicklistValuesList: ' + contPicklistValuesList);
        //console.log("requestEditWrapper.cdaRequestFieldsDetailMap: " + depnedentFieldMap);
           
        var listOfkeys = []; // for store all map keys (controller picklist values)
        var ControllerField = []; // for store controller picklist value to set on ui field. 
                
        for (var singlekey in depnedentFieldMap) {
            listOfkeys.push(singlekey);
        }                
        if (listOfkeys != undefined && listOfkeys.length > 0) {
            ControllerField.push({
                class: "optionClass",
                label: "--None--",
                value: null
            });
        }                
        for (var i = 0; i < listOfkeys.length; i++) {
            ControllerField.push({
                class: "optionClass",
                label: listOfkeys[i],
                value: listOfkeys[i]
            });
        }
        component.set("v." + contPicklistValuesList, ControllerField);  
        console.log('LXC_CDA_RequestEditScreen: js helper: setControllerPicklistValues End');            
    },
    
    fetchPicklistValues : function(component, sObjectType, contPicklistApiName, depPicklistApiName, fieldMap, contPicklistValuesList) {
        console.log('LXC_CDA_RequestEditScreen: js helper: fetchPicklistValues start');
        console.log('contPicklistApiName: ' + contPicklistApiName);
        console.log('depPicklistApiName: ' + depPicklistApiName);
        
        var action = component.get("c.getDependentOptionsImpl");
        
        action.setParams({
            'objApiName' : sObjectType,
            'contrfieldApiName' : contPicklistApiName,
            'depfieldApiName' : depPicklistApiName
        });
        
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var depnedentFieldMap = response.getReturnValue();
                
                component.set("v." + fieldMap, depnedentFieldMap);
                
                var listOfkeys = []; // for store all map keys (controller picklist values)
                var ControllerField = []; // for store controller picklist value to set on ui field. 
                
                for (var singlekey in depnedentFieldMap) {
                    listOfkeys.push(singlekey);
                }                
                if (listOfkeys != undefined && listOfkeys.length > 0) {
                    ControllerField.push({
                        class: "optionClass",
                        label: "--None--",
                        value: null
                    });
                }                
                for (var i = 0; i < listOfkeys.length; i++) {
                    ControllerField.push({
                        class: "optionClass",
                        label: listOfkeys[i],
                        value: listOfkeys[i]
                    });
                }
                component.set("v." + contPicklistValuesList, ControllerField);                
            }
        });
        $A.enqueueAction(action);
        console.log('LXC_CDA_RequestEditScreen: js helper: fetchPicklistValues End');
    }, 
    
    setDefaults: function(component) {
        console.log('LXC_CDA_RequestEditScreen: js helper: setDefaults start');
        
        this.preventConfirmEmailDefaults(component, component.find("recipeintConfirmEmail").getElement());
                
        var cdaRecord = component.get("v.simpleRequestObject");
        console.log('In setDefaults : cdaRecord.Location_of_Governing_Law__c : ' + cdaRecord.Location_of_Governing_Law__c);
        if (component.get("v.recordId") == null 
            || (cdaRecord.QI_Legal_Entity_Name__c == null
                || cdaRecord.Location_of_Governing_Law__c == null)) {
            this.setNewRequestDefaults(component, cdaRecord);
        } 
        
        // @@@@@@@@@ Will work later @@@@@@@ //
        /*
        qiLegalEntityRecord = SRV_CDA_CDARequest.getQILegalEntity(cdaRecord.QI_Legal_Entity_Name__c);
        qiLegalEntity = qiLegalEntityRecord.Name;
        governingLawRecord = SRV_CDA_CDARequest.getGoverningLaw(cdaRecord.Location_of_Governing_Law__c);    //Added by Vikram Singh under CR-11576
        governingLaw = governingLawRecord.Name; //Added by Vikram Singh under CR-11576*/
        
        
        component.set("v.isAuthorizedSigner", 'Yes');
        
        if(component.get("v.recordId") != null) {
            this.setEditRequestDefaults(component, cdaRecord);
        }
        if(cdaRecord.Disclosure_Period__c == null) {
            cdaRecord.Disclosure_Period__c = '5';
        }
        
        component.set("v.simpleRequestObject.Recipient_Account__c", cdaRecord.Recipient_Account__c);
        component.set('v.oldRecAccId', cdaRecord.Recipient_Account__c);
        component.set('v.oldCustLehEntityAccId', cdaRecord.Cust_Legal_Entity_Name__c);
        component.set("v.simpleRequestObject.Sponsor_Legal_Entity__c", cdaRecord.Sponsor_Legal_Entity__c);
        component.set("v.simpleRequestObject.Cust_Legal_Entity_Name__c", cdaRecord.Cust_Legal_Entity_Name__c);
        
        //component.set("v.customerLegalEntityAddress", cdaRecord.Cust_Legal_Entity_Address__c);
        //component.set("v.recipientAccountAddress", cdaRecord.Recipient_Account_Address__c);
        //component.set("v.sponsorLegalEntityAddress", cdaRecord.Sponsor_Legal_Entity_Address__c);
                    
        this.setQIBusinessPart(component);
                    
        this.setCdaType(component);
        if(component.get("v.recordId") != null && component.get("v.isCdaTypeAuditor")) {
            component.set("v.empClientCustomerOptionVal", 'No')
        }
        console.log('LXC_CDA_RequestEditScreen: js helper: setDefaults End');
    },
    
    preventConfirmEmailDefaults: function(component, confirmEmailElement) {
        console.log('LXC_CDA_RequestEditScreen: js helper: preventConfirmEmailDefaults start');
        
        console.log('confirmEmailElement: ' + confirmEmailElement);
        
        confirmEmailElement.addEventListener('paste', function(evt) {
            console.log('paste prevented');
            evt.preventDefault();
        });
        confirmEmailElement.addEventListener('copy', function(evt) {
            console.log('copy prevented');
            evt.preventDefault();
        });
        confirmEmailElement.addEventListener('cut', function(evt) {
            console.log('cut prevented');
            evt.preventDefault();
        });
        confirmEmailElement.addEventListener('drop', function(evt) {
            console.log('drop prevented');
            evt.preventDefault();
        });
        console.log('LXC_CDA_RequestEditScreen: js helper: preventConfirmEmailDefaults End');
    },
    
    setNewRequestDefaults: function(component, cdaRecord) {
        console.log('LXC_CDA_RequestEditScreen: js helper: setNewRequestDefaults start');
        
        var cdaSettingValue = component.get("v.cdaSetting");
        console.log('v.cdaSettingValue: ' + cdaSettingValue);
        
        cdaRecord.QI_Legal_Entity_Name__c = cdaSettingValue.Default_QI_Legal_Entity_Id__c != null ? cdaSettingValue.Default_QI_Legal_Entity_Id__c : '';
        cdaRecord.Location_of_Governing_Law__c = cdaSettingValue.Default_Governing_Law_Id__c != null ? cdaSettingValue.Default_Governing_Law_Id__c : '';
        
        console.log('cdaRecord.QI_Legal_Entity_Name__c: ' + cdaRecord.QI_Legal_Entity_Name__c);
        console.log('cdaRecord.Location_of_Governing_Law__c: ' + cdaRecord.Location_of_Governing_Law__c);
        
        cdaRecord.QuintilesIMS_Affiliates_Value__c = 'Yes';
        component.set("v.simpleRequestObject", cdaRecord);
        console.log('LXC_CDA_RequestEditScreen: js helper: setNewRequestDefaults End');
    },
    
    setEditRequestDefaults: function(component, cdaRecord) {
        console.log('LXC_CDA_RequestEditScreen: js helper: setEditRequestDefaults start');
        
        if (cdaRecord.Recipient_Authorized_Signer_First_Name__c != null) {
            component.set("v.isAuthorizedSigner", 'No');
        }
        
        if(cdaRecord.Customer_Legal_Entity_Name_Other__c != null) {
            component.set("v.isCustomerLegalEntityOther", true);
        } 
        
        if(cdaRecord.Recipient_Account_Name_Other__c != null) {
            component.set("v.isRecipientAccountNameOther", true);
        } 
        
        if(cdaRecord.Sponsor_Legal_Entity_Name_Other__c != null) {
            component.set("v.isSponsorLegalEntityNameOther", true);
        } 
        
        component.set("v.confirmEmailAddress", cdaRecord.Recipient_Point_of_Contact_Email_Address__c);
        
        if(component.get("v.isAuthorizedSigner") == 'Yes') {
            component.set("v.confirmRecipientAuthorizedSignerEmailAddress", cdaRecord.Recipient_Authorized_Signer_Email_Addres__c);
        }

        if(cdaRecord.Originating_Requestor_Flag__c == 'Yes') {
            if(cdaRecord.Originating_Requestor_IQVIA_Email__c != null) {
                component.set("v.originatingRequestorConfirmEmailAddress", cdaRecord.Originating_Requestor_IQVIA_Email__c);
            }
        }
        
        if(cdaRecord.Project_Description_Long_Textarea__c != null) {
            component.set("v.projectDescriptionValue", cdaRecord.Project_Description_Long_Textarea__c);
        }
        
        if(cdaRecord.QuintilesIMS_Business__c == $A.get("$Label.c.CDA_Strategic_Sites")){
            component.set("v.isCdaSourceDisabled", true);
        }
        
        console.log('LXC_CDA_RequestEditScreen: js helper: setEditRequestDefaults End');
    },
    
    setQIBusinessPart: function(component) {
        console.log('LXC_CDA_RequestEditScreen: js helper: setQIBusinessPart: start');
        
        var businessArea = component.get("v.simpleRequestObject.QuintilesIMS_Business__c");
        
        if(businessArea == $A.get("$Label.c.CDA_Technology_Analytics_Solutions_TAS_Legacy_IMS") 
           || businessArea == "Real World Solutions"
           || businessArea == $A.get("$Label.c.CDA_Contract_Sales_Medical_Solutions_CSMS_Legacy_IES")
           || businessArea == $A.get("$Label.c.CDA_Public_Health")) {
            component.set("v.isDataAndServices", true);
            component.set("v.isClinicalResearch", false);
        } else if(businessArea == $A.get("$Label.c.CDA_Research_Development_Solutions_RDS_Legacy_Quintiles") 
                  || businessArea == $A.get("$Label.c.CDA_Q_Squared")) {
            component.set("v.isDataAndServices", false);
            component.set("v.isClinicalResearch", true);
        } else {
            component.set("v.isDataAndServices", false);
            component.set("v.isClinicalResearch", false);   
        }
        
        console.log('component.get(v.isDataAndServices): ' + component.get("v.isDataAndServices"));
        console.log('component.get(v.competContractCapDepFieldMap): ' + component.get("v.competContractCapDepFieldMap"));
        console.log('LXC_CDA_RequestEditScreen: js helper: setQIBusinessPart: end');
    },
    
    fetchDepValues: function(component, ListOfDependentFields, depPicklistValuesListName, isDisabledFlag) {
        console.log('LXC_CDA_RequestEditScreen: js helper: fetchDepValues start');
        console.log('depPicklistValuesListName: ' + depPicklistValuesListName);
        console.log('ListOfDependentFields: ' + JSON.stringify(ListOfDependentFields));
                
        var dependentFields = [];
        
        if (ListOfDependentFields != undefined && ListOfDependentFields.length > 0) {
            dependentFields.push({
                class: "optionClass",
                label: "--None--",
                value: "" 
            });
            
        }
        for (var i = 0; i < ListOfDependentFields.length; i++) {
            dependentFields.push({
                class: "optionClass",
                label: ListOfDependentFields[i],
                value: ListOfDependentFields[i]
            });
        }
        //component.find('conState').set("v.options", dependentFields);
        component.set("v." + depPicklistValuesListName, dependentFields);
        component.set("v." + isDisabledFlag, false);
        console.log('LXC_CDA_RequestEditScreen: js helper: fetchDepValues End');
    },
    
    isValidEmail: function(component, sEmail) {
        console.log("LXC_CDA_RequestEditScreen: js helper: isValidEmail :  start");
        console.log('sEmail: ' + sEmail);
        var filter = /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        console.log('sEmail: ' + filter.test(sEmail));
        if (filter.test(sEmail)) {
            console.log('sEmail valid');
            return true;
        }
        else {
            console.log('sEmail invalid');
            return false;
        }
            
        console.log("LXC_CDA_RequestEditScreen: js helper: isValidEmail :  end");
    }, 

    validateCdaRequestForm : function(component) {
        console.log("LXC_CDA_RequestEditScreen: js helper: validateCdaRequestForm :  start");
        
        var cdaRequest = component.get("v.simpleRequestObject");
        var errorMessageBlock = component.find('errorMessageBlock');         
        var errorMsgs = [];   
        if (cdaRequest.Additional_Contact_Flag__c == 'Yes') {
            var addContactList = component.get("v.contactList");
            console.log('####validateCdaRequestForm addContactList: '+addContactList);
            if (addContactList == null || addContactList == '') {
                this.openPopup(component, event, "addContactInfo");
                return false;
            }
        }
        
        var allValid = component.find('editField').reduce( function(validSoFar, inputCmp) {
            // console.log('inputCmp: ' + inputCmp);
            if(inputCmp != null) {
                console.log('inputCmp: label ' + inputCmp.get('v.label'));
                console.log('inputCmp: label ' + inputCmp.isRendered());
                if(inputCmp.isRendered()) {
                    inputCmp.showHelpMessageIfInvalid();
                    if(inputCmp.get('v.validity').valueMissing) {
                        errorMsgs.push(inputCmp.get('v.label') + ': You must enter a value.'); 
                    } else if(inputCmp.get('v.validity').patternMismatch){
                        if (inputCmp.get('v.name') == 'acEmail'){
                            errorMsgs.push(inputCmp.get('v.label') + ': Please enter a valid email id');
                        }else{
                            errorMsgs.push(inputCmp.get('v.label') + ': Special characters are not allowed.');
                        }
                    }
                    return validSoFar && !inputCmp.get('v.validity').valueMissing && !inputCmp.get('v.validity').patternMismatch;
                }
                else {
                    return validSoFar;
                }
            }            
        }, true);
        
        console.log("allValid1: " + allValid);
        
        var cdadatePicker = component.find("datePicker");        
        var isValidateDateRange = cdadatePicker.validateDateRange();
        
        console.log('CDA_Effective_Date__c: ' + component.get("v.simpleRequestObject.CDA_Effective_Date__c"))
        
        if(cdaRequest.CDA_Effective_Date__c == null 
           || cdaRequest.CDA_Effective_Date__c == '' 
           || !isValidateDateRange) {
            allValid = false;
            
            if(!isValidateDateRange) {
                errorMsgs.push(cdadatePicker.get('v.label') + ': ' + component.get('v.dateRangeErrorMessage'));
                cdadatePicker.showError('Invalid Input');
            }
            else {
                errorMsgs.push(cdadatePicker.get('v.label') + ': You must enter a value.'); 
                cdadatePicker.showError('You must enter a value');
            }
        }
        
        console.log("allValid2: " + allValid);
        
        var recipientAccountLookup = component.find("recipientAccount");
        
        if(!component.get("v.isRecipientAccountNameOther") 
           && (cdaRequest.Recipient_Account__c == null || cdaRequest.Recipient_Account__c == '')) {
            allValid = false;
            recipientAccountLookup.showError('You must enter a value');
            errorMsgs.push(recipientAccountLookup.get('v.label') + ': You must enter a value.'); 
        }
        
        console.log("allValid3: " + allValid);
        
        var customLegalEntityLookup = component.find("customerLegalEntity");
        if(customLegalEntityLookup != null) {
            if(!component.get("v.isCustomerLegalEntityOther") 
               && (cdaRequest.Cust_Legal_Entity_Name__c == null 
                   || cdaRequest.Cust_Legal_Entity_Name__c == '')) {
                allValid = false;
                customLegalEntityLookup.showError('You must enter a value');
                errorMsgs.push(customLegalEntityLookup.get('v.label') + ': You must enter a value.'); 
            }
        } 
        
        var sponsorLegalEntityLookup = component.find("sponsorLegalEntity");
        if(sponsorLegalEntityLookup != null) {
            if(!component.get("v.isSponsorLegalEntityNameOther") 
               && (cdaRequest.Sponsor_Legal_Entity__c == null || cdaRequest.Sponsor_Legal_Entity__c == '')) {
                allValid = false;
                sponsorLegalEntityLookup.showError('You must enter a value');
                errorMsgs.push(sponsorLegalEntityLookup.get('v.label') + ': You must enter a value.'); 
            }
        } 
        
        var qiLegalEntityLookup = component.find("qiLegalEntity");
        
        if(cdaRequest.QI_Legal_Entity_Name__c != null){
            var qiLegalEntityObjSelected = component.get("v.qiLegalEntityObj");
            if(qiLegalEntityObjSelected != null && qiLegalEntityObjSelected != undefined && !qiLegalEntityObjSelected.Is_Active__c){
                component.set("v.simpleRequestObject.QI_Legal_Entity_Name__c", '');
            }
            if(qiLegalEntityObjSelected != null && qiLegalEntityObjSelected != undefined && qiLegalEntityObjSelected.Is_Signatories_Not_Available__c && cdaRequest.CDA_Format__c == 'PDF'){
                allValid = false;
            	errorMsgs.push('IQVIA Legal Entity Name: The selected Legal Entity does not have active Signatories So you can not select PDF Format. Please select Protected Word.'); 
            }
        }
        if(qiLegalEntityLookup != null) {
            if(cdaRequest.QI_Legal_Entity_Name__c == null || cdaRequest.QI_Legal_Entity_Name__c == '') {
                allValid = false;
                qiLegalEntityLookup.showError('You must enter a value');
                errorMsgs.push(qiLegalEntityLookup.get('v.label') + ': You must enter a value.'); 
            }
        } 
        
        var governingLawLookup = component.find("governingLaw");
        if(governingLawLookup != null) {
            governingLawLookup.hideError();
            if(cdaRequest.Location_of_Governing_Law__c == null || cdaRequest.Location_of_Governing_Law__c == '') {
                allValid = false;
                governingLawLookup.showError('You must enter a value');
                errorMsgs.push(governingLawLookup.get('v.label') + ': You must enter a value.'); 
            }
        } 
        
        console.log("allValid4: " + allValid);
        
        // Recipeint Point Of Contact Confirm Email validation
        var recipeintConfirmEmailInputCmp = component.find("recipeintConfirmEmail").getElement();
        var recipeintConfirmEmail = recipeintConfirmEmailInputCmp.value;
        component.set("v.confirmEmailAddress", recipeintConfirmEmail);
        var recipeintEmail = component.get('v.simpleRequestObject.Recipient_Point_of_Contact_Email_Address__c');
        console.log('recipeintConfirmEmail: ' + recipeintConfirmEmail);
        var recipeintConfirmEmailError = component.find("recipeintConfirmEmailError");
        var recipeintConfirmEmailItem = component.find("recipeintConfirmEmailItem");
        
        var recipeintEmailError = component.find("recipeintEmailError");
        var recipeintEmailItem = component.find("recipeintEmailItem");
        var requestEditWrapper = component.get("v.requestEditWrapper");
        var requestorDetail = requestEditWrapper.loggedIdUserDetail;
        $A.util.removeClass(recipeintEmailItem, "slds-has-error");
        $A.util.addClass(recipeintEmailError, "slds-hide");
        if(component.get("v.recordId") != null && component.get("v.recordId") != '') {
            requestorDetail = requestEditWrapper.cdaRequest.Owner;
        }        
        
        //console.log("$A.util.isEmpty(recipeintEmail): " + $A.util.isEmpty(recipeintEmail));
        if($A.util.isEmpty(recipeintEmail) == false) {
            //console.log("$A.util.isEmpty(recipeintEmail): " + $A.util.isEmpty(recipeintEmail));
            //console.log("!this.isValidEmail(component, recipeintEmail): " + !this.isValidEmail(component, recipeintEmail));
            if(!this.isValidEmail(component, recipeintEmail.trim())){
                //console.log("!this.isValidEmail(component, recipeintEmail): " + !this.isValidEmail(component, recipeintEmail.trim()));
                $A.util.removeClass(recipeintEmailError, "slds-hide");
            	$A.util.addClass(recipeintEmailItem, "slds-has-error");
                component.set('v.recipeintEmailError', 'You have entered an invalid format.');
                errorMsgs.push('Recipient Point-of-Contact Email : You have entered an invalid format.'); 
            }
        } else {
            $A.util.addClass(recipeintEmailError, "slds-hide");
            $A.util.removeClass(recipeintEmailItem, "slds-has-error");
        }
        
        if(recipeintConfirmEmail == null 
           || recipeintConfirmEmail == '' 
           || !this.isValidEmail(component, recipeintConfirmEmail)
            || (recipeintConfirmEmail.toLowerCase().trim() != recipeintEmail.toLowerCase().trim())) {
            
            allValid = false;
            
            $A.util.removeClass(recipeintConfirmEmailError, "slds-hide");
            $A.util.addClass(recipeintConfirmEmailItem, "slds-has-error");
            if(recipeintConfirmEmail == null || recipeintConfirmEmail == '') {
                component.set('v.recipeintConfirmEmailError', 'You must enter a value.');
                errorMsgs.push('Recipient Point-of-Contact Email Confirmation : You must enter a value.'); 
            }
            else if (recipeintConfirmEmail.toLowerCase().trim() != recipeintEmail.toLowerCase().trim()){
                component.set('v.recipeintConfirmEmailError', 'Email does not match the confirm Email');
                errorMsgs.push('Recipient Point-of-Contact Email Confirmation : Email does not match the confirm Email.'); 
            } else {
                component.set('v.recipeintConfirmEmailError', 'You have entered an invalid format.');
                errorMsgs.push('Recipient Point-of-Contact Email Confirmation : You have entered an invalid format.'); 
            }
        } else if(recipeintConfirmEmail.substring(0, recipeintConfirmEmail.indexOf('@')).toUpperCase() == requestorDetail.Email.substring(0, requestorDetail.Email.indexOf('@')).toUpperCase()) {
            allValid = false;
            $A.util.removeClass(recipeintEmailError, "slds-hide");
            $A.util.addClass(recipeintEmailItem, "slds-has-error");
            component.set('v.recipeintEmailError', 'The Requestor and the Recipient cannot be the same individual. Please correct the Recipients name and email address.');
            errorMsgs.push('Recipient Point-of-Contact Email : The Requestor and the Recipient cannot be the same individual. Please correct the Recipients name and email address.');
        } else {
            $A.util.addClass(recipeintConfirmEmailError, "slds-hide");
            $A.util.removeClass(recipeintConfirmEmailItem, "slds-has-error");
        }
        
        // Originating Requestor IQVIA Confirm Email validation
        var originatingReqConfirmEmailInput = component.find("originatingReqConfirmEmail");
        var originatingReqEmail = component.get('v.simpleRequestObject.Originating_Requestor_IQVIA_Email__c');
        var originatingReqEmailError = component.find("originatingReqEmailError");
        var originatingReqEmailItem = component.find("originatingReqEmailItem");
        
        if($A.util.isEmpty(originatingReqEmail) == false) {
            //console.log("$A.util.isEmpty(originatingReqEmail): " + $A.util.isEmpty(originatingReqEmail));
            //console.log("!this.isValidEmail(component, originatingReqEmail): " + !this.isValidEmail(component, originatingReqEmail));
            if(!this.isValidEmail(component, originatingReqEmail.trim())){
                //console.log("!this.isValidEmail(component, originatingReqEmail): " + !this.isValidEmail(component, originatingReqEmail.trim()));
                $A.util.removeClass(originatingReqEmailError, "slds-hide");
            	$A.util.addClass(originatingReqEmailItem, "slds-has-error");
                component.set('v.originatingReqEmailError', 'You have entered an invalid format.');
                errorMsgs.push('Originating Requestor IQVIA Email : You have entered an invalid format.'); 
            }
        } else {
            $A.util.addClass(originatingReqEmailError, "slds-hide");
            $A.util.removeClass(originatingReqEmailItem, "slds-has-error");
        }
        
        if(originatingReqConfirmEmailInput != null) {
            var originatingReqConfirmEmailInputCmp = originatingReqConfirmEmailInput.getElement();
            var originatingReqConfirmEmail = originatingReqConfirmEmailInputCmp.value;
            component.set("v.originatingRequestorConfirmEmailAddress", originatingReqConfirmEmail);
            
            console.log('originatingReqConfirmEmail: ' + originatingReqConfirmEmail);
            var originatingReqConfirmEmailError = component.find("originatingReqConfirmEmailError");
            var originatingReqConfirmEmailItem = component.find("originatingReqConfirmEmailItem");
            //var originatingReqEmailItem = component.get('v.simpleRequestObject.Originating_Requestor_IQVIA_Email__c');
            if(originatingReqConfirmEmail == null 
               || originatingReqConfirmEmail == '' 
               || !this.isValidEmail(component, originatingReqConfirmEmail)
                || (originatingReqConfirmEmail.toLowerCase().trim() != originatingReqEmail.toLowerCase().trim())) {
            
                allValid = false;
                
                $A.util.removeClass(originatingReqConfirmEmailError, "slds-hide");
                $A.util.addClass(originatingReqConfirmEmailItem, "slds-has-error");
                if(originatingReqConfirmEmail == null || originatingReqConfirmEmail == '') {
                    component.set('v.originatingReqConfirmEmailError', 'You must enter a value.');
                    errorMsgs.push('Originating Requestor IQVIA Confirm Email : You must enter a value.');
                } else if (originatingReqConfirmEmail.toLowerCase().trim() != originatingReqEmail.toLowerCase().trim()){
                    component.set('v.originatingReqConfirmEmailError', 'Email does not match the confirm Email');
                    errorMsgs.push('Originating Requestor IQVIA Confirm Email : Email does not match the confirm Email.'); 
                } 
                else {
                    component.set('v.originatingReqConfirmEmailError', 'You have entered an invalid format.');
                    errorMsgs.push('Originating Requestor IQVIA Confirm Email : You have entered an invalid format.');
                }
            } else {
                $A.util.addClass(originatingReqConfirmEmailError, "slds-hide");
                $A.util.removeClass(originatingReqConfirmEmailItem, "slds-has-error");
            }
        }
        
        // Site Contact Email validation
        var siteContactEmail = component.get('v.simpleRequestObject.Site_Contact_Email_Address__c');
        var siteContactEmailError = component.find("siteContactEmailError");
        var siteContactEmailItem = component.find("siteContactEmailItem");
        
        if($A.util.isEmpty(siteContactEmail) == false) {
            //console.log("$A.util.isEmpty(originatingReqEmail): " + $A.util.isEmpty(siteContactEmail));
            //console.log("!this.isValidEmail(component, originatingReqEmail): " + !this.isValidEmail(component, siteContactEmail));
            if(!this.isValidEmail(component, siteContactEmail.trim())){
                //console.log("!this.isValidEmail(component, originatingReqEmail): " + !this.isValidEmail(component, siteContactEmail.trim()));
                $A.util.removeClass(siteContactEmailError, "slds-hide");
            	$A.util.addClass(siteContactEmailItem, "slds-has-error");
                component.set('v.siteContactEmailError', 'You have entered an invalid format.');
                errorMsgs.push('Site Contact Email Address : You have entered an invalid format.'); 
            }
        } else {
            $A.util.addClass(originatingReqEmailError, "slds-hide");
            $A.util.removeClass(originatingReqEmailItem, "slds-has-error");
        }
        
        component.set('v.errorMsgs', errorMsgs);
        console.log("errorMsgs: " + errorMsgs);
        console.log("allValid4: " + allValid);
        if(allValid) {
            console.log("++++++++++++++++++++ "+allValid); 
            console.log("----------------------------------------------------------> " + (cdaRequest.QuintilesIMS_Business__c == $A.get("$Label.c.CDA_Research_Development_Solutions_RDS_Legacy_Quintiles") || cdaRequest.QuintilesIMS_Business__c == $A.get("$Label.c.CDA_Q_Squared")) && cdaRequest.Project_Specific_Indicator__c == 'No' && component.get('v.qiLegalEntityObj').is_For_RDS_Q2_Broad__c == true && (cdaRequest.CDA_Language__c != 'English' || cdaRequest.CDA_Language__c != 'Chinese'));
            if((cdaRequest.QuintilesIMS_Business__c == $A.get("$Label.c.CDA_Research_Development_Solutions_RDS_Legacy_Quintiles") || cdaRequest.QuintilesIMS_Business__c == $A.get("$Label.c.CDA_Q_Squared")) && cdaRequest.Project_Specific_Indicator__c == 'No' && component.get('v.qiLegalEntityObj').is_For_RDS_Q2_Broad__c == true && cdaRequest.CDA_Language__c != 'English'){
                if(cdaRequest.CDA_Language__c != 'Chinese' && cdaRequest.CDA_Language__c != 'Chinese (Bilingual)'){
                    this.openPopup(component, event, "broadCDALangPopup");
                    return false;
                }
            }
            component.set("v.isNextButtonDisabled", true);
            $A.util.addClass(errorMessageBlock, "slds-hide"); 
            return true;
        }
        else {
            console.log("++++++++++++++++++++--------- "+allValid);
            component.set("v.isNextButtonDisabled", false);
            $A.util.removeClass(errorMessageBlock, "slds-hide");
            window.scrollTo(0, 0);
        }
        console.log('LXC_CDA_RequestEditScreen: js helper: validateCdaRequestForm End');
    }, 
    
    showSpinner: function (component) {
        console.log('LXC_CDA_RequestEditScreen: js helper: showSpinner start');
        var spinner = component.find("mySpinner");
        $A.util.removeClass(spinner, "slds-hide");
        console.log('LXC_CDA_RequestEditScreen: js helper: showSpinner End');
    },
     
    hideSpinner: function (component) {
        console.log('LXC_CDA_RequestEditScreen: js helper: hideSpinner start');
        var spinner = component.find("mySpinner");
        $A.util.addClass(spinner, "slds-hide");
        console.log('LXC_CDA_RequestEditScreen: js helper: hideSpinner End');
    }, 
    
    openPopup: function(component, event, popupType) {
        console.log('LXC_CDA_RequestEditScreen: js helper: openPopup start');
        component.set("v.isPopupOpen", true);
        component.set("v.popupType", popupType);
        component.set("v.isShowPopupFooter", true);
        var tempMap = new Map();
        if(popupType == 'quintilesLegacyIMSPopup' || popupType == 'quintilesFinancePopup' || popupType == 'externalCdaSource') {
            tempMap['button1'] = 'Yes';
            tempMap['button2'] = 'No';
        } else if(popupType == 'quintilesBusinessAckPopupLegacyIms' 
                  || popupType == 'quintilesBusinessAckPopupfinance'
                  || popupType == 'cdaFormatProtectedWord' 
                  || popupType == 'empClientCustomerPopup'
                  || popupType == 'CompetitorAuditorPopup') {
            tempMap['button1'] = 'Acknowledge';
            tempMap['button2'] = 'Cancel';
        } else if(popupType == 'cdalanguageInfo' 
                  || popupType == 'externalOnlyWordPopup' 
                  || popupType == 'cdaFormatProtectedWordAckAlert'
                  || popupType == 'CompAuditorSrMangPopup'
                  || popupType == 'cdaDiscloseApprovalIndicationPopup'
                  || popupType == 'cdaCustomerConsentInfoPopup'
                  || popupType == 'customerLegalEntityChangePopup'
                  || popupType == 'competitorContractingCapacityPopup'
                  || popupType == 'sponsorLegalEntityNameOtherPopup'
                  || popupType == 'sponsorConsentToDiscloseNoPopup'
                  || popupType == 'sponsorConsentToDiscloseYesPopup'
                  || popupType == 'recipientAccountChangePopup'
                  || popupType == 'saveForLaterPopup'
                  || popupType == 'executedRequestPopup'
                  || popupType == 'qualificationQuestionPopupYes' 
                  || popupType == 'addContactInfo'
                  || popupType == 'broadCDALangPopup') {
            tempMap['button1'] = 'Ok';
            tempMap['button2'] = null;
        } else if(popupType == 'verifyIqviaPaperPopup') {
            tempMap['button1'] = 'Save';
            tempMap['button2'] = 'Back';
        } else if(popupType == 'cusVenTemplateYes') {
            tempMap['button1'] = 'Acknowledge';
            tempMap['button2'] = null;
        } else if(popupType == 'qualificationQuestionPopup') {
            tempMap['button1'] = 'Yes';
            tempMap['button2'] = 'No';
        } else if(popupType == 'broadCDAPopup'){
            tempMap['button1'] = 'CDA Not Needed';
            tempMap['button2'] = 'Continue';
            tempMap['button3'] = 'Project Specific';
        }else if(popupType == 'recAccPopup'){
            tempMap['button1'] = 'Yes';
            tempMap['button2'] = 'No';
        }else if(popupType == 'recAccIsMaster'){
            tempMap['button1'] = 'Continue';
            tempMap['button2'] = 'Exit';
        }
        
        component.set("v.popupButtonMap", tempMap);
        console.log('LXC_CDA_RequestEditScreen: js helper: openPopup End');        
    },
    
    navigateToLandingPage: function(component) {
        console.log('LXC_CDA_RequestEditScreen: js helper: navigateToLandingPage start');
        component.set("v.isPopupOpen", false);
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:LXC_CDA_LandingPage",
            componentAttributes: {}
        });
        evt.fire();
        console.log('LXC_CDA_RequestEditScreen: js helper: navigateToLandingPage End');
    }, 
    
    navigateToRecord : function(component, cdaRequest) {
        console.log('In LXC_CDA_RequestEditScreen controller: navigateToRecord Start');
        console.log('cdaRequest: ' + cdaRequest);
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId" : cdaRequest.Id
        });
        navEvt.fire();
        console.log('In LXC_CDA_RequestEditScreen controller: navigateToRecord End');
    },
    
    sponsorLegalEntityNameOtherPopup: function(component, event) {
        console.log('LXC_CDA_RequestEditScreen: js helper: sponsorLegalEntityNameOtherPopup start');
        if(component.get("v.isSponsorLegalEntityNameOther")) {
            component.set("v.simpleRequestObject.Sponsor_Legal_Entity__c", null);
            this.openPopup(component, event, "sponsorLegalEntityNameOtherPopup");
        }
        console.log('LXC_CDA_RequestEditScreen: js helper: sponsorLegalEntityNameOtherPopup End');
    },
    
    resetDefaults: function(component) {
        console.log('LXC_CDA_RequestEditScreen: js helper: resetDefaults start');
        var cdaRecord = component.get("v.simpleRequestObject");
        var requestEditWrapper = component.get("v.requestEditWrapper");
        var requestorDetail = requestEditWrapper.loggedIdUserDetail;
        if(cdaRecord.QuintilesIMS_Business__c == $A.get("$Label.c.CDA_Strategic_Sites")){
            cdaRecord.Disclosure_Period__c = '10';
            cdaRecord.CDA_Source__c = 'IQVIA';
            cdaRecord.IQVIA_Contact_Name__c = requestorDetail.Name;
            cdaRecord.Project_Specific_Indicator__c = null;
            component.set("v.isCdaSourceDisabled", true);
        }else{
            component.set("v.isCdaSourceDisabled", false);
            cdaRecord.CDA_Source__c = null;
        }
        cdaRecord.CDA_Format__c = null;
        cdaRecord.Competitor_Flag__c = null;
        cdaRecord.Additional_Contact_Flag__c = 'No';
        cdaRecord.Audit_Type__c = null;
        cdaRecord.Customer_Consent_to_Disclose__c = null;
        component.set("v.isCustomerLegalEntityOther", false);
        
        this.resetDefaultQILegalEntity(component, cdaRecord);        
        this.setCustomerLegalEntityOther(component);
        this.setSpecificIndicatorMethod(component, event);
        this.resetOriginatingRequestorFlag(component); 
        this.recipientAccountNameOtherChanged(component);
        this.sponsorConsentToDiscloseChanged(component, cdaRecord);
        this.recipientPointOfContactChanged(component, cdaRecord);
        this.recipientAuthorizedSignerChanged(component, cdaRecord);        
        
        component.set("v.simpleRequestObject", cdaRecord);
        console.log('LXC_CDA_RequestEditScreen: js helper: resetDefaults End');        
    },
    
    resetDefaultValues: function(component) {
        console.log('LXC_CDA_RequestEditScreen: js helper: resetDefaultValues start');
        this.resetDefaults(component);
        this.qiBusinessPartChanged(component);
        console.log('LXC_CDA_RequestEditScreen: js helper: resetDefaultValues End');
    },
    
    qiBusinessPartChanged: function(component) {
        console.log('LXC_CDA_RequestEditScreen: js helper: qiBusinessPartChanged start');
        component.set("v.simpleRequestObject.CDA_Type__c", null);
        this.setQIBusinessPart(component);
        console.log('LXC_CDA_RequestEditScreen: js helper: qiBusinessPartChanged End');
    },
    
    recipientPointOfContactChanged: function(component, cdaRecord) {
        console.log('LXC_CDA_RequestEditScreen: js helper: recipientPointOfContactChanged start');
        cdaRecord.Recipient_Point_of_Contact_Prefix__c = null;
        cdaRecord.Recipient_Point_of_Contact_First_Name__c = null;
        cdaRecord.Recipient_Point_of_Contact_Last_Name__c = null;
        cdaRecord.Recipient_Point_of_Contact_Title__c = null;
        cdaRecord.Recipient_Point_of_Contact_Telephone_Num__c = null;
        cdaRecord.Recipient_Point_of_Contact_Email_Address__c = null;
        cdaRecord.Recipient_Point_of_Contact_Preferred_Met__c = 'Email';
        component.set("v.confirmEmailAddress", null);
        component.set("v.isAuthorizedSigner", 'Yes');
        component.set("v.simpleRequestObject", cdaRecord);
        console.log('LXC_CDA_RequestEditScreen: js helper: recipientPointOfContactChanged end');
    },
    
    recipientAuthorizedSignerChanged: function(component, cdaRecord) {
        console.log('LXC_CDA_RequestEditScreen: js helper: recipientAuthorizedSignerChanged start');
        cdaRecord.Recipient_Authorized_Signer_Title__c = null;
        cdaRecord.Recipient_Authorized_Signer_First_Name__c = null;
        cdaRecord.Recipient_Authorized_Signer_Last_Name__c = null;
        cdaRecord.Recipient_Authorized_Signer_Email_Addres__c = null;
        component.set("v.confirmRecipientAuthorizedSignerEmailAddress", null);
        component.set("v.simpleRequestObject", cdaRecord);
        console.log('LXC_CDA_RequestEditScreen: js helper: recipientAuthorizedSignerChanged end');
    },
    
    resetOriginatingRequestorFlag: function(component) {
        console.log('LXC_CDA_RequestEditScreen: js helper: resetOriginatingRequestorFlag start');
        component.set("v.simpleRequestObject.Originating_Requestor_Flag__c", null);
        
        this.resetOriginatingRequestorSection(component);
        console.log('LXC_CDA_RequestEditScreen: js helper: resetOriginatingRequestorFlag end');
    },
    
    resetDefaultQILegalEntity: function(component, cdaRecord) {
        console.log('LXC_CDA_RequestEditScreen: js helper: resetDefaultQILegalEntity start');
        var cdaSettingValue = component.get("v.cdaSetting");
        
        if(cdaRecord.QuintilesIMS_Business__c == $A.get("$Label.c.CDA_Contract_Sales_Medical_Solutions_CSMS_Legacy_IES")) {
            component.set("v.simpleRequestObject.QI_Legal_Entity_Name__c", null);
            cdaRecord.QI_Legal_Entity_Name__c = cdaSettingValue.Default_Legal_Entity_Id_CSMS__c != null ? cdaSettingValue.Default_Legal_Entity_Id_CSMS__c : '';
        }
        else if(cdaRecord.QuintilesIMS_Business__c == $A.get("$Label.c.CDA_Q_Squared")){
            component.set("v.simpleRequestObject.QI_Legal_Entity_Name__c", null);
            cdaRecord.QI_Legal_Entity_Name__c = cdaSettingValue.Default_Legal_Entity_Id_Q_Squared__c != null ? cdaSettingValue.Default_Legal_Entity_Id_Q_Squared__c : '';
        }
        else if(cdaRecord.QuintilesIMS_Business__c == $A.get("$Label.c.CDA_Research_Development_Solutions_RDS_Legacy_Quintiles")){
            component.set("v.simpleRequestObject.QI_Legal_Entity_Name__c", null);
            cdaRecord.QI_Legal_Entity_Name__c = cdaSettingValue.Default_QI_Legal_Entity_Id__c != null ? cdaSettingValue.Default_QI_Legal_Entity_Id__c : '';
        }
        else if(cdaRecord.QuintilesIMS_Business__c == $A.get("$Label.c.CDA_Technology_Analytics_Solutions_TAS_Legacy_IMS") || cdaRecord.QuintilesIMS_Business__c == 'Real World Solutions'){
            component.set("v.simpleRequestObject.QI_Legal_Entity_Name__c", null);
            cdaRecord.QI_Legal_Entity_Name__c = cdaSettingValue.Default_Legal_Entity_Id_IQVIA_Commercial__c != null ? cdaSettingValue.Default_Legal_Entity_Id_IQVIA_Commercial__c : '';
        }else if(cdaRecord.QuintilesIMS_Business__c == $A.get("$Label.c.CDA_Public_Health")){
            component.set("v.simpleRequestObject.QI_Legal_Entity_Name__c", null);
            cdaRecord.QI_Legal_Entity_Name__c = cdaSettingValue.Default_Legal_Entity_Id_Public_Health__c != null ? cdaSettingValue.Default_Legal_Entity_Id_Public_Health__c : '';
        }else if(cdaRecord.QuintilesIMS_Business__c == $A.get("$Label.c.CDA_Strategic_Sites")){
            component.set("v.simpleRequestObject.QI_Legal_Entity_Name__c", null);
            cdaRecord.QI_Legal_Entity_Name__c = cdaSettingValue.Default_Legal_Entity_Id_Strategic_Site__c != null ? cdaSettingValue.Default_Legal_Entity_Id_Strategic_Site__c : '';
        }
        cdaRecord.Location_of_Governing_Law__c = cdaSettingValue.Default_Governing_Law_Id__c != null ? cdaSettingValue.Default_Governing_Law_Id__c : '';
        
        console.log('cdaRecord.QI_Legal_Entity_Name__c: ' + cdaRecord.QI_Legal_Entity_Name__c);
        console.log('cdaRecord.Location_of_Governing_Law__c: ' + cdaRecord.Location_of_Governing_Law__c);
        
        component.set("v.simpleRequestObject", cdaRecord);
        
        console.log('LXC_CDA_RequestEditScreen: js helper: resetDefaultQILegalEntity end');
    },
    
    setCdaType: function(component) {
        console.log('LXC_CDA_RequestEditScreen: js helper: setCdaType start');
        var cdaRequest = component.get("v.simpleRequestObject");
        component.set("v.isCdaTypeAuditor", ((cdaRequest.CDA_Type__c == 'Auditor') ? true : false));
        component.set("v.isCdaTypeVendor", ((cdaRequest.CDA_Type__c == 'Vendor') ? true : false));
        component.set("v.isCdaTypeCustomer", ((cdaRequest.CDA_Type__c == 'Customer') ? true : false));
        component.set("v.isCdaTypeCEVA", ((cdaRequest.CDA_Type__c == 'CEVA') ? true : false));
        
        console.log("cdaRequest.CDA_Type__c : " + cdaRequest.CDA_Type__c);
        console.log('LXC_CDA_RequestEditScreen: js helper: setCdaType End');
    }, 
    
    displayCDASourcePopup: function(component, event) {
        console.log('LXC_CDA_RequestEditScreen: js helper: displayCDASourcePopup start');
        var cdaSourceVal = component.get("v.simpleRequestObject.CDA_Source__c");
        
        if (cdaSourceVal == 'External') {
            this.openPopup(component, event, "externalCdaSource");
        }
        console.log('LXC_CDA_RequestEditScreen: js helper: displayCDASourcePopup End');
    }, 
    
    displaycustomerSpecifiedVendorTemplatePopup: function(component, event) {
        console.log('LXC_CDA_RequestEditScreen: js helper: displaycustomerSpecifiedVendorTemplatePopup:  start');
        var cusVenTemplate = component.get("v.simpleRequestObject.Customer_Specified_Vendor_Template__c");
        
        if (cusVenTemplate == 'Yes') {
            this.openPopup(component, event, "cusVenTemplateYes");
        }
        console.log('LXC_CDA_RequestEditScreen: js helper: displaycustomerSpecifiedVendorTemplatePopup End');
    }, 
    
    cdaRequestDeleteAndReturnToLanding: function(component) {
        console.log('LXC_CDA_RequestEditScreen: js helper: cdaRequestDeleteAndReturnToLanding start');
        var cdaRecord = component.get("v.simpleRequestObject");
        if(cdaRecord != null && cdaRecord.Id != null && cdaRecord.Status__c != 'Sent for Signature') {
            //detele cda request code will work later
        }
        this.navigateToLandingPage(component);
        console.log('LXC_CDA_RequestEditScreen: js helper: cdaRequestDeleteAndReturnToLanding End');
    }, 
    
    setSpecificIndicatorMethod: function(component, event) {
        console.log('LXC_CDA_RequestEditScreen: js helper: setSpecificIndicatorMethod: start');
        var cdaRecord = component.get("v.simpleRequestObject");
        if(cdaRecord.CDA_Type__c == 'Auditor') {
            if (cdaRecord.Audit_Type__c == 'Project') {
                cdaRecord.Project_Specific_Indicator__c = 'Yes';
            } else if (cdaRecord.Audit_Type__c == 'Qualification') {
                cdaRecord.Project_Specific_Indicator__c = 'No';
            } else {
                cdaRecord.Project_Specific_Indicator__c = null;
            }
        } else if(cdaRecord.CDA_Type__c == 'Vendor') {
            if((cdaRecord.QuintilesIMS_Business__c != $A.get("$Label.c.CDA_Research_Development_Solutions_RDS_Legacy_Quintiles") && cdaRecord.QuintilesIMS_Business__c != $A.get("$Label.c.CDA_Q_Squared"))){
                cdaRecord.Project_Specific_Indicator__c = 'Yes';
            }
        } else if (cdaRecord.Competitor_Flag__c == 'Yes') {
            cdaRecord.Project_Specific_Indicator__c = 'Yes';
        } else if (cdaRecord.Competitor_Flag__c == 'No') {
            cdaRecord.Project_Specific_Indicator__c = null;
        }
        component.set("v.simpleRequestObject", cdaRecord);
        this.competitorFlagChanged(component); 
        console.log('LXC_CDA_RequestEditScreen: js helper: setSpecificIndicatorMethod: end');
    },
    
    competitorFlagChanged: function(component) {
        console.log('LXC_CDA_RequestEditScreen: js helper: competitorFlagChanged: start');
        var cdaRecord = component.get("v.simpleRequestObject");
        cdaRecord.Competitor_Contracting_Capacity__c = null;
        cdaRecord.Competitor_Originating_from_Sponsor__c = null;
        if(cdaRecord.Competitor_Flag__c != 'Yes') {
            this.recipientAccountNameOtherChanged(component);
        }
        this.competitorContractingCapacityChanged(component);
        console.log('LXC_CDA_RequestEditScreen: js helper: competitorFlagChanged: end');
    }, 
    
    recipientAccountNameOtherChanged: function(component) {
        console.log('LXC_CDA_RequestEditScreen: js helper: recipientAccountNameOtherChanged: start');
        var cdaRecord = component.get("v.simpleRequestObject");
        cdaRecord.Recipient_Account__c = null;
        component.set("v.recipientAccount", null);
        //component.set("v.recipientAccountAddress", null);
        //component.set("v.recipientAccountName", null);
        cdaRecord.Recipient_Account_Name_Other__c = null;
        cdaRecord.Recipient_Account_Street_Other__c = null;
        cdaRecord.Recipient_Account_City_Other__c = null;
        cdaRecord.Recipient_Account_State_Other_PL__c = null;
        cdaRecord.Recipient_Account_Country_Other_PL__c = null;
        cdaRecord.Recipient_Account_ZipCode_Other__c = null;
        component.set("v.simpleRequestObject", cdaRecord);
        console.log('LXC_CDA_RequestEditScreen: js helper: recipientAccountNameOtherChanged: End');
    }, 
    
    competitorContractingCapacityChanged: function(component) {
        console.log('LXC_CDA_RequestEditScreen: js helper: competitorContractingCapacityChanged: start');
        var cdaRecord = component.get("v.simpleRequestObject");
        if(!component.get("v.isCdaTypeAuditor") && cdaRecord.Project_Specific_Indicator__c != 'Yes') { 
            this.isProtocolNumberKnownChanged(component, cdaRecord);
        }
        this.whatIsTheStudySponsorSituationChanged(component, cdaRecord);
        cdaRecord.Competitor_System_Access__c = null;
        this.competitorSystemAccessChanged(component, cdaRecord);
        console.log('LXC_CDA_RequestEditScreen: js helper: competitorContractingCapacityChanged: end');
    }, 
    
    isProtocolNumberKnownChanged: function(component, cdaRecord) {
        console.log('LXC_CDA_RequestEditScreen: js helper: isProtocolNumberKnownChanged start');
        //cdaRecord.Is_Protocol_Number_Known__c = null;
        component.set("v.simpleRequestObject.Is_Protocol_Number_Known__c", null);
        this.isProtocolTitleKnownChanged(component, cdaRecord);
        console.log('LXC_CDA_RequestEditScreen: js helper: isProtocolNumberKnownChanged end');
    }, 
    
    isProtocolTitleKnownChanged: function(component, cdaRecord) {
        console.log('LXC_CDA_RequestEditScreen: js helper: isProtocolTitleKnownChanged start');
        //cdaRecord.Protocol_Number__c = null;
        //cdaRecord.Is_Protocol_Title_Known__c = null;
        component.set("v.simpleRequestObject.Protocol_Number__c", null);
        component.set("v.simpleRequestObject.Is_Protocol_Title_Known__c", null);
        this.isProtocolTitleDiscriptionChanged(component, cdaRecord);
        console.log('LXC_CDA_RequestEditScreen: js helper: isProtocolTitleKnownChanged end');
    }, 
    
    isProtocolTitleDiscriptionChanged: function(component, cdaRecord) {
        console.log('LXC_CDA_RequestEditScreen: js helper: isProtocolTitleDiscriptionChanged start');
        //cdaRecord.Protocol_Title_Long_Textarea__c = null;
        //cdaRecord.Project_Description_Long_Textarea__c = null;
        component.set("v.simpleRequestObject.Protocol_Title_Long_Textarea__c", null);
        component.set("v.simpleRequestObject.Project_Description_Long_Textarea__c", null);
        console.log('LXC_CDA_RequestEditScreen: js helper: isProtocolTitleDiscriptionChanged end');
    }, 
    
    whatIsTheStudySponsorSituationChanged: function(component, cdaRecord) {
        console.log('LXC_CDA_RequestEditScreen: js helper: whatIsTheStudySponsorSituationChanged start');
        cdaRecord.What_is_the_Study_Sponsor_situation__c = null;
        component.set("v.simpleRequestObject", cdaRecord);
        this.sponsorConsentToDiscloseChanged(component, cdaRecord);
        console.log('LXC_CDA_RequestEditScreen: js helper: whatIsTheStudySponsorSituationChanged end');
    },
    
    sponsorConsentToDiscloseChanged: function(component, cdaRecord) {
        console.log('LXC_CDA_RequestEditScreen: js helper: sponsorConsentToDiscloseChanged start');
        if (cdaRecord.Sponsor_Consent_to_Disclose__c != null 
            && (cdaRecord.What_is_the_Study_Sponsor_situation__c != 'Study Sponsor identified'
                || (cdaRecord.What_is_the_Study_Sponsor_situation__c == null 
                    && cdaRecord.What_is_the_Study_Sponsor_situation__c == ''))) {
            cdaRecord.Sponsor_Consent_to_Disclose__c = null;
        }
        this.sponsorLegalEntityNameOtherChanged(component, cdaRecord);
        component.set("v.simpleRequestObject", cdaRecord);
        console.log('LXC_CDA_RequestEditScreen: js helper: sponsorConsentToDiscloseChanged end');
    }, 
    
    sponsorLegalEntityNameOtherChanged: function(component, cdaRecord) {
        console.log('LXC_CDA_RequestEditScreen: js helper: sponsorLegalEntityNameOtherChanged start');
        cdaRecord.Sponsor_Legal_Entity__c = null;
        component.set("v.sponsorLegalEntity", null);
        //component.set("v.sponsorLegalEntityName", null);
        //component.set("v.sponsorLegalEntityAddress", null);
        cdaRecord.Sponsor_Legal_Entity_Name_Other__c = null;
        component.set("v.simpleRequestObject", cdaRecord);
        console.log('LXC_CDA_RequestEditScreen: js helper: sponsorLegalEntityNameOtherChanged end');
    }, 
    
    competitorSystemAccessChanged: function(component, cdaRecord) {
        console.log('LXC_CDA_RequestEditScreen: js helper: competitorSystemAccessChanged start');
        cdaRecord.Systems_To_Be_Accessed__c = null;
        cdaRecord.Purpose_for_Working_for_a_Competitor__c = null;
        cdaRecord.Description_of_work_provided_to_Customer__c = null;
        cdaRecord.Desc_of_Work_provided_to_Cust_By_Comp__c = null;
        cdaRecord.QI_information_disclosed_to_competitor__c = null;
        cdaRecord.Competitor_information_disclosed_to_QI__c = null;
        component.set("v.simpleRequestObject", cdaRecord);
        console.log('LXC_CDA_RequestEditScreen: js helper: competitorSystemAccessChanged end');
    },
    
    setSpecificIndicator: function(component, event) {
        console.log('LXC_CDA_RequestEditScreen: js helper: setSpecificIndicator:  start');
        var CompetitorFlagVal = component.get("v.simpleRequestObject.Competitor_Flag__c");
        var cdaType = component.get("v.simpleRequestObject.CDA_Type__c");
        
        if (cdaType == 'Auditor') {
            component.set("v.isProjectSpeIndiDisabled", true);
        }
        if (CompetitorFlagVal == 'Yes') {
            if (cdaType == 'Auditor') {
                this.isCompetitorAuditor(component);
            } else {
                this.openPopup(component, event, "CompAuditorSrMangPopup");
            }
            component.set("v.isProjectSpeIndiDisabled", true);
        } else if (CompetitorFlagVal == 'No' && cdaType != 'Auditor') {
            component.set("v.isProjectSpeIndiDisabled", false);
        }
        console.log('LXC_CDA_RequestEditScreen: js helper: setSpecificIndicator End');
    }, 
    
    isCompetitorAuditor: function(component) {
        console.log('LXC_CDA_RequestEditScreen: js helper: isCompetitorAuditor start');
        var cdaTypeVal = component.get("v.simpleRequestObject.CDA_Type__c");
        if (cdaTypeVal == 'Auditor') {
            this.openPopup(component, event, "CompetitorAuditorPopup");
        }
        console.log('LXC_CDA_RequestEditScreen: js helper: isCompetitorAuditor End');
    },
    
    resetOriginatingRequestorSection: function(component) {
        console.log('LXC_CDA_RequestEditScreen: js helper: resetOriginatingRequestorSection start');
        var cdaRecord = component.get("v.simpleRequestObject");
        cdaRecord.Originating_Requestor_First_Name__c = null;
        cdaRecord.Originating_Requestor_Last_Name__c = null;
        cdaRecord.Originating_Requestor_IQVIA_Email__c = null;
        component.set("v.originatingRequestorConfirmEmailAddress", null);
        cdaRecord.Requestor_Admin_Email_Flag__c = 'Yes';
        component.set("v.simpleRequestObject", cdaRecord); 
        console.log('LXC_CDA_RequestEditScreen: js helper: resetOriginatingRequestorSection end');
    },
    
    setCustomerLegalEntityOther: function(component) {
        console.log('LXC_CDA_RequestEditScreen: js helper: setCustomerLegalEntityOther start');
        var cdaRecord = component.get("v.simpleRequestObject");
        cdaRecord.Cust_Legal_Entity_Name__c = null;
        component.set("v.customerLegalEntityAccount", null);
        //component.set("v.customerLegalEntityAddress", null);
        cdaRecord.Customer_Legal_Entity_Name_Other__c = null;
        cdaRecord.Customer_Legal_Entity_Address_Other__c = null;
        cdaRecord.Customer_Legal_Entity_Street_Other__c = null;
        cdaRecord.Customer_Legal_Entity_City_Other__c = null;
        cdaRecord.Customer_Legal_Entity_State_Other_PL__c = null; 
        cdaRecord.Customer_Legal_Entity_Country_Other_PL__c = null;
        cdaRecord.Customer_Legal_Entity_ZipCode_Other__c = null;
        component.set("v.simpleRequestObject", cdaRecord);
        console.log('LXC_CDA_RequestEditScreen: js helper: setCustomerLegalEntityOther end');
    },
    
    disableCustomerLegalEntityName: function(component) {
        console.log('LXC_CDA_RequestEditScreen: js helper: disableCustomerLegalEntityName start');
        
        if(component.get("v.isCustomerLegalEntityOther")) {
            component.set("v.simpleRequestObject.Cust_Legal_Entity_Name__c", null);
            
            /*if(component.get("v.customerEntityStateDepnedentFieldMap") == null) {
                helper.fetchPicklistValues(component, 
                                           "CDA_Request__c", 
                                           "Customer_Legal_Entity_Country_Other_PL__c", 
                                           "Customer_Legal_Entity_State_Other_PL__c", 
                                           "customerEntityStateDepnedentFieldMap", 
                                           "customerLegalEntityCountryValues");
            }*/
            
            this.openPopup(component, event, "customerLegalEntityChangePopup");            
        }  
        console.log('LXC_CDA_RequestEditScreen: js helper: disableCustomerLegalEntityName End');      
    },
    
    competitorContractingCapacityPopup: function(component, event) {
        console.log('LXC_CDA_RequestEditScreen: js helper: competitorContractingCapacityPopup start');
        if(component.get("v.simpleRequestObject.Competitor_Contracting_Capacity__c") == 'Customer') {
            this.openPopup(component, event, "competitorContractingCapacityPopup");
        }
        console.log('LXC_CDA_RequestEditScreen: js helper: competitorContractingCapacityPopup End');
    },
    
    getCdaAccountInfo: function(component, event, cdaAccountId, cdaAccountName) {
        console.log('LXC_CDA_RequestEditScreen: js helper: getCdaAccountInfo:  start');
        console.log('cdaAccountId: ' + cdaAccountId);
        console.log('cdaAccountName: ' + cdaAccountName);
        var cdaRecord = component.get("v.simpleRequestObject");
        if(cdaAccountId != null  && cdaAccountId != '') {
            this.showSpinner(component);
            if(component.find(cdaAccountName) != null) {
                component.find(cdaAccountName).hideError();
            }
            
            var action = component.get("c.getCdaAccountInfo");
            
            action.setParams({
                "recordId" : cdaAccountId
            });
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state == 'SUCCESS') {
                    var cdaAccount = response.getReturnValue();
                    
                    //component.set("v." + cdaAccountAddress, cdaAccount.Complete_Address__c);
                    component.set("v." + cdaAccountName, cdaAccount);
                    console.log(cdaAccountName + ' : ' + JSON.stringify(cdaAccount));
                    
                    if(cdaAccountName == 'recipientAccount' 
                       && cdaAccount.Competitor_flag__c 
                       && component.get("v.simpleRequestObject.CDA_Type__c") != 'CEVA'
                       && component.get("v.simpleRequestObject.Competitor_Flag__c") == 'No') {
                        //console.log('@@@ Here');
                        if(component.get("v.simpleRequestObject.QuintilesIMS_Business__c") != 'Q Squared' && component.get("v.simpleRequestObject.QuintilesIMS_Business__c") != 'Research &amp; Development Solutions (RDS) (Legacy Quintiles)'){
                            component.set("v.simpleRequestObject.Competitor_Flag__c", 'Yes');
                        }
                        this.setSpecificIndicatorMethod(component, event);  
                        this.setSpecificIndicator(component, event);
                        //console.log('v.simpleRequestObject.Competitor_Flag__c: '+ component.get("v.simpleRequestObject.Competitor_Flag__c"));
                    }
                    if(cdaAccountName == 'recipientAccount' && cdaAccount.Id != null && cdaAccount.Individual_Indicator__c != null){
                        component.set("v.simpleRequestObject.Individual_Indicator__c", cdaAccount.Individual_Indicator__c);
                    }else if(cdaAccountName == 'recipientAccount' && cdaAccount.Id != null && cdaAccount.Individual_Indicator__c == null){
                        component.set("v.simpleRequestObject.Individual_Indicator__c", '');
                    }
                    var recAccountName2Compare = 'Boehringer';
                    var recAccountName2Compare1 = 'Ingelheim';
                    var isPopupRecAccSelected = component.get('v.isPopupRecAccSelected');
                    var oldRecAccId = component.get('v.oldRecAccId');
                    var oldCustLehEntityAccId = component.get('v.oldCustLehEntityAccId');
                    if(cdaAccount.CDA_Account_Name__c.toLowerCase().includes(recAccountName2Compare.toLowerCase()) && cdaAccount.CDA_Account_Name__c.toLowerCase().includes(recAccountName2Compare1.toLowerCase())){
                        if(cdaRecord.Id == null || cdaRecord.Id == ''){
                            this.openPopup(component, event, "recAccPopup");
                        }else if(cdaAccountName == 'recipientAccount' && oldRecAccId != cdaAccount.Id){
                            this.openPopup(component, event, "recAccPopup");
                            component.set("v.oldRecAccId", cdaAccountId);
                        }else if(cdaAccountName == 'customerLegalEntityAccount' && oldCustLehEntityAccId != cdaAccount.Id){
                            this.openPopup(component, event, "recAccPopup");
                            component.set("v.oldCustLehEntityAccId", cdaAccountId);
                        }
                    }

                    console.log("abcd"+cdaAccount.Is_Master_Account__c);
                    if(cdaAccount.Is_Master_Account__c){
                        console.log("In here");
                        this.openPopup(component,event,"recAccIsMaster");
                    }
                    this.hideSpinner(component);
                }
            });
            
            $A.enqueueAction(action);
        } else {
            component.set("v." + cdaAccountName, null);
        } 
        console.log('LXC_CDA_RequestEditScreen: js helper: getCdaAccountInfo End');   
    },
    
    getQiLegalEntityInfo: function(component, qiLegalEntityId, qiLegalEntityAddress) {
        console.log('LXC_CDA_RequestEditScreen: js helper: getQiLegalEntityInfo start');
        console.log('Selected Legal Entity: ' + qiLegalEntityId);
        console.log('qiLegalEntityAddress: ' + qiLegalEntityAddress);
        var cdaRecord = component.get("v.simpleRequestObject");
        if(qiLegalEntityId != null  
           && qiLegalEntityId != '') {
            this.showSpinner(component);
            
            if(component.find('qiLegalEntity') != null) {
                var hideErrorFunctionRef = component.find("qiLegalEntity").hideError;
                if(typeof hideErrorFunctionRef === "function") {
                    hideErrorFunctionRef();
                }
            }
            
            var action = component.get("c.getQiLegalEntityInfo");
            action.setParams({
                "recordId" : qiLegalEntityId
            });
            
            action.setCallback(this, function(response) {
                console.log('LXC_CDA_RequestEditScreen: js helper: getQiLegalEntityInfo setCallback start');
                var state = response.getState();
                if(state == 'SUCCESS') {
                    var qiLegalEntity = response.getReturnValue();
                    
                    component.set('v.qiLegalEntityObj', qiLegalEntity);
                    component.set("v." + qiLegalEntityAddress, qiLegalEntity.QI_Legal_Entity_Address__c);
                    component.set("v.simpleRequestObject.Location_of_Governing_Law__c", null);
                    component.set("v.simpleRequestObject.Location_of_Governing_Law__c", qiLegalEntity.Location_of_Governing_Law__c);
                    
                    console.log('Selected Legal Entity Name: ' + qiLegalEntity.Name);
                    console.log('Selected Legal Entity Id: ' + qiLegalEntity.Id); 
                    console.log('Selected Governing Law: ' + qiLegalEntity.Location_of_Governing_Law__c);
                    console.log('cdaRecord.CDA_Source__c: ' + cdaRecord.CDA_Source__c);
                    console.log('cdaRecord.CDA_Format__c: ' + cdaRecord.CDA_Format__c);
                    console.log('Is Signatories Not Available: ' + qiLegalEntity.Is_Signatories_Not_Available__c);
                    var LegalEntityLookup = component.find("qiLegalEntity");
                    
                    console.log('qiLegalEntity.IQVIA_Business_Area__c: ' + qiLegalEntity.IQVIA_Business_Area__c);
                    if(!qiLegalEntity.Is_Active__c){
                        component.set("v.simpleRequestObject.QI_Legal_Entity_Name__c", '');
                    }
                    if(qiLegalEntity.Is_Signatories_Not_Available__c && cdaRecord.CDA_Source__c == 'IQVIA' && cdaRecord.CDA_Format__c == 'PDF'){
                        console.log('Is Signatories Not Available:inside: ' + qiLegalEntity.Is_Signatories_Not_Available__c);
                        LegalEntityLookup.showError('The selected Legal Entity does not have active Signatories So you can not select PDF Format. Please select Protected Word.');
                        component.set("v.simpleRequestObject.CDA_Format__c", '--None--');
                        //this.openPopup(component,event,"recAccIsMaster");
                    }
                    else {
                        if(component.find('qiLegalEntity') != null) {
                            var hideErrorFunctionRef = component.find("qiLegalEntity").hideError;
                            if(typeof hideErrorFunctionRef === "function") {
                                hideErrorFunctionRef();
                            }
                        }
                    }
                    this.hideSpinner(component);
                }
            });
            
            $A.enqueueAction(action);
        } else {
            component.set("v." + qiLegalEntityAddress, null);
        }   
        console.log('LXC_CDA_RequestEditScreen: js helper: getQiLegalEntityInfo End'); 
    },
    
    saveForLaterRecord: function(component) {
        console.log('LXC_CDA_RequestEditScreen: js helper: saveForLaterRecord start');
        
        var cdaRecord = component.get("v.simpleRequestObject");
        
        if(component.get("v.recordId") == null || cdaRecord.Status__c == 'In Draft') {
            if(component.get("v.isCdaTypeAuditor")) {
                if(cdaRecord.Competitor_Flag__c == 'Yes'){
                    component.set("v.simpleRequestObject.Competitor_Flag__c", null);
                    this.competitorFlagChanged(component);
                }
            }
        }
        cdaRecord.Status__c = 'In Draft';
        console.log('LXC_CDA_RequestEditScreen: js helper: saveForLaterRecord End');
    },
    
    saveForLaterPopup: function(component) {
        console.log('LXC_CDA_RequestEditScreen: js helper: saveForLaterPopup start');
        
        this.openPopup(component, event, "saveForLaterPopup");
        
        console.log('LXC_CDA_RequestEditScreen: js helper: saveForLaterPopup End');
    },
    
    saveRequest: function(component, cdarequest) {
        console.log('LXC_CDA_RequestEditScreen: js helper: saveRequest: start ');
        console.log("Save Location_of_Governing_Law__c: " + cdarequest.Location_of_Governing_Law__c);
        console.log("Before Save Project_Description_Long_Textarea__c: " + cdarequest.Project_Description_Long_Textarea__c);

        var action = component.get("c.saveRequest");
        
        action.setParams({
            "cdaRecord" : cdarequest
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state == 'SUCCESS') {
                var cdaRequest = response.getReturnValue();
                console.log("cdaRequest after save: " + JSON.stringify(cdaRequest));
                console.log("cdaRequest after save: " + JSON.stringify(cdaRequest.Location_of_Governing_Law__c));
                 this.showSpinner(component);
                if(cdaRequest.Status__c == 'In Draft') {
                    this.navigateToLandingPage(component);  
                } else {
                    this.navigateToRecord(component, cdaRequest);
                }
            }
            else {
                var errors = response.getError();
                var message = 'Unknown error'; // Default error message
                // Retrieve the error message sent by the server
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                // Display the message
                console.log(JSON.stringify(errors));
            }
        });
        
        $A.enqueueAction(action);
        console.log('LXC_CDA_RequestEditScreen: js helper: saveRequest End');
    },
    
    cdaSourceChanged: function(component) {
        console.log('LXC_CDA_RequestEditScreen: js helper: cdaSourceChanged: start ');
        
        var cdaRecord = component.get("v.simpleRequestObject");
        cdaRecord.CDA_Format__c = null;
        
        if (cdaRecord.CDA_Source__c == 'IQVIA') {
            cdaRecord.QuintilesIMS_Affiliates_Value__c = 'Yes';
            if(component.get("v.isCdaTypeCustomer") || component.get("v.isCdaTypeCEVA") || component.get("v.isCdaTypeVendor")) {
                cdaRecord.Recipient_Affiliates__c = 'Yes';
            }
            cdaRecord.CDA_Format__c = 'PDF';
        }
        if(cdaRecord.CDA_Source__c == 'External') {
            cdaRecord.QuintilesIMS_Affiliates_Value__c = null;
        } 
        
        component.set("v.simpleRequestObject", cdaRecord);
        console.log('LXC_CDA_RequestEditScreen: js helper: cdaSourceChanged End');
    },
    
    iqviaBusiDependencyChange: function(component, controllerValueKey) {
        console.log('LXC_CDA_RequestEditScreen: js helper: iqviaBusiDependencyChange:  start');
        console.log('"v.disclosurePeriodDepnedentFieldMap" ---> ' + JSON.stringify(component.get("v.disclosurePeriodDepnedentFieldMap")));
        var Map = component.get("v.cdaTypedepnedentFieldMap");
        var disclosureValuesMap = component.get("v.disclosurePeriodDepnedentFieldMap");
        
        if(controllerValueKey != "") {
            component.set("v.qiLegalEntityFilter", "IQVIA_Business_Area__c = '" + controllerValueKey + "' and Is_Active__c = true");
            var ListOfDependentFields = Map[controllerValueKey];
            var ListOfDependentFields2 = disclosureValuesMap[controllerValueKey];
            this.fetchDepValues(component, ListOfDependentFields, "cdaTypePicklistValues", "isDependentDisable");
            this.fetchDepValues(component, ListOfDependentFields2, "disclosurePeriodPicklistValues", "isDependentDisable");            
        } 
        else {
            var defaultVal = [{
                class: "optionClass",
                label: "--None--",
                value: ""
            }];
            component.set("v.cdaTypePicklistValues", defaultVal);
            component.set("v.isDependentDisable", true);
            component.set("v.cdaLanguagePicklistValues", defaultVal);
            component.set("v.isCdaLangDisabled", true);
            component.set("v.competContractCapValues", defaultVal);
            component.set("v.isCompetContractCapDisabled", true);
            component.set("v.studySponSituValues", defaultVal);
            component.set("v.isStudySponSituDisabled", true);
            component.set("v.qiLegalEntityFilter", "IQVIA_Business_Area__c != '--None--' and Is_Active__c = true");
        }
        console.log('LXC_CDA_RequestEditScreen: js helper: iqviaBusiDependencyChange End');
    }, 
    
    cdaTypeDependencyChange: function(component, controllerValueKey) {
        console.log('LXC_CDA_RequestEditScreen: js helper: cdaTypeDependencyChange: start ');
        
        var cdaLangDepnedentMap = component.get("v.cdaLangDepnedentFieldMap");
        var competContractCapDepMap = component.get("v.competContractCapDepFieldMap");
        
        if(controllerValueKey != "") {
            console.log('cdaLangDepnedentMap: ' + JSON.stringify(cdaLangDepnedentMap));
            var ListOfDependentFields = cdaLangDepnedentMap[controllerValueKey];
            this.fetchDepValues(component, ListOfDependentFields, "cdaLanguagePicklistValues", "isCdaLangDisabled");
            if(competContractCapDepMap != null) {
                console.log('competContractCapDepMap: ' + JSON.stringify(competContractCapDepMap));
                ListOfDependentFields = competContractCapDepMap[controllerValueKey];
                this.fetchDepValues(component, ListOfDependentFields, "competContractCapValues", "isCompetContractCapDisabled");
            }            
        } 
        else {
            var defaultVal = [{
                class: "optionClass",
                label: "--None--",
                value: ""
            }];
            //component.find('conState').set("v.options", defaultVal);
            component.set("v.cdaLanguagePicklistValues", defaultVal);
            component.set("v.isCdaLangDisabled", true);
            component.set("v.competContractCapValues", defaultVal);
            component.set("v.isCompetContractCapDisabled", true);
        }
        console.log('LXC_CDA_RequestEditScreen: js helper: cdaTypeDependencyChange End');
    },
    
    competitorContractCapacityDepChange: function(component, controllerValueKey) {
        console.log('LXC_CDA_RequestEditScreen: js helper: competitorContractCapacityDepChange: start');
        
        var Map = component.get("v.studySponSituDepFieldMap");
        
        if(controllerValueKey != "" && Map[controllerValueKey] != null && Map[controllerValueKey].length > 0) {
            var ListOfDependentFields = Map[controllerValueKey];
            
            this.fetchDepValues(component, ListOfDependentFields, "studySponSituValues", "isStudySponSituDisabled");            
        } 
        else {
            var defaultVal = [{
                class: "optionClass",
                label: "--None--",
                value: ""
            }];
            //component.find('conState').set("v.options", defaultVal);
            console.log('defaultVal: ' + JSON.stringify(defaultVal));
            component.set("v.studySponSituValues", defaultVal);
            component.set("v.isStudySponSituDisabled", true);
        }
        console.log('LXC_CDA_RequestEditScreen: js helper: competitorContractCapacityDepChange: End');
    },
    
    customerLegalEntityDepChange: function(component, controllerValueKey) {
        console.log('LXC_CDA_RequestEditScreen: js helper: customerLegalEntityDepChange: start');
        
        component.set("v.toggleCustomerLEntityStatesError", false);
        
        var Map = component.get("v.customerEntityStateDepnedentFieldMap");
        //console.log('Map: ' + JSON.stringify(Map));
        if(controllerValueKey != "" && Map[controllerValueKey] != null && Map[controllerValueKey].length > 0) {
            var ListOfDependentFields = Map[controllerValueKey];
            console.log('ListOfDependentFields: ' + JSON.stringify(ListOfDependentFields));
            this.fetchDepValues(component, ListOfDependentFields, "customerLegalEntityStateValues", "isCustomerEntityStateDisabled");            
        } 
        else {
            var defaultVal = [{
                class: "optionClass",
                label: "--None--",
                value: ""
            }];
            console.log('defaultVal: ' + JSON.stringify(defaultVal));
            component.set("v.customerLegalEntityStateValues", defaultVal);
            component.set("v.isCustomerEntityStateDisabled", true);
        }
        component.set("v.toggleCustomerLEntityStatesError", true);
        console.log('LXC_CDA_RequestEditScreen: js helper: customerLegalEntityDepChange: End');
    }, 
    
    recipientAccountDependencyChange: function(component, controllerValueKey) {
        console.log('LXC_CDA_RequestEditScreen: js helper: recipientAccountDependencyChange: start');
        component.set("v.toggleRecipientLEntityStatesError", false);
        var Map = component.get("v.recipientAccountStateDepnedentFieldMap");
        console.log('Map: ' + JSON.stringify(Map));
        if(controllerValueKey != "" && Map[controllerValueKey] != null && Map[controllerValueKey].length > 0) {
            var ListOfDependentFields = Map[controllerValueKey];
            console.log('ListOfDependentFields: ' + JSON.stringify(ListOfDependentFields));
            this.fetchDepValues(component, ListOfDependentFields, "recipientAccountStateValues", "isRecipientAccountStateDisabled");            
        } 
        else {
            var defaultVal = [{
                class: "optionClass",
                label: "--None--",
                value: ""
            }];
            //component.find('conState').set("v.options", defaultVal);
            console.log('defaultVal: ' + JSON.stringify(defaultVal));
            component.set("v.recipientAccountStateValues", defaultVal);
            component.set("v.isRecipientAccountStateDisabled", true);
        }
        component.set("v.toggleRecipientLEntityStatesError", true);
        console.log('LXC_CDA_RequestEditScreen: js helper: recipientAccountDependencyChange: End');
    },
    
    resetAdditionalContactFlag: function (component, event) {
        console.log('LXC_CDA_RequestEditScreen: js helper: resetAdditionalContactFlag: start');
        var requestEditWrapper = component.get("v.requestEditWrapper");
        if (requestEditWrapper.cdaAdditionalContactWrapperList != null) {
            component.set("v.contactList", requestEditWrapper.cdaAdditionalContactWrapperList);
        } else {
            component.set("v.contactList", []);
        }
        console.log('LXC_CDA_RequestEditScreen: js helper: resetAdditionalContactFlag: end');
    },
    
    setSiteSignatoryFlag: function (component, event) {
        var cdaRequest = component.get("v.simpleRequestObject");
        console.log('cdaRequest.IsSiteSignatorySameAsSiteContact__c ' + cdaRequest.IsSiteSignatorySameAsSiteContact__c);
        component.set('v.isSiteSignatorySameAsSiteContact', cdaRequest.IsSiteSignatorySameAsSiteContact__c);
    },
    
    addContactRecord: function (component, event) {
        //get the contact List from component  
        var contactList = component.get("v.contactList");
        //Add New Contact Record
        contactList.push({
            'acFirstName': '',
            'acLastName': '',
            'acEmail': ''
        });
        component.set("v.contactList", contactList);
    },

    validateContactList: function (component, event) {
        var isValid = true;
        var contactList = component.get("v.contactList");
        for (var i = 0; i < contactList.length; i++) {
            if (contactList[i].Name == '') {
                isValid = false;
                alert('Contact Name cannot be blank on row number ' + (i + 1));
            }
        }
        return isValid;
    }
})
