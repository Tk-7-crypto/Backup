trigger TGR_ContractMilestone on Contract_Milestone__c (before insert, before update, before delete, after insert, after update) {
    if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_Contract_Trigger__c && !UTL_ExecutionControl.stopMilestoneTriggerExecution)
        fflib_SObjectDomain.triggerHandler(DAO_ContractMilestone.class);
}