/**
 * This trigger is used for Proxy Project object.
 * version : 1.0
 */
trigger TGR_ProxyProject on Proxy_Project__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(!UTL_ExecutionControl.stopTriggerExecution)
        fflib_SObjectDomain.triggerHandler(DAO_ProxyProject.class);
}