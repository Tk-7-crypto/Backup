/**
 * Author : Shubham Jain
 * Created Date : 26-03-2019
 * This is OpportunityTeamMember Domain handler class.
 */
public class DAOH_OpportunityTeamMember {
    
    /**
     * This method is used to verify Analytics Products
     * @param List<OpportunityTeamMember> oldList
     * @returns void 
     */ 
    public static void verifyPrivacyAnalyticsProducts(List<OpportunityTeamMember> oldList) {
        Map<Id, List<OpportunityTeamMember>> oppIdToOTMMap = new Map<Id, List<OpportunityTeamMember>>();
        Set<String> paProductCodeSet = new Set<String>();
        Set<Id> paGroupMembersSet = new Set<Id>();
        Set<Id> oppIdSet = new Set<Id>();
        List<GroupMember> groupMemberList = [SELECT UserOrGroupId FROM GroupMember WHERE Group.Name =: CON_CRM.GROUP_PLATFORM_ANALYTICS_SALES_GROUP];
        for (GroupMember gm : groupMemberList) {
            paGroupMembersSet.add(gm.UserOrGroupId);
        }
        for(OpportunityTeamMember otm: oldList) {
            if(oppIdToOTMMap.get(otm.OpportunityId) == null) {
                oppIdToOTMMap.put(otm.OpportunityId, new List<OpportunityTeamMember>());
            } 
            oppIdToOTMMap.get(otm.OpportunityId).add(otm);      
        }
        List<PrivacyAnalyticsProductCode__c> paProductCodeList = PrivacyAnalyticsProductCode__c.getall().values();
        for (PrivacyAnalyticsProductCode__c papc : paProductCodeList) {
            paProductCodeSet.add(papc.Product_Code__c);
        }
        for (OpportunityTeamMember otm : oldList) {
            oppIdSet.add(otm.OpportunityId);
        }
        Set<String> fieldSet = new Set<String>{'Id', 'OpportunityId'};
        List<OpportunityLineItem> oliList = new SLT_OpportunityLineItems().getOLIByOppIdAndProductCode(oppIdSet, fieldSet, paProductCodeSet);
        for (OpportunityLineItem oli: oliList) {
            for(OpportunityTeamMember otm :oppIdToOTMMap.get(oli.OpportunityId)) {
                if(paGroupMembersSet.contains(otm.UserId)) {
                    otm.addError('Cannot remove PA team member from Opportunity with PA products');
                }
            }
        }
    }
    
    /**
     * This method is used to verify Opportunity Team and Opportunity Bussiness Unit matches or not
     * @param List<OpportunityTeamMember> newList
	 * @returns void 
     */
    public static void validateOppTeam(List<OpportunityTeamMember> newList, Map<Id,OpportunityTeamMember> oldMap){
        Set<id> oppIdSet = New Set<id>();
        Set<id> oppTeamUserSet = new Set<id>();
        Map<id,Opportunity> opportunityMap = new Map<id,Opportunity>();
        Map<id,User> teamMemberUserMap = new Map<id,User>();
        
        for(OpportunityTeamMember opptm : newList){
            if(!oppIdSet.contains(opptm.OpportunityId)){
                oppIdSet.add(opptm.OpportunityId);
            }
            if(!oppTeamUserSet.contains(opptm.UserId)){
                oppTeamUserSet.add(opptm.UserId);
            }
        }
        if(!oppIdSet.isEmpty() && !oppTeamUserSet.isEmpty()){
            opportunityMap = new SLT_Opportunity().getOpportunityById(oppIdSet ,new Set<String>{'Id','Line_of_Business__c','Opportunity_Sharing_Business_Unit__c'});
            teamMemberUserMap = new SLT_User().selectByUserId(oppTeamUserSet,new Set<String>{'Id','User_Type__c'});
            Set<Id> adminprofileIdSet = UTL_CRM.getSystemAdminstratorProfiles().keySet();
            for(OpportunityTeamMember optm : newList){
                if(optm.TeamMemberRole == 'Opportunity Owner' && adminprofileIdSet.contains(UserInfo.getProfileId())){
                    //admin user can change Opportunity Owner avacare to non-avacare and vise versa
                }else{
                    if(opportunityMap.get(optm.OpportunityId).Opportunity_Sharing_Business_Unit__c == 'Avacare' && teamMemberUserMap.get(optm.UserId).User_Type__c != CON_CRM.USER_TYPE_Avacare){
                        optm.addError('Please select only Avacare User to Avacare Opportunity');
                    } else if((new Set<String>{CON_CRM.EPG,CON_CRM.EPG_Collaborative,CON_CRM.EPG_IME}).Contains(opportunityMap.get(optm.OpportunityId).Opportunity_Sharing_Business_Unit__c) && (teamMemberUserMap.get(optm.UserId).User_Type__c != CON_CRM.USER_TYPE_EPG && teamMemberUserMap.get(optm.UserId).User_Type__c != CON_CRM.USER_TYPE_EPG_IME  && teamMemberUserMap.get(optm.UserId).User_Type__c != CON_CRM.USER_TYPE_EPG_Collaborative )){
                        optm.addError('Please select only EPG Health User to EPG Health Opportunity');
                    } else if(opportunityMap.get(optm.OpportunityId).Opportunity_Sharing_Business_Unit__c != 'Avacare' && teamMemberUserMap.get(optm.UserId).User_Type__c == CON_CRM.USER_TYPE_Avacare && optm.OpportunityAccessLevel != 'Read'){
                        optm.addError('Avacare user can have maximum Read Permission of the Non-Avacare Opportunity.');
                    }
                }
            }
        }
    }
    
}