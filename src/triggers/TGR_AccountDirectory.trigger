trigger TGR_AccountDirectory on Account_Directory__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    If(!UTL_ExecutionControl.stopTriggerExecution)
        fflib_SObjectDomain.triggerHandler(DAO_AccountDirectory.class);
}