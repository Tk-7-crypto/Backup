/*
 *This trigger is used for AccountContactRelation object 
 */
trigger TGR_AccountContactRelation on AccountContactRelation (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	fflib_SObjectDomain.triggerHandler(DAO_AccountContactRelation.class);       
}