public class CNT_OWF_CreateAgreementOrQuote {
    @auraEnabled
    public static boolean canCurrentUserCreateQuoteOrAgreement(Id bidId, String actionName){
        Set<Id> userIds = new Set<Id>{UserInfo.getUserId()};
        List<pse__Assignment__c> assignmentList = new List<pse__Assignment__c>();
        String assignmentCondition = 'Bid_History__c IN :bidIdSet AND Subgroup_Name__c IN: subGroup and pse__Resource__r.pse__Salesforce_User__c IN: userIds and pse__Status__c = \''+ CON_OWF.OWF_STATUS_ACCEPTED+ '\'';
        Set<String> assignmentFieldSet = new Set<String>{'Id', 'pse__Resource__c', 'Subgroup_Name__c', 'pse__Resource__r.pse__Salesforce_User__c','pse__Status__c'};
        if(actionName == 'Create_Agreement'){
            assignmentList = new SLT_Assignment(false,false).getAssignmentBySubgroupAndbidIdAnduserId(new Set<Id>{bidId}, CON_OWF.SUBGROUPS_ELIGIBLE_FOR_CREATING_AGREEMENT_ON_CONTRACT_POST_AWARD_BID, assignmentFieldSet, userIds, assignmentCondition);
        } 
        if(actionName == 'Create_Budget' || actionName == 'Create_CNF_Quote'){
            assignmentList = new SLT_Assignment(false,false).getAssignmentBySubgroupAndbidIdAnduserId(new Set<Id>{bidId}, CON_OWF.SUBGROUPS_ELIGIBLE_FOR_CREATING_QUOTE_ON_CONTRACT_POST_AWARD_BID, assignmentFieldSet, userIds, assignmentCondition);  
        }
        if (assignmentList.isEmpty()){
            return false;     
        }
        else {
            return true;           
        }    
    }
}