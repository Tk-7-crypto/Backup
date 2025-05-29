trigger TGR_TPA_Commercial_Review on TPA_Commercial_Review__c (after update,before update, before insert) {
	fflib_SObjectDomain.triggerHandler(DAO_TPA_Commercial_Review.class);
}
