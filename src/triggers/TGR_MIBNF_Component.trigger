trigger TGR_MIBNF_Component on MIBNF_Component__c (after insert, after delete) {
    if(!UTL_ExecutionControl.stopTriggerExecution)
        fflib_SObjectDomain.triggerHandler(DAO_MIBNF_Component.class);
}