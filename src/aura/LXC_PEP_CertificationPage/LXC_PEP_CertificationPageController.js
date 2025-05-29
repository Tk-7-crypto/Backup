({
    
    doInit: function(component, event, helper) {
        console.log('action:');
        var action = component.get("c.getAccountCertifications");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(JSON.stringify(response.getReturnValue()));
            if (state === "SUCCESS") {
                console.log("Certification List : "+ response.getReturnValue());
                if($A.util.isEmpty(response.getReturnValue())) {
                    component.set("v.empty", true);
                }
                else {
                    component.set("v.accountCertificationList", response.getReturnValue());
                } 
            }
        });
        $A.enqueueAction(action); 
        
    },
    
    newPopup1 : function(component, event, helper){
        var cmpTarget = component.find('Modalbox1');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
        
        var clickedElement = event.srcElement;
        
        // var certificationName=event.getSource().get('v.value');
        var certificationName= clickedElement.dataset.id;
        console.log("in new popup : "+certificationName);
        
        var action = component.get("c.getBadgeVariations");
        action.setParams({ "certificationName" : certificationName});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(JSON.stringify(response.getReturnValue()));
            if (state === "SUCCESS") {
                console.log("Badge List : "+ response.getReturnValue());
                if($A.util.isEmpty(response.getReturnValue())) {
                    component.set("v.empty", true);
                }
                else {
                    component.set("v.badgeList", response.getReturnValue());
                } 
            }
        });
        $A.enqueueAction(action);
    },
    
    newPopup2 : function(component, event, helper){
        var cmpTarget = component.find('Modalbox2');
        $A.util.addClass(cmpTarget, 'slds-fade-in-open');
    },
    
    
    closeNewModal1 : function(component, event, helper){
        var cmpTarget = component.find('Modalbox1');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
    },
    
    closeNewModal2 : function(component, event, helper){
        var cmpTarget = component.find('Modalbox2');
        var cmpBack = component.find('Modalbackdrop');
        $A.util.removeClass(cmpBack,'slds-backdrop--open');
        $A.util.removeClass(cmpTarget, 'slds-fade-in-open');
    },
    downloadBadge:function(component, event, helper){
        var imageFormat=event.getSource().getLocalId();
        var badge=event.getSource().get('v.value');
        console.log("in download badge : "+badge.Certification_Name__c);
        
        var action = component.get("c.getBadgeDownloadURL");
        action.setParams({ "certificationName" : badge.Certification_Name__c,"imageFormat" : imageFormat,"badgeVariation" : badge.Badge_Variation__c});
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log(JSON.stringify(response.getReturnValue()));
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());	
                var downloadPath=response.getReturnValue();
                window.open(downloadPath,"_top");
            }
        });
        $A.enqueueAction(action);
        
        
        // var certificationName=event.getSource().get('v.value');
        //  var path=buttonClicked;
        ///   console.log(path);
        // window.open("../sfc/servlet.shepherd/document/download/06956000000dy3wAAA?operationContext=S1");
        //window.open("../servlet/servlet.FileDownload?file=0150n0000007msj");
    },
    goToPartnerBrandGuide: function(component, event, helper){
        let urlString = document.location.href;
        let baseURL = urlString.substring(0, urlString.indexOf("/alliance-management"));
        
        window.open(baseURL + "/partner/s/partner-branding-guidelines", "_blank");
    }
})