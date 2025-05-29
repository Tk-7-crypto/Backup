trigger TGR_Quote on Quote (before insert, before update, before delete, after insert, after update, after delete, after undelete){
    if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_STD_Quote_Trigger__c) {
        fflib_SObjectDomain.triggerHandler(DAO_Quote.class);
    }
}