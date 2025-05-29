({
    doInit: function(component, event, helper) {
        var buttonVisibilityControl = component.get("v.bidHistoryRecord").Create_Agreement_Quote_Button_Visibility__c;
        var bidHistory = component.get("v.bidHistoryRecord");
            
        if(buttonVisibilityControl == 'Create_Agreement'){
            if((bidHistory.Agreement_Pathway__c =='Clinical' && bidHistory.Requested_Agreement_Type__c =='Preliminary Agreement Amendment')
              || ((bidHistory.Agreement_Pathway__c =='Late Phase' || bidHistory.Agreement_Pathway__c =='RBU') && (bidHistory.Requested_Agreement_Type__c == 'Preliminary Agreement Amendment' || bidHistory.Requested_Agreement_Type__c == 'New Change Order'))
              || (bidHistory.Agreement_Pathway__c =='Other Special Agreement' && bidHistory.Requested_Agreement_Type__c == 'LRA Amendment')){
                component.set("v.flowName","CLM_Agreement_ScreenFlow_RWLP_Amend");
            }
            else{
                component.set("v.flowName","CLM_RWLP_Agreement_Flow");
            }
            component.set("v.actionName","Create_Agreement"); 
            component.set("v.isItAgreementCreation",true); 
            component.set("v.errorMsg","Only the assigned resource can create the agreement.");
        }
        else if(buttonVisibilityControl == 'Create_Budget'){
            component.set("v.actionName","Create_Budget");
            component.set("v.isItQuoteCreation",true);
            component.set("v.errorMsg","Only the assigned resource can create the quote.");
        }
        else  if(buttonVisibilityControl == 'Create_CNF_Quote'){
            component.set("v.actionName","Create_CNF_Quote");
            component.set("v.isItCNFQuoteCreation",true);
            component.set("v.errorMsg","Only the assigned resource can create the CNF quote.");
        }
        if(bidHistory.Agreement_Pathway__c =='RBU'){
            component.set("v.showSpinner", false); 
            component.set("v.showError", false);
        }
        else{
            helper.isCurrentUserEligibleforCreatingQuoteOrAgreement(component, event);
        }
    }
})