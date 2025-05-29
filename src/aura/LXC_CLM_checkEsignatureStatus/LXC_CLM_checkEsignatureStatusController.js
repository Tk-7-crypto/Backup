({
	init : function(component, event, helper) {
      
        var pageReference = component.get("v.pageReference");
        if(pageReference!==undefined && pageReference!==null && pageReference.state!=null)
        {
            var recordId=pageReference.state.c__recordId; 
            component.set("v.recordId",recordId);

        } 
        
        helper.processESignatureStatus(component,helper);
    },
    
    goto0: function (component, event, helper) {
        var navSer = component.find("navigate");
        var rId = (component.get("v.agrId") != undefined ? component.get("v.agrId") : component.get("v.recordId"));
        window.open('/lightning/r/IQVIA_Agreement__c/' + rId + '/view', '_top');
    }
})