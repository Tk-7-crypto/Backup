trigger TGR_TPA_AgreementAdditionalField on TPA_Agreement_Additional_Field__c (before insert, before update, after update) {
    fflib_SObjectDomain.triggerHandler(DAO_TPA_AgreementAdditionalField.class);
}