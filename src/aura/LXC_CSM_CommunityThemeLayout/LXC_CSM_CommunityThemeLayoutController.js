({
    doInit: function (component, event, helper) {
        let currentUser = $A.get("$SObjectType.CurrentUser.Id");
        sessionStorage.removeItem('localTransfer');
        component.set("v.copyright_date", new Date().getFullYear());
        if(currentUser) {
            component.set("v.userId", currentUser.substring(0, 15))
            helper.getCurrentUserInfo(component);
            helper.getUserContact(component);
            helper.getTPAAccess(component);
        }
    },
    openIncidentDetails: function (component, event, helper) {
        component.find("cPrompt").show();
    },
    openMenu: function (component, event, helper) {
        var page = event.target.getAttribute("data-pageName");
        var navService = component.find("navService");
        event.preventDefault();

        var pageReference = {
            type: "standard__namedPage",
            attributes: {
                pageName: page
            },
            state: {
                name: "all"
            }
        };
        sessionStorage.setItem('localTransfer', JSON.stringify(pageReference.state));
        navService.navigate(pageReference);
    },
    closeTPAPopover: function (component, event, helper) {
        $A.util.addClass(component.find('TPAPopover'), 'slds-popover_hide');
    },
    openIQVIADoc: function (component, event) {
        if (component.get("v.userId") !== undefined) {
            var navService = component.find("navService");
            event.preventDefault();
            var pageReference = {
                type: "standard__namedPage",
                attributes: {
                    pageName: "resources"
                },
                state: {
                    name: "IQVIA CUSTOMER SERVICE"
                }
            };
            sessionStorage.setItem('localTransfer', JSON.stringify(pageReference.state));
            navService.navigate(pageReference);
        } else {
            window.location.href = '/support/login?ec=302&startURL='+ $A.get("$Site.siteUrlPrefix") +'/resources?name=IQVIA CUSTOMER SERVICE';
        }
    }
})
