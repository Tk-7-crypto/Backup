({
    getRecordTypes : function(component, event) {
        component.set("v.showSpinner",true);
        var params = {
            originalRecordId : component.get("v.recordId")
        };
        var index = '';
        this.callServer(component, "c.getRecordTypes", 
            function(response) {
                if (response) {
                    for(let i = 0; i < response.length; i++) {
                        if(response[i].Name == 'Preliminary Agreement') {
                            index = i;
                            response.splice(index, 1);
                        }
                        if(response[i].Name == "Project Specific Agreement") {
                            response[i].Name = "RDS Clinical";
                        }
                        if(response[i].Name == "RWLP") {
                            response[i].Name = "Late Phase (excluding RBU)";
                        }
                    }
                    component.set("v.agrRecordTypes", response);
                    component.set("v.showSpinner",false);
                    if (response && Array.isArray(response) && response.length <= 0) {
                        this.showToast("Error",$A.get("$Label.c.CLM_CL00011_No_RecordType_To_Select"),"Error","dismissible");
                    }
                }
            }
        , params);    
    },
    
    getDefaultFields : function(component, event) {
		component.set("v.showSpinner",true);
        this.callServer(component, "c.getDefaultFieldValues", 
            function(response){
                if (response) {
                    component.set("v.defaultValues", response);
                    component.set("v.showSpinner",false);
                }
            },{
                "originalRecordId" : component.get("v.recordId"),
                "recordTypeId": component.get("v.selectedRecordType")
            }
        );
    },

    processSelection : function(component, event) {
        component.set("v.showSpinner",true);
        if(component.get("v.selectedRecordTypeDevName") == undefined) {
            this.showToast("Error",$A.get("$Label.c.CLM_CL00011_Select_RecordType_Pathway"),"Error","dismissible");
            component.set("v.showSpinner",false);
            return;
        }
        if(component.get("v.selectedRecordTypeDevName") == 'RWSSOW'){
            component.set("v.isOpen", true);
            component.set("v.showSpinner",false);
            var recId = component.get("v.recordId");
            var inputVariables = [
                {
                    name : "recordId",
                    type : "String",
                    value : recId
                }
            ];
        	var flow = component.find("flowData");
        	flow.startFlow("CLM_RWSSOW_Agreement", inputVariables);
        } else if(component.get("v.selectedRecordTypeDevName") == 'EMEA'){
            component.set("v.isOpen", true);
            component.set("v.showSpinner",false);
            var recId = component.get("v.recordId");
            var inputVariables = [
                {
                    name : "recordId",
                    type : "String",
                    value : recId
                }
            ];
        	var flow = component.find("flowData");
        	flow.startFlow("CLM_EMEA_Agreement_Flow", inputVariables);
            
        } else if(component.get("v.selectedRecordTypeDevName") == 'Commercial'){
            component.set("v.isOpen", true);
            component.set("v.showSpinner",false);
            var recId = component.get("v.recordId");
            var inputVariables = [
                {
                    name : "recordId",
                    type : "String",
                    value : recId
                }
            ];
        	var flow = component.find("flowData");
        	flow.startFlow("CLM_Commercial_Agreement_Flow", inputVariables);
        } 
        else if(component.get("v.selectedRecordTypeDevName") == 'PSA'
            || component.get("v.selectedRecordTypeDevName") == 'OSA'
            || component.get("v.selectedRecordTypeDevName") == 'RWLP'
            || component.get("v.selectedRecordTypeDevName") == 'RWLP_RBU') {
            component.set("v.isOpen", true);
            component.set("v.showSpinner", false);
            var recId = component.get("v.recordId");
            var selectedPathWay = null;
            if(component.get("v.selectedRecordTypeDevName") == 'PSA'){
                selectedPathWay = "Clinical";
            }   
            else if(component.get("v.selectedRecordTypeDevName") == 'OSA') {
                selectedPathWay = "Other Special Agreement";
            } else if(component.get("v.selectedRecordTypeDevName") == 'RWLP') {
                selectedPathWay = "Late Phase";
            }
            else {
                selectedPathWay = "RBU";
            }
            var inputVariables = [
                {
                    name : "recordId",
                    type : "String",
                    value : recId
                },
                {
                    name : "varT_Pathway",
                    type : "String",
                    value : selectedPathWay
                }
            ];
            var flow = component.find("flowData");
            flow.startFlow("CLM_RWLP_Agreement_Flow", inputVariables);
        }
        else if(component.get("v.selectedRecordTypeDevName") == 'AMESA') {
            component.set("v.showSpinner", false);
            this.callServer(component, "c.validateQuoteDetails", 
                function(response) {
                    if (response == true) {
                        component.set("v.isQuoteExist",true);
                    } else if(response == false){
                        this.createRecord(component,event);
                    }
                }, {"opportunityId" : component.get("v.recordId")}
            );
        }
        else if(component.get("v.selectedRecordTypeDevName") == 'Vendor_Agreement') {
            component.set("v.isOpen", true);
            component.set("v.showSpinner", false);
            var recId = component.get("v.recordId");
            var inputVariables = [
                {
                    name : "recordId",
                    type : "String",
                    value : recId
                }
            ];
            var flow = component.find("flowData");
            flow.startFlow("CLM_Create_Vendor_ScreenFlow", inputVariables);
        }
        else if(component.get("v.selectedRecordTypeDevName") == 'AMA') {
            component.set("v.isOpen", true);
            component.set("v.showSpinner", false);
            var recId = component.get("v.recordId");
            var inputVariables = [
                {
                    name : "recordId",
                    type : "String",
                    value : recId
                }
            ];
            var flow = component.find("flowData");
            flow.startFlow("CLM_AMA_Agreement", inputVariables);
        }
        else if(component.get("v.selectedRecordTypeDevName") == 'MSA') {
            component.set("v.isOpen", true);
            component.set("v.showSpinner", false);
            var recId = component.get("v.recordId");
            var inputVariables = [
                {
                    name : "recordId",
                    type : "String",
                    value : recId
                }
            ];
            var flow = component.find("flowData");
            flow.startFlow("CLM_Create_MSA_Screen_Flow", inputVariables);
        }
        else if(component.get("v.selectedRecordTypeDevName") == 'USBU' || component.get("v.selectedRecordTypeDevName") == 'USBU_Other_Agreement') {
            var recId = component.get("v.recordId");
            this.callServer(component, "c.getOpportunityDetails", 
                function(response) {
                    if(response) {
                        component.set("v.showSpinner", false);
                        if(response.StageName == '1. Identifying Opportunity' || response.StageName == '2. Qualifying Opportunity'
                            || response.StageName == '3. Developing Proposal') {
                            component.set("v.hasError", true);
                        } 
                        else {
                            component.set("v.isOpen", true);
                            var inputVariables = [
                                {
                                    name : "recordId",
                                    type : "String",
                                    value : recId
                                }
                            ];       
                            var flow = component.find("flowData");
                            let flowName = component.get("v.selectedRecordTypeDevName") == 'USBU' ? "CLM_USBU_Agreement_Creation_Screen_Flow" : "CLM_USBU_Other_Agreement_Create_Amend_ScreenFlow";            
                            flow.startFlow(flowName, inputVariables);
                        }
                    }   
                }, {"opportunityId" : recId}
            );
        }
        else if(component.get("v.selectedRecordTypeDevName") == 'IQVIA_MSA') {
            component.set("v.isOpen", true);
            component.set("v.showSpinner", false);
            var recId = component.get("v.recordId");
            var inputVariables = [
                {
                    name : "recordId",
                    type : "String",
                    value : recId
                }
            ];
            var flow = component.find("flowData");
            flow.startFlow("CLM_Create_Amend_IQVIA_MSA_Screen_Flow", inputVariables);
        }
        else if(component.get("v.selectedRecordTypeDevName") == 'Avacare') {
            component.set("v.showSpinner",false);
            this.createAvacareRecord(component,event);
        }
        else if(component.get("v.selectedRecordTypeDevName") == 'IQVIA_Vendor_Agreement') {
            component.set("v.showSpinner",false);
            this.createIQVIARecord(component,event);
        }
        else {
            component.set("v.showSpinner",false);
            this.createRecord(component,event);
        }
    },

    createRecord : function (component, event) {
        component.set("v.showSpinner",true);
        var recId = component.get("v.selectedRecordType");
        var oppID =  component.get("v.recordId");
        var defaultVal = component.get("v.defaultValues") ;
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "Apttus__APTS_Agreement__c",
            "recordTypeId": recId,
            "defaultFieldValues": JSON.parse(defaultVal),
            "panelOnDestroyCallback": function(event) {
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": oppID,
                });
                navEvt.fire();
            }
        });
        createRecordEvent.fire();
    },
    
    createAvacareRecord : function (component, event) {
        component.set("v.showSpinner",true);
        var recId = component.get("v.selectedRecordType");
        var siteID =  component.get("v.recordId");
        var defaultVal = component.get("v.defaultValues") ;
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "IQVIA_Agreement__c",
            "recordTypeId": recId,
            "defaultFieldValues": JSON.parse(defaultVal),
            "panelOnDestroyCallback": function(event) {
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": siteID,
                });
                navEvt.fire();
            }
        });
        createRecordEvent.fire();
    },
    
    createIQVIARecord : function (component, event) {
        component.set("v.showSpinner",true);
        var recId = component.get("v.selectedRecordType");
        var oppID =  component.get("v.recordId");
        var defaultVal = component.get("v.defaultValues") ;
        var createRecordEvent = $A.get("e.force:createRecord");
        createRecordEvent.setParams({
            "entityApiName": "IQVIA_Agreement__c",
            "recordTypeId": recId,
            "defaultFieldValues": JSON.parse(defaultVal),
            "panelOnDestroyCallback": function(event) {
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": oppID,
                });
                navEvt.fire();
            }
        });
        createRecordEvent.fire();
    }
})