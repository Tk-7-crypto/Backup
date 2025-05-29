({
    getData : function(cmp) {
        var action = cmp.get("c.getActiveRelationsForCSH");
        var recordId = cmp.get("v.recordId");
        action.setParams({userId : recordId, contactType : 'Employee'});
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                var rows = response.getReturnValue();
                if (rows.length == 0) {
                    cmp.set('v.noDataReturned', true);
                }
                //Flattening response for dot notation fields
                for(var i = 0; i < rows.length; i++) {
                    var row = rows[i];
                    if (row.Contact) {
                        row.ContactName = row.Contact.Name;
                    }
                    
                    // Create links for related records
                    row.linkName = '/'+row.ContactId;
                    
                }
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
    getUserDetail : function(cmp) {
        var action = cmp.get("c.getUserDetail");
        var recordId = cmp.get("v.recordId");
        action.setParams({userId : recordId});
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                var rows = response.getReturnValue();
                //Flattening response for dot notation fields
                for(var i = 0; i < rows.length; i++) {
                    var row = rows[i];
                    
                    cmp.set("v.photoURL", row);
                    
                }
                
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
    
    upload: function(component, file, base64Data) {
        component.set("v.fileName", file.name);
        var action = component.get("c.saveAttachment"); 
        console.log(file.name+file.type+base64Data); 
        action.setParams({
            fileName: file.name,
            base64Data: base64Data, 
            contentType: file.type
        });
        action.setCallback(this, function(a) {
            component.set("v.fileName", file.name);
        });
        //$A.get('e.force:refreshView').fire();
        //component.set("v.message", "Uploading...");
        $A.enqueueAction(action); 
    },
    
    setPhoto : function(cmp) {
        var action = cmp.get("c.setPhotoURL");
        var recordId = cmp.get("v.recordId");
        var fName = cmp.get("v.fileName");
        action.setParams({userId : recordId, fileName :fName });
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                var rows = response.getReturnValue();
                //Flattening response for dot notation fields
                for(var i = 0; i < rows.length; i++) {
                    var row = rows[i];
                }
                
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
        //$A.get('e.force:refreshView').fire();
        $A.enqueueAction(action);
        
    },
    
    deleteAttachment :function(cmp) {
        var action = cmp.get("c.deletePhoto");
        var recordId = cmp.get("v.recordId");
        var fName = cmp.get("v.fileName");
        action.setParams({userId : recordId, fileName :fName });
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                var rows = response.getReturnValue();
                //Flattening response for dot notation fields
                for(var i = 0; i < rows.length; i++) {
                    var row = rows[i];  
                }
                
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
        //window.location.reload();
    },
    getContactData : function(cmp) {
        var action = cmp.get("c.getContactDetails");
        var recordId = cmp.get("v.recordId");
        action.setParams({userId : recordId});
        action.setCallback(this, $A.getCallback(function (response) {
            var state = response.getState();
            if (state === "SUCCESS") { 
                var rows = response.getReturnValue();
                //Flattening response for dot notation fields
                for(var i = 0; i < rows.length; i++) {
                    var row = rows[i];
                    cmp.set("v.simpleRecord", row);
                }
                
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
    
    
    showToast : function(cmp, type, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": type,
            "title": title,
            "message": message,
            "mode": "pester"
        });
        toastEvent.fire();
    }
})