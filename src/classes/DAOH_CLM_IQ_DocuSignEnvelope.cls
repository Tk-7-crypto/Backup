/**
 * @description DAOH for IQ_DocuSignEnvelope__c Object
 */
public class DAOH_CLM_IQ_DocuSignEnvelope {
	
    /**
    * This method is used to update the agreement status on the basis of docusign envelope status
    * @param List<IQ_DocuSignEnvelope__c> lstDocusignEnv 
    * @param Map<Id, IQ_DocuSignEnvelope__c> oldMap
    */
    public static void updateAgreementStatus(List<IQ_DocuSignEnvelope__c> lstDocusignEnv, 
        Map<Id, IQ_DocuSignEnvelope__c> oldMap) {
        Set<Id> agrIds = new Set<Id>();
        for(IQ_DocuSignEnvelope__c docEnv : lstDocusignEnv) { 
            if(docEnv.Status__c != oldMap.get(docEnv.Id).Status__c && docEnv.Agreement__c != null) {
                agrIds.add(docEnv.Agreement__c);
            }
        }
        if(!agrIds.isEmpty()) {
            Map<Id, IQVIA_Agreement__c> agreementMap = new Map<Id, IQVIA_Agreement__c>(new SLT_IQVIA_Agreement().getIQVIAAgreementFieldsById(agrIds, 
                new Set<String>{'RecordTypeId', 'Status__c', 'Other_Party_Does_Not_Need_To_Sign__c', 'Company_Signed_Date__c', 'Other_Party_Signed_Date__c'}));
            for(IQ_DocuSignEnvelope__c docEnv : lstDocusignEnv) {
                if(agreementMap.containsKey(docEnv.Agreement__c) && docEnv.Docusign_Envelope_Info__c == null) {
                    IQVIA_Agreement__c agr = agreementMap.get(docEnv.Agreement__c);   
                    if(docEnv.Status__c == CON_CLM.SENT_STATUS) {
                        agr.Status__c = (agr.RecordTypeId == CON_CLM.USBU_IQVIA_RECORDTYPEID || agr.RecordTypeId == CON_CLM.MSA_IQVIA_RECORDTYPEID)
                        ? CON_CLM.SENT_FOR_SIGNATURES : CON_CLM.STATUS_OTHER_PARTY_SIGNATURE;
                    }
                    else if(docEnv.Status__c == CON_CLM.DECLINED_STATUS) {
                        agr.Status__c = CON_CLM.SIGNATURE_DECLINED_STATUS;   
                    }
                    else if(docEnv.Status__c == CON_CLM.IQ_VOIDED_STATUS) {
                        agr.Status__c = CON_CLM.READY_FOR_SIGNATURES;
                    }
                    else if(docEnv.Status__c == CON_CLM.COMPLETED_STATUS 
                        && ((agr.Other_Party_Does_Not_Need_To_Sign__c && agr.Company_Signed_Date__c != null) 
                        || (!agr.Other_Party_Does_Not_Need_To_Sign__c && agr.Other_Party_Signed_Date__c != null && agr.Company_Signed_Date__c != null))) {
                        agr.Status__c = CON_CLM.FULLY_SIGNED;
                    }
                }
            }
            if(!agreementMap.values().isEmpty()) {
                try {  
                    fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                        new Schema.SObjectType[] {
                            IQVIA_Agreement__c.SObjectType
                        }
                    );
                    uow.registerDirty(agreementMap.values());
                    uow.commitWork();
                } catch(DMLException dmlExp) {
                    System.debug(System.LoggingLevel.ERROR, dmlExp.getMessage() + ' \n ' + dmlExp.getStackTraceString());
                }
            } 
        }        
    }
}