({
    Init : function(cmp, event, helper) {
        
        cmp.set('v.showSpinner', true);
        
        cmp.set('v.columns', [
            {label: 'Login Time', fieldName: 'LoginTime', type: 'date', typeAttributes: {  
                day: 'numeric',  
                month: 'short',  
                year: 'numeric',  
                hour: '2-digit',  
                minute: '2-digit',  
                second: '2-digit',  
                hour12: true}},
            
            {label: 'Status', fieldName: 'Status', type: 'text'},
            
        ]);
            helper.getLoginHistory(cmp);	
            
    },
            
    resetOrUnlock : function(component, event, helper) {
        component.set('v.showSpinner', true);
        helper.resetPasswordOrUnlockUser(component);
    },

    reactive: function(component, event, helper) {
        component.set('v.showSpinner', true);
        helper.activeUser(component);
    }
    
})