({
    init: function(component, event, helper) {
        helper.hasEditPermission(component);
        helper.getData(component);
        var field  = component.get("v.field");
        field = field.replace("__c", "");
        field = field.split('_').join(' ');
        component.set("v.fieldLabel",field);
    },
    handleEditCSMNews : function(component, event, helper) {
        document.body.style.overflow = "hidden";
        document.body.style.height = "100%";
        component.set("v.isModalOpen",true);
    },
    closeModel : function(component, event, helper) {
        component.set("v.isModalOpen", false);
        document.body.style.overflow = "auto";
        document.body.style.height = "auto";
    },
    handleSubmit :function(component, event, helper) {
        component.find("editForm").submit();
    },
    handleError : function(component, event, helper) {
    },
    handleSuccess:function(component, event, helper) {
        helper.getData(component);
        document.body.style.overflow = "auto";
        document.body.style.height = "auto";
        component.set("v.isModalOpen", false);
        var fieldLabel = component.get("v.fieldLabel");
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "message": fieldLabel + " saved.",
            "type" :"success"
        });
        toastEvent.fire();
    }
})