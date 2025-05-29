/**
* This trigger is used for DocuSign Envelope object.
* version : 1.0
*/
trigger TGR_IQ_DocuSignEnvelope on IQ_DocuSignEnvelope__c (after update) {
     if(Trigger_Control_For_Migration__c.getInstance() != null 
        && !Trigger_Control_For_Migration__c.getInstance().Disable_IQ_DocuSignEnvelope_Trigger__c) {
        fflib_SObjectDomain.triggerHandler(DAO_IQ_DocuSignEnvelope.class);
    }
}