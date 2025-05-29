trigger TGR_CaseAutomationScheduler on CSM_QI_CaseAutomationScheduler__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    if(!UTL_ExecutionControl.stopTriggerExecution)
        fflib_SObjectDomain.triggerHandler(DAO_CaseAutomationScheduler.class);
}