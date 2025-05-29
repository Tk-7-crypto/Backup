({
    getFeedback: function (component) {
        component.set('v.isLoading', true);
        var recordId = component.get('v.recordId');
        var action = component.get('c.getFeedback');
        action.setParams({
            'kid': recordId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var feedback = response.getReturnValue();
                var feedbackCSH = [];
                var feedbackInternal = [];
                var counterDislike = 0;
                var counterLike = 0;
                feedback.forEach(f => {
                    if (f.Source__c === 'Internal'){
                    feedbackInternal.push(f);
                    
                    if (f.Like_or_Dislike__c != null && f.Like_or_Dislike__c === 'Dislike'){
                    counterDislike += 1;
                }
                                 if (f.Like_or_Dislike__c != null && f.Like_or_Dislike__c === 'Like'){
                    counterLike += 1;                           
                }              
            }
            else if (f.Source__c === 'CSH' || f.Source__c === 'PRM'){
                feedbackCSH.push(f);
                
                if (f.Like_or_Dislike__c != null && f.Like_or_Dislike__c === 'Dislike'){
                    counterDislike += 1;
                }
                if (f.Like_or_Dislike__c != null && f.Like_or_Dislike__c === 'Like'){
                    counterLike += 1;                           
                } 
            }    
        });
        component.set('v.counterDislike', counterDislike);
        component.set('v.counterLike', counterLike);
        component.set('v.feedbackInternal', feedbackInternal);
        component.set('v.feedbackCSH', feedbackCSH);
        console.log('feedbackInternal '+feedbackInternal);
        var action = component.get('v.feedbackInternal');
        console.log('V.FeedbackInternal '+action);
        } else {
        console.log('err', JSON.stringify(response.getError()));
    	}
     	component.set('v.isLoading', false);
    	});
    	$A.enqueueAction(action);
    },
    
    getLikeOrDislike: function (component) {
        component.set('v.isLoading', true);
        var recordId = component.get('v.recordId');
        var action = component.get('c.getLikeDislike');
        action.setParams({
            'kid': recordId,
            'source': 'Internal'
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var likeOrDislike = response.getReturnValue().Like_or_Dislike__c;
                if (likeOrDislike === 'Like') {
                    component.set('v.liked', true);
                    component.set('v.disliked', false);
                } else if (likeOrDislike === 'Dislike') {
                    component.set('v.liked', false);
                    component.set('v.disliked', true);
                } else {
                    component.set('v.liked', false);
                    component.set('v.disliked', false);
                }
            } else {
                console.log('err', JSON.stringify(response.getError()));
            }
            component.set('v.isLoading', false);
        });
        $A.enqueueAction(action);
    },

    sendFeedback: function (component, fbValue) {
        component.set('v.isLoading', true);
        var recordId = component.get('v.recordId');
        var action = component.get('c.saveFeedback');
        action.setParams({
            'feedback': fbValue,
            'kid': recordId,
            'source': 'Internal'
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.find('feedback').set('v.value','')
                component.set('v.isModalOpen', false);
                var resultsToast = $A.get('e.force:showToast');
                resultsToast.setParams({
                    'type': 'success',
                    'title': 'Saved',
                    'message': 'Thank you for your feedback'
                });
                resultsToast.fire();
                this.getFeedback(component);
            } else {
                console.log('err', JSON.stringify(response.getError()));
            }
            component.set('v.isLoading', false);
        });
        $A.enqueueAction(action);
    },

    saveLikeOrDislike: function (component, likeOrDislike) {
        component.set('v.isLoading', true);
        var recordId = component.get('v.recordId');
        var action = component.get('c.saveLikeDislike');
        action.setParams({
            'likeOrDislike': likeOrDislike,
            'kid': recordId,
            'source': 'Internal'
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                this.getLikeOrDislike(component);
                this.getFeedback(component);
            } else {
                console.log('err', JSON.stringify(response.getError()));
            }
            component.set('v.isLoading', false);
        });
        $A.enqueueAction(action);
    }
})