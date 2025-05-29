({
    doInit: function (component, event, helper) {
        var c = "";
        if (sessionStorage) {
            if (sessionStorage.getItem('localTransfer')) {
                var json = sessionStorage.getItem('localTransfer');
                if (JSON.parse(json).name) {
                    if (JSON.parse(json).name !== 'all') {
                        c = JSON.parse(json).name;
                    }
                }
            } else {
                if (component.get("v.category") !== undefined && component.get("v.category") !== 'all') {
                    c = component.get("v.category");
                }
            }
        }
        component.set("v.category", c);
    },
    
    createLead : function (component, event, helper) {
        console.log("In resource footer : " + component.get("v.category"));
        var action = component.get("c.checkLeadProductExistence");
        action.setParams({"product" : component.get("v.category")});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var getProduct = response.getReturnValue();
                console.log('Product exists? : ' + getProduct);
                if(getProduct == '')
                {
                    console.log('inside false footer');
                    getProduct = 'Other Product';
                }
                
                var createRecordEvent = $A.get("e.force:createRecord");
                createRecordEvent.setParams({
                    "entityApiName": "Lead",
                    "defaultFieldValues": {
                        "Product__c": getProduct
                    }
                });
                createRecordEvent.fire();
            }
        });
        $A.enqueueAction(action);
    }
})