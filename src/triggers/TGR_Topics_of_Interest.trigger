/**
 * This trigger is used for SD Runs Result(Topics_of_Interest__c) object.
 * version : 1.0
 */
trigger TGR_Topics_of_Interest on Topics_of_Interest__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_PSA_Topics_of_Interest_Trigger__c) {
        fflib_SObjectDomain.triggerHandler(DAO_Topics_of_Interest.class);
    }
}