trigger TGR_OutOfOffice on OutOfOffice (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(Trigger.isInsert || Trigger.isUpdate) {
        for (OutOfOffice outOfOfficeRecord : Trigger.new) {}
    } 
    if(Trigger.isDelete) {
        for (OutOfOffice outOfOfficeRecord : Trigger.old) {}
    }
    if(!UTL_ExecutionControl.stopTriggerExecution)
         fflib_SObjectDomain.triggerHandler(DAO_OutOfOffice.class);
}