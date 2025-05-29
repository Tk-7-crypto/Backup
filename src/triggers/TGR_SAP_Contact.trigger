/**
 * This trigger is used for SAP Contact object.
 * version : 1.0
 */
trigger TGR_SAP_Contact on SAP_Contact__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    fflib_SObjectDomain.triggerHandler(DAO_SAP_Contact.class);
}