/**
* This trigger is used for Agreement object.
* version : 1.0
*/
trigger TGR_APTS_Agreement on Apttus__APTS_Agreement__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(Trigger_Control_For_Migration__c.getInstance() != null 
       && !Trigger_Control_For_Migration__c.getInstance().Disable_Agreement_Trigger__c ){
        fflib_SObjectDomain.triggerHandler(DAO_APTS_Agreement.class);
    }
}