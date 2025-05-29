/**
 * This trigger is used for Certification(LMS) Certification object.
 * version : 1.0
 */
trigger TGR_Certification on Certification__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    fflib_SObjectDomain.triggerHandler(DAO_Certification.class);
}