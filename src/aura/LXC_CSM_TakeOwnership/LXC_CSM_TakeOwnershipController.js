({
	openForm : function(component, event, helper) {
        //component.set('v.newContact.AssignCaseToCurrentUser__c',true);
        helper.checkUserFromCurrentQueue(component);
        
	},
     showSpinner: function(component, event, helper) {
       // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
     },
    
   // this function automatic call by aura:doneWaiting event 
     hideSpinner : function(component,event,helper){
     // make Spinner attribute to false for hide loading spinner    
       component.set("v.Spinner", false);
     },
    PickStatusChange : function(component, event, helper) {
        helper.pickStatus(component,'PickStatusChange');
        
    },
     onCheck: function(cmp, evt) {
		 var checkCmp = cmp.find("checkbox");

	 },
    saveData : function(component, event, helper) {
        var recordData = component.get("v.recordId");
        var status = component.get("v.newContact.Status");
        var substatus = component.get("v.newContact.SubStatus__c");
        var currentQ = component.get('v.newContact.CurrentQueue__c');
        if(component.get('v.disabledPick')){
            component.set("v.newContact.SubStatus__c",'');
        }
        if(typeof currentQ === 'undefined'){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Ownership',
                message: 'Please Select the Assign Current Queue',
                messageTemplate: 'Record {0} created! See it {1}!',
                duration:'2000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
        }else if(typeof currentQ !== 'undefined'){
            var newcon = component.get("v.newContact");
            var action = component.get("c.Save");
            action.setParams({ 
                "con": newcon,
                "recordId": recordData
            });
            action.setCallback(this, function(a) {
                var state = a.getState();
                if (state === "SUCCESS") {
                    var result = a.getReturnValue();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Ownership',
                        message: 'Case is Saved Successfully',
                        messageTemplate: 'Record {0} created! See it {1}!',
                        duration:'5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                }
                else if(state === "ERROR"){
                    var errors = action.getError();
                    if (errors) {        
                        if(errors[0].message.split('.')[0] == 'Update failed') {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Error',
                                message: errors[0].message.split(',')[1].split('.')[0]+ '.',
                                messageTemplate: 'Record {0} created! See it {1}!',
                                duration:'20000',
                                key: 'info_alt',
                                type: 'error',
                                mode: 'pester'
                            });
                            toastEvent.fire();
                        }  
                    }
                }
            });
    }
        $A.enqueueAction(action);
}
});
