public class DAOH_CLM_Agreement_Clause {
    /**
    * Set the default values for Questionnaire Tab fields on the Agreement Caluse record creation.
    * @param lstAgreementClause   List of Agreement Clause records to set default values on.
    * @return none
    */
    public static void updateQuestionnaireTabDetails(List<Apttus__Agreement_Clause__c> lstAgreementClause) {
        Map<String, String> clauseNameToFieldMap = new Map<String, String>();
        Map<Id, Apttus__APTS_Agreement__c> agreementMap = new Map<Id, Apttus__APTS_Agreement__c>();
        Map<Id, List<Apttus__Agreement_Clause__c>> agrIdToAgreementClauseMap = new Map<Id, List<Apttus__Agreement_Clause__c>>();       
        List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
        for(CLM_Agreement_Clause_Field_Mapping__c clausefieldMappingRecord : CLM_Agreement_Clause_Field_Mapping__c.getAll().values()) {
            if(clausefieldMappingRecord.Clause_Name__c != null) {
                clauseNameToFieldMap.put(clausefieldMappingRecord.Clause_Name__c, clausefieldMappingRecord.Field_To_Update__c);
            }
        }
        if(!clauseNameToFieldMap.isEmpty()) {
            for(Apttus__Agreement_Clause__c agreementClause : lstAgreementClause) {
                if(agreementClause.Apttus__Agreement__c != null) {
                    if(!agrIdToAgreementClauseMap.containsKey(agreementClause.Apttus__Agreement__c)) {
                        agrIdToAgreementClauseMap.put(agreementClause.Apttus__Agreement__c, new List<Apttus__Agreement_Clause__c>());
                    }
                    agrIdToAgreementClauseMap.get(agreementClause.Apttus__Agreement__c).add(agreementClause);
                }
            }
        }
        if(!agrIdToAgreementClauseMap.isEmpty()) {
            Set<String> fieldSet = new Set<String>();
            List<String> lstFields = clauseNameToFieldMap.values();
            fieldSet.addAll(lstFields);
            agreementMap = new SLT_APTS_Agreement().getAgreementsById(agrIdToAgreementClauseMap.keySet(), fieldSet); 
            for(Id agreementId : agrIdToAgreementClauseMap.keySet()) {
                if(agreementMap.containsKey(agreementId)) {
                    Apttus__APTS_Agreement__c  agreement = agreementMap.get(agreementId);
                    for(Apttus__Agreement_Clause__c agreementClause: agrIdToAgreementClauseMap.get(agreementId)) {
                        if(clauseNameToFieldMap.containsKey(agreementClause.Apttus__Clause__c)) {
                            if(agreementClause.Apttus__Action__c == CON_CLM.MODIFIED) {
                                agreement.put(clauseNameToFieldMap.get(agreementClause.Apttus__Clause__c), CON_CLM.WITHIN_FALLBACKS);
                            } else if(agreementClause.Apttus__Action__c == CON_CLM.DELETED) {
                                agreement.put(clauseNameToFieldMap.get(agreementClause.Apttus__Clause__c), CON_CLM.DELETED);
                            }
                        }
                        agreementList.add(agreement);
                    }
                }
            }
        }
        if(!agreementList.isEmpty()) {
            try {  
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                    new Schema.SObjectType[] {
                        Apttus__APTS_Agreement__c.SObjectType
                    }
                );
                uow.registerDirty(agreementList);
                uow.commitWork();
            } 
            catch(DMLException dmlExp) {
                System.debug(System.LoggingLevel.ERROR, dmlExp.getMessage() + ' \n ' + dmlExp.getStackTraceString());
            }
        }
    }
    
     /**
    * Update Auto Renew Checkbox of MSA Agreement to false when Auto Renew sentence is deleted
    * from MSA Term and Termination clause
    * @param lstAgreementClause   List of MSA Agreement Clause records.
    * @return none
    */
    public static void updateAutoRenewCheckboxOnAgreement(List<Apttus__Agreement_Clause__c> lstAgreementClause) {
        try {
            Set<String> agreementFieldSet = new Set<String>{'Id', 'Name', 'Apttus__Auto_Renewal__c', 'Renewal_Term_Years__c',
                'Renewal_Notification_Days__c'};
            Map<Id, Apttus__Agreement_Clause__c> agreementToAgreementClauseMap = new Map<Id, Apttus__Agreement_Clause__c>();
            Map<Id, Apttus__APTS_Agreement__c> agreementMap = new Map<Id, Apttus__APTS_Agreement__c>();
            List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
            for(Apttus__Agreement_Clause__c agreementClause : lstAgreementClause) {
                if(agreementClause.Apttus__Clause__c == CON_CLM.MSA_TERM_AND_TERMINATION && agreementClause.Apttus__Active__c &&
                    (agreementClause.Apttus__Action__c == CON_CLM.MODIFIED || 
                    agreementClause.Apttus__Action__c == CON_CLM.DELETED)) {
                    agreementToAgreementClauseMap.put(agreementClause.Apttus__Agreement__c, agreementClause);
               }
            }
            if(agreementToAgreementClauseMap.size() != 0) {
                agreementMap = new SLT_APTS_Agreement().getAgreementsById(agreementToAgreementClauseMap.keySet(), agreementFieldSet);
                for(Id agreementId: agreementToAgreementClauseMap.keySet()) {
                    Apttus__APTS_Agreement__c agreement = new Apttus__APTS_Agreement__c();
                    agreement = agreementMap.get(agreementId);
                    String text = 'The Agreement will automatically renew each year thereafter for a period of ' + 
                        agreement.Renewal_Term_Years__c + ' years, unless either party notifies the other party in ' +
                        'writing at least ' + agreement.Renewal_Notification_Days__c 
                        + ' days prior to the renewal date that the notifying party does not want to renew the Agreement.';
                    Apttus__Agreement_Clause__c agreementClause = agreementToAgreementClauseMap.get(agreementId);
                    if((agreementClause.Apttus__Action__c == CON_CLM.MODIFIED && (agreementClause.Apttus__Text__c == null || 
                        !(agreementClause.Apttus__Text__c.contains(text)))) || 
                        agreementClause.Apttus__Action__c == CON_CLM.DELETED) {
                        agreement.Apttus__Auto_Renewal__c = false;
                        agreementList.add(agreement);
                    }
                }
            }
            if(agreementList.size() != 0) {
                fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
                    new Schema.SObjectType[] {
                        Apttus__APTS_Agreement__c.SObjectType
                    }
                );
                uow.registerDirty(agreementList);
                uow.commitWork();
            }
        } catch(DMLException dmlExp) {
            System.debug(System.LoggingLevel.ERROR, dmlExp.getMessage() + ' \n ' + dmlExp.getStackTraceString());
        }
    }
}