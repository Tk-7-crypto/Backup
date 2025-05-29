({
    initializeData : function(component, event) {
        let params = {
            agreementId : component.get("v.recordId")
        }
        component.set("v.showSpinner", true);
        this.callServer(component, "c.setAgreementWrapper", function(agreementWrapper) {
            if(agreementWrapper) {
                component.set("v.agreementWrapper", agreementWrapper);
            }
            component.set("v.showSpinner", false);
        }, params);
    },

    deleteAgreement : function(component,helper) {
        var agreementId = component.get("v.agreementWrapper.agreement").Id;
        helper.callServer(component, "c.deleteAgreementById", 
            function(response){
                if (response) {
                    if(response == true){
                        helper.showToast("Deleted !!",$A.get("$Label.c.CLM_CL0006_Delete_Confirm_Message"),"info","dismissible");
                        var homeEvent = $A.get("e.force:navigateToObjectHome");
                        homeEvent.setParams({
                            "scope": "Apttus__APTS_Agreement__c"
                        });
                        homeEvent.fire();
                    }else{
                        var userMsg = $A.get("$Label.c.CLM_CL_0001_UnknownError");
                        helper.showToast("Error",userMsg,"Error","dismissible");
                    }
                }
            },{"agreementId" : agreementId}
        );
    },

    scrollEventCall : function(component) {
        if(component.isValid()) {
            var header = component.find("headerDiv").getElement();
            var headerReplaceDiv = component.find("headerReplaceDiv").getElement();
            var image = component.find("oppImage").getElement();
            var scrollTop = document.documentElement.scrollTop;
            if(scrollTop > 20) {
                $A.util.addClass(header, "changeHeader");
                $A.util.removeClass(headerReplaceDiv, "slds-hide");
                $A.util.addClass(image, "imageChange");
            } else {
                $A.util.removeClass(header, "changeHeader");
                $A.util.removeClass(image, "imageChange");
                $A.util.addClass(headerReplaceDiv, "slds-hide");
            }
        }
    }

})