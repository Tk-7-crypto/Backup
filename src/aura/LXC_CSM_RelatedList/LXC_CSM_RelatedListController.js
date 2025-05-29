({
    doInit: function (component, event, helper) {
        var objectName = component.get('v.objectName');
        var type = component.get("v.type");
        if(window.location.pathname.startsWith('/partner')){
            component.set("v.partnerURL", true);
        }
        var partnerURL = component.get("v.partnerURL");
        if (type === 'CombinedAttachments') {
            if (partnerURL == true) {
                component.set('v.columns', [
                    {
                        label: $A.get("$Label.c.Title"), fieldName: 'downloadUrl', type: 'url',
                        typeAttributes: { label: { fieldName: 'title' }, target: '_blank' }
                    },
                    {
                        label: 'Preview',
                        type: 'button',
                        initialWidth: 90,
                        typeAttributes: { disabled: false, name: 'view', title: 'Click to Preview', iconName: 'utility:preview' }
                    },
                    { label: $A.get("$Label.c.Last_Modified"), fieldName: 'lastModified', type: 'date' }
                ]);
            }
            else {
                var columns = [
                    {
                        label: $A.get("$Label.c.Title"), fieldName: 'downloadUrl', type: 'url', sortable: true,
                        typeAttributes: { label: { fieldName: 'title' }, target: '_blank' }
                    },
                    { label: $A.get("$Label.c.Type"), fieldName: 'fileType', type: 'text', sortable: true },
                    { label: $A.get("$Label.c.Created"), fieldName: 'createdDate', type: 'date', typeAttributes:{year: "numeric", month: "2-digit", day: "2-digit"}, sortable: true },
                    { label: $A.get("$Label.c.Last_Modified"), fieldName: 'lastModified', type: 'date', typeAttributes:{year: "numeric", month: "2-digit", day: "2-digit", hour: "2-digit", minute: "2-digit"}, sortable: true },
                    { label: $A.get("$Label.c.Created_by"), fieldName: 'created', type: 'text', sortable: true }];

                if (objectName === 'Case')
                    columns.push({
                        label: 'Delete',
                        type: 'button-icon',
                        typeAttributes: { disabled: false, name: 'delete', title: 'Click to Delete', iconName: 'utility:delete' }
                    });
                component.set('v.columns', columns);
            }
        } else if (type === 'EmailMessages') {
            component.set('v.columns', [
                {
                    label: $A.get("$Label.c.Subject"), fieldName: 'UrlName', type: 'url', sortable: true,
                    typeAttributes: { label: { fieldName: 'Subject' }, target: '_blank' }
                },
                { label: $A.get("$Label.c.From_Address"), fieldName: 'FromAddress', type: 'email', sortable: true },
                { label: $A.get("$Label.c.To_Address"), fieldName: 'ToAddress', type: 'email', sortable: true },
                { label: $A.get("$Label.c.Date"), fieldName: 'LastModifiedDate', type: 'date', typeAttributes:{year: "numeric", month: "2-digit", day: "2-digit"}, sortable: true }
            ]);
        } else if (type === 'CaseArticles') {
            component.set('v.columns', [
                {
                    label: $A.get("$Label.c.Title"), fieldName: 'UrlName', type: 'url', sortable: true,
                    typeAttributes: { label: { fieldName: 'Title' }, target: '_blank' }
                },
                {
                    label: $A.get("$Label.c.Number"), fieldName: 'UrlName', type: 'url', sortable: true,
                    typeAttributes: { label: { fieldName: 'ArticleNumber' }, target: '_blank' }
                },
                { label: $A.get("$Label.c.Last_Modified"), fieldName: 'LastModifiedDate', type: 'date', typeAttributes:{year: "numeric", month: "2-digit", day: "2-digit"}, sortable: true }
            ]);
        }
        helper.getDatas(component);
    },

    handleRowAction: function (cmp, event, helper) {
        console.log('inside handle row');
        var action = event.getParam('action');
        var row = event.getParam('row');
        console.log(action.name);
        switch (action.name) {
            case 'view':
                helper.previewDocument(row);
                break;
            case 'delete':
                if (row.parentType === 'email') {
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "type": "ERROR",
                        "title": $A.get("$Label.c.Action_Denied"),
                        "message": $A.get("$Label.c.You_are_not_allowed_to_delete_this_file")
                    });
                    $A.get("e.force:closeQuickAction").fire();
                    resultsToast.fire();
                    break;
                }

                var r = confirm("Are you sure you want to delete this file ?");
                if (r == true) {
                    helper.deleteContentDocumentById(cmp, row.id);
                }
                break;
        }
    },

    handleSort: function(cmp, event, helper) {
        helper.handleSort(cmp, event);
    }
})