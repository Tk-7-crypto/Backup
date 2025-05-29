trigger TGR_TpaSecondaryDataAsset on TPA_Secondary_Data_Asset__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    fflib_SObjectDomain.triggerHandler(DAO_TpaSecondaryDataAsset.class);
    
}