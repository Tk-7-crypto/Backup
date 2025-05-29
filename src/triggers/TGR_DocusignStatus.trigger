trigger TGR_DocusignStatus on dsfs__DocuSign_Status__c (before insert, after insert,before update,after update,before delete,after delete) {
    //Added Single Trigger Pattern
    fflib_SObjectDomain.triggerHandler(DAO_DocusignStatus.class);
}