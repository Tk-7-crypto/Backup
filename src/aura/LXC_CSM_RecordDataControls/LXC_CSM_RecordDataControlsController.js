({
    doInit: function(component, event, helper) {
    },
    
    recordUpdate: function(component, event, helper) {
        if(component.get("v.simpleRecord").AccountId != undefined){
            component.set("v.accountRecordId", component.get("v.simpleRecord").AccountId)
            component.find("accountRecord").reloadRecord();
        }else{
            console.log("No AccountId on this record");
        }
        if(component.get("v.simpleRecord").ContactId != undefined){
            component.set("v.contactRecordId", component.get("v.simpleRecord").ContactId)
            component.find("contactRecord").reloadRecord();
        }else{
            console.log("No ContactId on this record");
        }
        
    },
    
    accountRecordUpdate: function(component, event, helper) {
        if(component.get("v.simpleAccountRecord").MDM_Validation_Status__c != "Validated"){
            component.set("v.warning",true);
        }
    },
    
    contactRecordUpdate: function(component, event, helper) {
        if(component.get("v.simpleContactRecord").IsEmailBounced  != undefined){
            if(component.get("v.simpleContactRecord").IsEmailBounced == true){
                component.set("v.warning2",true);                
            } 
        }
    }
    
    
    
    
    
})