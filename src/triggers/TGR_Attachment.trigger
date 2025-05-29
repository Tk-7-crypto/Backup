/**
 * This trigger is used for Attachment Object.
 * version: 1.0
 */
trigger TGR_Attachment on Attachment (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(Trigger_Control_For_Migration__c.getInstance() != null 
        && !Trigger_Control_For_Migration__c.getInstance().Disable_Attachment_Trigger__c) {
        fflib_SObjectDomain.triggerHandler(DAO_Attachment.class);
    }
}