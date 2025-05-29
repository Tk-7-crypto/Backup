({
    init : function(component, event, helper) {
        var code =  component.get("v.code");
        if(code != undefined) {
        } else {
           helper.fetchDocusignDataHelper(component, event, helper); 
        }
    },
    
    handleCancel : function(component, event, helper) {
        window.open('/lightning/n/DocuSign_Authentication','_top');        
    },

    insertAuthData : function(component, event, helper) {
        var expireAfter = (component.get("v.expireAfter"));
        var expireWarn = (component.get("v.expireWarn"));
        if(expireAfter > expireWarn){
            helper.insertAuthData(component, event, helper);   
            helper.addToConsentData(component);  
            helper.fetchDocusignDataHelper(component, event, helper);
        }
        else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error',
                message:'The value of Expire After should be greater than Expire warn.',
                duration:' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'dismissible'
            });
            toastEvent.fire();
        } 
    },
})