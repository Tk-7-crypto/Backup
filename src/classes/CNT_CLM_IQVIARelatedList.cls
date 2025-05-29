/*
* This is common controller class for aura and lwc
*/
public class CNT_CLM_IQVIARelatedList {
    /**
    * This method is used to fetch agreement Clauses.
    * @param String recordId
    * @return List<Apttus__Agreement_Clause__c>
    */
    
    @AuraEnabled(cacheable=true)
    public static List<Apttus__Agreement_Clause__c> getAgreementClause(Id recordId) {
        Set<Id> agreementIds = new set<Id>();
        if(recordId.getSObjectType().getDescribe().getName() == CON_CLM.IQVIA_AGR_OBJ_NAME) {
             List<IQVIA_Agreement__c> iqAGRList = new SLT_IQVIA_Agreement().getIQVIAAgreementFieldsById(
                new Set<Id>{recordId}, new Set<String>{'Id','Conga_Agreement_Id__c'});            
            if(!iqAGRList.isEmpty() && iqAGRList.get(0).Conga_Agreement_Id__c != null) {
                recordId = iqAGRList.get(0).Conga_Agreement_Id__c;
            }
        }        
        return new SLT_Agreement_Clause().getAgreementClauseDetails(new Set<Id>{recordId}, new Set<String>{'Id', 'Name', 'Apttus__Action__c', 'Apttus__Clause__c', 'Apttus__Category__c', 'Apttus__Agreement__c', 'CreatedDate'}, 
                'Apttus__Agreement__c IN: agreementClauseIdset',null ).values();
    }

    /**
    * This method is used to check object`s edit permission.
    * @param String objectAPIName
    * @return Boolean
    */
    @AuraEnabled(cacheable=true)
    public static Boolean hasEditAccess(String objectAPIName) {
        return Schema.getGlobalDescribe().get(objectAPIName).getDescribe().isUpdateable();
    }
    
    /**
    * This method is used to check object`s delete permission.
    * @param String objectAPIName
    * @return Boolean
    */
    @AuraEnabled(cacheable=true)
    public static Boolean hasDeleteAccess(String objectAPIName) {
        return Schema.getGlobalDescribe().get(objectAPIName).getDescribe().isDeletable();
    }
}