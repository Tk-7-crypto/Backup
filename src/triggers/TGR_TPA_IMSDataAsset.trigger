trigger TGR_TPA_IMSDataAsset on IMS_Data_Asset__c (before insert, before update, after insert, after update) {
    fflib_SObjectDomain.triggerHandler(DAO_TPA_IMSDataAsset.class);
}