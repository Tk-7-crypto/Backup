trigger TGR_ContractInOutLog on Contract_In_Out_Log__c (before insert, before update, before delete, after insert, after update) {
    if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_Contract_Trigger__c)
        fflib_SObjectDomain.triggerHandler(DAO_ContractInOutLog.class);
}