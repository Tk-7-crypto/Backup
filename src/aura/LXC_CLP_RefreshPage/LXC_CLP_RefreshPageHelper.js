({
    bannerShow: function(component, event, helper){
        let recId = component.get("v.recordId");
        let action = component.get("c.getAgreementDetail");
        let isRecordCreateNow; 
        action.setParams({
            recordId : recId
        });
        action.setCallback(this, function(response) {
            let state = response.getState();
            let returnValue;
            const recordTypeName = 'Clinical_Bid';
            
            if (state === "SUCCESS") {
               returnValue = response.getReturnValue();
            }
            if(returnValue != null && returnValue.Record_Type_Developer_Name__c === recordTypeName && returnValue.Unity_Living_Proposal__c == undefined){
                let action2 = component.get("c.isRecordCreatedNow");
                action2.setParams({
                    recordCreatedDate : returnValue.CreatedDate
                });
                action2.setCallback(this, function(response1) {
                    if(response1.getState() === "SUCCESS"){
                        isRecordCreateNow = response1.getReturnValue();
                    }else{
                        isRecordCreateNow = false;
                    }
                    if(isRecordCreateNow){
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'Unity link ',
                            message: 'The Unity link is being generated automatically. Please allow about 30 seconds for it to appear below.',
                            duration: '30000',
                            key: 'info_alt',
                            type: 'info',
                            mode: 'dismissible'
                        });
                        toastEvent.fire();
                    }
                })
                $A.enqueueAction(action2);
            }
        })
        $A.enqueueAction(action);
    },
    
    subscribe: function(component, event, helper) {
        // Get the empApi component.
        console.log('testing event');
        const empApi = component.find("empApi");
        // Get the channel from the attribute.
        const channel = component.get("v.channel");
        // Subscription option to get only new events.
        const replayId = -1;
        // Callback function to be passed in the subscribe call. After an event is received, this callback prints the event
        const callback = function(message) {
          let messageReceived = JSON.parse(JSON.stringify(message));
          var StatusReturned = '';
          var recId = component.get("v.recordId");
            if (messageReceived.data.payload.Record_Id__c == recId) {
            //helper.init(component, event, helper);
                $A.get('e.force:refreshView').fire();
            }
          
        };
        // Subscribe to the channel and save the returned subscription object.
        empApi.subscribe(channel, replayId, $A.getCallback(callback)).then(
          $A.getCallback(function(newSubscription) {
            component.set("v.platformEvtHandlerEnabled", true);
          })
        );
      }
})