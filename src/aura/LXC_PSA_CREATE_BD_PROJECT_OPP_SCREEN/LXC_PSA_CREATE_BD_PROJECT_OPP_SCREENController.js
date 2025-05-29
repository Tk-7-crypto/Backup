({
    doInit : function(component, event, helper) {
        component.set('v.isLoading', true);
        component.set('v.showErrorMessage', false);
        var legacyOrgLink;
        
        var action1 = component.get("c.getLegacyOrgLink");
        action1.setCallback(this, function(response){
            if(component.isValid() && response !== null && response.getState() == 'SUCCESS'){
                //getting custom setting to variable
                var legacyOrgLinks = response.getReturnValue();
                legacyOrgLink = legacyOrgLinks.Legacy_IMS_URL__c;
            }
        });
        
        var action2 = component.get("c.validateOppForProjectCreation");
        action2.setParams({ opportunityId : component.get("v.oppId") });
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var arrayOfMessages = response.getReturnValue();
                if(arrayOfMessages.length>0 && arrayOfMessages[0].length>18) {
                    if(arrayOfMessages[0].includes('Atleast one MDM validated address is required to create a BD project')){
                        component.set('v.isMDMUnvalidated', true);
                    }
                    component.set("v.errorArray", arrayOfMessages); 
                    component.set('v.isLoading', false);
                    component.set('v.showErrorMessage', true);
                }
                else{
                    component.set('v.isLoading', false);
                    var urlVal = 'https://'+legacyOrgLink+'/apex/PSA_CreateBDProject?id='+arrayOfMessages[0];
                    window.open(urlVal,'_top');
                }
            }
        });
        $A.enqueueAction(action1); 
        $A.enqueueAction(action2);       
        
    },
    BackToOpportunity: function(component, event, helper) {
        var url = "/one/one.app#/sObject"; 
        window.open(url+"/"+component.get("v.oppId"),"_parent");
    },
    
    redirectToMDMTeam : function(component,event, helper) {
        var url = "https://quintiles.service-now.com/via/?id=sc_cat_item&sys_id=4b0859dddb28c8107cf37e77f4961900"; 
        window.open(url,"_blank");
    } 
})
