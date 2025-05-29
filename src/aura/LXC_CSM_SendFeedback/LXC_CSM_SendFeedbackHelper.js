({
    getLikeOrDislike: function (component) {
        var recordId = component.get('v.recordId');
        var action = component.get('c.getLikeDislike');
        action.setParams({
            'kid': recordId,
            'source': 'CSH'
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var likeOrDislike = response.getReturnValue().Like_or_Dislike__c;
                component.set('v.likeOrDislike', likeOrDislike);
            } else {
                console.log('err', JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
    },

    sendFeedback: function (component, fbValue) {
        var recordId = component.get('v.recordId');
        var action = component.get('c.saveFeedback');
        action.setParams({
            'feedback': fbValue,
            'kid': recordId,
            'source': 'CSH'
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set('v.isModalOpen', false);
                var resultsToast = $A.get('e.force:showToast');
                resultsToast.setParams({
                    'type': 'success',
                    'title': 'Saved',
                    'message': $A.get('$Label.c.Thank_you_for_your_feedback')
                });
                resultsToast.fire();
            } else {
                console.log('err', JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
    },

    saveLikeOrDislike: function (component, likeOrDislike) {
        var recordId = component.get('v.recordId');
        var action = component.get('c.saveLikeDislike');
        action.setParams({
            'likeOrDislike': likeOrDislike,
            'kid': recordId,
            'source': 'CSH'
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                this.getLikeOrDislike(component);
            } else {
                console.log('err', JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
    }
})