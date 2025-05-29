({
    openRecord: function (component, event, helper) {
        var selectedItem = event.currentTarget;
        var recordId = selectedItem.dataset.value;
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId,
            "slideDevName": "related"
        });
        navEvt.fire();
    }
})