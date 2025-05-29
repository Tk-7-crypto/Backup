({
    doInit: function(component, event, helper) {      
        if($A.get("$Browser.isPhone")){
            component.set("v.backButton","Back");
        }
        if(component.get("v.source") == 'Opportunity'){
        	helper.getOpportunityRecord(component,event, helper);
        }else if(component.get("v.source") == 'Quote__c'){
        	helper.getQuoteRecord(component,event, helper);
        }
        document.addEventListener("scroll", function() {
            helper.scrollEventCall();
        });
    },
    
    gotoURL : function (component, event, helper) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId"),
            //"isredirect" : true
        });
        navEvt.fire();
    },
})