/**
 * This trigger is used for Journals Main Catalogue (Journals_Main_Catalogue__c) object.
 * version : 1.0
 */
trigger TGR_Journals_Main_Catalogue on Journals_Main_Catalogue__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(!UTL_ExecutionControl.stopTriggerExecution && Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_Journals_Main_Catalogue_Trigger__c)
        fflib_SObjectDomain.triggerHandler(DAO_PSA_Journals_Main_Catalogue.class);

}
