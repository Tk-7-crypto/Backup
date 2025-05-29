({
    doInit : function(component, event, helper) {
        component.set('v.isLoading', true);
        component.set('v.showErrorMessage', false);
        var opportunityId = component.get("v.oppId");
        
        var action = component.get("c.validateOppForProjectCreation");
        action.setParams({ "opportunityId" : opportunityId });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                debugger;
                var result = response.getReturnValue();
                console.log('result',result);
                if(result != null) { 
                    var errorMessages = JSON.parse(result['errorMessages']);
                    component.set('v.isLoading', false);
                    if(errorMessages.length > 0) {
                        for(var i = 0; i<  errorMessages.length ; i++){
                            if(errorMessages[i].includes('At least one MDM validated address is required to create a')){
                                if(errorMessages[i].includes('At least one MDM validated address is required to create a Planned project.'))
                                {
                                    component.set('v.isPlannedProject', true);
                                }
                                component.set('v.errorArraySize',errorMessages.length);
                                component.set('v.isMDMUnvalidated', true);
                                errorMessages.splice(i, 1);;
                            }
                        }
						component.set('v.showErrorMessage', true);
                        component.set('v.isLoading', false);
                        component.set("v.errorArray", errorMessages);                
                    } else {
                        component.set('v.isLoading', false);
                        if(result['IsZQUIProduct']=='ZQUI') {
                            window.open('https://'+result['legacyOrgLink']+'/apex/CreateProject?id='+result['legacyOrgOppId']+'&LQ_opp_number='+result['legacyQuintilesOppNumber']+'&SalesOrg='+result['SalesOrg'],'_top');
                        } else {
                            window.open('https://'+result['legacyOrgLink']+'/apex/CreateProject?id='+result['legacyOrgOppId']+'&LQ_opp_number=None'+'&SalesOrg='+result['SalesOrg'],'_top'); 
                        }
                    }
                }
           }else if (state === "ERROR") {
               console.log('Error :: ',response.getError());
           }
       });
       $A.enqueueAction(action);
    },
    BackToOpportunity: function(component, event, helper) {
        var url = "/one/one.app#/sObject"; 
        window.open(url+"/"+component.get("v.oppId"),"_parent");
    },
    
    redirectToMDMTeam : function(component,event, helper) {
        var url = "https://quintiles.service-now.com/via/?id=sc_cat_item&amp;sys_id=4b0859dddb28c8107cf37e77f4961900"; 
        window.open(url,"_blank");
    } 
    
})
