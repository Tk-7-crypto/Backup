/**
 * This trigger is used for RA Feedback (Partner_Contact__c) object.
 * version : 1.0 
 */
trigger TGR_Partner_Contact on Partner_Contact__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    if(Trigger_Control_For_Migration__c.getInstance() != null  && !Trigger_Control_For_Migration__c.getInstance().Disable_Partner_Contact_Trigger__c) {
        fflib_SObjectDomain.triggerHandler(DAO_Partner_Contact.class);
    } 
}