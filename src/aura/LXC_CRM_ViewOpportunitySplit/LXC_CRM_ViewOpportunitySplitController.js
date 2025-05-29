({
    doInit : function(component, event, helper) {   
        helper.getOpportunitySplitRecordList(component, event, helper); 
    },
    
    viewOpportunitySplit : function(component, event, helper) {
        helper.openOppSplitComp(component, event, helper, "c:LXC_CRM_ViewOpportunitySplit");
    },
    
    editOpportunitySplit : function(component, event, helper) {
        helper.openOppSplitComp(component, event, helper, "c:LXC_CRM_EditOpportunitySplits");
    },
})