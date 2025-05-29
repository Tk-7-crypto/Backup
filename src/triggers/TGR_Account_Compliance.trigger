trigger TGR_Account_Compliance on Account_Compliance__c (before insert,before update,after insert,after update) {
	fflib_SObjectDomain.triggerHandler(DAO_Account_Compliance.class);
}