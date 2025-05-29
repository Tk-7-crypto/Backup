/**
 * This trigger is used for Report Country (Report_Country__c) object.
 * version : 1.0
 */
trigger TGR_Report_Country on Report_Country__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_Aggregate_Report_Trigger__c) {
        fflib_SObjectDomain.triggerHandler(DAO_Report_Country.class);
    } 
}