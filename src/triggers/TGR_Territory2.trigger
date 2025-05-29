/**
* This trigger is used for Territory2 object.
* version : 1.0
*/
trigger TGR_Territory2 on Territory2 (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(!UTL_ExecutionControl.stopTriggerExecution)
        fflib_SObjectDomain.triggerHandler(DAO_Territory2.class);
}