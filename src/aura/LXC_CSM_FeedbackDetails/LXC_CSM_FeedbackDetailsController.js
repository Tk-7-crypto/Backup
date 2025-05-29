({
    doInit: function (component, event, helper) {
        helper.getLikeOrDislike(component);
        helper.getFeedback(component);
    },

    closeModal: function (component, event, helper) {
        component.set('v.isModalOpen', false);
    },

    openModal: function (component, event, helper) {
        component.set('v.isModalOpen', true);
    },

    handleLikeButtonClick: function (component, event, helper) {
        component.set('v.liked', !component.get('v.liked'));
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

    like: function (component, event, helper) {
        helper.saveLikeOrDislike(component, 'Like');
    },

    dislike: function (component, event, helper) {
        helper.saveLikeOrDislike(component, 'Dislike');
    },

    openRecord: function (component, event, helper) {
        const recordId = event.currentTarget.dataset.id;
        const type = event.currentTarget.dataset.type;
        var pageReference = {
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: type,
                actionName: 'view'
            }
        };
        var navService = component.find("navService");
        navService.navigate(pageReference);
    }
})