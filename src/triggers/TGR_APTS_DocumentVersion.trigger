trigger TGR_APTS_DocumentVersion on Apttus__DocumentVersion__c (before insert, before update, before delete, after insert, after update) {
    fflib_SObjectDomain.triggerHandler(DAO_APTS_DocumentVersion.class);
}