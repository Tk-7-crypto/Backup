({
	doInit: function(component, event, helper) {
        console.log("In LXC_CDA_LandingPagesearchSection: Js Controller: doInit called");
        
        helper.fetchPicklistValues(component);
        
        /*component.find("searchRequest").getNewRecord(
            "CDA_Request__c", // sObject type (entityAPIName)
            "012Z0000000HEHQIA4",      // recordTypeId
            false,     // skip cache?
            $A.getCallback(function() {
                var rec = component.get("v.requestObject");
                var error = component.get("v.requestError");
                if(error || (rec === null)) {
                    console.log("Error initializing record template: " + error);
                }
                else {
                    console.log("Record template initialized: " + JSON.stringify(rec));
                }
            })
        );    */
    }, 
    
    keyCheck: function (component, event, helper) {
        console.log("In LXC_CDA_LandingPagesearchSection: Js Controller: keyCheck called Start event.which: " + event.which);
        if (event.which == 13) {
            event.preventDefault();
            var s = component.get('c.Search');
            $A.enqueueAction(s);
            return false; 
        }  
        console.log("In LXC_CDA_LandingPagesearchSection: Js Controller: keyCheck called End");        
    },
    
    Search : function(component, event, helper) {
        console.log("In LXC_CDA_LandingPagesearchSection: Js Controller: Search called");
        var searchFieldsMap = new Map();
        if(component.find("CDA_Id_c") != null) {
        	searchFieldsMap["CDA_ID__c"] = component.find("CDA_Id_c").get("v.value");
        }
        if(component.find("QuintilesIMS_Business__c") != null) {
        	searchFieldsMap["QuintilesIMS_Business__c"] = component.find("QuintilesIMS_Business__c").get("v.value");
        }
        if(component.find("CDA_Type__c") != null) {
        	searchFieldsMap["CDA_Type__c"] = component.find("CDA_Type__c").get("v.value");
        }
        if(component.find("Status__c") != null) {
        	searchFieldsMap["Status__c"] = component.find("Status__c").get("v.value");
        }
        
        if(component.get('v.isLookupReportTab')) {
            searchFieldsMap["Status__c"] = 'Contract Executed';
        }

        if(component.find("recipientLegalEntityName") != null) {
        	searchFieldsMap["Recipient_Account__r.Name"] = component.find("recipientLegalEntityName").get("v.value");
        }
        if(component.find("recipientPointOfContactName") != null) {
        	searchFieldsMap["Recipient_Point_of_Contact_Name__c"] = component.find("recipientPointOfContactName").get("v.value");
        }
        if(component.find("Negotiator_Assigned_List__c") != null) {
        	searchFieldsMap["Negotiator_Assigned_List__c"] = component.find("Negotiator_Assigned_List__c").get("v.value");
        }
        if(component.find("requestorName") != null) {
        	searchFieldsMap["CreatedBy.Name"] = component.find("requestorName").get("v.value");
        }
        //component.set("v.searchFieldsMap", searchFieldsMap);
        
        var searchEvt = $A.get("e.c:LXE_CDA_LandingPageSearchEvt");
        
        searchEvt.setParams({
            "searchMap" : searchFieldsMap
        });
        
        searchEvt.fire();
        console.log('In LXC_CDA_LandingPagesearchSection: Js Controller: LXE_CDA_LandingPageSearchEvt fired.');
    }, 
    
    resetSearchForm : function(component, event, helper) {
        console.log("In LXC_CDA_LandingPagesearchSection: Js Controller: resetSearchForm called");
        if(component.find("CDA_Id_c") != null) {
        	component.find("CDA_Id_c").set("v.value", '');
        }
        if(component.find("QuintilesIMS_Business__c") != null) {
        	component.find("QuintilesIMS_Business__c").set("v.value" , '--None--');
        }
        if(component.find("CDA_Type__c") != null) {
        	component.find("CDA_Type__c").set("v.value" , '--None--');
        }
        if(component.get("v.isDependentDisable") != null) {
        	component.set("v.isDependentDisable", true);
        }
        if(component.find("Status__c") != null) {
        	component.find("Status__c").set("v.value" , '--None--');
        }
        if(component.find("recipientLegalEntityName") != null) {
        	component.find("recipientLegalEntityName").set("v.value", '');
        }
        if(component.find("recipientPointOfContactName") != null) {
        	component.find("recipientPointOfContactName").set("v.value", '');
        }
        if(component.find("Negotiator_Assigned_List__c") != null) {
        	component.find("Negotiator_Assigned_List__c").set("v.value", '--None--');
        }
        if(component.find("requestorName") != null) {
        	component.find("requestorName").set("v.value", '');
        }
        
        var searchFieldsMap = new Map();
        var searchEvt = $A.get("e.c:LXE_CDA_LandingPageSearchEvt");
        
        searchEvt.setParams({
            "searchMap" : searchFieldsMap
        });
        
        searchEvt.fire();
    }, 
    
    onControllerFieldChange: function(component, event, helper) {
        var controllerValueKey = event.getSource().get("v.value");
        
        var Map = component.get("v.depnedentFieldMap");
        if(controllerValueKey == $A.get("$Label.c.CDA_Strategic_Sites")){
            component.set("v.cdaType", 'Region');
        }else{
            component.set("v.cdaType", 'CDA Type');
        }
        if(controllerValueKey != '--None--') {
            var ListOfDependentFields = Map[controllerValueKey];
            helper.fetchDepValues(component, ListOfDependentFields);            
        } 
        else {
            var defaultVal = [{
                class: "optionClass",
                label: '--None--',
                value: '--None--'
            }];
            //component.find('conState').set("v.options", defaultVal);
            component.set("v.cdaTypePicklistValues", defaultVal);
            component.set("v.isDependentDisable", true);
        }
    },
})