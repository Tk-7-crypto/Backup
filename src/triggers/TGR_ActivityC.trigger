trigger TGR_ActivityC  on Activity__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    fflib_SObjectDomain.triggerHandler(DAO_ActivityC.class);
}