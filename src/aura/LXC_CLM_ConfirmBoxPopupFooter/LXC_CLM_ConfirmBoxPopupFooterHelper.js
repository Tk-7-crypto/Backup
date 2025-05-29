({
    deleteAgreement : function(component,helper) {
        var recordId = component.get("v.objectRecordId");
        helper.callServer(component, "c.deleteAgreementById", 
            function(response){
                if (response) {
                    var homeEvent = $A.get("e.force:navigateToObjectHome");
                    homeEvent.setParams({
                        "scope": "Apttus__APTS_Agreement__c"
                    });
                    homeEvent.fire();
                    if(component.get("v.fromEditPage") == true){
                        helper.showToast("", "Agreement " + component.get("v.agreementName") + " was deleted.","Success","dismissible");
                    }
                    component.find("overlayLib").notifyClose();
                }
            },{"agreementId" : recordId}
        );
    }
    
})