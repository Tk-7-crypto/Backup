({
    doInit : function(component, event, helper) {
        console.log('LXC_CDA_RequestEditScreen: js controller: doInit Start');
        helper.setRequestEditDefaults(component);
        
        // @@@@@@@@@ Will work later @@@@@@@@@@//
        /*cdaRequestId = controller.getId();
        cdaRequestType = ApexPages.currentPage().getparameters().get(UTL_CDAUtility.REQUEST_TYPE_STR);
        isQaTesting = ApexPages.currentPage().getparameters().get(UTL_CDAUtility.QATESTING_STR) == null ? false : Boolean.valueOf(ApexPages.currentPage().getparameters().get(UTL_CDAUtility.QATESTING_STR));    //Added by Vikrm Singh under CR-11526
        cdaRecord = SRV_CDA_CDARequest.getCDARequest(cdaRequestId);*/
        console.log('LXC_CDA_RequestEditScreen: js controller: doInit End');        
    }, 
    loadIframe : function (component, event, helper) {
        console.log('In LXC_CDA_Pagination js controller: loadIframe method called');
        var cdaSettingValue = component.get("v.cdaSetting");
        window.addEventListener("message", function(e) {
            console.log("Event Triggered : e.data.type : " + e.data.type + " : e.data.authenticated : " + e.data.authenticated);
            // redirect to SSO login if the web client logs in but is logged in as a guest user(unauthenticated)
            if(e.data.type==="SESSION_CREATED" && e.data.authenticated === false) {
                window.location.href = cdaSettingValue.IQVIASupportChatLoginURL__c+cdaSettingValue.LandingPageURL__c;
                console.log('In 1');
            }

            // redirect to SSO login if the ServiceNow platform logs out from underneath the web client
            if(e.data.type==="SESSION_LOGGED_OUT") {
                window.location.href = cdaSettingValue.IQVIASupportChatLoginURL__c+cdaSettingValue.LandingPageURL__c; 
                console.log('In 2');
            }
        });
	},

    toggleChatbot : function (component, event, helper) {
        console.log('In LXC_CDA_Pagination js controller: toggleChatbot method called');
        
        var toggleChatbot = component.get("v.isOpenChatbot");
        component.set("v.isOpenChatbot", !toggleChatbot);
        
	},
    
    recordUpdated: function(component, event, helper) {
        console.log('LXC_CDA_RequestEditScreen: js controller: recordUpdated start');
        
        var changeType = event.getParams().changeType;
        if (changeType === "ERROR") { 
            console.log('ERROR: ');
        }
        else if (changeType === "LOADED") { 
            console.log('LOADED: ');
        }
        else if (changeType === "REMOVED") { 
            console.log('REMOVED: ');
        }
        else if (changeType === "CHANGED") {
            console.log('CHANGED: ');
            
        }
        
        console.log('LXC_CDA_RequestEditScreen: js controller: recordUpdated end');
    },
    
    onIqviaBusinessFieldChange: function(component, event, helper) {
        console.log('LXC_CDA_RequestEditScreen: js controller: onIqviaBusinessFieldChange Start');
        var cdaRequest = component.get("v.simpleRequestObject");
        var controllerValueKey = event.getSource().get("v.value");
        helper.iqviaBusiDependencyChange(component, controllerValueKey);
        component.set("v.simpleRequestObject.QI_Legal_Entity_Name__c", null);
        component.set("v.popupType", null);
        component.set("v.simpleRequestObject.Recipient_Account__c", null);
        helper.setIsPrivilegedBusinessAreaSelected(component, controllerValueKey);
        console.log('isPrivilegedBusinessAreaSelected: ' + component.get('v.isPrivilegedBusinessAreaSelected'));
        
        if(controllerValueKey != $A.get("$Label.c.CDA_Research_Development_Solutions_RDS_Legacy_Quintiles")){
            component.set("v.isAuditTypeDisabled", false);
            component.set("v.isProjectSpeIndiDisabled", false);
        }

        if(controllerValueKey == $A.get("$Label.c.CDA_Technology_Analytics_Solutions_TAS_Legacy_IMS") 
           || controllerValueKey == $A.get("$Label.c.CDA_Contract_Sales_Medical_Solutions_CSMS_Legacy_IES")
           || controllerValueKey == 'Real World Solutions'
           || controllerValueKey == $A.get("$Label.c.CDA_Public_Health")) {
            helper.openPopup(component, event, "quintilesLegacyIMSPopup");
        }else if(controllerValueKey == $A.get("$Label.c.CDA_Research_Development_Solutions_RDS_Legacy_Quintiles") 
           || controllerValueKey == $A.get("$Label.c.CDA_Q_Squared")) {
            helper.openPopup(component, event, "broadCDAPopup");
        }else {
            helper.resetDefaultValues(component);
        }
        console.log('LXC_CDA_RequestEditScreen: js controller: onIqviaBusinessFieldChange End');
    },
    
    handleNextAction : function(component, event, helper) {
        console.log("LXC_CDA_RequestEditScreen: js controller: handleNextAction : Start");
        
        if(helper.validateCdaRequestForm(component)) {
            var cdarequest = component.get("v.simpleRequestObject");
            console.log("cdarequest ---------------------------------------> " + JSON.stringify(cdarequest));
            cdarequest.Status__c = 'Awaiting Requestor Submission';
            var contactDetailsList = component.get('v.contactList');
            console.log('LXC_CDA_RequestEditScreen: js controller: contactList: ');
            console.log(contactDetailsList);
            var contactDetailsStr = '';
            contactDetailsList.forEach(function (item, index, array) {
                contactDetailsStr = contactDetailsStr.concat(item.acFirstName, ',', item.acLastName, ',', item.acEmail.trim(), ';');
            });
            contactDetailsStr.substring(contactDetailsStr.length - 1);
            cdarequest.Additional_Contact_Details__c = contactDetailsStr;
            console.log('outside contactFlag: ' + cdarequest.Additional_Contact_Flag__c);
            helper.saveRequest(component, cdarequest);
        }
        console.log("LXC_CDA_RequestEditScreen: js controller: handleNextAction : End");
    },
    
    popupActionButton3: function(component, event, helper){
        console.log('LXC_CDA_RequestEditScreen: js controller: popupActionButton3 start');
        var popupType = component.get("v.popupType");
        console.log('popupType : ' + popupType);
        var cdaRequest = component.get("v.simpleRequestObject");
        if(popupType == 'broadCDAPopup'){
            helper.resetDefaultValues(component);
            component.set("v.simpleRequestObject.Project_Specific_Indicator__c", 'Yes');
            component.set("v.simpleRequestObject.Competitor_Flag__c", 'null');
            component.set("v.isPopupOpen", false);
            //if(cdaRequest.QuintilesIMS_Business__c == $A.get("$Label.c.CDA_Research_Development_Solutions_RDS_Legacy_Quintiles") && cdaRequest.CDA_Type__c == 'Auditor'){
                //component.set("v.simpleRequestObject.Audit_Type__c", 'Project');
                //component.set("v.simpleRequestObject.Project_Specific_Indicator__c", 'Yes');
                //component.set("v.isAuditTypeDisabled", true);
                //component.set("v.isProjectSpeIndiDisabled", true);
            //}
        }
    },
    
    popupActionButton2: function(component, event, helper) {
        console.log('LXC_CDA_RequestEditScreen: js controller: closeModel start');
        var popupType = component.get("v.popupType");
        console.log('popupType : ' + popupType);
        var cdaRequest = component.get("v.simpleRequestObject");
        if(popupType == 'quintilesLegacyIMSPopup' 
           || popupType == 'quintilesBusinessAckPopupfinance') {
           	if(component.get('v.simpleRequestObject.QuintilesIMS_Business__c') != 'Real World Solutions'){
            	helper.openPopup(component, event, "quintilesFinancePopup");
        	}
        	else{
                helper.resetDefaultValues(component);
            	component.set("v.isPopupOpen", false);
            }
        } else if(popupType == 'quintilesBusinessAckPopupLegacyIms') {
            helper.openPopup(component, event, "quintilesLegacyIMSPopup");
        } else if(popupType == 'quintilesFinancePopup') {
            helper.resetDefaultValues(component);
            component.set("v.isPopupOpen", false);
        } else if(popupType == 'externalCdaSource') {
            helper.openPopup(component, event, "verifyIqviaPaperPopup");
        } else if(popupType == 'verifyIqviaPaperPopup') {
            helper.displayCDASourcePopup(component);
        } else if(popupType == 'cdaFormatProtectedWord') {
            component.set("v.simpleRequestObject.CDA_Format__c", 'PDF');
            component.set("v.isPopupOpen", false);
        } else if(popupType == 'CompetitorAuditorPopup') {
            component.set("v.simpleRequestObject.Competitor_Flag__c", null);
            helper.setSpecificIndicatorMethod(component);
            helper.setSpecificIndicator(component, event);
            component.set("v.isPopupOpen", false);
        } else if(popupType == 'empClientCustomerPopup') {
            component.set("v.empClientCustomerOptionVal", null);
            component.set("v.isPopupOpen", false);
        } else if(popupType == 'executedRequestPopup') {
            helper.navigateToRecord(component, component.get("v.simpleRequestObject"));
            component.set("v.isPopupOpen", false);
        } else if(popupType == 'broadCDAPopup'){
            helper.resetDefaultValues(component);
            component.set("v.isPopupOpen", false);
            component.set("v.simpleRequestObject.Audit_Type__c", '--None--');
            component.set("v.simpleRequestObject.Project_Specific_Indicator__c", '--None--');
            component.set("v.simpleRequestObject.Competitor_Flag__c", 'null');
            component.set("v.isProjectSpeIndiDisabled", false);
            //if(cdaRequest.QuintilesIMS_Business__c == $A.get("$Label.c.CDA_Research_Development_Solutions_RDS_Legacy_Quintiles") && cdaRequest.CDA_Type__c == 'Auditor'){
                //component.set("v.simpleRequestObject.Audit_Type__c", 'Project');
                //component.set("v.simpleRequestObject.Project_Specific_Indicator__c", 'Yes');
                //component.set("v.isAuditTypeDisabled", true);
                //component.set("v.isProjectSpeIndiDisabled", true);
            //}
        } else if(popupType == 'recAccIsMaster'){
			helper.navigateToLandingPage(component);            
        } else {
            component.set("v.isPopupOpen", false);
        }
        
        console.log("popupType: " + component.get("v.popupType"));
        console.log('LXC_CDA_RequestEditScreen: js controller: closeModel End');
    },
    
    popupActionButton1: function(component, event, helper) {
        console.log('LXC_CDA_RequestEditScreen: js controller: popupAction start');
        var popupType = component.get("v.popupType");
        
        console.log('popupType : ' + popupType);
        
        if(popupType == 'quintilesLegacyIMSPopup') {
            helper.openPopup(component, event, "quintilesBusinessAckPopupLegacyIms");
        } else if(popupType == 'quintilesBusinessAckPopupLegacyIms' 
                  || popupType == 'quintilesBusinessAckPopupfinance' 
                  || popupType == 'empClientCustomerPopup'
                  || popupType == 'qualificationQuestionPopupYes'
                  || popupType == 'broadCDAPopup'
                  || popupType == 'recAccPopup') {
            helper.navigateToLandingPage(component);            
        } else if(popupType == 'quintilesFinancePopup') {
            helper.openPopup(component, event, "quintilesBusinessAckPopupfinance");
        } else if(popupType == 'cdalanguageInfo' 
                  || popupType == 'externalOnlyWordPopup' 
                  || popupType == 'verifyIqviaPaperPopup' 
                  || popupType == 'cdaFormatProtectedWordAckAlert'
                  || popupType == 'cdaDiscloseApprovalIndicationPopup'
                  || popupType == 'cdaCustomerConsentInfoPopup'
                  || popupType == 'customerLegalEntityChangePopup'
                  || popupType == 'competitorContractingCapacityPopup'
                  || popupType == 'sponsorLegalEntityNameOtherPopup'
                  || popupType == 'sponsorConsentToDiscloseNoPopup'
                  || popupType == 'sponsorConsentToDiscloseYesPopup'
                  || popupType == 'recipientAccountChangePopup' 
                  || popupType == 'addContactInfo' 
                  || popupType == 'broadCDALangPopup'
                  || popupType == 'recAccIsMaster') {
            component.set("v.isPopupOpen", false);
        } else if(popupType == 'externalCdaSource') {
            helper.openPopup(component, event, "externalOnlyWordPopup");
        } else if(popupType == 'cusVenTemplateYes') {
            helper.cdaRequestDeleteAndReturnToLanding(component);
        } else if(popupType == 'cdaFormatProtectedWord') {
            helper.openPopup(component, event, "cdaFormatProtectedWordAckAlert");
        } else if(popupType == 'CompetitorAuditorPopup') {
            helper.saveForLaterRecord(component);
            helper.saveRequest(component, component.get("v.simpleRequestObject"));
        } else if(popupType == 'CompAuditorSrMangPopup') {
            helper.isCompetitorAuditor(component);
            component.set("v.isPopupOpen", false);
        } else if(popupType == 'saveForLaterPopup') {
            helper.saveRequest(component, component.get("v.simpleRequestObject"));
            component.set("v.isPopupOpen", false);
        } else if(popupType == 'executedRequestPopup') {
            helper.navigateToRecord(component, component.get("v.simpleRequestObject"));
            component.set("v.isPopupOpen", false);
        } else if(popupType == 'qualificationQuestionPopup') {
            helper.openPopup(component, event, "qualificationQuestionPopupYes");
        }
        
        console.log('LXC_CDA_RequestEditScreen: js controller: popupAction end');
    }, 
    
    cdaTypeChangeInvoke: function(component, event, helper) {
        console.log('LXC_CDA_RequestEditScreen: js controller: cdaTypeChangeInvoke start');
        
        var requestObject = component.get("v.simpleRequestObject");
        console.log(requestObject.QuintilesIMS_Business__c + ':::' + requestObject.CDA_Type__c);
        if(requestObject.QuintilesIMS_Business__c == $A.get("$Label.c.CDA_Research_Development_Solutions_RDS_Legacy_Quintiles") || requestObject.QuintilesIMS_Business__c == $A.get("$Label.c.CDA_Technology_Analytics_Solutions_TAS_Legacy_IMS") || requestObject.QuintilesIMS_Business__c == "Real World Solutions" || requestObject.QuintilesIMS_Business__c == $A.get("$Label.c.CDA_Public_Health")) {
            if(requestObject.CDA_Type__c == "Customer" || requestObject.CDA_Type__c == "Vendor") {
                helper.openPopup(component, event, "qualificationQuestionPopup");
            }
        }
        
        var controllerValueKey = event.getSource().get("v.value");
        
        helper.cdaTypeDependencyChange(component, controllerValueKey);
        
        var submitButton = component.find("submitButton");
        //$A.util.addClass(submitButton, "slds-show");
        
        helper.resetDefaults(component);
        helper.setCdaType(component);
        
        var cdaRequest = component.get("v.simpleRequestObject");
        
        if(component.get("v.isCdaTypeCEVA")) {
            if (cdaRequest.Customer_Specified_Vendor_Template__c == 'Yes') {
                cdaRequest.CDA_Source__c = 'External';
            } else {
                cdaRequest.CDA_Source__c = 'IQVIA';
            }
        } else if (component.get("v.isCdaTypeAuditor")) {
            cdaRequest.CDA_Source__c = 'IQVIA';
            //if(cdaRequest.QuintilesIMS_Business__c == $A.get("$Label.c.CDA_Research_Development_Solutions_RDS_Legacy_Quintiles")){
                //cdaRequest.Audit_Type__c = 'Project';
                //cdaRequest.Project_Specific_Indicator__c = 'Yes';
                //component.set("v.isAuditTypeDisabled", true);
                //component.set("v.isProjectSpeIndiDisabled", true);
            //}
        } else if (component.get("v.isCdaTypeVendor")) {
            if((cdaRequest.QuintilesIMS_Business__c != $A.get("$Label.c.CDA_Research_Development_Solutions_RDS_Legacy_Quintiles") && cdaRequest.QuintilesIMS_Business__c != $A.get("$Label.c.CDA_Q_Squared"))){
                cdaRequest.Project_Specific_Indicator__c = 'Yes';
            }
        }
        
        if(!component.get("v.isCdaTypeAuditor")){
            component.set("v.isAuditTypeDisabled", false);
            component.set("v.isProjectSpeIndiDisabled", false);
        }
        
        component.set("v.simpleRequestObject", cdaRequest);
        console.log('LXC_CDA_RequestEditScreen: js controller: cdaTypeChangeInvoke end');
    }, 
    
    onCustomerLegalEntityCountryChange: function(component, event, helper) {
        console.log('LXC_CDA_RequestEditScreen: js controller: onCustomerLegalEntityCountryChange start');
        
        var controllerValueKey = event.getSource().get("v.value");
        helper.customerLegalEntityDepChange(component, controllerValueKey);
        console.log('LXC_CDA_RequestEditScreen: js controller: onCustomerLegalEntityCountryChange end');
    },
    
    onRecipientAccountCountryChange: function(component, event, helper) {
        console.log('LXC_CDA_RequestEditScreen: js controller: onRecipientAccountCountryChange start');
        var controllerValueKey = event.getSource().get("v.value");
        console.log('controllerValueKey: ' + controllerValueKey);
        helper.recipientAccountDependencyChange(component, controllerValueKey);
        console.log('LXC_CDA_RequestEditScreen: js controller: onRecipientAccountCountryChange end');
    },
    
    showLanguageInfo: function(component, event, helper) {
        console.log('LXC_CDA_RequestEditScreen: js controller: showLanguageInfo start');
        if(component.get("v.simpleRequestObject.CDA_Language__c") != 'English' 
           && component.get("v.simpleRequestObject.CDA_Language__c") != ''
           && component.get("v.simpleRequestObject.CDA_Language__c") != null) {
            helper.openPopup(component, event, "cdalanguageInfo");
        }
        console.log('LXC_CDA_RequestEditScreen: js controller: showLanguageInfo end');
    }, 
    
    handleCdaSourseChange: function(component, event, helper) {
        console.log('LXC_CDA_RequestEditScreen: js controller: handleCdaSourseChange start');
        helper.cdaSourceChanged(component);
        helper.displayCDASourcePopup(component, event);
        console.log('LXC_CDA_RequestEditScreen: js controller: handleCdaSourseChange end');
    },
    
    customerSpecifiedVendorTemplateChanged: function(component, event, helper) {
        console.log('LXC_CDA_RequestEditScreen: js controller: customerSpecifiedVendorTemplateChanged start');
        var cdaRecord = component.get("v.simpleRequestObject");
        if (cdaRecord.Customer_Specified_Vendor_Template__c == 'Yes') {
            cdaRecord.CDA_Source__c = 'External';
        } else {
            cdaRecord.CDA_Source__c = 'IQVIA';
        }
        component.set("v.simpleRequestObject", cdaRecord);
        
        helper.displaycustomerSpecifiedVendorTemplatePopup(component, event);
        console.log('LXC_CDA_RequestEditScreen: js controller: customerSpecifiedVendorTemplateChanged end');
    }, 
    
    displayCDAFormatPopup: function(component, event, helper) {
        console.log('LXC_CDA_RequestEditScreen: js controller: displayCDAFormatPopup start');
        var cdaFormatVal = component.get("v.simpleRequestObject.CDA_Format__c");
        var qiLegalEntityId = component.get("v.simpleRequestObject.QI_Legal_Entity_Name__c");
        
        console.log('LXC_CDA_RequestEditScreen: qiLegalEntityId: '+qiLegalEntityId);
        var action = component.get("c.getQiLegalEntityInfo");
        action.setParams({
            "recordId" : qiLegalEntityId
        });
        action.setCallback(this, function(response) {
                console.log('LXC_CDA_RequestEditScreen: js Controller: getQiLegalEntityInfo setCallback start');
                var state = response.getState();
                var errorMsgs = [];
                if(state == 'SUCCESS') {
                    var qiLegalEntity = response.getReturnValue();
                    
                    console.log('Selected Legal Entity Name: ' + qiLegalEntity.Name);
                    console.log('Selected Legal Entity Id: ' + qiLegalEntity.Id); 
                    console.log('Selected Governing Law: ' + qiLegalEntity.Location_of_Governing_Law__c);
                    console.log('Is Signatories Not Available: ' + qiLegalEntity.Is_Signatories_Not_Available__c);
                    var LegalEntityLookup = component.find("qiLegalEntity");
                    
                    console.log('qiLegalEntity.IQVIA_Business_Area__c: ' + qiLegalEntity.IQVIA_Business_Area__c);
                    if(qiLegalEntity.Is_Signatories_Not_Available__c && cdaFormatVal == 'PDF'){
                        console.log('Is Signatories Not Available:inside: ' + qiLegalEntity.Is_Signatories_Not_Available__c);
            			LegalEntityLookup.showError('The selected Legal Entity does not have active Signatories So you can not select PDF Format. Please select Protected Word.');
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
                    
                }
            });
            
            $A.enqueueAction(action);
        
        if (cdaFormatVal == 'Protected Word') {
            if(component.find('qiLegalEntity') != null) {
                var hideErrorFunctionRef = component.find("qiLegalEntity").hideError;
                if(typeof hideErrorFunctionRef === "function") {
                    hideErrorFunctionRef();
                }
            }
            helper.openPopup(component, event, "cdaFormatProtectedWord");
        }
        console.log('LXC_CDA_RequestEditScreen: js controller: displayCDAFormatPopup end');
    },
    
    isProtocolNumberKnownChanged: function(component, event, helper) {
        console.log('LXC_CDA_RequestEditScreen: js controller: isProtocolNumberKnownChanged: start');
        var cdaRecord = component.get("v.simpleRequestObject");
        helper.isProtocolNumberKnownChanged(component, cdaRecord);
        console.log('LXC_CDA_RequestEditScreen: js controller: isProtocolNumberKnownChanged: end');
    }, 
    
    resetOriginatingRequestorSection: function(component, event, helper) {
        console.log('LXC_CDA_RequestEditScreen: js controller: resetOriginatingRequestorSection start');
        helper.resetOriginatingRequestorSection(component);
        console.log('LXC_CDA_RequestEditScreen: js controller: resetOriginatingRequestorSection end');
    },
    
    isEmpClientCustomer: function(component, event, helper) {
        console.log('LXC_CDA_RequestEditScreen: js controller: isEmpClientCustomer start');
        if(component.get("v.empClientCustomerOptionVal") == "Yes") {
            helper.openPopup(component, event, "empClientCustomerPopup");
        }
        console.log('LXC_CDA_RequestEditScreen: js controller: isEmpClientCustomer end');
    },
    
    isCustomerProvideDiscloseInfo: function(component, event, helper) {
        console.log('LXC_CDA_RequestEditScreen: js controller: isCustomerProvideDiscloseInfo start');
        var submitButton = component.find("submitButton");
        if(component.get("v.simpleRequestObject.Customer_Consent_to_Disclose__c") == "Yes") {
            $A.util.removeClass(submitButton, "slds-hide");
            helper.openPopup(component, event, "cdaDiscloseApprovalIndicationPopup");
        }
        else {
            $A.util.addClass(submitButton, "slds-hide");
            helper.openPopup(component, event, "cdaCustomerConsentInfoPopup");
        }
        console.log('LXC_CDA_RequestEditScreen: js controller: isCustomerProvideDiscloseInfo end');
    },
    
    customerLegalEntityChangePopup: function(component, event, helper) {
        console.log('LXC_CDA_RequestEditScreen: js controller: customerLegalEntityChangePopup');
        helper.setCustomerLegalEntityOther(component);
        helper.disableCustomerLegalEntityName(component);        
    }, 
    
    recipientAccountNameOtherChanged: function(component, event, helper) {
        console.log('LXC_CDA_RequestEditScreen: js controller: recipientAccountNameOtherChanged start');
        helper.recipientAccountNameOtherChanged(component);
        
        if(component.get("v.isRecipientAccountNameOther")) {
            component.set("v.simpleRequestObject.Recipient_Account__c", null);
            component.find("recipientAccount").hideError();
            helper.openPopup(component, event, "recipientAccountChangePopup");            
        }        
        console.log('LXC_CDA_RequestEditScreen: js controller: recipientAccountNameOtherChanged end');
    }, 
    
    setCustomerLegalEntity: function(component, event, helper) {
        console.log('LXC_CDA_RequestEditScreen: js controller: setCustomerLegalEntity start');
        helper.getCdaAccountInfo(component, event, 
                                 component.get("v.simpleRequestObject.Cust_Legal_Entity_Name__c"),
                                 'customerLegalEntityAccount'); 
        console.log('LXC_CDA_RequestEditScreen: js controller: setCustomerLegalEntity end');      
    }, 
    
    setSponsorLegalEntity: function(component, event, helper) {
        console.log('LXC_CDA_RequestEditScreen: js controller: setSponsorLegalEntity start');
        helper.getCdaAccountInfo(component, event, 
                                 component.get("v.simpleRequestObject.Sponsor_Legal_Entity__c"),
                                 'sponsorLegalEntity');
        console.log('LXC_CDA_RequestEditScreen: js controller: setSponsorLegalEntity end');  
    },
    
    setRecipentAccount: function(component, event, helper) {
        console.log('LXC_CDA_RequestEditScreen: js controller: setRecipentAccount: ');
        helper.getCdaAccountInfo(component, event, 
                                 component.get("v.simpleRequestObject.Recipient_Account__c"),
                                 'recipientAccount');  
    }, 
    
    setQILegalEntity: function(component, event, helper) {
        console.log('LXC_CDA_RequestEditScreen: js controller: setQILegalEntity');
        helper.getQiLegalEntityInfo(component, 
                                    component.get("v.simpleRequestObject.QI_Legal_Entity_Name__c"),
                                    'qiLegalEntityAddress');       
        
    }, 
    
    competitorContractingCapacityChanged: function(component, event, helper) {
        console.log('LXC_CDA_RequestEditScreen: js controller: competitorContractingCapacityChanged start');
        var controllerValueKey = event.getSource().get("v.value");
        helper.competitorContractingCapacityChanged(component);
        helper.competitorContractingCapacityPopup(component, event);
        helper.competitorContractCapacityDepChange(component, controllerValueKey);
        
        console.log('LXC_CDA_RequestEditScreen: js controller: competitorContractingCapacityChanged end');
    },
    
    sponsorConsentToDiscloseChanged: function(component, event, helper) {
        console.log('LXC_CDA_RequestEditScreen: js controller: sponsorConsentToDiscloseChanged start');
        helper.sponsorConsentToDiscloseChanged(component, component.get("v.simpleRequestObject"));
        console.log('LXC_CDA_RequestEditScreen: js controller: sponsorConsentToDiscloseChanged end');
    },
    
    sponsorLegalEntityNameOtherChanged: function(component, event, helper) {
        console.log('LXC_CDA_RequestEditScreen: js controller: sponsorLegalEntityNameOtherChanged start');
        helper.sponsorLegalEntityNameOtherChanged(component, component.get("v.simpleRequestObject"));
        helper.sponsorLegalEntityNameOtherPopup(component, event);
        console.log('LXC_CDA_RequestEditScreen: js controller: sponsorLegalEntityNameOtherChanged end');
    },
    
    sponsorConsentToDisclosePopup: function(component, event, helper) {
        console.log('LXC_CDA_RequestEditScreen: js controller: sponsorConsentToDisclosePopup start');
        var sponsorConsentToDiscloseVal = component.get("v.simpleRequestObject.Sponsor_Consent_to_Disclose__c");
        var competitorContractingCapacityVal = component.get("v.simpleRequestObject.Competitor_Contracting_Capacity__c");
        
        console.log('sponsorConsentToDiscloseVal:' + sponsorConsentToDiscloseVal);
        console.log('competitorContractingCapacityVal:' + competitorContractingCapacityVal);
        
        var submitButton = component.find("submitButton");
        if (sponsorConsentToDiscloseVal == 'No') {
            helper.openPopup(component, event, "sponsorConsentToDiscloseNoPopup");
            $A.util.addClass(submitButton, "slds-hide");
        } else if (sponsorConsentToDiscloseVal == 'Yes' && competitorContractingCapacityVal == 'Vendor') {
            helper.openPopup(component, event, "sponsorConsentToDiscloseYesPopup");
            $A.util.removeClass(submitButton, "slds-hide");
        } else {
            $A.util.removeClass(submitButton, "slds-hide");
        }
        console.log('LXC_CDA_RequestEditScreen: js controller: sponsorConsentToDisclosePopup end');
    },
    
    competitorSystemAccessChanged: function(component, event, helper) {
        console.log('LXC_CDA_RequestEditScreen: js controller: competitorSystemAccessChanged start');
        helper.competitorSystemAccessChanged(component, component.get("v.simpleRequestObject"));
        console.log('LXC_CDA_RequestEditScreen: js controller: competitorSystemAccessChanged end');
    },
    
    isProtocolTitleKnownChanged: function(component, event, helper) {
        console.log('LXC_CDA_RequestEditScreen: js controller: isProtocolTitleKnownChanged start');
        helper.isProtocolTitleKnownChanged(component, component.get("v.simpleRequestObject")); 
        console.log('LXC_CDA_RequestEditScreen: js controller: isProtocolTitleKnownChanged end');
    },
    
    isProtocolTitleDiscriptionChanged: function(component, event, helper) {
        console.log('LXC_CDA_RequestEditScreen: js controller: isProtocolTitleDiscriptionChanged start');
        helper.isProtocolTitleDiscriptionChanged(component, component.get("v.simpleRequestObject"));
        console.log('LXC_CDA_RequestEditScreen: js controller: isProtocolTitleDiscriptionChanged end');        
    },
     
    saveForLaterRecord: function(component, event, helper) {
        console.log('LXC_CDA_RequestEditScreen: js controller: saveForLaterRecord start');
        
        helper.saveForLaterRecord(component);
        helper.saveForLaterPopup(component); 
        console.log('LXC_CDA_RequestEditScreen: js controller: saveForLaterRecord end');
    },
    
    onRenderOrigiReqConfEmail: function(component, event, helper) {
        console.log('LXC_CDA_RequestEditScreen: js controller: onRenderOrigiReqConfEmail: start');
        if(component.find("originatingReqConfirmEmail") != undefined) {
            helper.preventConfirmEmailDefaults(component, component.find("originatingReqConfirmEmail").getElement());
        }
           
        console.log('LXC_CDA_RequestEditScreen: js controller: onRenderOrigiReqConfEmail: end');                     
    },
    
    setSpecificIndicatorMethod_AF: function(component, event, helper) {
        console.log('LXC_CDA_RequestEditScreen: js controller: setSpecificIndicatorMethod_AF: start');
        helper.setSpecificIndicatorMethod(component, event);  
        helper.setSpecificIndicator(component, event);
        console.log('LXC_CDA_RequestEditScreen: js controller: setSpecificIndicatorMethod_AF: end');
    },
    
    cancelRequest: function(component, event, helper) {
        console.log('LXC_CDA_RequestEditScreen: js controller: cancelRequest: start');
        helper.navigateToLandingPage(component);
        console.log('LXC_CDA_RequestEditScreen: js controller: cancelRequest: end');
    },
    
    reInit: function(component, event, helper) {
        console.log('ReInit Called Start');
        $A.get('e.force:refreshView').fire();
        console.log('ReInit Called Start');
    },

    resetAdditionalContactFlag: function(component, event, helper) {
        console.log('LXC_CDA_RequestEditScreen: js controller: setAdditionalContactFlag: start');
        helper.resetAdditionalContactFlag(component, event);
        console.log('LXC_CDA_RequestEditScreen: js controller: setAdditionalContactFlag: end');
    },
    
    setSiteSignatoryFlag: function (component, event) {
        var cdaRequest = component.get("v.simpleRequestObject");
        console.log('cdaRequest.IsSiteSignatorySameAsSiteContact__c ' + cdaRequest.IsSiteSignatorySameAsSiteContact__c);
    },

    addContact: function (component, event, helper) {
        helper.addContactRecord(component, event);
    },

    removeContact: function (component, event, helper) {
        var contactList = component.get("v.contactList");
        var selectedItem = event.currentTarget;
        var index = selectedItem.dataset.record;
        contactList.splice(index, 1);
        component.set("v.contactList", contactList);
    }
})
