({
    LaunchFinance : function(component, event, helper) {
        var actionFetchUserSessionId = component.get('c.fetchUserSessionId'); 
        var actionGetNewAppId = component.get('c.getNewAppId');
        var actionGetBaseURL = component.get('c.getBaseURL');
        var sessionId;
        var urlVal;
        var hostUrl;
        actionFetchUserSessionId.setCallback(this, function(a){
            var state = a.getState();
            if(state == 'SUCCESS') {
                sessionId = a.getReturnValue();
            } 
        });
        
        actionGetBaseURL.setCallback(this, function(a) {
            var state = a.getState();
            if(state == 'SUCCESS') {
                hostUrl = a.getReturnValue();   
            }
        });
        
        actionGetNewAppId.setParams({  appName : 'Finance Unbilled_Unsigned'  });
        actionGetNewAppId.setCallback(this, function(a){
            var state = a.getState();
            if(state == 'SUCCESS') {
                var appId = a.getReturnValue();
                var recordId = $A.get("$SObjectType.CurrentUser.Id");
                
                urlVal = ('xauthorforexcel:export '+ appId + ' ' + recordId + ' ' + sessionId + ' ' + hostUrl);
               
                document.location = urlVal;
            }
        });
         
        $A.enqueueAction(actionFetchUserSessionId);
        $A.enqueueAction(actionGetBaseURL);
        $A.enqueueAction(actionGetNewAppId);
    }
})