({
    helperMethod : function() {
        
    },
    
    hasPSSFRecordOnProject: function(component, event, helper) {
        var action = component.get("c.pssfParentRecId");
        action.setParams({ 
            "projectId" : component.get("v.RecId"),
            
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result !== null) { 
                     component.set('v.parRecordId', result);
                    this.fetchRelatedRecords(component, event);
                }
                else{
                    component.set('v.NoRecord', 'No records to display.');
                }
            }
            else if (state === "ERROR") {
                console.log('Error :: ',response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    getAutoPopulatedFields: function(component, event){
        var action2 = component.get("c.autoPopulatedFieldData");
        action2.setParams({ "projectID" : component.get("v.RecId") });
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.account", result.account);
                component.set("v.projectCode", result.projectCode);
            }
            else if (state === "ERROR") {
                console.log('Error :: ',response.getError());
            }
        });
        $A.enqueueAction(action2);
    },
    
    /*
    getVersionOfPFFS: function(component, event){
        var action2 = component.get("c.fetchVersionOfPSSF");
        action2.setParams({ "projectID" : component.get("v.RecId") });
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log(result);
                component.set("v.pssfVersion", result);
            }
            else if (state === "ERROR") {
                console.log('Error :: ',response.getError());
            }
        });
        $A.enqueueAction(action2);
    },
    */
    
    checkPermissionForVisibility: function(component, event, helper) {
        var action = component.get("c.isSignalManagementProject");
        action.setParams({ "projectID" : component.get("v.RecId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.isSignalManagement', result);
                if(result == false){
                    component.set('v.NoSignalManagementRecord', 'This is a Signal Management object and you do not have permissions or you are not on SM project to create the record.');                 
                }
               }
            else if (state === "ERROR") {
                console.log('Error :: ',response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    hasEditPermission: function(component, event){
        var action2 = component.get("c.hasEditPermission");
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.hasEditAccess', result);
            }
            else if (state === "ERROR") {
                console.log('Error :: ',response.getError());
            }
        });
        $A.enqueueAction(action2);
        
    },

    fetchRelatedRecords: function(component, event){
        var action2 = component.get("c.fetchRelatedRecords");
        action2.setParams({ "pssfParentRecId" : component.get("v.parRecordId") });
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result != null){
                    if(result['Company Safety Database']){
                        component.set('v.compSafeDbRecordId', result['Company Safety Database']);
                    } 
                    if(result['Clinical Trial Database']){
                        component.set('v.clinicalTrialRecordId', result['Clinical Trial Database']);
                    }
                    if(result['Literature']){
                        component.set('v.litrRecordId', result['Literature']);
                    }
                    if(result['Health Authority Websites']){
                        component.set('v.healthAuthWebRecordId', result['Health Authority Websites']);
                    }
                    if(result['Eudravigilance']){
                        component.set('v.eudravigRecordId', result['Eudravigilance']);
                    }
                    if(result['FAERS']){
                        component.set('v.faersRecordId', result['FAERS']);
                    }
                    if(result['VAERS']){
                        component.set('v.vaersRecordId', result['VAERS']);
                    }
                    if(result['Competitors RSI']){
                        component.set('v.compRSARecordId', result['Competitors RSI']);
                    }
                    if(result['Others1']){
                        component.set('v.others1RecordId', result['Others1']);
                    }
                    if(result['Others2']){
                        component.set('v.other2RecordId', result['Others2']);
                    }
                    if(result['Others3']){
                        component.set('v.other3RecordId', result['Others3']);
                    }
                    if(result['Others4']){
                        component.set('v.other4RecordId', result['Others4']);
                        //component.set("v.isTableDisplay", true);
                    }
                    if(result['History Record 0']){
                        component.set('v.History0RecordId', result['History Record 0']);
                        var row = component.get("v.historyRow");
                        row.push(row.length + 1);
                        component.set("v.historyRow",row);
                        component.set("v.History0RecordTypeEdit",true);
                    }
                    if(result['History Record 1']){
                        component.set('v.History1RecordId', result['History Record 1']);
                        var row1 = component.get("v.historyRow");
                        row1.push(row1.length + 1);
                        component.set("v.historyRow",row1);
                        component.set("v.History1RecordTypeEdit",true);
                    }
                    if(result['History Record 2']){
                        component.set('v.History2RecordId', result['History Record 2']);
                        var row2 = component.get("v.historyRow");
                        row2.push(row2.length + 1);
                        component.set("v.historyRow",row2);
                        component.set("v.History2RecordTypeEdit",true);
                    }
                    if(result['History Record 3']){
                        component.set('v.History3RecordId', result['History Record 3']);
                        var row3 = component.get("v.historyRow");
                        row3.push(row3.length + 1);
                        component.set("v.historyRow",row3);
                        component.set("v.History3RecordTypeEdit",true);
                    }
                    if(result['History Record 4']){
                        component.set('v.History4RecordId', result['History Record 4']);
                        var row4 = component.get("v.historyRow");
                        row4.push(row4.length + 1);
                        component.set("v.historyRow",row4);
                        component.set("v.History4RecordTypeEdit",true);
                    }
                    if(result['History Record 5']){
                        component.set('v.History5RecordId', result['History Record 5']);
                        var row5 = component.get("v.historyRow");
                        row5.push(row5.length + 1);
                        component.set("v.historyRow",row5);
                        component.set("v.History5RecordTypeEdit",true);
                    }
                    if(result['History Record 6']){
                        component.set('v.History6RecordId', result['History Record 6']);
                        var row6 = component.get("v.historyRow");
                        row6.push(row6.length + 1);
                        component.set("v.historyRow",row6);
                        component.set("v.History6RecordTypeEdit",true);
                    }
                    if(result['History Record 7']){
                        component.set('v.History7RecordId', result['History Record 7']);
                        var row7 = component.get("v.historyRow");
                        row7.push(row7.length + 1);
                        component.set("v.historyRow",row7);
                        component.set("v.History7RecordTypeEdit",true);
                    }
                    if(result['History Record 8']){
                        component.set('v.History8RecordId', result['History Record 8']);
                        var row8 = component.get("v.historyRow");
                        row8.push(row8.length + 1);
                        component.set("v.historyRow",row8);
                        component.set("v.History8RecordTypeEdit",true);
                    }
                    if(result['History Record 9']){
                        component.set('v.History9RecordId', result['History Record 9']);
                        var row9 = component.get("v.historyRow");
                        row9.push(row9.length + 1);
                        component.set("v.historyRow",row9);
                        component.set("v.History9RecordTypeEdit",true);
                    }
                    if(result['History Record 10']){
                        component.set('v.History10RecordId', result['History Record 10']);
                        var row10 = component.get("v.historyRow");
                        row10.push(row10.length + 1);
                        component.set("v.historyRow",row10);
                        component.set("v.History10RecordTypeEdit",true);
                    }
                    if(result['History Record 11']){
                        component.set('v.History11RecordId', result['History Record 11']);
                        var row11 = component.get("v.historyRow");
                        row11.push(row11.length + 1);
                        component.set("v.historyRow",row11);
                        component.set("v.History11RecordTypeEdit",true);
                    }
                    if(result['History Record 12']){
                        component.set('v.History12RecordId', result['History Record 12']);
                        var row12 = component.get("v.historyRow");
                        row12.push(row12.length + 1);
                        component.set("v.historyRow",row12);
                        component.set("v.History12RecordTypeEdit",true);
                    }
                    if(result['History Record 13']){
                        component.set('v.History13RecordId', result['History Record 13']);
                        var row13 = component.get("v.historyRow");
                        row13.push(row13.length + 1);
                        component.set("v.historyRow",row13);
                        component.set("v.History13RecordTypeEdit",true);
                    }
                    if(result['History Record 14']){
                        component.set('v.History14RecordId', result['History Record 14']);
                        var row14 = component.get("v.historyRow");
                        row14.push(row14.length + 1);
                        component.set("v.historyRow",row14);
                        component.set("v.History14RecordTypeEdit",true);
                    }
                    if(result['History Record 15']){
                        component.set('v.History15RecordId', result['History Record 15']);
                        var row15 = component.get("v.historyRow");
                        row15.push(row15.length + 1);
                        component.set("v.historyRow",row15);
                        component.set("v.History15RecordTypeEdit",true);
                    }
                    component.set("v.isTableDisplay", true);
                }
            }
            else if (state === "ERROR") {
                console.log('Error :: ',response.getError());
            }
        });
        $A.enqueueAction(action2);
        
    },
    
    fetchFocusFields: function(component, event){
        var action2 = component.get("c.getFocusFieldMap");
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result != null){
                    if(result['Clinical Trial Db']){
                        component.set('v.clinicalTrialDb', result['Clinical Trial Db']);
                    } 
                    if(result['HA Website']){
                        component.set('v.hAWebsite', result['HA Website']);
                    }
                    if(result['Literature']){
                        component.set('v.literature', result['Literature']);
                    }
                    if(result['Company Safe Db']){
                        component.set('v.companySafeDb', result['Company Safe Db']);
                    }
                    if(result['Eudravigilance']){
                        component.set('v.eudravigilance', result['Eudravigilance']);
                    }
                    if(result['FAERS']){
                        component.set('v.faers', result['FAERS']);
                    }
                    if(result['VAERS']){
                        component.set('v.vaers', result['VAERS']);
                    }
                    if(result['Comp RSA']){
                        component.set('v.compRSA', result['Comp RSA']);
                    }
                }
            }
            else if (state === "ERROR") {
                console.log('Error :: ',response.getError());
            }
        });
        $A.enqueueAction(action2);
        
    },
    
    getProjectId: function(component, event){
        var action2 = component.get("c.fetchProjectId");
        action2.setParams({ "pssfParentRecId" : component.get("v.parRecordId") });
        action2.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.ProjectIdVersion', result);
                console.log('project id', result);
            }
            else if (state === "ERROR") {
                console.log('Error :: ',response.getError());
            }
        });
        $A.enqueueAction(action2);
    },
    
    getAllPSSFRecordForProject: function(component, event, helper) {
        var action = component.get("c.getAllPSSFParentRecord");
        action.setParams({ "projectID" : component.get("v.RecId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                
               console.log('pssf records' , result);
               component.set('v.PSSFList', result);
               }
            else if (state === "ERROR") {
                console.log('Error :: ',response.getError());
            }
        });
        $A.enqueueAction(action);
    },
    checkPSSFRecordId : function(component,event,helper) {
        var action = component.get("c.getPSSFRecord");
        action.setParams({ "pssfRecordId" : pageRef.attributes.recordId });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.parRecordId', result);
                alert( result);
            }
            else if (state === "ERROR") {
                console.log('Error :: ',response.getError());
            }
        });
        $A.enqueueAction(action2);
    },
    checkDeletePermission: function(component, event, helper) {
        console.log('component.get("v.RecId"): '+component.get("v.RecId"));
        var action = component.get("c.hasRDSAdminPermission");
        action.setParams({
            pssfParentRecId : component.get("v.RecId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS"){
                var result = response.getReturnValue();
                console.log('delete permission: '+result);
                component.set("v.hasDeletePermission", result);
            }
        });
        $A.enqueueAction(action);
    }
})
