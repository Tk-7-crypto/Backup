({
    doInit: function(component, event, helper) {
    },
    
    recordUpdate: function(component, event, helper) {
        if(component.get("v.simpleRecord").Status != null && component.get("v.simpleRecord").Status == 'New') //Add the condtion case.CurrentQueue.DiableIQVIAPopUp == true
        {
            if(component.get("v.simpleRecord").AccountId != undefined){               
                component.set("v.accountRecordId", component.get("v.simpleRecord").AccountId);
                component.find("accountRecord").reloadRecord();
            }else{
                console.log("No AccountId on this record");
            }  
        }
    },   
    accountLoad: function(component, event, helper)  {
        if(component.get("v.simpleAccountRecord").MDMID__c != null && component.get("v.simpleAccountRecord").MDMID__c == 504051 && component.get("v.simpleRecord").CurrentQueue__c != undefined){
            component.set("v.CurrentQueueRecordId", component.get("v.simpleRecord").CurrentQueue__c);
            component.find("CurrentQueueRecord").reloadRecord();
        }       
    },
    showToast : function(component, event, helper) {
        console.log('Disable_IQVIA_Popup__c : ' + component.get("v.simpleCurrentQueueRecord").Disable_IQVIA_Popup__c);
        if(!component.get("v.simpleCurrentQueueRecord").Disable_IQVIA_Popup__c){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams(
                {"title": "IQVIA Consolidated Account Warning : \n",
                 "message": "\nYou have selected the IQVIA account for the creation of a case. Please do not proceed with the case creation for the IQVIA\naccount if the customer impacted by this case can be found in CSM.\nIf you don't know the person impacted you can select the No Contact Known checkbox against the affected Account.\nIf the case is internal only, select the real customer and set the field case Source as Internal." ,
                 type: 'warning',
                 mode: 'sticky'}
            );
            toastEvent.fire();
        }       
    }
})
