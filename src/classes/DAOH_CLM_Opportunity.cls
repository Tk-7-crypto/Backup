/**
 * This class is used to handle opportunity trigger for CLM module. 
 */
public class DAOH_CLM_Opportunity {
	
    public static partnerSoapSforceCom.Soap atUpdate;
    public static boolean isCalloutTrue = false;
    
    /**
     * This method checks for agreement related to the opportunity and checks for opportunity stages
     * if condition meets then it is updating the is_Study_awarded field of agreement.
     */
    public static void updateIsStudyAwaredOfAgreement(List<Opportunity> opportunities, 
        Map<Id, Opportunity> oldMap) {
        Map<Id, Opportunity> opportunityMap = new Map<Id, Opportunity>(opportunities);
        List<Apttus__APTS_Agreement__c> agreementListToUpdate = new List<Apttus__APTS_Agreement__c>();
        Set<Id> recordTypeIdSet = new Set<Id>{CON_CLM.PRELIMINARY_RECORDTYPEID};
        Set<String> fields = new Set<String>{'Id', 'Apttus__Related_Opportunity__c', 'Is_Study_Awarded__c'};
        Set<Id> opportunityIds = new Set<Id>();
        for(Opportunity opp : opportunities) {
            if(oldMap != null && opp.StageName != null && opp.StageName != oldMap.get(opp.Id).StageName) {
                opportunityIds.add(opp.Id);
            }
        }
        if(!opportunityIds.isEmpty()) {
            Map<Id, Apttus__APTS_Agreement__c> agreementMap = new SLT_Agreement(false, false).getAgreementByOpportunityAndRecordTypeId(
                opportunityIds, recordTypeIdSet, fields);
            for(Id agreementId : agreementMap.keySet()) {
                Apttus__APTS_Agreement__c agreement = agreementMap.get(agreementId);
                Opportunity opp = opportunityMap.get(agreement.Apttus__Related_Opportunity__c);
                if (CON_CLM.OPPORTUNITY_STAGE_NAME_SET_FOR_NO.contains(opp.StageName) 
                    && agreement.Is_Study_Awarded__c != 'No') {
                    agreement.Is_Study_Awarded__c = 'No';
                    agreementListToUpdate.add(agreement);
                } else if(CON_CLM.OPPORTUNITY_STAGE_NAME_SET_FOR_YES.contains(opp.StageName) 
                    && agreement.Is_Study_Awarded__c != 'Yes') {
                    agreement.Is_Study_Awarded__c = 'Yes';
                    agreementListToUpdate.add(agreement);
                }
            }
        }
        if (!agreementListToUpdate.isEmpty()) {
            try {
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                    new Schema.SObjectType[] {
                        Apttus__APTS_Agreement__c.SObjectType
                    }
                );
                uow.registerDirty(agreementListToUpdate);
                UTL_ExecutionControl.disableTriggerCRUDAGR = true;
                uow.commitWork();
                UTL_ExecutionControl.disableTriggerCRUDAGR = false;
            } catch(Exception e) {
                throw e;
            }
        }
    }
    
	/**
     * This method is to create instance of agreement temp
     * @param opportunityIds
     * @return sobjectPartnerSoapSforceCom.sObject_x
    */
    @TestVisible
    private static sobjectPartnerSoapSforceCom.sObject_x createAgreement(Opportunity opp) {
        sobjectPartnerSoapSforceCom.sObject_x tempObj = new sobjectPartnerSoapSforceCom.sObject_x();
        tempObj.type_x = 'Apttus__APTS_Agreement__c';
        tempObj.agrName = opp.Name;
        tempObj.agrApttusAccount = opp.AccountId;
        tempObj.agrApttusRelatedOpportunity = opp.Id;
        tempObj.agrApttusSubtype = CON_CLM.REQUESTED_AGREEMENT_TYPE_WO;
        tempObj.agrRecordTypeId = CON_CLM.PSA_RECORDTYPEID;
        tempObj.agrOwnerId = opp.OwnerId;
        tempObj.agrApttusRequestor = opp.OwnerId;
        return tempObj;
    }
}