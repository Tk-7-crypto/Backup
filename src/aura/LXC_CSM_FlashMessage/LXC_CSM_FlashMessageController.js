({
    doInit: function(component, event, helper) {
    },
    
    recordUpdate: function(component, event, helper) { 
        //helper.GetReasonForLateMessage(component);
        if(component.get("v.simpleRecord").RecordTypeId != undefined){
            component.set("v.recordTypeId", component.get("v.simpleRecord").RecordTypeId)              
        }
        if(event.getParams() != undefined && component.get("v.simpleRecord").RecordTypeId != undefined && component.get("v.simpleRecord").RecordType.Name == 'DATA CREATE Service' && event.getParams().changeType == 'CHANGED'){
            helper.checkTimeSheetMessage(component);   
        }
        if((component.get("v.simpleRecord").ServiceNow_Status__c != undefined && component.get("v.simpleRecord").ServiceNow_Status__c != null && component.get("v.simpleRecord").ServiceNow_Status__c == 'Cancelled')
           ||(component.get("v.simpleRecord").ParentId != undefined && component.get("v.simpleRecord").ParentId != null && component.get("v.simpleRecord").ParentId != '')){
           helper.getSNStatus(component);
        }
        if(component.get("v.simpleRecord").CaseNumber != undefined && component.get("v.simpleRecord").CaseNumber != ''){
            component.set("v.caseNumber", component.get("v.simpleRecord").CaseNumber) 
            //console.log(component.get("v.caseNumber") );
            helper.GetMessageFromLOS(component);
        }
        
        if(component.get("v.simpleRecord").ContactId != undefined){
            component.set("v.contactRecordId", component.get("v.simpleRecord").ContactId)
            component.find("contactRecord").reloadRecord();
        }else{
            console.log("No ContactId on this record");
        }
    },
    
    showToast: function(component, event, helper)  { 
        helper.GetMessageFromObject(component);
    }
})
