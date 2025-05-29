({
    doInit: function(component, event, helper) {
        var cookieName = component.get("v.pageName");        
        var action = component.get("c.getPageDetails");    
        action.setParams({"pageName":cookieName});
        console.log('Page name to be passed : ' + cookieName);
        action.setCallback(this, function(response){
            console.log('in callback');
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('in success');
                var pageRecord = response.getReturnValue();
                console.log('return value : ' + pageRecord);
                var pageDescription = pageRecord.Feature_Description__c;
                var expirationDate = pageRecord.Expiration_Date__c;
                var d = new Date();
                var currentDate = d.toISOString().slice(0,10);
                var numberOfDays =  Math.floor(( Date.parse(expirationDate) - Date.parse(currentDate) ) / 86400000); 
                component.set("v.pageDescription",pageDescription);
                if(pageDescription != '' || pageDescription != undefined){
                    console.log('inside cookies get set');
                    helper.getCookie(component,cookieName);
                    helper.setCookie(component, event, helper, numberOfDays);
                }
            }  
            else{console.log('Error');}
        });
        $A.enqueueAction(action);
        
    },
    
    closeModal: function(component, event, helper) {
        component.set("v.isModalOpen", false);
    },
    
    openModal: function(component, event, helper) {
        component.set("v.isModalOpen", true);
    },
    
    resetPopupCookie: function(component, event, helper)
    {
        var cookieName = component.get("v.pageName"); 
        document.cookie = cookieName +"=;expires=Thu, 01 Jan 1970 00:00:00 UTC ;path=/";
        console.log('Expired cookie : ' + document.cookie);
        alert('Cookie reset for ' + cookieName);
    }
})