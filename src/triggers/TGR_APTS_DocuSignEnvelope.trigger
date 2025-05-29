/**
* This trigger is used for DocuSign Envelope object.
* version : 1.0
*/
trigger TGR_APTS_DocuSignEnvelope on Apttus_DocuApi__DocuSignEnvelope__c (after update) {
     if(Trigger_Control_For_Migration__c.getInstance() != null 
        && !Trigger_Control_For_Migration__c.getInstance().Disable_APTS_DocuSignEnvelope_Trigger__c) {
        fflib_SObjectDomain.triggerHandler(DAO_APTS_DocuSignEnvelope.class);
    }
}