({
    doInit: function (component, event, helper) {
        component.set("v.showPopUp", true);
        helper.getProposalWithLineItems(component);
    },

    submitCSSApprovalRequest: function (component, event, helper) {
        component.set("v.showSpinner", true);
        var approvalDetailsJSON = {
            proposalId: component.get("v.recordId"),
            approvalUserEmail: component.get("v.selectedCSSApprover"),
            subject: component.get("v.subject"),
            templateBody: component.get("v.richTextContent")
        };
        helper.submitCSSApprovalRequest(component, JSON.stringify(approvalDetailsJSON));
    },

    closePopUp: function (component, event, helper) {
        component.set("v.showPopUp", false);
        var parentPopUp = component.get("v.parent");
        parentPopUp.set("v.isDisplayCSSForm", false);
        $A.get('e.force:refreshView').fire();
    },
})