({
    helperMethod : function() {
        
    },
    
    GetMessageFromObject : function(component){
        var action =  component.get('c.getFlashMessage');
        action.setParams({
            'contactId' : component.get("v.contactRecordId"),
            'caseNumber' : '',
            'recordTypeId' : component.get("v.recordTypeId")
        });
        
        action.setCallback(this, function(a){
            var state = a.getState();
            console.log('a.getReturnValue() inside helper.GetMessageFromObject: '+a.getReturnValue());
            if(a.getReturnValue() != ''){
                if(state == 'SUCCESS') {
                    var toastEvent = $A.get("e.force:showToast");                
                    toastEvent.setParams({"title": "Flash Message : \n","message": "\n"+a.getReturnValue(),type: 'success',mode: 'sticky'});
                    toastEvent.fire();
                }                
            }            
        });
        $A.enqueueAction(action);
    }, 
    
    GetMessageFromLOS: function(component){
        var action =  component.get('c.getFlashMessage');
        action.setParams({
            'contactId' : '',
            'caseNumber' : component.get("v.caseNumber"),
            'recordTypeId' : component.get("v.recordTypeId")
        });
        
        action.setCallback(this, function(a){
            var state = a.getState();
            console.log('a.getReturnValue() inside helper.GetMessageFromLOS : '+a.getReturnValue());
            if(a.getReturnValue() != ''){
                if(state == 'SUCCESS') {
                    var toastEvent = $A.get("e.force:showToast");                
                    toastEvent.setParams({"title": "Flash Message : \n","message": "\n"+a.getReturnValue(),type: 'warning',mode: 'sticky'});
                    toastEvent.fire();
                }                
            }            
        });
        $A.enqueueAction(action);
    },
    GetReasonForLateMessage:function(component){
        var action =  component.get('c.getReasonForLateMessage');
        action.setParams({
            'caseId' : component.get("v.simpleRecord").Id,
            'recordTypeId' : component.get("v.simpleRecord").RecordTypeId
        });
        
        action.setCallback(this, function(a){
            var state = a.getState();
            console.log('a.getReturnValue() inside helper.GetMessageFromLOS : '+a.getReturnValue());
            if(a.getReturnValue() != ''){
                if(state == 'SUCCESS' && a.getReturnValue() == true) {
                    var toastEvent = $A.get("e.force:showToast");                
                    toastEvent.setParams({"title": "Flash Message : \n","message": "\nThis case has been flagged as Late.",type: 'error',mode: 'sticky'});
                    toastEvent.fire();
                }                
            }            
        });
        $A.enqueueAction(action);        
    },
    checkTimeSheetMessage:function(component){
        var action =  component.get('c.checkTimeSheetMessage');
        action.setParams({
            'caseId' : component.get("v.simpleRecord").Id,
            'recordTypeId' : component.get("v.simpleRecord").RecordTypeId
        });
        
        action.setCallback(this, function(a){
            var state = a.getState();
            console.log('a.getReturnValue() inside helper.GetMessageFromLOS : '+a.getReturnValue());
            if(a.getReturnValue() != ''){
                if(state == 'SUCCESS' && a.getReturnValue() == true) {
                    var toastEvent = $A.get("e.force:showToast");                
                    toastEvent.setParams({"title": "Flash Message : \n","message": "\nNo related time sheet record associated to the current update. Please add your time and type in the Time Sheet component before updating the case.",type: 'info',mode: 'sticky'});
                    toastEvent.fire();
                }                
            }            
        });
        $A.enqueueAction(action);        
    },
    getSNStatus: function(component){
        console.log('OUTPUTs Case IDs : '+component.get("v.simpleRecord").RecordTypeId);
        var action =  component.get('c.checkIfSNStatusCancelled');
        action.setParams({
            'recordTypeId': component.get("v.simpleRecord").RecordTypeId,
            'SNStatus': component.get("v.simpleRecord").ServiceNow_Status__c,
            'parentId': component.get("v.simpleRecord").ParentId
        });
        
        action.setCallback(this, function(a){
            var state = a.getState();
            
            console.log('OUTPUT a.getReturnValue() inside helper.getSNStatus : '+a.getReturnValue());
            console.log('OUTPUT state Flas: '+state);
            if(a.getReturnValue() != ''){
                if(state == 'SUCCESS' && a.getReturnValue() == true) {
                    component.set("v.warning",true);
                }                
            }            
        });
        $A.enqueueAction(action);
    }
    
    
})
