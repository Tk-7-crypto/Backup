({
	getRecordTypes : function(component, event, helper) {
		var action = component.get("c.getEligibleRecordTypes");
        var OpportunityId = component.get("v.recordId");
        var oppFields = component.get("v.oppFields");
        action.setParams({
            "opportunityId" : OpportunityId,
            "oppFields" : oppFields
        });
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
                component.set("v.bidTypes",actionResult.getReturnValue());             
                //Here we get the clinical record type
                if(component.get("v.isByPassClinicalBid")){
                var allRecordTypes = component.get("v.bidTypes");
                allRecordTypes.forEach(function(entry) {
                    if(entry.name=="Clinical"){
                        component.set("v.recordTypeTypeName",entry.name);     
                        component.set("v.recordTypeId",entry.typeId);   
                        helper.getDefaultVal(component, event, helper);
                    }
                });
                }
            }else{
                component.set("v.isSpinner",false);
            }
        });
        $A.enqueueAction(action);
    },
    
    //This method is used to get the value default values for the 
    //clinical bid record type.
      getDefaultVal : function(component, event, helper){  
        var recId = component.get("v.recordTypeId"); 
        var recTypeName = component.get("v.recordTypeTypeName");       
        component.set("v.selectedBidTypeOnRadio" , recId);
        component.set("v.selectedBidTypeNameOnRadio" , recTypeName); 
        var action = component.get("c.getDefaultFieldValues");
        var OpportunityId = component.get("v.recordId");
        action.setParams({
            "opportunityId" : OpportunityId,
            "recordTypeId": recId,
        });
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {                
                component.set("v.defaultValues",actionResult.getReturnValue());
                console.log(component.get("v.defaultValues")); 
                if(component.get("v.defaultValues")!=null){
                    helper.createRecord_helper(component, event, helper);
                }
            }else{
                component.set("v.isSpinner",false);
            }
       });
       $A.enqueueAction(action);
   },
    getOppDetails : function(component, event, helper) {
		var action = component.get("c.getAccountId");
        var OpportunityId = component.get("v.recordId");
        var oppFields = component.get("v.oppFields");
        action.setParams({
            "opportunityId" : OpportunityId,
            "oppFields" : oppFields
        });
        action.setCallback(this, function(actionResult) {
            var state = actionResult.getState();
            if (state === "SUCCESS") {
                component.set("v.accountId",actionResult.getReturnValue());             
            }
       });
       $A.enqueueAction(action);
   },
 usingMap : function(component, event, helper) {       
  var action = component.get("c.getEligibleRecordTypes");
        action.setCallback(this,function(response){
            var values = [];
            var result = response.getReturnValue();
            for(var key in result){
                values.push({
                    class:'optionClass',
                    label:key.bidHeader+key.bidDescription,
                    value:key.typeId});         
            }
            component.set("v.optionsList",values);
        });
        $A.enqueueAction(action);
 },
    
    createRecord_helper : function (component, event, helper) {
        var recId = component.get("v.selectedBidTypeOnRadio");
        var recTypeName = component.get("v.selectedBidTypeNameOnRadio");
        var oppID =  component.get("v.recordId");
        var ligValidatedState = '';
        component.set("v.selectedBidType" , recId);
        component.set("v.selectedBidTypeName" , recTypeName);  
        console.log('recId '+recId);
        if(recId == undefined) {
            component.set("v.isSpinner",false);
            var errorMsg = 'Please select a record type!';
            component.set("v.isError" , true); 
            component.set("v.errorMessage", errorMsg);
        }
        else 
        {
            component.set("v.isSpinner",false);
            var tAction = component.get("c.validateLIGForClinicalAgreement");
            tAction.setParams({
                "opportunityId" : oppID,
                "recordTypeId" : recId
            });
            tAction.setCallback(this, function(actionResult) {
                if(actionResult.getReturnValue() == 6){ 
                    var r = confirm('You can only create a Clinical bid for Strategy changes at stage 6.');
                    if (r == false) {
                        $A.get("e.force:closeQuickAction").fire();
                        return false;                        
                    }
                }
                ligValidatedState = tAction.getState();
                if (ligValidatedState === "SUCCESS") {
                    component.set("v.isSpinner",false);
                    var defaultVal = component.get("v.defaultValues") ;
                    if(recTypeName === "Non-RFP"){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : '',
                            message: ' Non-RFP records should not be used for Early Engagement, Rebids or Post Award.',
                            duration:' 5000',
                            type: 'Warning'
                        });
                        toastEvent.fire();                        
                    }
                    var createRecordEvent = $A.get("e.force:createRecord");
                    createRecordEvent.setParams({
                        "entityApiName": "Bid_History__c",
                        "defaultFieldValues": JSON.parse(defaultVal),
                        "recordTypeId": recId,
                        "panelOnDestroyCallback": function(event) {
                            var navEvt = $A.get("e.force:navigateToSObject");
                            navEvt.setParams({
                                "recordId": oppID,
                            });
                            navEvt.fire();
                        }
                    });
                    createRecordEvent.fire();
                }
                else
                {
                    component.set("v.isSpinner",false);
                    var errors = actionResult.getError();	
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Validate Opportunity',
                        message: errors[0].message,
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'Error',
                        mode: 'sticky'
                    });
                    toastEvent.fire();
                    
                }
            });
            $A.enqueueAction(tAction);   
        }
    }
})