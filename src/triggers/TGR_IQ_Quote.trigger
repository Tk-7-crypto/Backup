trigger TGR_IQ_Quote on Quote__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if (!UTL_ExecutionControl.stopTriggerExecutionCPQ && Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_IQVIA_Quote_Trigger__c) {
        fflib_SObjectDomain.triggerHandler(DAO_IQ_Quote.class);
    } 
}