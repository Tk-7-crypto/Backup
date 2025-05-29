/*
 * Version       : 1.0
 * Description   : Apex Controller for Add Opportunity team member component.
 */
public without sharing class CNT_CRM_AddOpportunityTeamMember {
	/**
     * This method used to get field detail of opportunity Team member object
     * @params  String fieldData
     * @return  List<ObjectFieldsWrapper>
     */
    @AuraEnabled
    public static List<ObjectFieldsWrapper> getOppTeamMemberFieldDetail(String fieldData) {
        List<ObjectFieldsWrapper> objectSelectedFieldList = new List<ObjectFieldsWrapper>();
        try {
            List<String> fieldList = fieldData.split(',');
            objectSelectedFieldList = new UTL_Sobject('OpportunityTeamMember').getSobjectFieldDetails(fieldList);
        } catch(Exception ex) {
            throw new AuraHandledException(JSON.serialize(ex));
        }
        return objectSelectedFieldList;
    }
    
    /**
     * This method used to get details of opportunity team members.
     * @params  Id recordId
     * @return  List<OpportunityTeamMember>
     */
    @AuraEnabled
    public static List<OpportunityTeamMember> getOppTeamMemberList(Id recordId) {
        List<OpportunityTeamMember> opportunityTeamMemberList = new List<OpportunityTeamMember>();
        try {
            Set<String> fieldSet = new Set<String>{'Id', 'OpportunityId', 'TeamMemberRole', 'UserId', 'OpportunityAccessLevel'};
            Set<Id> oppIdSet = new Set<Id>();
            oppIdSet.add((Id)recordId);
            opportunityTeamMemberList = new SLT_OpportunityTeamMember().selectByOpportunityId(oppIdSet, fieldSet);
        } catch(Exception ex) {
            throw new AuraHandledException(JSON.serialize(ex));
        }
        return opportunityTeamMemberList;
    }
    
    /**
     * This method used to save opportunity Team member records.
     * @params  String recordJSON
     */
    @AuraEnabled
    public static void saveOpportunityTeamMembers(String recordJSON, Opportunity opportunityRecord, Boolean isAccountChanged) {
        try {
            List<OpportunityTeamMember> opportunityTeamMemberList = (List<OpportunityTeamMember>)JSON.deserialize(recordJSON, List<OpportunityTeamMember>.class);
            List<OpportunityTeamMember> opportunityTeamMemberListToInsert = new List<OpportunityTeamMember> ();
            for(OpportunityTeamMember oppTeamMember :opportunityTeamMemberList) {
                if(!String.isBlank(oppTeamMember.userId)){
                    opportunityTeamMemberListToInsert.add(oppTeamMember);
                }
            }
            SRV_CRM_OpportunityTeamMember.addOpportunityTeamMember(opportunityTeamMemberListToInsert);
            if(isAccountChanged)
                SRV_CRM_Opportunity.updateAccountOnOpportunity(opportunityRecord);
        } catch(Exception ex) {
            throw new AuraHandledException(JSON.serialize(ex));
        }
    }
    
    /**
     * This method used to delete opportunity Team member records.
     * @params  String recordJSON
     */
    @AuraEnabled
    public static void deleteOpportunityTeamMembers(String recordJSON) {
        try {
            List<OpportunityTeamMember> opportunityTeamMemberListToDelete = (List<OpportunityTeamMember>)JSON.deserialize(recordJSON, List<OpportunityTeamMember>.class);
            List<OpportunityTeamMember> opportunityTeamMembersToDelete = new List<OpportunityTeamMember>();
            for(OpportunityTeamMember oppTeamMember : opportunityTeamMemberListToDelete) {
                if(!String.isBlank(oppTeamMember.Id)){
                    opportunityTeamMembersToDelete.add(oppTeamMember);
                }
            }
            if(opportunityTeamMembersToDelete != null && opportunityTeamMembersToDelete.size() > 0 ) {
            	SRV_CRM_OpportunityTeamMember.deleteOpportunityTeamMember(opportunityTeamMembersToDelete); 
            }
        } catch(Exception ex) {
            system.debug(ex);
            throw new AuraHandledException(JSON.serialize(ex));
        }
    }
    
    /**
     * This method used to check for commercial user.
     * @return  Boolean isManagerUser
     */
    @AuraEnabled
    public static Boolean getCommercialUserDetail() {
        Boolean isCommercialUser = false;
        try {
            String userProfile = UTL_CRM.getCurrentUserProfileName();
            if(userProfile.equalsIgnoreCase(CON_CRM.COMMERCIAL_OPERATION_PROFILE) || FeatureManagement.checkPermission(CON_CRM.CP_COMMERCIAL_OPS_USER)) {       
               isCommercialUser = true;
            }
        } catch(Exception ex) {
            throw new AuraHandledException(JSON.serialize(ex));
        }
        return isCommercialUser;
    }
}