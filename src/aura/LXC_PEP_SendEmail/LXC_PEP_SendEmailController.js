({
    doInit : function(component, event, helper) {
        var idParam = component.get("v.recordId");
        var action = component.get("c.getAnnouncementDetails");
        action.setParams({"announcementId":idParam});
        action.setCallback(this, function(data) {
            var state = data.getState();
            console.log(state);
            if (state === "SUCCESS") {
                var annDetail = data.getReturnValue();
                console.log('Email Stauts:  ' + annDetail[0].Email_Sent__c);
                component.set("v.emailStatus", annDetail[0].Email_Sent__c);
                component.set("v.emailStatusCSM", annDetail[0].Email_Sent_for_CSM__c);
                var expiryDate = annDetail[0].Expiry_Date__c;
                console.log('Expiry date : ' + expiryDate);
                var today = $A.localizationService.formatDate(new Date(), "YYYY-MM-DD");
                console.log('today date : ' + today);
                if(expiryDate < today)
                {
                    component.set("v.expired", true);
                    console.log('inside check');
                }
            }
        });
        $A.enqueueAction(action);
    },
    onChecked : function(component,event,helper)
    {
        var a = event.getSource();
        var id = a.getLocalId();
        console.log('Checked id  : ' + id);
        if(id == 'prmId')
        {
            var check = component.get("v.booleanValue");
            var uncheckCSM = component.find("csmId");
            if(check){component.set("v.booleanValue",false);}
            else{
                component.set("v.booleanValue",true);
                uncheckCSM.set("v.checked",false);
                component.set("v.booleanValueCSM",false);
            }
        }
        else if(id == 'csmId')
        {
            var checkCSM = component.get("v.booleanValueCSM");
            var uncheckPRM = component.find("prmId");
            if(checkCSM){component.set("v.booleanValueCSM",false);}
            else{
                component.set("v.booleanValueCSM",true);
                uncheckPRM.set("v.checked",false);
                component.set("v.booleanValue",false);
            }
        }
        
        console.log('prm checkbox  : ' + component.get("v.booleanValue"));
        console.log('csm checkbox  : ' + component.get("v.booleanValueCSM"));
        
    },
    
    sendMail : function(component,event,helper)
    {
        var checkBoxPRM = component.find("prmId").get("v.value");
        var checkBoxCSM = component.find("csmId").get("v.value");
        var mailStatus = component.get("v.emailStatus");
        var mailStatusCSM = component.get("v.emailStatusCSM");
        var expiredDate = component.get("v.expired");
        
        console.log('Expired date : ' + expiredDate);
        console.log('checkbox value :  ' + checkBoxPRM);
        var idParam = component.get("v.recordId");
        console.log('inside sendmail');
        console.log('recordID : ' + idParam);
        if((checkBoxPRM || checkBoxCSM) && !expiredDate){
            if(checkBoxPRM  && !mailStatus){
                var action = component.get("c.sendAnnouncementMail");
                action.setParams({"announcementId":idParam});
                action.setCallback(this, function(data) {
                    var state = data.getState();
                    console.log(state);
                    if (state === "SUCCESS") {
                        console.log('Successfully sent email for PRM');
                    }
                });
                $A.enqueueAction(action);
                $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success",
                    "message": "Email has been sent."
                });
                toastEvent.fire();
            }
            else if(checkBoxCSM && !mailStatusCSM){
                var action = component.get("c.sendAnnouncementMailForCSM");
                action.setParams({"announcementId":idParam});
                action.setCallback(this, function(data) {
                    var state = data.getState();
                    console.log(state);
                    if (state === "SUCCESS") {
                        console.log('Successfully sent email for CSM');
                    }
                });
                $A.enqueueAction(action);
                $A.get("e.force:closeQuickAction").fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success",
                    "message": "Email has been sent."
                });
                toastEvent.fire();
            }
                else if(mailStatus)
                {
                    component.set("v.showError", true);
                }
                    else if(expiredDate)
                    {
                        component.set("v.showExpiredError", true);
                    }
        }
    }
})
