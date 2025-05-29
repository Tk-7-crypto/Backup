/**
 * This trigger is used for ContentDocument object.
 * version : 1.0
 */
trigger TGR_ContentDocument on ContentDocument(before delete, after delete) {
    if(Trigger_Control_For_Migration__c.getInstance() != null 
        && !Trigger_Control_For_Migration__c.getInstance().Disable_ContentDocument_Trigger__c) {
        fflib_SObjectDomain.triggerHandler(DAO_ContentDocument.class);
    }
}