public class CNT_CLM_AgreementHeader {

    /**
    * This method used to set agreement and agreement extension in wrapper
    * @param Id agreementId
    * @return AgreementWrapper
    */
    @AuraEnabled
    public static AgreementWrapper setAgreementWrapper(Id agreementId) {
        AgreementWrapper agreementWrapper = null; 
        Apttus__APTS_Agreement__c agreement = new Apttus__APTS_Agreement__c();
        Agreement_Extension__c agreementExtesion = new Agreement_Extension__c();
        try {
            Set<String> fieldSet = new Set<String>{'Id', 'Name', 'RecordTypeId','RecordType.DeveloperName',
                'RecordType.Name','Rel_Opp_Global_Project_Unit__c', 'IQVIA_Project_Manager_Con__c', 'Apttus__Status_Category__c'};
            if(Schema.sObjectType.Apttus_Proposal__Proposal__c.isAccessible()) {
                fieldSet.addAll(new Set<String>{'Apttus_QPComply__RelatedProposalId__r.RecordType.DeveloperName',
                    'Apttus_QPComply__RelatedProposalId__r.Apttus_QPConfig__ConfigurationFinalizedDate__c'});
            }
            agreement = SRV_CLM_Agreement.getAgreementDetailById(agreementId, fieldSet);
            agreementWrapper = new AgreementWrapper(agreement, agreementExtesion);
            if(agreement.RecordTypeId == CON_CLM.PSA_RECORDTYPEID || agreement.RecordTypeId == CON_CLM.PRELIMINARY_RECORDTYPEID){
                agreementWrapper.showProjectManagerPrompt = showProjectManagerPrompt(agreement.IQVIA_Project_Manager_Con__c);
                if(agreement.RecordTypeId == CON_CLM.PSA_RECORDTYPEID && Schema.sObjectType.Apttus_Proposal__Proposal__c.isAccessible()
                    && (agreement.Apttus__Status_Category__c == CON_CLM.IN_AUTHORING || agreement.Apttus__Status_Category__c == CON_CLM.IN_SIGNATURES)
                    && agreement.Apttus_QPComply__RelatedProposalId__r.RecordType.DeveloperName == CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET
                    && agreement.Apttus_QPComply__RelatedProposalId__r.Apttus_QPConfig__ConfigurationFinalizedDate__c == null) {
                    agreementWrapper.showBudgetPrompt = true;
                } else {
                    agreementWrapper.showBudgetPrompt = false;
                }
            }
            agreementWrapper.recordTypeName = agreementWrapper.agreement.RecordType.DeveloperName;


        } catch(Exception ex) {
            throw new AuraHandledException(JSON.serialize(ex));
        }
        return agreementWrapper;
    }
    
     /**
    * This method is to get if to show the prompt message on component
    * @return Boolean
    */
    @TestVisible
    private static Boolean showProjectManagerPrompt(String iQVIAProjectManager) {
        if(String.isNotEmpty(iQVIAProjectManager)) {
            return false;
        } else {
            return true;
        }
    }
}