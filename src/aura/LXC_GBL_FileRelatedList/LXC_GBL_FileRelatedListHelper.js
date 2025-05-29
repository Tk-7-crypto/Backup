({
    fetchData: function(component){
        var numberOfRecords = component.get('v.numberOfRecords');
        var folderName = component.get('v.folderName');
        var jsonData = JSON.stringify({
            recordId: component.get('v.recordId'),
            numberOfRecords: numberOfRecords + 1,
            folderName: folderName
        });
        component.set('v.showLoading', true);

        this.callServerAction(component, "c.initData", function(response) {
            var jsonData = JSON.parse(response);
            
            const {
                records, 
                parentRecord, 
                parentObjectName, 
                parentObjectLabel
            } = jsonData;
            
            component.set("v.parentObjectName", parentObjectName);
            component.set("v.parentObjectLabel", parentObjectLabel);
            component.set("v.parentRecord", parentRecord);
            
            if((numberOfRecords != -1) && (records.length > numberOfRecords)) {
                records.pop();
                component.set('v.numberOfRecordsForTitle', numberOfRecords + '+');
            }
            else{
                component.set('v.numberOfRecordsForTitle', Math.min(numberOfRecords, records.length));
            }
            records.forEach(record => {
                record.LinkName = '/' + record.Id;
            });
            component.set('v.records', records);
            component.set('v.showLoading', false);
        }, {
            jsonData: jsonData
        });
    },

    initColumnsWithActions: function(component, event, helper) {
        var customActions = component.get('v.customActions');
        if (!customActions.length) {
            customActions = [{
                    label: $A.get("$Label.c.CLM_CL0004_Download"),
                    name: 'download'
                },
                {
                    label: $A.get("$Label.c.CLM_CL0004_Delete"),
                    name: 'delete'
                }
            ];
        }

        var columns = component.get('v.columns');
        var columnsWithActions = [];
        columnsWithActions.push(...columns);
        columnsWithActions.push({
            type: 'action',
            typeAttributes: {
                rowActions: customActions
            }
        });
        component.set('v.columnsWithActions', columnsWithActions);
    },

    removeRecord: function(component, row) {
        var modalBody;
        var modalFooter;
        var sobjectLabel = component.get('v.sobjectLabel');
        $A.createComponents(
            [
                ['c:LXC_GBL_DeleteFileConfirmPopup', {
                    sobjectLabel: sobjectLabel,
                    fileName: row.File_Name__c
                }],
                ['c:LXC_GBL_DeleteFileConfirmPopupFooter', {
                    record: row,
                    sobjectLabel: sobjectLabel,
                    folderName: component.get('v.folderName')
                }],
            ],
            function(components, status) {
                if (status === 'SUCCESS') {
                    modalBody = components[0];
                    modalFooter = components[1];
                    component.find('overlayLib').showCustomModal({
                        header: 'Delete ' + sobjectLabel,
                        body: modalBody,
                        footer: modalFooter,
                        showCloseButton: true,
                    });
                }
            }
        );
    },

    downloadFile: function(component, row) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/apex/VFP_GBL_ViewSharepointFile?sharepointFileId=" + row.Id + "&parentId=" + component.get("v.recordId") 
                + "&folderName=" + component.get("v.folderName")
        });
        urlEvent.fire();
    },

    
    /**
     * To Call the Server method
     * @param {Object} component     Root Component
     * @param {String} actionName    Apex Controller Method name to be called
     * @param {Object} callback      Function which should call after Server Action
     * @param {Object} param         Parameters to be passed in Apex Controller Method
     */
    callServerAction: function(component, actionName, callback, param) {
        var action = component.get(actionName);
        if (param) {
            action.setParams(param);
        }
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                callback.call(this, response.getReturnValue());
            } else if (state === "ERROR") {
                var errors = response.getError();
                console.log("Errors", errors);
            }
        });
        $A.enqueueAction(action);
    },
});