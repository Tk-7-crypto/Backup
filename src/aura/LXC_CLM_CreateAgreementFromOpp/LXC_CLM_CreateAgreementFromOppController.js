({
    doInit : function(component, event, helper) {
        helper.getRecordTypes(component, event, helper);
    },
    onRadioSelect : function(component, event, helper){
        var recId = event.getSource().get("v.value");
        var recTypeName = event.getSource().get("v.label");
        var recDevName = event.getSource().get("v.id");
        component.set("v.selectedRecordType" , recId);
        component.set("v.selectedRecordTypeDevName", recDevName);
        component.set("v.disableNextButton", false);
        if((component.get("v.recordId").startsWith('006') && recTypeName != 'RWLP_RBU')
            || (!component.get("v.recordId").startsWith('006') && !component.get("v.recordId").startsWith('001'))) {
            helper.getDefaultFields(component, event);
        }
    },
    createRecord : function(component, event, helper){
        component.set("v.disableNextButton", true);
        helper.processSelection(component, event);
    },
    closeQuickAction : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }, 
    closeFlowModal: function(component, event, helper){
        component.set("v.isOpen", false);
        window.location = '/lightning/r/Opportunity/' + component.get("v.recordId") + '/view';
    },

})