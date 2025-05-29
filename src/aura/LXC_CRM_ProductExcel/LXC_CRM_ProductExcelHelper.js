({
    generateExcel: function(component, event, helper) {
        var id = component.get("v.recordId");
        if(id) {
            try {
                let vfUrl = '/apex/VFP_CRM_NavigateToProductExcel?id='+id;
                window.open(vfUrl, '_self');
            } catch (e) {
                console.error('Error in executing : ' + e);
            }
        }
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    }
})