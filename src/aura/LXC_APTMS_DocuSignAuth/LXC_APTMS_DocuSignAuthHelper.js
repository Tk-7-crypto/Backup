({
    fetchDocusignDataHelper : function(component, event, helper) {
        component.set('v.docuSigncolumns', [
            {
                label: 'Account Id',
                fieldName: 'linkName',
                type: 'url',
                typeAttributes: {
                    label: {
                        fieldName: 'Account_Id__c'
                    },
                    target: '_blank'
                }
            },
            {label: 'User Name', fieldName: 'User_Name__c', type: 'text'}
        ]);
        var action = component.get("c.fetchDocusignData");
        action.setParams({
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var records =response.getReturnValue();
                records.forEach(function(record){
                    record.linkName = '/'+record.Id;
                });
                component.set("v.docuSignList", records);    
            }
        });
        $A.enqueueAction(action);
    },

    addToConsentData : function(component){
        var action = component.get("c.getUserInfoBeforeInserting");                
        action.setParams({
            "accountId" : component.get("v.accountId"),
            "userEmail" : component.get("v.userEmail")
        });
        action.setCallback(this, function (a) {
            if (a.getState() === "SUCCESS") {
                var eSResult = a.getReturnValue();
                var toastEvent = $A.get("e.force:showToast");
                if (eSResult.status == 'SUCCESS') {
                    
                } else {
                    if(eSResult.message.includes("AUTHORIZATION_INVALID_TOKEN")) {
                        toastEvent.setParams({
                            "title": "Sorry!",
                            "type": "warning",
                            "mode": 'dismissible',
                            "message": $A.get("$Label.c.CLM_CL00020_DOCUSIGN_EMAIL_INCORRECT") + " " + component.get("v.userEmail")
                        });
                        toastEvent.fire();
                    }
                    else {
                        toastEvent.setParams({
                            "title": "Sorry!",
                            "type": "warning",
                            "mode": 'dismissible',
                            "message": "User Doesn't Exist in Docusign. Please select another User " + component.get("v.userEmail")
                        });
                        toastEvent.fire();
                    }
                }
            }
            else if (a.getState() === "ERROR") {   
            }
        });
        $A.enqueueAction(action);
    },
    
    insertAuthData: function(component, event, helper) {
        var jsObject = { "userName" : component.get("v.userName") ,
                        "name" : component.get("v.name"),
                       "userEmail" :  component.get("v.userEmail"),
                       "baseURL" : component.get("v.baseURL"),
                       "accountId" : component.get("v.accountId"),
                       "clientId" : component.get("v.clientId"),
                       "expireAfter" : component.get("v.expireAfter"),
                       "expireWarn" : component.get("v.expireWarn"),
                       "reminderDelay" : component.get("v.reminderDelay"),
                       "reminderFrequency" : component.get("v.reminderFrequency"),                                              
                       "privateKey" : component.get("v.privateKey"),
                       "publicKey" : component.get("v.publicKey")
                      };
        var packagedString = JSON.stringify(jsObject);
        var action = component.get("c.insertDocusignAuthData");                
        action.setParams({
            packagedString:packagedString
        });
        
        action.setCallback(this, function (a) {
            if (a.getState() === "SUCCESS") {            
                var data = a.getReturnValue();
                component.set('v.userName','');
                component.set('v.name','');
                component.set('v.privateKey','');
                component.set('v.publicKey','');
                component.set('v.baseURL','');
                component.set('v.clientId','');
                component.set('v.expireAfter','');
                component.set('v.expireWarn','');
                component.set('v.reminderDelay','');
                component.set('v.reminderFrequency','');
            } else if (a.getState() === "ERROR") {
                $A.log("Errors", a.getError());
                $A.util.removeClass(component.find("noValidUserData"), "slds-show");
                $A.util.addClass(component.find("noValidUserData"), "slds-hide");
                var errors = a.getError();
                var msg = 'Exception Type : '+errors[0].exceptionType+ ' ' +'Message : '+ errors[0].message ;
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title" : "Error",
                    "mode" : "dismissible",
                    "message" : msg,
                    "type" : "error"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})