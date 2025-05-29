trigger TGR_TPADataAsset on TPA_Data_Asset__c (before insert, after insert, after update, before update, before delete, after delete) { 
    fflib_SObjectDomain.triggerHandler(DAO_TPADataAsset.class);    
}