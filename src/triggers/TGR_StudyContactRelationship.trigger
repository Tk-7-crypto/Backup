trigger TGR_StudyContactRelationship  on Study_Contact_Relationship__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    fflib_SObjectDomain.triggerHandler(DAO_StudyContactRelationship.class);
}