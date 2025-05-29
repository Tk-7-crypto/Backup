/**
* This trigger is used for Project Metric Actual object.
* version : 1.0
*/
trigger TGR_Project_Metric_Actual on Project_Metric_Actual__c (before insert, before update, after insert, after update, before delete, after delete) {
    if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_Project_Metric_Actual_Trigger__c) {
        fflib_SObjectDomain.triggerHandler(DAO_Project_Metric_Actual.class);
    }
}