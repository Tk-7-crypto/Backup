/**
 * @description DAOH for Apttus_DocuApi__DocuSignEnvelope__c Object
 */
public class DAOH_CLM_APTS_DocuSignEnvelope {
	
    /**
    * This method is used to set agreement status to Other Party Signature when env status is changed to Sent
    * @params  lstDocusignEnv List<Apttus_DocuApi__DocuSignEnvelope__c>
    * @params  Map<Id, Apttus_DocuApi__DocuSignEnvelope__c> oldMap
    * @return  void
    */
    public static void updateAgreementStatus(List<Apttus_DocuApi__DocuSignEnvelope__c> lstDocusignEnv, 
        Map<Id, Apttus_DocuApi__DocuSignEnvelope__c> oldMap) {
        Set<Id> agreementIds = new Set<Id>();
        List<Apttus__APTS_Agreement__c> lstToUpdate = new List<Apttus__APTS_Agreement__c>();
        for(Apttus_DocuApi__DocuSignEnvelope__c docusignEnv : lstDocusignEnv) {
            Apttus_DocuApi__DocuSignEnvelope__c oldDocEnv = oldMap.get(docusignEnv.Id);
            if((oldDocEnv.Apttus_DocuApi__Status__c == CON_CLM.DRAFT || oldDocEnv.Apttus_DocuApi__Status__c == CON_CLM.CANCELLED)
                && docusignEnv.Apttus_DocuApi__Status__c == CON_CLM.ENVELOPE_STATUS_SENT 
                && docusignEnv.Apttus_CMDSign__Agreement__c != null) {
                agreementIds.add(docusignEnv.Apttus_CMDSign__Agreement__c);
            }
        }
        if(!agreementIds.isEmpty()) {
            String condition = 'Id IN :agreementIds AND Apttus__Status__c != \''+CON_CLM.STATUS_OTHER_PARTY_SIGNATURE+'\'';
            for(Apttus__APTS_Agreement__c agreement : new SLT_Agreement().getAgreementListByCondition(
                new Set<String>{'Id'}, condition, agreementIds)){
                agreement.Apttus__Status__c = CON_CLM.STATUS_OTHER_PARTY_SIGNATURE;
                lstToUpdate.add(agreement);
            }
        }
        if(!lstToUpdate.isEmpty()) {
            try {  
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                    new Schema.SObjectType[] {
                        Apttus__APTS_Agreement__c.SObjectType
                    }
                );
                uow.registerDirty(lstToUpdate);
                uow.commitWork();
            } catch(DMLException dmlExp) {
                System.debug(System.LoggingLevel.ERROR, dmlExp.getMessage() + ' \n ' + dmlExp.getStackTraceString());
            }
        }
    }
}