/**
 * Author : Shubham Jain 
 * Date Of Creation : 26-03-2019
 * This trigger is used for opportunityTeamMember object.
 */
trigger TGR_OpportunityTeamMember on OpportunityTeamMember (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    fflib_SObjectDomain.triggerHandler(DAO_OpportunityTeamMember.class);
}