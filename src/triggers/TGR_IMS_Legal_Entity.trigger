trigger TGR_IMS_Legal_Entity on IMS_Legal_Entity__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    fflib_SObjectDomain.triggerHandler(DAO_IMS_Legal_Entity.class);
}