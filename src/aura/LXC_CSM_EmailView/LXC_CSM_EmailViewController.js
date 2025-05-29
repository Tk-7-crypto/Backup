({
    Init : function(component, event, helper) {
        var objectType = component.get("v.sObjectName");
        var recordData = component.get("v.recordId");
        var st = window.location.href;
        if(st.includes('Case') || st.includes('Report') || st.includes('Dashboard')){
            helper.getEmailInfo(component,recordData);	
            helper.getEmailMessageRelation(component,recordData);	
            helper.getAttachmentsInfo(component,recordData);
        }
        
        else {
            var base_url = window.location.origin;
            var urlEvent = $A.get("e.force:navigateToURL");
            var URLC = base_url+'/lightning/r/EmailMessage/'+recordData+'/view?nooverride=1';
            urlEvent.setParams({
                "url": URLC
            });
            urlEvent.fire(); 
        }
        
    },
    
    NavigationRec : function(component, event, helper) {
        var address = component.find("address").get("v.value");
        //alert("NAVAAA");
        /* var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      "url": 'https://iqvia--csmxag.lightning.force.com/lightning/r/EmailMessage/02s3J0000003scQQAQ/view?nooverride=1ws=%2Flightning%2Fr%2FOpportunity%2F0063J000002TqgYQAS%2Fview?nooverride=1'
    });
    urlEvent.fire();
    */
        component.find("navId").navigate({
            
            type: 'standard__recordPage',
            attributes: {
                recordId : '02s3J0000002xQhQAI', // Hardcoded record id from given objectApiName
                actionName: 'view',  //Valid values include clone, edit, and view.
                objectApiName: 'EmailMessage' //The API name of the record’s object
            }}, true);
        //alert("nevI");
        
    },
    navigateToSenderRelatedList: function(component,event,helper){
        var recordId1 = component.get("v.recordId");
        var rlEvent = $A.get("e.force:navigateToRelatedList");
        rlEvent.setParams({
            "relatedListId": "EmailMessageRelations",
            "parentRecordId": recordId1
        });
        rlEvent.fire();
    },
    navigateToApprovalHistoryRelatedList: function(component,event,helper){
        var recordId1 = component.get("v.recordId");
        var rlEvent = $A.get("e.force:navigateToRelatedList");
        rlEvent.setParams({
            "relatedListId": "ProcessSteps",
            "parentRecordId": recordId1
        });
        rlEvent.fire();
    },
    
    navigateToAttachmentsRelatedList: function(component,event,helper){
        var recordId1 = component.get("v.recordId");
        var rlEvent = $A.get("e.force:navigateToRelatedList");
        rlEvent.setParams({
            "relatedListId": "CombinedAttachments",
            "parentRecordId": recordId1
        });
        rlEvent.fire();
    },
    
    navigateToMyForwardComponent : function(component, event, helper) {
        var recordId1 = component.get("v.recordId");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:LXC_CSM_ForwardEmailMessage",
            componentAttributes: {
                recordId : recordId1 
                
            }
        });
        evt.fire();
    },
    
    navigateToReplyAllComponent : function(component, event, helper) {
        var recordId1 = component.get("v.recordId");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:LXC_CSM_ReplyAllEmailMessage",
            componentAttributes: {
                recordId : recordId1 
                
            }
        });
        evt.fire();
    },
    
    navigateToReplyToComponent : function(component, event, helper) {
        var recordId1 = component.get("v.recordId");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:LXC_CSM_ReplyToEmailMessage",
            componentAttributes: {
                recordId : recordId1 
                
            }
        });
        evt.fire();
    },
    navigateToRecord : function(component, event, helper) {
        var recordId = event.currentTarget.dataset.recordid;
        var objectName = event.target.dataset.objectname;
        helper.navigateToRecord(component, objectName, recordId, 'view');       
    },
    toggleSection: function (component, event, helper) {
        var sectionAuraId = event.target.getAttribute("data-auraId");
        var sectionDiv = component.find(sectionAuraId);
        var toggle = component.get("v.toggle");
        if (toggle){
            $A.util.removeClass(sectionDiv, 'slds-section slds-is-open');
            $A.util.addClass(sectionDiv, 'slds-section slds-is-close');
            component.set("v.toggle", false);
        }
        else{
            $A.util.removeClass(sectionDiv, 'slds-section slds-is-close');
            $A.util.addClass(sectionDiv, 'slds-section slds-is-open');
            component.set("v.toggle", true);
        }
    },

    togglePIIDataIdentified: function(component, event, helper) {
        helper.updatePIIDataIdentified(component);
    },

    showLoadingSpinner: function(component, event, helper) {
        component.set("v.isLoading", true);
    },

    hideLoadingSpinner: function(component, event, helper) {
        component.set("v.isLoading", false);
    }
})