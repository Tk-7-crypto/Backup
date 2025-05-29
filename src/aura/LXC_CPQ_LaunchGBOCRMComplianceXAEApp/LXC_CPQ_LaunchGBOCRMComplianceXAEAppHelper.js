({
    LaunchBidHistory : function(component, event, helper) {
        var actionFetchUserSessonId = component.get('c.fetchUserSessionId'); 
        var actionGetNewAppId = component.get('c.getNewAppId');
        var actionGetBaseURL = component.get('c.getBaseURL');
        var sessionId;
        var urlVal;
        var hostUrl;
        actionFetchUserSessonId.setCallback(this, function(a){
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
        
        actionGetNewAppId.setParams({  appName : 'CRM Compliance - Bid History'  });
        actionGetNewAppId.setCallback(this, function(a){
            var state = a.getState();
            if(state == 'SUCCESS') {
                    var appId = a.getReturnValue();
                    var recordId = $A.get("$SObjectType.CurrentUser.Id");
                    
                    urlVal = ('xauthorforexcel:export '+ appId + ' ' + recordId + ' ' + sessionId + ' ' + hostUrl);                    
                    document.location = urlVal;
            }
        });
         
        $A.enqueueAction(actionFetchUserSessonId);
        $A.enqueueAction(actionGetBaseURL);
        $A.enqueueAction(actionGetNewAppId);    
        
    },
    LaunchContracts : function(component, event, helper) {
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
        
        actionGetNewAppId.setParams({  appName : 'CRM Compliance - Contracts'  });
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
        
    },
    LaunchMSA : function(component, event, helper) {
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
        
        actionGetNewAppId.setParams({  appName : 'Master Service Agreements Updates'  });
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