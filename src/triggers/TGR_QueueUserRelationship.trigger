trigger TGR_QueueUserRelationship on Queue_User_Relationship__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
	fflib_SObjectDomain.triggerHandler(DAO_QueueUserRelationship.class);
}