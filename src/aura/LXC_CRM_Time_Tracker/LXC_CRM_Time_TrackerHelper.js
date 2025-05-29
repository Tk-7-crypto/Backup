({
    timerId : null,
    startTimeStamp : 0,
    startTimer : function(component){
        var action = component.get('c.getCurrentTimestamp');
        action.setCallback(this, function(a){
            var state = a.getState();
            if(state == 'SUCCESS') {
                this.startTimeStamp = a.getReturnValue();
                //console.log('Tacking started at : '+this.startTimeStamp);
            }
        });
        $A.enqueueAction(action);
    },
    logEditTime : function(component) {
        //console.log('logEditTime : '+ component.get('v.sObjectName') +' : '+component.get('v.recordId')+' : '+this.startTimeStamp);
        if(this.startTimeStamp == 0)
            return;
        var action = component.get('c.logEditTime');
        action.setParams({
            'sObjectName' : component.get('v.sObjectName'),
            'recordId' : component.get('v.recordId'),
            'startTimeStamp' : this.startTimeStamp
        });
        $A.enqueueAction(action);
	}
})