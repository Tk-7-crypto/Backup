/**
 * This trigger is used for ContentDocumentLinkobject.
 * version : 1.0
 */
trigger TGR_ContentVersion on ContentVersion (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(Trigger_Control_For_Migration__c.getInstance() != null 
        && !Trigger_Control_For_Migration__c.getInstance().Disable_ContentVersion_Trigger__c) {
        fflib_SObjectDomain.triggerHandler(DAO_ContentVersion.class);
    }
}