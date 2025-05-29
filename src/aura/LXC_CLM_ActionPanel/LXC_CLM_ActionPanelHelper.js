({
    startFlow : function(component,event)
    {
        var recId = component.get("v.recordId");
        var inputVariables = [
            {
                name : "recordId",
                type : "String",
                value : recId
            }
        ];
        var flow = component.find("flowData");
        flow.startFlow("CLM_LCN_Review_Check", inputVariables);
    }
})