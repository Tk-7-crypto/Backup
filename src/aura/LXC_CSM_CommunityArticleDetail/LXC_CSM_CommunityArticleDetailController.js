({
    doInit: function (component, event, helper) {
        let currentUser = $A.get("$SObjectType.CurrentUser.Id");
        if(currentUser)
            component.set("v.userId", currentUser.substring(0, 15))
        var c = "";
        if (sessionStorage) {
            if (sessionStorage.getItem('localTransfer')) {
                var json = sessionStorage.getItem('localTransfer');
                if (JSON.parse(json).name) {
                    if (JSON.parse(json).name !== 'all') {
                        c = JSON.parse(json).name;
                    }
                }
            }
        }
        component.set("v.category", c);
        helper.getArtcilesByIdForCurrentUser(component);
        component.set("v.itemType", "KB Article");

        const pathname = window.location.pathname;
        const pathParts = pathname.split('/').filter(part => part !== '');
        const articleURL = pathParts[pathParts.length - 1];
        const partnerURL = component.get("v.partnerURL");
        const baseUrl = $A.get('$Site.siteUrlPrefix');
        if (!partnerURL) {
            window.location.href = baseUrl + '/kb?u=' + articleURL;
        }
    }
})