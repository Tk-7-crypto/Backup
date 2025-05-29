({
    init : function(cmp, event, helper) {
        cmp.set('v.showSpinner', true);
        cmp.set('v.columns', [
            {label: $A.get("$Label.c.Employee_Name"), fieldName: 'ContactName', type: 'text', sortable: true},
            {label: $A.get("$Label.c.Focus"), fieldName: 'Focus__c', type: 'text', sortable: true},
            {label: $A.get("$Label.c.Function"), fieldName: 'Function__c', type: 'text', sortable: true},
            {label: $A.get("$Label.c.Geographic_Responsibility"), fieldName: 'Geographic_Responsibility__c', type: 'text', sortable: true},
            {label: $A.get("$Label.c.Segment_Responsibility"), fieldName: 'Responsibility__c', type: 'text', sortable: true},
            
        ]);
            helper.getContactData(cmp);
            helper.getUserDetail(cmp);
            helper.getData(cmp);
            
    },
           
    uploadImage:function(cmp, event, helper) {
        $A.util.removeClass(cmp.find("modaldialog"), "slds-fade-in-hide");
        $A.util.addClass(cmp.find("modaldialog"), "slds-fade-in-open");
        $A.util.removeClass(cmp.find("backdrop"), "slds-backdrop--hide");
        $A.util.addClass(cmp.find("backdrop"), "slds-backdrop--open");
          
    },
    closeForm :function(cmp, event, helper) {
        helper.deleteAttachment(cmp);
        $A.util.addClass(cmp.find("modaldialog"), "slds-fade-in-hide");
        $A.util.removeClass(cmp.find("modaldialog"), "slds-fade-in-open");
        $A.util.addClass(cmp.find("backdrop"), "slds-backdrop--hide");
        $A.util.removeClass(cmp.find("backdrop"), "slds-backdrop--open");
    },
            
    handleFilesChange: function(component, event, helper) {
        var file ;
        if (event.getSource().get("v.files").length > 0) {
           file = event.getSource().get("v.files")[0];
        }
        var reader = new FileReader();
        reader.onloadend = function() {
            var dataURL = reader.result;
            helper.upload(component, file, dataURL.match(/,(.*)$/)[1]);
        };
        reader.readAsDataURL(file);
    },
    saveData:function(cmp, event, helper) {
        helper.setPhoto(cmp);
        $A.util.addClass(cmp.find("modaldialog"), "slds-fade-in-hide");
        $A.util.removeClass(cmp.find("modaldialog"), "slds-fade-in-open");
        $A.util.addClass(cmp.find("backdrop"), "slds-backdrop--hide");
        $A.util.removeClass(cmp.find("backdrop"), "slds-backdrop--open");
        //window.location.reload();
    }
})