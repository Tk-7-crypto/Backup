/**
 * This trigger is used for Lead object.
 * version : 1.0
 */
trigger TGR_Lead on Lead (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    fflib_SObjectDomain.triggerHandler(DAO_Lead.class);
}