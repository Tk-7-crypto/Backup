({
    doInit: function (component, event, helper) {
        component.set("v.isLoading", true);
        helper.setupTable(component, event, helper);
    },
    handleGotoRelatedList: function (component, event, helper) {
        helper.relatedList(component, event, helper);
    },
    saveTableRecords: function (component, event, helper) {
        var recordsData = event.getParam("recordsString");
        var tableAuraId = event.getParam("tableAuraId");
        var action = component.get("c.updateRecords");
        component.set("v.isLoading", true);
        action.setParams({ jsonString: JSON.stringify(recordsData) });
        action.setCallback(this, function (response) {
            if(response){
                var datatable = component.find(tableAuraId);
                datatable.finishSaving("SUCCESS");
            }
        });
        $A.enqueueAction(action);
        component.set("v.isLoading", false);   
    },
    doRefresh : function (component, event, helper) {
        helper.doRefreshHelper(component, event);
    }
});