trigger TGR_PSA_Metric on PSA_Metric__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_PSA_Metric_Trigger__c) {
        fflib_SObjectDomain.triggerHandler(DAO_PSA_Metric.class);
    } 
}