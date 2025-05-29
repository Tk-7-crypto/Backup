/**
 * This trigger is used for Target (Target__c) object.
 * version : 1.0
 */
trigger TGR_Target on Target__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_Target_Trigger__c) {
        fflib_SObjectDomain.triggerHandler(DAO_Target.class);
    } 
}