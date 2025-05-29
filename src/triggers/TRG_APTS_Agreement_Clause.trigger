/**
 * This trigger is used for Agreement Clause object.
 * version : 1.0
 */
trigger TRG_APTS_Agreement_Clause on Apttus__Agreement_Clause__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(Trigger_Control_For_Migration__c.getInstance() != null && !Trigger_Control_For_Migration__c.getInstance().Disable_Agreement_Clause_Trigger__c)
        fflib_SObjectDomain.triggerHandler(DAO_APTS_Agreement_Clause.class);
}