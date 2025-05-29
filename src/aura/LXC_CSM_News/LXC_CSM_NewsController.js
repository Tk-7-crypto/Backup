({
	init: function(component, event, helper) {
		helper.getUserProfileId(component);
		helper.getCSMNews(component);
		if( component.get("v.module") == 'CRT') {
			helper.getUserPermissionSets(component);
			component.set("v.title", "US Change Request NEWS");
		}
        /*
        if(component.get("v.type") == 'Notes'){
            component.set("v.icon","standard:note");
            component.set("v.title", "Notes");
        }else{
            component.set("v.icon","standard:news");
            component.set("v.title", "News");
        }*/
	},

	handleRowAction: function (cmp, event, helper) {
		var action = event.getParam('action');
		var row = event.getParam('row');
		switch (action.name) {
		case 'edit':

			var editRecordEvent = $A.get("e.force:editRecord");
			editRecordEvent.setParams({
				"recordId": row.Id
			});
			editRecordEvent.fire();
			break;
		case 'delete':
			var rows = cmp.get('v.mydata');
			var rowIndex = rows.indexOf(row);
			rows.splice(rowIndex, 1);
			cmp.set('v.mydata', rows);
			break;
		}
	},

/*	handleSaveSuccess : function(component, event, helper) {
		$A.get('e.force:refreshView').fire();
        //helper.navigateToHome(component, event, helper);
        
	},*/
    navigateToHome : function(component, event, helper) {
        var isRedirect = component.get('v.isRedirect');
        if(isRedirect) {
            helper.navigateToHome(component, event, helper);
            component.set('v.isRedirect', false);
        }
    },
	handleEditCSMNews : function(component, event, helper) {
		var editRecordEvent = $A.get("e.force:editRecord");
		editRecordEvent.setParams({
			"recordId": component.get("v.csmNewsObject.Id")
		});
		editRecordEvent.fire();
	},
	
	closeModal : function(component, event, helper) {
		helper.closeModal(component,"modaldialogCSMNews");
	},

	newCSMNews: function(component, event, helper) {
		var createRecordEvent = $A.get("e.force:createRecord");
        var redirectURL = "/lightning/page/home";
		createRecordEvent.setParams({
			"entityApiName": "CSM_QI_News__c",
            "defaultFieldValues": {
            'Module__c' : component.get("v.module"),
            'Type__c' : component.get("v.type"),
            },
            "panelOnDestroyCallback": function(event) {
                window.location = redirectURL;
            }
		});
		createRecordEvent.fire();
	},
	
	openViewModal : function(component, event, helper) {
		helper.openModal(component,"modaldialogCSMNews");
	},
})