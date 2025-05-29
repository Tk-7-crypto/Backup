trigger TGR_DocuSignEnvelopeDocument on dsfs__DocuSign_Envelope_Document__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	fflib_SObjectDomain.triggerHandler(DAO_DocuSignEnvelopeDocument.class);
}