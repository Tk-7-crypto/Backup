({
	init : function(cmp, event, helper) {
        cmp.set('v.showSpinner', true);
        
        var actions = [
            {label: 'View Relationship', name: 'view_relationship'},
            {label: 'Edit Relationship', name: 'edit_relationship'}
        ];

        cmp.set('v.columns', [
            {label: 'Employee Name', fieldName: 'linkName', type: 'url', sortable: true,
             typeAttributes: {label: {fieldName: 'ContactName'}, target: '_blank', tooltip: {fieldName: 'ContactName'}}},
            {label: 'Function', fieldName: 'Function__c', type: 'text', sortable: true},
            {label: 'Focus', fieldName: 'Focus__c', type: 'text', sortable: true},
            {label: 'User Country', fieldName: 'User_Country__c', type: 'text', sortable:true},
            {label: 'Geographic Responsibility', fieldName: 'Geographic_Responsibility__c', type: 'text', sortable: true},
            {label: 'Segment Responsibility', fieldName: 'Responsibility__c', type: 'text', sortable: true},
            {label: 'End Date', fieldName: 'EndDate', type: 'date', sortable: true},
            {type: 'action', typeAttributes: {rowActions: actions}}
        ]);
        helper.getData(cmp);
	},
    
    handleRowAction : function(cmp, event, helper) {
        var action = event.getParam('action');
        var row = event.getParam('row');
        
        switch (action.name) {
            case 'view_relationship':
                var viewRecordEvent = $A.get("e.force:navigateToSObject");
                viewRecordEvent.setParams({
                    "recordId": row.Id,
                    "slideDevName": "detail"
                });
                viewRecordEvent.fire();
                break;
            case 'edit_relationship':
                var editRecordEvent =$A.get("e.force:navigateToURL");
                var accContactId = row.Id;
                var accountId = cmp.get("v.recordId");
                var redirectionPath = "Account Detail Page";
                editRecordEvent.setParams({
                  "url": "/flow/Edit_New_Employee_Relationship?recordId=" + accContactId + "&redirectionPath=" + redirectionPath + "&retURL=" + accountId
                });
                editRecordEvent.fire();
                cmp.addEventHandler("force:recordChange",  cmp.getReference("c.handleEditEvent"));
                break;  
            default:
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": 'error',
                    "title": 'Error',
                    "message": 'There was an issue performing the desired action.',
                    "mode": "pester"
                });
                toastEvent.fire();
        }
    },
    
    handleEditEvent : function(cmp, event, helper) {
        $A.get('e.force:refreshView').fire();
    },
    
    updateColumnSorting : function(cmp, event, helper) {
        console.log('sort');
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        cmp.set("v.sortedBy", fieldName);
        cmp.set("v.sortedDirection", sortDirection);
        helper.sortData(cmp, fieldName, sortDirection);
    },
    
    viewRelationshipMobile : function(cmp, event, helper) {
        var relationId = event.currentTarget.dataset.record;
        var viewRecordEvent = $A.get("e.force:navigateToSObject");
        viewRecordEvent.setParams({
            "recordId": relationId,
            "slideDevName": "detail"
        });
        viewRecordEvent.fire();
        cmp.addEventHandler("force:recordChange",  cmp.getReference("c.handleEditEvent"));
    }
})