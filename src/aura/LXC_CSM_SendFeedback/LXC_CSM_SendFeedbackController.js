({
    doInit: function (component, event, helper) {
        helper.getLikeOrDislike(component);
    },

    closeModal: function (component, event, helper) {
        component.set('v.isModalOpen', false);
    },

    openModal: function (component, event, helper) {
        component.set('v.isModalOpen', true);
    },

    sendFeedback: function (component, event, helper) {
        component.set('v.showError', false);
        var fbValue = component.find('feedback').get('v.value');
        if (fbValue != undefined && fbValue != '') {
            helper.sendFeedback(component, fbValue);
        } else {
            component.set('v.showError', true);
        }
    },

    saveLikeOrDislike: function (component, event, helper) {
        var selectedItem = event.currentTarget;
        var likeOrDislike = selectedItem.dataset.value;
        helper.saveLikeOrDislike(component, likeOrDislike);
    },

    waiting: function (component, event, helper) {
        component.set("v.isLoading", true);
    },

    doneWaiting: function (component, event, helper) {
        component.set("v.isLoading", false);
    }
})