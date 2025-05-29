trigger TGR_CSAT_Response on CSAT_Responses__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    fflib_SObjectDomain.triggerHandler(DAO_CSAT_Response.class);
}