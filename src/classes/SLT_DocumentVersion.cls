public with sharing class SLT_DocumentVersion extends fflib_SObjectSelector {

    public SLT_DocumentVersion() {
        super(false, false, false);
    }
    
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Apttus__DocumentVersion__c.Id,
            Apttus__DocumentVersion__c.Apttus__Title__c,
            Apttus__DocumentVersion__c.Apttus__IsTransient__c,
            Apttus__DocumentVersion__c.Apttus__LatestVersionId__c,
            Apttus__DocumentVersion__c.Apttus__LatestVersion__c,
            Apttus__DocumentVersion__c.Apttus__LatestReviewCycleStatus__c
        };
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Apttus__DocumentVersion__c.sObjectType; 
    }

    /*
    * This method is use to query DocumentVersion on the basis of query to get the required details
    */
    public Apttus__DocumentVersion__c getDocumentVersionById(Id documentVersionId, Set<String> fieldSet) {
        return (Apttus__DocumentVersion__c) Database.query(
            newQueryFactory(true).selectFields(fieldSet).setCondition('Id =: documentVersionId').toSOQL());
    }

    /**
    * This method returns Apttus__DocumentVersion__c list on the basis of agreementIdSet   
    * @param Set<Id> agreementIds
    * @param Set<String> fieldSet
    * @return List<Apttus__DocumentVersion__c>
    */
    public List<Apttus__DocumentVersion__c> getDocumentVersionByAgreementId(Set<Id> agreementIds, Set<String> fieldSet) {
        fflib_QueryFactory queryFactory = newQueryFactory(true);
        if(!fieldSet.isEmpty()) {
            queryFactory.selectFields(fieldSet);
        }
        queryFactory.setCondition('Apttus__AgreementId__c IN: agreementIds');
        return (List<Apttus__DocumentVersion__c>) Database.query(queryFactory.toSOQL());
    }

    /**
     * This method returns Apttus__DocumentVersion__c list on the basis of Condition.
     * @param Set<Id> agreementIds
     * @param Set<String> fieldset
     * @param String condition
     * @return List<Apttus__DocumentVersion__c>
     */
    public List<Apttus__DocumentVersion__c> getDocumentVersionByConditions(Set<Id> agreementIds, Set<String> fieldSet, String condition) {
        fflib_QueryFactory factory = newQueryFactory(true);
        if(!fieldSet.isEmpty()) {
            factory.selectFields(fieldSet);
        }
        if(!String.isBlank(condition)) {
            factory.setCondition(condition);
        }
        return (List<Apttus__DocumentVersion__c>) Database.query(factory.toSOQL());  
    }
    
    /**
    * This method returns Apttus__DocumentVersion__c list on the basis of documentVersionIdSet   
    * @param Set<Id> dvIds
    * @param Set<String> fieldSetParent
    * @param Set<String> fieldSetChild
    * @return List<Apttus__DocumentVersion__c>
    */
    public List<Apttus__DocumentVersion__c> getDocumentVersionWithDetails(Set<Id> dvIds, Set<String> fieldSetParent, Set<String> fieldSetChild) {
        fflib_QueryFactory queryFactory = newQueryFactory(true);
        new SLT_Document_Version_Detail().addQueryFactorySubselect(queryFactory, 'Apttus__Document_Version_Details__r').selectFields(fieldSetChild)
        .setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING, false);
        queryFactory.setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING, false);
        return (List<Apttus__DocumentVersion__c>) Database.query(
            queryFactory.selectFields(fieldSetParent).setCondition('ID IN :dvIds').toSOQL());
    }
}