({
    setupTable: function (component, event, helper) {
        // Calling apex method to get picklist values dynamically
        var action = component.get("c.getPicklistValues");
        var recordId = component.get("v.recordId");
        action.setParams({
            objectAPIName: "Task",
            fieldAPIName: "Status",
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                var winReason = [];
                Object.entries(response.getReturnValue()).forEach(([key, value]) => winReason.push({ label: key, value: value }));
                component.set("v.statusList", winReason);
                //this.setupTableStatus(component, event, helper);
                this.defineColumns(component, event, helper);
            } else {
                var errors = response.getError();
                var message = "Error: Unknown error";
                if (errors && Array.isArray(errors) && errors.length > 0) message = "Error: " + errors[0].message;
                component.set("v.error", message);
            }
        });
        $A.enqueueAction(action);
    },
    defineColumns: function (component, event, helper) {
        var statusOption = [];
        statusOption = component.get("v.statusList");
        var cols = [
            { label: "Subject", fieldName: "subjectLink", type: "link", resizable: true, attributes: { label: { fieldName: "Subject" }, target: "_blank" } },
            { label: "Assigned To", fieldName: "assignedToLink", type: "link", resizable: true, attributes: { label: { fieldName: "Task_Owner_Name__c" }, target: "_blank" } },
            { label: "Status", fieldName: "Status", editable: true, type: "picklist", selectOptions: statusOption, resizable: true },
            { label: "Due Date", fieldName: "ActivityDate", type: "date", editable: true, resizable: true },
            { label: "Completed Date", fieldName: "CompletedDateTime", type: "date", resizable: true },
            { label: "Comments", fieldName: "Description", type: "text", editable: true, resizable: true },
            {
                type: "button-icon", initialWidth: 20,
                typeAttributes: { iconName: "utility:edit", name: "edit", label: "edit", }
            },
        ];
        component.set("v.columns", cols);
        this.loadRecords(component);
    },
    relatedList: function (component, event, helper) {
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:LXC_CLM_RelatedListCmp",
            isredirect: false,
            componentAttributes: {
                recordId: component.get("v.recordId"),
                numberOfRecords: -1,
                isRelatedList: true,
                sobjectApiName: component.get("v.sobjectApiName")
            },
        });
        evt.fire();
    },
    loadRecords: function (component) {
        var action = component.get("c.getRecords");
        action.setParams({
            recordId: component.get("v.recordId"),
        });
        action.setCallback(this, function (response) {
            if (response.getState() === "SUCCESS") {
                var allRecords = response.getReturnValue();
                allRecords.forEach((rec) => {
                    rec.subjectLink = "/" + rec.Id;
                    rec.assignedToLink = "/" + rec.OwnerId;
                });
                component.set("v.data", allRecords);
                component.set("v.isLoading", false);
            } else {
                var errors = response.getError();
                var message = "Error: Unknown error";
                if (errors && Array.isArray(errors) && errors.length > 0) message = "Error: " + errors[0].message;
                component.set("v.error", message);
                console.log("Error: " + message);
            }
        });
        $A.enqueueAction(action);
    },
    doRefreshHelper: function (component, event) {
        component.set("v.isLoading", true);
        this.loadRecords(component);
    }
});