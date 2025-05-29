({

    doInit: function (component, event, helper) {
        helper.recordIsFollowed(component);
    },
    follow: function (component, event, helper) {
        helper.followRecord(component);
    }
})