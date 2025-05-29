/**
* This is Agreement Clause trigger handler class.
* version : 1.0 
*/
public class DAO_APTS_Agreement_Clause extends fflib_SObjectDomain {
    /**
    * Constructor of this class
    * @params sObjectList List<Apttus__Agreement_Clause__c>
    */
    public DAO_APTS_Agreement_Clause(List<Apttus__Agreement_Clause__c> sObjectList) {
        super(sObjectList);
    }

    /**
    * Constructor Class for construct new Instance of This Class
    */
    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new DAO_APTS_Agreement_Clause(sObjectList);
        }
    }

    /**
    * This method is used for after insert of the Agreement Clause trigger.
    * @return void
    */
    public override void onAfterInsert() {
        
        Set<Id> agreementClauseIdset = Trigger.newMap.keySet();
        Set<Id> setRecTypes = new Set<Id>{CON_CLM.PSA_RECORDTYPEID,CON_CLM.MSA_RECORDTYPEID};
        List<Apttus__Agreement_Clause__c> newAgreementClauseList = new List<Apttus__Agreement_Clause__c>();
        List<Apttus__Agreement_Clause__c> msaAgreementClauseList = new List<Apttus__Agreement_Clause__c>();
        Set<String> fieldSet = new Set<String> {'Id', 'Apttus__Agreement__r.RecordTypeId'};
        String condition = 'ID IN: agreementClauseIdset AND Apttus__Agreement__r.RecordTypeId IN :setRecTypes';

        Map<Id, Apttus__Agreement_Clause__c> agreementClauseMap = new SLT_Agreement_Clause().getAgreementClauseDetails(
            agreementClauseIdset, fieldSet, condition, setRecTypes);

        for(Apttus__Agreement_Clause__c agreementClause : (List<Apttus__Agreement_Clause__c>) Records) {
            if(agreementClauseMap.containsKey(agreementClause.Id)) {
                newAgreementClauseList.add((Apttus__Agreement_Clause__c)agreementClause);
                if(agreementClauseMap.get(agreementClause.Id).Apttus__Agreement__r.RecordTypeId == CON_CLM.MSA_RECORDTYPEID) {
                    msaAgreementClauseList.add((Apttus__Agreement_Clause__c)agreementClause);
                }
            }
        }

        if(!newAgreementClauseList.isEmpty()){
            DAOH_CLM_Agreement_Clause.updateQuestionnaireTabDetails(newAgreementClauseList);
        }
        if(!msaAgreementClauseList.isEmpty()){
            DAOH_CLM_Agreement_Clause.updateAutoRenewCheckboxOnAgreement(msaAgreementClauseList);
        }
        
    }
}