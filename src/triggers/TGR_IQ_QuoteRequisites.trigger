trigger TGR_IQ_QuoteRequisites on Quote_Requisites__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if (Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_Quote_Requisites__c) {
        fflib_SObjectDomain.triggerHandler(DAO_IQ_QuoteRequisites.class);
    }
}