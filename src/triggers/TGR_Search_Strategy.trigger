/**
 * This trigger is used for Search Strategy (Search_Strategy__c) object.
 * version : 1.0
 */
trigger TGR_Search_Strategy on Search_Strategy__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(!UTL_ExecutionControl.stopTriggerExecution && Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_PSA_Search_Strategy_Trigger__c)
        fflib_SObjectDomain.triggerHandler(DAO_PSA_Search_Strategy.class);

}