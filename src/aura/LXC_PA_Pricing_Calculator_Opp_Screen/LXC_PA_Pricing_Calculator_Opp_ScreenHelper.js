({
	getValidationMessages : function(component, event, helper) {
        var opportunityId = component.get("v.opportunityId");
        var action = component.get("c.getPricingErrors");
        action.setParams({
            "opportunityId" : opportunityId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result',result);
                if(result != null) { 
                    var errorMessages = JSON.parse(result['errorMessages']);
                    component.set('v.isLoading', false);
                    if(errorMessages.length > 0) {
                        component.set("v.showError",true);
                        component.set("v.arrayOfErrorMessage", errorMessages);                
                    } 
                    else if(result['isQuoteExist'] === 'true')
                    {
                        component.set("v.showQuoteWarning",true);                        
                    }
                    else { 
                        window.open('https://'+result['legacyOrgLink']+'/apex/VFP_PA_Pricing_Calculator_Opp_Screen?OppId='+result['legacyOrgOppId'],'_top');
                    }
                }
           }else if (state === "ERROR") {
               console.log('Error :: ',response.getError());
           }
       });
       $A.enqueueAction(action);
	},
    processCancelActiveQuotes : function(component, event, helper) {
        var opportunityId = component.get("v.opportunityId");
        var action = component.get('c.cancelActiveQuotes'); 
        action.setParams({
            "opportunityId" : opportunityId
        });
        action.setCallback(this, function(response){
            component.set('v.isLoading', false);
            var state = response.getState();            
            if(state == 'SUCCESS') {
                var result = response.getReturnValue();
                console.log('result',result);
                if(result['status'] === 'success'){
                	window.open('https://'+result['legacyOrgLink']+'/apex/VFP_PA_Pricing_Calculator_Opp_Screen?OppId='+result['legacyOrgOppId'],'_top');
                }
                else{
                    let errorMsg = result['status']; 
                    console.log("Error :: ", errorMsg);
                    component.set("v.showQuoteCancelError",true);
                    component.set("v.quoteCancelErrorMsg",errorMsg);
                }
            }
            else if(state == 'ERROR'){
                let errorMsg = response.getError(); 
                console.log("Error :: ", errorMsg);
                component.set("v.showQuoteCancelError",true);
                component.set("v.quoteCancelErrorMsg",errorMsg);
            }
        });
        $A.enqueueAction(action);
    }
})