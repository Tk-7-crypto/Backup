({
    showModel : function(component, event, helper) {
        var params = event.getParams();   
        helper.setProductRecordToCurrentLayer(component, event, helper, params.currentLayer, params.productRecords);
    }
})