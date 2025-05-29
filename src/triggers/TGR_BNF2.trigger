trigger TGR_BNF2 on BNF2__c (after insert, after delete) {
    if(!UTL_ExecutionControl.stopTriggerExecution)
        fflib_SObjectDomain.triggerHandler(DAO_BNF2.class);
}