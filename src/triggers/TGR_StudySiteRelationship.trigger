trigger TGR_StudySiteRelationship on Study_Site_Relationship__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    fflib_SObjectDomain.triggerHandler(DAO_StudySiteRelationship.class);
}