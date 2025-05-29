trigger TGR_MDM_Invoicing_Transaction on MDM_Invoicing_Transaction__c (after insert, after update) {
    if(!UTL_ExecutionControl.stopTriggerExecution)
        fflib_SObjectDomain.triggerHandler(DAO_MDM_Invoicing_Transaction.class);
}