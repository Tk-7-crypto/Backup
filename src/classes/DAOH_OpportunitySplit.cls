/**
* Author : Ronak Mehta
* Created Date : 02-09-2024
* This is OpportunitySplit Domain handler class.
*/
public class DAOH_OpportunitySplit {
    
    /**
     * This method is used to verify Opportunity Split Owner and Opportunity Bussiness Unit matches or not
     * @param List<OpportunityTeamMember> newList
	 * @returns void 
     */
    public static void validateOppSplit(List<OpportunitySplit> newList){
        Set<id> oppIdSet = New Set<id>();
        Set<id> splitOwnerUserSet = new Set<id>();
        Map<id,Opportunity> opportunityMap = new Map<id,Opportunity>();
        Map<id,User> splitOwnerUserMap = new Map<id,User>();
        
        for(OpportunitySplit opSplt : newList){
            if(!oppIdSet.contains(opSplt.OpportunityId)){
                oppIdSet.add(opSplt.OpportunityId);
            }
            if(!splitOwnerUserSet.contains(opSplt.SplitOwnerId)){
                splitOwnerUserSet.add(opSplt.SplitOwnerId);
            }
        }
        
        if(!oppIdSet.isEmpty() && !splitOwnerUserSet.isEmpty()){
            opportunityMap = new SLT_Opportunity().getOpportunityById(oppIdSet ,new Set<String>{'id','Line_of_Business__c','Opportunity_Sharing_Business_Unit__c'});
            splitOwnerUserMap = new SLT_User().selectByUserId(splitOwnerUserSet,new Set<String>{'id', 'User_Type__c', 'ProfileId'});
            Set<Id> adminprofileIdSet = UTL_CRM.getSystemAdminstratorProfiles().keySet();
            
            for(OpportunitySplit oppsp : newList){
                if(adminprofileIdSet.Contains(splitOwnerUserMap.get(oppsp.SplitOwnerId).ProfileId) && adminprofileIdSet.contains(UserInfo.getProfileId())){
                    //admin user can clone avacare and non-avacare Opportunity.
                }else if(opportunityMap.get(oppsp.OpportunityId).Line_of_Business__c == CON_CRM.LOB_Avacare && splitOwnerUserMap.get(oppsp.SplitOwnerId).User_Type__c != CON_CRM.USER_TYPE_Avacare){
                    oppsp.addError('Please select only Avacare User to Avacare Opportunity.');
                }else if((new Set<String>{CON_CRM.EPG,CON_CRM.EPG_Collaborative,CON_CRM.EPG_IME}).Contains(opportunityMap.get(oppsp.OpportunityId).Opportunity_Sharing_Business_Unit__c) && (splitOwnerUserMap.get(oppsp.SplitOwnerId).User_Type__c != CON_CRM.USER_TYPE_EPG && splitOwnerUserMap.get(oppsp.SplitOwnerId).User_Type__c != CON_CRM.USER_TYPE_EPG_IME  && splitOwnerUserMap.get(oppsp.SplitOwnerId).User_Type__c != CON_CRM.USER_TYPE_EPG_Collaborative )){
                    oppsp.addError('Please select only EPG Health User to EPG Health Opportunity.');
                }
            }
        }
    }
    
}