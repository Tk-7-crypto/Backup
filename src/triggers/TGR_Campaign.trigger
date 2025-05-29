/**
 * This trigger is used for Campaign object.
 * version : 1.0
 */
trigger TGR_Campaign on Campaign (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(!UTL_ExecutionControl.stopTriggerExecution){
        fflib_SObjectDomain.triggerHandler(DAO_Campaign.class);
    }
}