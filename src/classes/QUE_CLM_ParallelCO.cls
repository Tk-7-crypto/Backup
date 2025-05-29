public class QUE_CLM_ParallelCO implements Queueable {
    Map<Id, Id> inFlightIdToBeingAmendedIdMap;
    public QUE_CLM_ParallelCO(Map<Id, Id> inFlightIdToBeingAmendedIdMap) {
        this.inFlightIdToBeingAmendedIdMap = inFlightIdToBeingAmendedIdMap;
    }
    
    public void execute(QueueableContext qc) {
        List<Apttus__APTS_Agreement__c> lstAgreement = new SLT_Agreement().getAgreementFieldsById(inFlightIdToBeingAmendedIdMap.keySet(), 
            new Set<String>{'Id', 'Agreement_Cloned_From__c'});
        for(Apttus__APTS_Agreement__c agr : lstAgreement) {
            if(inFlightIdToBeingAmendedIdMap.containsKey(agr.Id)) {
                agr.Agreement_Cloned_From__c =  inFlightIdToBeingAmendedIdMap.get(agr.Id);
            }
        } 
        String condition = 'Apttus__APTS_Contract_To__c IN: idSet'; 
        List<Apttus__APTS_Related_Agreement__c> lstRelatedAgreement = new SLT_RelatedAgreement().getRelatedAgreementsByCondition(inFlightIdToBeingAmendedIdMap.keySet(), 
            new Set<String>{'Id', 'Apttus__APTS_Contract_To__c', 'Apttus__APTS_Contract_From__c'}, condition);         
        for(Apttus__APTS_Related_Agreement__c rel : lstRelatedAgreement) {
            if(inFlightIdToBeingAmendedIdMap.containsKey(rel.Apttus__APTS_Contract_To__c)) {
                rel.Apttus__APTS_Contract_From__c = inFlightIdToBeingAmendedIdMap.get(rel.Apttus__APTS_Contract_To__c); 
            }
        }
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                Apttus__APTS_Related_Agreement__c.SObjectType, Apttus__APTS_Agreement__c.SObjectType
            }
        );        
        if(!lstAgreement.isEmpty() && !lstRelatedAgreement.isEmpty()) {
            try {
                uow.registerDirty(lstAgreement);
                uow.registerDirty(lstRelatedAgreement);
                uow.commitWork();
            }
            catch(DMLException e) {
                System.debug(System.LoggingLevel.ERROR, e.getMessage() + ' \n ' + e.getStackTraceString());
            }
        }    
    }    
}