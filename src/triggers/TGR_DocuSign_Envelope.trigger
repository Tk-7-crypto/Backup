trigger TGR_DocuSign_Envelope on dsfs__DocuSign_Envelope__c (before insert, before update, before delete, 
    after insert, after update, after delete, after undelete) {
    if(!UTL_ExecutionControl.stopTriggerExecution && !Trigger_Control_For_Migration__c.getInstance().Disable_Docusign_Envelope_Trigger__c) {
        fflib_SObjectDomain.triggerHandler(DAO_DocuSign_Envelope.class);
    }
}