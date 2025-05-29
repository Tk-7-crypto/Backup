trigger TGR_IQVIA_Agreement on IQVIA_Agreement__c (before insert, before update, before delete, after insert,
    after update, after delete, after undelete) {
    if(Trigger_Control_For_Migration__c.getInstance() != null 
        && !Trigger_Control_For_Migration__c.getInstance().Disable_IQVIA_Agreement_Trigger__c ){
        fflib_SObjectDomain.triggerHandler(DAO_IQVIA_Agreement.class);
    }
}