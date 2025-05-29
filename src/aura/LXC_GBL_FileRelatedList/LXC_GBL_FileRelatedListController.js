({
    init: function (component, event, helper) {
        var acceptFiles = component.get("v.acceptFiles");
        if(acceptFiles)
            component.set("v.fileFormats", acceptFiles.split(","));

        component.set('v.columns', [
            {
                label: 'File Name',
                fieldName: 'File_Name__c',
                type: 'text',
            }
        ]);
        helper.fetchData(component, event, helper);
        helper.initColumnsWithActions(component, event, helper);
    },

    parentRecordChange: function(component, event, helper){
        var value = event.getParam("value");
        if(value == ""){
            $A.enqueueAction(component.get("c.navigateToParentObjectList"));
        }
    },
    
    parentRefresh : function(component, event, helper) {
        helper.fetchData(component, event, helper);
    },
    
    handleColumnsChange: function (component, event, helper) {
        helper.initColumnsWithActions(component, event, helper);
    },
    
    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        var onRowActionHandler = component.get('v.onRowActionHandler');
        
        if (onRowActionHandler) {
            $A.enqueueAction(onRowActionHandler);
        } else {
            switch (action.name) {
                case 'download':
                    helper.downloadFile(component, row);
                    break;
                case 'delete':
                    helper.removeRecord(component, row);
                    break;
            }
        }
    },
    
    handleGotoRelatedList: function (component, event, helper) {
        var relatedListEvent = $A.get('e.force:navigateToComponent');
        relatedListEvent.setParams({
            componentDef: "c:LXC_GBL_FileRelatedList",
            componentAttributes: {
                recordId: component.get("v.recordId"),
                numberOfRecords: -1,
                isRelatedList:true,
                folderName: component.get("v.folderName")
            }
        });
        relatedListEvent.fire();  
    },
    
    handleToastEvent: function (component, event, helper) {
        var eventType = event.getParam('type');
        var eventMessage = event.getParam('message');
        if (eventType == 'SUCCESS' && eventMessage.includes(component.get('v.sobjectLabel'))) {
            helper.fetchData(component, event, helper);
            event.stopPropagation();
        }
    },
    
    navigateToParentObjectList: function (component, event) {
        //event.preventDefault();
        var homeEvent = $A.get("e.force:navigateToObjectHome");
        homeEvent.setParams({
            "scope": component.get("v.parentObjectName")
        });
        homeEvent.fire();
    },
    
    navigateToParentObject: function (component, event) {
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": component.get("v.recordId"),
            "slideDevName": "detail"
        });
        navEvt.fire();
    }
});