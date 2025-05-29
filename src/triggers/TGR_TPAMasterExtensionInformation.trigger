trigger TGR_TPAMasterExtensionInformation on TPA_Master_Extension_Information__c (before update, after update) {
    fflib_SObjectDomain.triggerHandler(DAO_TPAMasterExtensionInformation.class);
}