({
    doInit: function (component, event, helper) {
        var c = "";
        if (sessionStorage) {
            if (sessionStorage.getItem('localTransfer')) {
                var json = sessionStorage.getItem('localTransfer');
                if (JSON.parse(json).name) {
                    if (JSON.parse(json).name !== 'all') {
                        c = JSON.parse(json).name;
                    }
                }
            } else {
                if (component.get("v.category") !== undefined && component.get("v.category") !== 'all') {
                    c = decodeURI(component.get("v.category"));
                }
            }
        }

        var view_article = component.get("v.view_article");
        var partnerURL = component.get("v.partnerURL");
        var baseUrl = $A.get('$Site.siteUrlPrefix');

        if (view_article && !partnerURL) {
            var destination = (c !== 'all') ? '/kb?p=' + c : '/products';
            window.location.href = baseUrl + destination;
        }

        component.set("v.category", c);
        component.set("v.isLoading", false);
    }
})