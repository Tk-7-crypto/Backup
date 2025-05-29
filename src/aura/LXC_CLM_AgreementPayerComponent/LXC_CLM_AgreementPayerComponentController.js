({ 
    doInit: function(component, event, helper) {  
        var agreementId = component.get("v.pageReference").state.c__recordId;
        component.set("v.recordId", agreementId); 
        helper.getPicklistData(component, event);
        helper.getCustomSettingData(component, event);
    }, 
    handleSubmit : function(component, event, helper) {
        var action = component.get("c.updateSpecialTerms");
        var specialTerms = component.get("v.specialTermsList"); 
        var toastEvent = $A.get("e.force:showToast");
        var isNoneAttribute = false;
        var rowSize = specialTerms.length;
        var allFalseCheck = 0;
        var allTrueCheck = 0;
        for(var i=0;i<rowSize;i++){
            var wObj = specialTerms[i]; 
            if(wObj.isNo == true){
                allFalseCheck += 1;
            }
            if(wObj.isYes == true && wObj.label != "None of the Above Selections Apply"){
                isNoneAttribute = true;
            }
            if(wObj.isYes == false && wObj.isNo == false){
                helper.showToast('error', 'Every row must have a selection inorder to save');
                return;
            }else if(wObj.label == "None of the Above Selections Apply" && isNoneAttribute == true && wObj.isYes == true){
                helper.showToast('error', "If None of the Above Selections Apply' is 'yes', all other rows must be 'no' inorder to save.");
                return;
            }else if(allFalseCheck == rowSize){ 
                helper.showToast('error', "At least 1 row must have a 'yes' selection inorder to save.");
                return;
            }          
            
        }
        action.setParams({"recordId" : component.get("v.recordId"),"objString":JSON.stringify(specialTerms)});
        component.set('v.showSpinner', true);
        action.setCallback(this, function(response) {
            var state = response.getState();
            var recordId = component.get("v.recordId");
            if (state === "SUCCESS") { 
                var result = response.getReturnValue(); 
                helper.showToast('info', result);
                window.parent.location = '/lightning/r/Apttus__APTS_Agreement__c/' + recordId + '/view';
            }
            component.set('v.showSpinner', false);
        });
        $A.enqueueAction(action);
    },handleClose : function(component, event, helper) {
        //$A.get("e.force:closeQuickAction").fire(); 
        component.set('v.showSpinner', true);
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId"),
            "slideDevName": "detail"
        });
        component.set('v.showSpinner', false);
        navEvt.fire();
    },onChangeRadio: function(component, event, helper) {
        var selectedIndex = event.getSource().get("v.name");
        var specialTerms = component.get("v.specialTermsList");  
        
        var selected = event.getSource().get("v.text");
        if(selected == 'isNo'){
            specialTerms[selectedIndex].isYes = false;
        }else if(selected == 'isYes'){
            specialTerms[selectedIndex].isNo = false;
        }    
        
    }
})