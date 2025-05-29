/**
 * This trigger is used for Product Configuration object.
 * version : 1.0
 */
trigger TGR_ProductConfiguration on Apttus_Config2__ProductConfiguration__c
        (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    fflib_SObjectDomain.triggerHandler(DAO_ProductConfiguration.class);
}