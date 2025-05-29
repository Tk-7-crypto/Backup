({
	getLoginHistory : function(cmp) {
        var action = cmp.get("c.getLoginHistory");
        var recordId = cmp.get("v.recordId");
        action.setParams({ 
            "recordIDD": recordId
        });
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                var result = response.getReturnValue();
                var rows = result.loginHistory;
                var isCommunityUser = result.isCommunityUser;
                var isActive = result.isActive;
                var passwordActionButtonLabel = 'NONE';
                if (rows.length == 0) {
                    cmp.set('v.noDataReturned', true);
                    passwordActionButtonLabel = 'Send Welcome Email';
                }
                //Flattening response for dot notation fields
                for(var i = 0; i < rows.length; i++) {
                    var row = rows[i];
                   
                    
                    // Create links for related records
                   
                }
                if(rows.length > 0) {
                    var lastLogin = rows[0];
                    if(lastLogin.LoginTime == null || lastLogin.Status == 'Invalid Password') {
                        passwordActionButtonLabel = 'Send Welcome Email';
                    } else if(lastLogin.Status == 'Password Lockout') {
                        passwordActionButtonLabel = 'Unlock CSH User';
                    }
                }
                cmp.set('v.passwordActionButtonLabel', passwordActionButtonLabel);
                cmp.set('v.isCommunityUser', isCommunityUser);
                cmp.set('v.isActive', isActive);
                cmp.set('v.data', rows);
                cmp.set('v.showSpinner', false);
            }
            else if (state === "ERROR") {
                cmp.set('v.showSpinner', false);
                var errors = response.getError();
                if (errors && errors.length > 0) {
                    console.error(errors[0].message);
                }
            }
        }));
        $A.enqueueAction(action); 
    },
    
    resetPasswordOrUnlockUser : function(component) {
        var contactId = component.get('v.recordId');
        var passwordActionButtonLabel = component.get('v.passwordActionButtonLabel');
        var reset = passwordActionButtonLabel == "Send Welcome Email" ? true : false;
        var unlock = passwordActionButtonLabel == "Unlock CSH User" ? true : false ;
        var action = component.get("c.resetPasswordOrUnlockUser");
        action.setParams({ 
            "contactId": contactId,
            "reset": reset,
            "unlock": unlock
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.showSpinner', false);
                var message = '';
                if(unlock && !reset) {
                    message = "User has been unlocked and Password has been reset successfully!!";
                } else if(!unlock && reset) {
                    message = "Password has been reset successfully!!";
                }
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": message
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            }
            else if (state === "ERROR") {
                component.set('v.showSpinner', false);
                var errors = response.getError();
                if (errors && errors.length > 0) {
                    console.error("LXC_CSM_LoginDetails Error = ", errors[0].message);
                }
            }
        });
        $A.enqueueAction(action);
    },

    activeUser : function(component) {
        var contactId = component.get('v.recordId');
        var action = component.get("c.activeUser");
        action.setParams({ 
            "contactId": contactId,
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var message = 'User has been reactivated successfully!!';
                component.set('v.isActive', true);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": message
                });
                toastEvent.fire();
                component.set('v.showSpinner', false);
                const myTimeout = window.setTimeout(function(){ 
                    $A.get('e.force:refreshView').fire();
                }, 3000);                
            }
            else if (state === "ERROR") {
                component.set('v.showSpinner', false);
                var errors = response.getError();
                if (errors && errors.length > 0) {
                    console.error("LXC_CSM_LoginDetails Error = ", errors[0].message);
                }
            }
        });
        $A.enqueueAction(action);
    },
	
})
