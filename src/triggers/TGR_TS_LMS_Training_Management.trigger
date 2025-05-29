trigger TGR_TS_LMS_Training_Management on TS_LMS_Training_Management__c (before insert, before update, before delete, after insert, after update) {
    fflib_SObjectDomain.triggerHandler(DAO_TS_LMS_Training_Management.class);
}