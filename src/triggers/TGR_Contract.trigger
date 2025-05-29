trigger TGR_Contract on Contract (before insert, before update, before delete, after insert, after update) {
    if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_Contract_Trigger__c && !UTL_ExecutionControl.stopTriggerExecution)
        fflib_SObjectDomain.triggerHandler(DAO_Contract.class);
}