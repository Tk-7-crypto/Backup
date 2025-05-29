({
	doInit : function(component, event, helper) { 
        var pageReference = component.get("v.pageReference");
        var recordId=pageReference.state.c__recordId;
        component.set("v.recordId",recordId);
    },
	
    openModel: function(component, event, helper) {
        component.set("v.isModalOpen", true);
    },
  
    closeModel: function(component, event, helper) { 
        component.set("v.isModalOpen", false);
        var navSer = component.find("navigate");        
        var rId = (component.get("v.agrId") != undefined ? component.get("v.agrId") : component.get("v.recordId"));
        window.open('/lightning/r/Apttus__APTS_Agreement__c/'+rId+'/view','_top');   
    },
  
    submitDetails: function(component, event, helper) {
        var action = component.get("c.recallESignature");       
        var rId = (component.get("v.agrId") != undefined ? component.get("v.agrId") : component.get("v.recordId"));
        action.setParams({
            "agreementId": rId,
            "voidedReason" : component.get("v.voidedReason")
        });
        
        // Register the callback function
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var eSResult = response.getReturnValue();
                        if(eSResult.status=="SUCCESS"){
                            var navSer = component.find("navigate");        
                    var rId = (component.get("v.agrId") != undefined ? component.get("v.agrId") : component.get("v.recordId"));
                    window.open('/lightning/r/Apttus__APTS_Agreement__c/'+rId+'/view','_top');
                        }
                
            } else if (response.getState() === "ERROR") {                
                $A.log("Errors", response.getError());
            }
        });
        // Invoke the service
        $A.enqueueAction(action);
       component.set("v.isModalOpen", false);
    },
})