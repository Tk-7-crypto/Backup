global class AgreementLifecycle extends Apttus.AbstractAgreementLifecycleCallback {

    global override void afterAmend(Apttus__APTS_Agreement__c originalSO, Apttus__APTS_Agreement__c amendmentSO) {
         
        amendmentSO.Agreement_Cloned_From__c = originalSO.Id;
        if(originalSO.Apttus__Version_Number__c == 0) {
            amendmentSO.Original_Agreement__c = originalSO.Id;
        }
        if(originalSO.RecordTypeId == CON_CLM.AMA_RECORDTYPEID) {
            amendmentSO.CLM_Event__c = CON_CLM.AMEND;
        }
        if(originalSO.RecordTypeId == CON_CLM.MSA_RECORDTYPEID) {
            amendmentSO.Name = CON_CLM.REQUESTED_AGREEMENT_TYPE_AMENDMENT+ ' '+amendmentSO.Apttus__Version_Number__c+ ' to '+originalSO.Name;
        }
        if (originalSO.RecordTypeId != CON_CLM.AMESA_RECORDTYPEID
            && originalSO.RecordTypeId != CON_CLM.AMA_RECORDTYPEID) {
            UTL_CLM.excludeFieldsFromCloningWhileAmendingAgreement(CON_CLM.AGREEMENT_OBJECT_API_NAME, amendmentSO);    
        }
    }

    global override void afterRenew(Apttus__APTS_Agreement__c originalSO, Apttus__APTS_Agreement__c renewalSO) {
        renewalSO.Agreement_Cloned_From__c = originalSO.Id;
        if(originalSO.RecordTypeId == CON_CLM.AMA_RECORDTYPEID) {
            renewalSO.CLM_Event__c = CON_CLM.RENEWAL;
        }
    }
    /*
    handle onAfterActivate for AMA - fill the Original_Effective_Date__c and Apttus__Amendment_Effective_Date__c fields
    */
    global override void afterActivate(Apttus__APTS_Agreement__c agreementSO, Apttus.CustomClass.ActivationType actType) {
        if(agreementSO.RecordTypeId ==  CON_CLM.AMA_RECORDTYPEID){
           if(agreementSO.Apttus__Version_Number__c == 0){
               agreementSO.Original_Effective_Date__c = Date.today();
           }
           else if(agreementSO.Apttus__Version_Number__c > 0){
               agreementSO.Apttus__Amendment_Effective_Date__c = Date.today();
           }
        }
    }
}