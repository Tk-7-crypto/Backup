({
    getDatas: function (component) {
        var action;
        var partnerURL = component.get("v.partnerURL");
        var type = component.get("v.type");
        if (type === 'CombinedAttachments')
            action = component.get("c.getContentDocumentLinks");
        else if (type === 'EmailMessages')
            action = component.get("c.getEmailMessages");
        else if (type === 'CaseArticles')
            action = component.get("c.getCaseArticles");
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var rows = response.getReturnValue();
                for (var i = 0; i < rows.length; i++) {
                    var row = rows[i];
                    if (row.type === 'Attachment') {
                        if (partnerURL == true) {
                            if (row.latestPublishedVersionId)
                            row.downloadUrl = "/partner/sfc/servlet.shepherd/version/download/" + row.latestPublishedVersionId;
                            else row.downloadUrl = "/partner/sfc/servlet.shepherd/version/download/" + row.id;
                        }
                        else {
                            if (row.latestPublishedVersionId)
                            row.downloadUrl = "/support/sfc/servlet.shepherd/version/download/" + row.latestPublishedVersionId;
                            else row.downloadUrl = "/support/servlet/servlet.FileDownload?file=" + row.id;
                        }
                    }

                    if (row.KnowledgeArticleVersion) {
                        row.Title = row.KnowledgeArticleVersion.Title;
                        row.UrlName = "/support/s/article/" + row.KnowledgeArticleVersion.UrlName;
                        row.ArticleNumber = row.KnowledgeArticleVersion.ArticleNumber;
                        row.LastModifiedDate = row.KnowledgeArticleVersion.LastModifiedDate;
                    }

                    if (row.FromAddress) {
                        row.UrlName = "/support/s/detail/" + row.Id;
                    }
                }
                component.set("v.data", rows);
            }
        });
        $A.enqueueAction(action);
    },

    previewDocument: function (row) {
        console.log('inside view doc');
        $A.get('e.lightning:openFiles').fire({
            recordIds: [row.ContentDocumentId]
        });
    },

    deleteContentDocumentById: function (component, contentDocumentId) {
        var action = component.get("c.deleteContentDocumentById");
        action.setParams({
            "contentDocumentId": contentDocumentId,
            "recordId": component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                $A.get('e.force:refreshView').fire();
            } else if (state === "ERROR") {
                if (response.getError()[0].pageErrors[0].statusCode === "INSUFFICIENT_ACCESS_OR_READONLY") {
                    var resultsToast = $A.get("e.force:showToast");
                    resultsToast.setParams({
                        "type": "ERROR",
                        "title": $A.get("$Label.c.Action_Denied"),
                        "message": $A.get("$Label.c.You_are_not_allowed_to_delete_this_file")
                    });
                    $A.get("e.force:closeQuickAction").fire();
                    resultsToast.fire();
                } else {
                    console.log("LXC_CSM_PortalFile] ERROR " + JSON.stringify(response.getError()));
                }
            }
        });
        $A.enqueueAction(action);
    },

    sortBy: function(field, reverse) {
        return function(a, b) {
            a = a[field];
            b = b[field];
            if (typeof a === 'string' && !isNaN(Date.parse(a))) {
                console.log('is a date');
                a = Date.parse(a);
                b = Date.parse(b);
            }
    
            return reverse * ((a > b) - (b > a));
        };
    },
    
    handleSort: function(cmp, event) {
        var sortedBy = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        var datas = cmp.get("v.data");
        var cloneData = datas.slice(0);
        cloneData.sort((this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1)));
        cmp.set('v.data', cloneData);
        cmp.set('v.sortDirection', sortDirection);
        cmp.set('v.sortedBy', sortedBy);
    }
})