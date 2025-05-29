({
	doInit : function(component, event, helper) {
        helper.callServer(component, "c.getContactEmailOptOut",function(response){
            if(response != undefined){
                component.set('v.contactData',response);
                component.set('v.isEmailNotification',response.EmailOptOut__c);
                
            } 
        },{});
		
	},
    onEmailNotificationCheck: function(component, event) {
		 var checkCmp = component.find("checkbox");
        component.set("v.isEmailNotification", checkCmp.get("v.value"));

	 },
    handleClick : function(component, event, helper) {
        helper.callServer(component, "c.saveEmailOptOut",function(response){
            if(response != undefined){
                component.set('v.isEmailNotification',response);
                component.set('v.contactData',response);
                component.set('v.isEmailNotification',response.EmailOptOut__c);
                helper.showToastmsg(component,"","success","Email Settings changed Successfully.");
            } 
        },{"contactId" : component.get('v.contactData').Id, "emailOptOut" : component.get('v.isEmailNotification')});
		
	}
})