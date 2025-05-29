({
	getLikeOrDislike: function (component) {
        var recordId = component.get('v.recordId');
        var action = component.get('c.getLikeDislike');
        action.setParams({
            'kid': recordId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                console.log('get like dislike');
                var likeOrDislike = response.getReturnValue().Like_or_Dislike__c;
                component.set('v.likeOrDislike', likeOrDislike);
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
            'kid': recordId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                console.log('like dislike call');
                this.getLikeOrDislike(component);
            } else {
                console.log('err', JSON.stringify(response.getError()));
            }
        });
        $A.enqueueAction(action);
    }
})