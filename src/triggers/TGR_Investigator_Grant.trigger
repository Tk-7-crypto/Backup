trigger TGR_Investigator_Grant on Investigator_Grant__c (before insert,before update, before delete, after insert, after update, after delete, after undelete) {
	fflib_SObjectDomain.triggerHandler(DAO_Investigator_Grant.class);
}