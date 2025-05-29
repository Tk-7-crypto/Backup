({
    doInit : function(component, event, helper) {
        var caseRecord = component.get('v.simpleRecord');
        component.set("v.mailCCValue",caseRecord.Mail_CC_List__c);
        var productsAccessingDTMSInformation = component.get('v.productsAccessingDTMSInformation');
        if (caseRecord.Asset != null)
            component.set('v.showDTMSInformation',productsAccessingDTMSInformation.includes(caseRecord.Asset.Product2.Name));
        if(caseRecord.ClosedDate != null ) {
            var today = new Date($A.localizationService.formatDate(new Date(), "MM/DD/YYYY"));
            var closedDate = new Date($A.localizationService.formatDate(caseRecord.ClosedDate, "MM/DD/YYYY"));
            var diffInTime = today.getTime() - closedDate.getTime(); 
            var diffInDays = diffInTime / (1000 * 3600 * 24);
            var showRequestFollowButton = ((diffInDays < 30) && caseRecord.Status == 'Closed') ? true : false;
            component.set('v.showRequestFollowButton', showRequestFollowButton);
            if(showRequestFollowButton) {
                if((caseRecord.Followed_Case_Id__c == '' || caseRecord.Followed_Case_Id__c == null) && caseRecord.ParentId != null && 
                   caseRecord.Parent.Followed_Case_Id__c != '' && caseRecord.Parent.Followed_Case_Id__c != null &&
                   caseRecord.Parent.Followed_Case_Id__c != undefined) {
                    component.set('v.isCaseFollowed', true);
                    var clonedCaseId = component.get("v.simpleRecord").ParentId;
                    helper.getFollowerCase(component, clonedCaseId);
                } else if(caseRecord.Followed_Case_Id__c != null &&  caseRecord.Followed_Case_Id__c != '' &&
                          caseRecord.Status == 'Closed') {
                    component.set('v.isFollowerCase', true);
                    helper.getFollowerCase(component, caseRecord.Followed_Case_Id__c);
                }
            }
        }
    },
    
    saveMailCC : function(component, event, helper) {
        var recordData = component.get("v.recordId");
        var emailFieldValue = component.get("v.mailCCValue");
        var isValidEmail = true;
        var emailField = component.find("leadEMail");
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;    
        if(!$A.util.isEmpty(emailFieldValue)){ 
            var storevalue =0;
            for(storevalue =0;storevalue <emailFieldValue.split(';').length; storevalue++){
                var mail =emailFieldValue.split(';')[storevalue];
                if(mail.match(regExpEmailformat)){
                    isValidEmail = true;
                    
                }else{
                    isValidEmail = false;
                    component.set("v.errorMessageCheck","true");
                    component.set("v.errorMessage","Please Enter a Valid Email Address");
                    $A.util.addClass(emailField, 'slds-has-error');
                    emailField.set("v.errors", [{message: "Please Enter a Valid Email Address"}]);
                }
            }
        }
        
        // if Email Address is valid then execute code     
        if(isValidEmail){
            helper.saveCase(component,event); 
        }
          
    },
    handleEdit : function(component, event, helper) {
        component.set("v.editMaillCC","true");
        component.set("v.editMaillCCButton","false");
        var mailCCValue = component.get("v.simpleRecord.Mail_CC_List__c");
        component.set("v.mailCCValue",mailCCValue);  
    },
    
    openCloneCaseDescriptionForm : function(component, event, helper) {
        component.set("v.isOpenModal", true);
    },
    
    cloneCaseForFollowUp : function(component, event, helper) {
        var followUpDescriptionInput = component.find("followUpDescriptionInput");
        var inputCmpValue = followUpDescriptionInput.get('v.value');
        var isValid = true;
        if(inputCmpValue == '' || inputCmpValue == null || inputCmpValue == undefined) {
            followUpDescriptionInput.set('v.validity', {valid:false});
            $A.util.addClass(followUpDescriptionInput, "is-required slds-has-error lightningInput");
            followUpDescriptionInput.showHelpMessageIfInvalid();
            isValid = false;
        } 
        if(isValid) {
            helper.cloneCaseForFollowUp(component);
        }
    },
    
    seeFollowCase : function(component, event, helper) {
        var followerCase = component.get("v.followerCase");
        component.set("v.isOpenModal", false);
        component.set("v.simpleRecord", followerCase);
        component.set("v.recordId", followerCase.Id);
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/case/" + followerCase.Id 
        });
        urlEvent.fire();
    },
    
    closeForm : function(component, event, helper) {
        component.set("v.isOpenModal", false);
    },
    
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    }
})