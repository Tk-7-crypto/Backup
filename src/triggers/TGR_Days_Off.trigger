/**
 * This trigger is used for Days Off object.
 * version : 1.0
 */
trigger TGR_Days_Off on Days_Off__c (before insert,before update,before delete, after insert, after update, after delete) {
    if(!UTL_ExecutionControl.stopTriggerExecution_OWF)
        fflib_SObjectDomain.triggerHandler(DAO_Days_Off.class);
}