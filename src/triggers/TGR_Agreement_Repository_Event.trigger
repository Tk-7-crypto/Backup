trigger TGR_Agreement_Repository_Event  on Agreement_Repository_Event__e (After Insert) { 
    if(Trigger_Control_For_Migration__c.getInstance() != null 
       && !Trigger_Control_For_Migration__c.getInstance().Disable_AR_Event_Trigger__c ) {
        fflib_SObjectDomain.triggerHandler(DAO_Agreement_Repository_Event.class);
    }
}