trigger TGR_CDARequest on CDA_Request__c (before insert, before update, before delete, after insert, after delete, after update) {
    //Added Single Trigger Pattern
    if(!UTL_CDAUtility.isSkipCDATriggers) {
        fflib_SObjectDomain.triggerHandler(DAO_CDARequest.class);
    }
}