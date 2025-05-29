trigger TGR_TeamMember on Team_Member__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    if(Trigger_Control_For_Migration__c.getInstance() != null)
        fflib_SObjectDomain.triggerHandler(DAO_TeamMember.class);
}