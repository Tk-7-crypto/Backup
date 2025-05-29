trigger TGR_DocuSignRecipientStatus on dsfs__DocuSign_Recipient_Status__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	fflib_SObjectDomain.triggerHandler(DAO_DocuSignRecipientStatus.class);
}