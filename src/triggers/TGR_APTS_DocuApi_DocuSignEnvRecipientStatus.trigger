trigger TGR_APTS_DocuApi_DocuSignEnvRecipientStatus on Apttus_DocuApi__DocuSignEnvelopeRecipientStatus__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(!UTL_ExecutionControl.stopTriggerExecution && !Trigger_Control_For_Migration__c.getInstance().Disable_DocuSign_Envelope_RS__c) {
        fflib_SObjectDomain.triggerHandler(DAO_APTS_DocuApi_DocuSignEnvelopeRS.class);
    }
}