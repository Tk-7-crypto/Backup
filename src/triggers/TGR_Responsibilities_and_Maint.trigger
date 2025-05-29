/**
 * This trigger is used for Responsibilities and Maintenance (Responsibilities_and_Maintenance__c) object.
 * version : 1.0
 */
trigger TGR_Responsibilities_and_Maint on Responsibilities_and_Maintenance__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_Target_Trigger__c) {
        fflib_SObjectDomain.triggerHandler(DAO_Responsibilities_and_Maint.class);
    }
}