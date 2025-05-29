trigger TGR_ContractLifecycle on Contract_Lifecycle__c (before insert, before update, before delete, after insert, after update) {
    if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_Contract_Trigger__c)
        fflib_SObjectDomain.triggerHandler(DAO_ContractLifecycle.class);
}