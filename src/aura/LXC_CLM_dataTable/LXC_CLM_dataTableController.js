({
    doInit: function (component, event, helper) {
        helper.setupTable(component);
    },
    calculateWidth: function (component, event, helper) {
        event.preventDefault();
           var childObj = event.target;
           var parObj = childObj.parentNode;
            while(parObj.tagName != 'TH') {
                parObj = parObj.parentNode;
            }
        var t= childObj.closest('table');
        var tableWidth = t.offsetWidth;
        var startOffset = parObj.offsetWidth;
        var startX = event.pageX
        component.set("v.startOffset", (startX - startOffset));
        document.addEventListener('mousemove', onMouseMove);
        document.addEventListener('mouseup', onMouseUp);
        
        function onMouseMove(event) {
            let newWidth = startOffset + (event.clientX - startX);
            parObj.style.width = newWidth + 'px';
            t.style.width = (tableWidth + (event.clientX - startX)) + 'px';
            event.preventDefault();
        }
        
        function onMouseUp() {
            document.removeEventListener('mousemove', onMouseMove);
            document.removeEventListener('mouseup', onMouseUp);
        }

    },
    editRecord: function (component, event, helper) {
        var index = event.getSource().get("v.value"),
            data = component.get("v.dataCache"), recId = data[index].Id;
        var editRecordEvent = $A.get("e.force:editRecord");
        editRecordEvent.setParams({
            recordId: recId
        });
        editRecordEvent.fire();
    },
    editField: function (component, event, helper) {
        var field = event.getSource(),
            indexes = field.get("v.name"),
            rowIndex = indexes.split('-')[0],
            colIndex = indexes.split('-')[1];
        var data = component.get("v.tableData");
        data[rowIndex].fields[colIndex].mode = 'edit';
        data[rowIndex].fields[colIndex].tdClassName = 'slds-cell-edit slds-is-edited';
        component.set("v.tableData", data);
        component.set("v.isEditModeOn", true);
    },
    onInputChange: function (component, event, helper) {
        var field = event.getSource(),
            value = field.get("v.value"),
            indexes = field.get("v.name"),
            rowIndex = indexes.split('-')[0],
            colIndex = indexes.split('-')[1];
        helper.updateTable(component, rowIndex, colIndex, value);
    },
    closeEditMode: function (component, event, helper) {
        component.set("v.buttonsDisabled", true);
        component.set("v.buttonClicked", "Cancel");
        component.set("v.isLoading", true);
        setTimeout(function () {
            var dataCache = component.get("v.dataCache");
            var originalData = component.get("v.tableDataOriginal");
            component.set("v.data", JSON.parse(JSON.stringify(dataCache)));
            component.set("v.tableData", JSON.parse(JSON.stringify(originalData)));
            component.set("v.isEditModeOn", false);
            component.set("v.isLoading", false);
            component.set("v.error", "");
            component.set("v.buttonsDisabled", false);
            component.set("v.buttonClicked", "");
        }, 0);
    },
    saveRecords: function (component, event, helper) {
        component.set("v.buttonsDisabled", true);
        component.set("v.buttonClicked", "Save");
        component.set("v.isLoading", true);
        setTimeout(function () {
            var saveEvent = component.getEvent("LXC_CLM_dataTableSaveEvent");
            saveEvent.setParams({
                tableAuraId: component.get("v.auraId"),
                recordsString: component.get("v.modifiedRecords")
            });
            saveEvent.fire();
        }, 0);
    },
    finishSaving: function (component, event, helper) {
        var params = event.getParam('arguments');
        if (params) {
            var result = params.result, //Valid values are "SUCCESS" or "ERROR"
                data = params.data, //refreshed data from server
                message = params.message;
            console.log('message---' + JSON.stringify(message));
            if (result === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": 'success',
                    "message": "Records has been updated Successfully!"
                });
                toastEvent.fire();
                if (data) {
                    helper.setupData(component, data);
                } else {
                    var dataCache = component.get("v.dataCache"),
                        updatedData = component.get("v.updatedTableData");
                    component.set("v.data", JSON.parse(JSON.stringify(dataCache)));
                    component.set("v.tableDataOriginal", JSON.parse(JSON.stringify(updatedData)));
                    component.set("v.tableData", JSON.parse(JSON.stringify(updatedData)));
                }
                component.set("v.isEditModeOn", false);
            }
            else {
                if (message) component.set("v.error", message);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": 'error',
                    "message": "Error in Updating Records!" + message
                });
                toastEvent.fire();
            }
        }
        component.set("v.isLoading", false);
        component.set("v.buttonsDisabled", false);
        component.set("v.buttonClicked", "");
    }
})