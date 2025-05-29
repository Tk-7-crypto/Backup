/**
* This trigger is used for Budget object.
* version : 1.0
*/
trigger TGR_Budget on pse__Budget__c (before insert, before update,before delete, after insert, after update, after delete) { 
    if(!UTL_ExecutionControl.stopTriggerExecution && Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_Budget_Trigger__c){
        fflib_SObjectDomain.triggerHandler(DAO_Budget.class); 
    }
}
