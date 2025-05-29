/**
 * This trigger is used for SD Runs Result(SD_Runs__c) object.
 * version : 1.0
 */
trigger TGR_Sd_Run on SD_Runs__c (before insert,before update,after insert, after update,before delete, after delete, after undelete) {
    if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_PSA_Sd_Run_Trigger__c) {
        fflib_SObjectDomain.triggerHandler(DAO_Sd_Run.class);
    }
}