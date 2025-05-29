/**
 * This trigger is used for RA Recommendation (RA_Recommendation__c) object.
 * version : 1.0
 */
trigger TGR_RA_Recommendation on RA_Recommendation__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_Aggregate_Report_Trigger__c) {
        fflib_SObjectDomain.triggerHandler(DAO_RA_Recommendation.class);
    } 
}