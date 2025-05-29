/**
 * This trigger is used for HA_Websites_Review__c object.
 * version : 1.0
 */
trigger TGR_HA_Websites_Review on HA_Websites_Review__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_PSA_HA_Websites_Review_Trigger__c) {
        fflib_SObjectDomain.triggerHandler(DAO_HA_Websites_Review.class);
    }
}