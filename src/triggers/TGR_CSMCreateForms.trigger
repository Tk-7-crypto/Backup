trigger TGR_CSMCreateForms on CSM_CREATE_FORMS__c (before insert, after insert, before update, before delete) {
    if(!UTL_ExecutionControl.stopTriggerExecution)
        fflib_SObjectDomain.triggerHandler(DAO_CSMCreateForms.class);
}