({
    doInit: function(component, event, helper) {
    },

    recordUpdate: function(component, event, helper) {
        if(component.get("v.simpleRecord").ContactId != undefined){
            component.set("v.contactRecordId", component.get("v.simpleRecord").ContactId)
            component.find("contactRecord").reloadRecord();
        }else{
            console.log("No ContactId on this record");
        }
    },

    contactRecordUpdate: function(component, event, helper) {
        if(component.get("v.simpleContactRecord") != null && component.get("v.simpleContactRecord") != undefined && component.get("v.simpleContactRecord").IsEmailBounced  != undefined){
            if(component.get("v.simpleContactRecord").IsEmailBounced == true){
                component.set("v.warning",true);
            } 
        }
    }
})