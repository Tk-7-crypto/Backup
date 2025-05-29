({
    init: function (component, event, helper) {
        component.set("v.cssStyle", "<style>.cuf-scroller-outside {background: rgb(255, 255, 255) !important;}</style>");
        helper.getCSATInternalIfAuthorized(component);
        helper.getCase(component);
    },

    handleRateClick: function (component, event, helper) {
        var id = event.currentTarget.dataset.id;
        var rate = event.currentTarget.dataset.rate;
        helper.saveRate(component, id, rate);
    },
})