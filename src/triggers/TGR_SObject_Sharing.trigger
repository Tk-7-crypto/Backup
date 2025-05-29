/**
* This trigger is used for SObject Sharing object.
* version : 1.0
*/
trigger TGR_SObject_Sharing on SObject_Sharing__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(!UTL_ExecutionControl.stopTriggerExecution)
        fflib_SObjectDomain.triggerHandler(DAO_SObject_Sharing.class);
}