trigger TGR_IQ_DocuSignEnvRecipientStatus on IQ_DocuSignEnvelopeRecipientStatus__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(!UTL_ExecutionControl.stopTriggerExecution && !Trigger_Control_For_Migration__c.getInstance().Disable_IQ_DocuSign_Envelope_RS__c) {
        fflib_SObjectDomain.triggerHandler(DAO_IQ_DocuSignEnvelopeRS.class);
    }
}