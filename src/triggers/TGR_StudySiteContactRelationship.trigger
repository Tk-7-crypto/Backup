trigger TGR_StudySiteContactRelationship on StudySiteContactRelationship__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
fflib_SObjectDomain.triggerHandler(DAO_StudySiteContactRelationship.class);
}