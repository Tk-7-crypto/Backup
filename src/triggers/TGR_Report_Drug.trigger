/**
 * This trigger is used for the Report Drug(Report_Drug__c) object.
 * version : 1.0
 */
trigger TGR_Report_Drug on Report_Drug__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_Report_Drug_Trigger__c) {
        fflib_SObjectDomain.triggerHandler(DAO_Report_Drug.class);
    } 
}