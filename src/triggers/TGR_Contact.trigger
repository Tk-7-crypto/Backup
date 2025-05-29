/**
 * This trigger is used for Contact object.
 * version : 1.0
 */
trigger TGR_Contact on Contact (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(!UTL_ExecutionControl.stopTriggerExecution)
    fflib_SObjectDomain.triggerHandler(DAO_Contact.class);
    
    if(Trigger.isAfter && Trigger.isUpdate) {
        SRV_CRM_Field_History fieldHistoryService = SRV_CRM_Field_History.getInstance('Contact');
        fieldHistoryService.saveFieldHistories(Trigger.new, Trigger.oldMap);
    }
}