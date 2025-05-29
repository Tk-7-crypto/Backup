({
    doInit: function (component, event, helper) {
        var sURL = window.location.href;
        var id = sURL.split('id=')[1];
        component.set("v.dashbordId", id);
    }
})