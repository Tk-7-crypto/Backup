({
    doInit: function (component, event, helper) {
        helper.callToServer(
            component,
            "c.findHierarchyData",
            function (response) {
                var apexResponse = response;
                var roles = {};
                var results = apexResponse;

                roles[undefined] = { Name: "Root", items: [] };
                apexResponse.forEach(function (v) {
                    if (v.rec.Subject != null && v.rec.Subject != '') {
                        var subject = v.rec.Subject.substring(0, 69);
                        roles[v.rec.Id] = {
                            label: v.rec.CaseNumber + ' - ' + v.rec.Priority + ' - ' + subject,
                            name: v.rec.Id,
                            expanded: v.expanded,
                            items: []
                        };
                    }
                    else {
                        roles[v.rec.Id] = {
                            label: v.rec.CaseNumber + ' - ' + v.rec.Priority,
                            name: v.rec.Id,
                            expanded: v.expanded,
                            items: []
                        };
                    }
                });
                apexResponse.forEach(function (v) {
                    roles[v.rec.ParentId].items.push(roles[v.rec.Id]);
                });
                component.set("v.items", roles[undefined].items);
            },
            {
                recId: component.get('v.recordId')
            }
        );

        helper.callToServer(
            component,
            "c.showMassEditActivityButton",
            function (response) {
                var showMassEditActivityButton = response;
                component.set('v.showMassEditActivityButton', showMassEditActivityButton);
            },
            {
                recordId: component.get('v.recordId')
            }
        );
    },

    handleSelect: function (component, event, helper) {
        var recordId = event.getParam('name');
        var fromCSH = component.get('v.fromCSH');
        if (fromCSH) {
            var url = $A.get("$Site.siteUrlPrefix") + '/case/' + recordId;
            window.open(url, '_blank');
        } else {
            var modalBody;
            $A.createComponent("c:LXC_CSM_CaseHierarchyContent", {
                recordId: recordId
            },
                function (content, status) {
                    if (status === "SUCCESS") {
                        modalBody = content;
                        component.find('overlayLib').showCustomModal({
                            header: "Case Hierarchy Details",
                            body: modalBody,
                            showCloseButton: true,
                            cssClass: "slds-modal_medium",
                            closeCallback: function () { }
                        })
                    }
                });
        }
    },

    openActivityEditForm: function (component, event, helper) {
        var caseId = component.get('v.recordId');
        var workspaceAPI = component.find("workspace");
        workspaceAPI.openTab({
            url: '/lightning/r/Case/' + caseId + '/view',
            focus: false
        }).then(function (response) {
            workspaceAPI.openSubtab({
                parentTabId: response,
                url: '/lightning/n/Mass_Edit_Activity?c__recordId=' + caseId,
                focus: true
            });
        })
            .catch(function (error) {
                console.log(error);
            });
    }
})