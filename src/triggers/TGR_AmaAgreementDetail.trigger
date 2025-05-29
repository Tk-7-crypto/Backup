trigger TGR_AmaAgreementDetail on AMA_Agreement_Detail__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

	fflib_SObjectDomain.triggerHandler(DAO_AmaAgreementDetail.class);
    
}