trigger TGR_TPA_IMSSecondaryDataAsset on IMS_Secondary_Data_Asset__c (after insert,after update) {
    fflib_SObjectDomain.triggerHandler(DAO_TPA_IMSSecondaryDataAsset.class);
}