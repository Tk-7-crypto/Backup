/**
 * This trigger is used for Signal (Signal__c) object.
 * version : 1.0
 */
trigger TGR_Signal on Signal__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_PSA_Signal_Trigger__c) {
        fflib_SObjectDomain.triggerHandler(DAO_Signal.class);
    }
}