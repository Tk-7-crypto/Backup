/**
* Selector class for Apttus__DocumentVersionDetail__c object
*/
public class SLT_Document_Version_Detail extends fflib_SObjectSelector {
    
    /**
    * constructor to initialize CRUD and FLS
    */
    public SLT_Document_Version_Detail() {
        super(false, true, true);
    }

    /**
    * constructor to initialize CRUD and FLS
    */
    public SLT_Document_Version_Detail(Boolean enforceCRUD, Boolean enforceFLS) {
        super(false, enforceCRUD, enforceFLS);
    }
    
    /**
    * This method used to set up type of sobject.
    */
    public Schema.SObjectType getSObjectType() {
        return Apttus__DocumentVersionDetail__c.sObjectType;
    }
    
    /**
    * This method gives the list of SObjectField of Apttus__DocumentVersionDetail__c object.
    */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Apttus__DocumentVersionDetail__c.Id, Apttus__DocumentVersionDetail__c.Apttus__DocumentVersionId__c,
            Apttus__DocumentVersionDetail__c.Apttus__ContentVersionId__c, Apttus__DocumentVersionDetail__c.Apttus__DocumentInfo__c,
            Apttus__DocumentVersionDetail__c.Name, Apttus__DocumentVersionDetail__c.Apttus__Title__c, Apttus__DocumentVersionDetail__c.Apttus__Action2__c, 
            Apttus__DocumentVersionDetail__c.Apttus__View__c, Apttus__DocumentVersionDetail__c.Apttus__ContentId__c, Apttus__DocumentVersionDetail__c.Apttus__FileType__c
        };
    }
    
    /**
    * This method returns Apttus__DocumentVersionDetail__c list on the basis of agreementIdSet   
    * @param Set<Id> agreementIds
    * @param Set<String> fieldSet
    * @return List<Apttus__DocumentVersionDetail__c>
    */
    public List<Apttus__DocumentVersionDetail__c> getDocumentVersionDetailByAgreementId(Set<Id> agreementIds, Set<String> fieldSet) {
        fflib_QueryFactory queryFactory = newQueryFactory(true);
        if(!fieldSet.isEmpty()) {
            queryFactory.selectFields(fieldSet);
        }
        queryFactory.setCondition('Apttus__DocumentVersionId__r.Apttus__AgreementId__c IN: agreementIds');
        queryFactory.setOrdering(Apttus__DocumentVersionDetail__c.CreatedDate, fflib_QueryFactory.SortOrder.descending, true);
        return (List<Apttus__DocumentVersionDetail__c>) Database.query(queryFactory.toSOQL());
    }
    
    /*
    * This method is used to query document version details on the basis of id
    * @param Id documentVersionDetailId  
    * @param Set<String> fieldSet
    * @return Apttus__DocumentVersionDetail__c
    */
    public Apttus__DocumentVersionDetail__c getDocumentVersionDetailById(Id documentVersionDetailId, Set<String> fieldSet) {
        return (Apttus__DocumentVersionDetail__c)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id =: documentVersionDetailId').toSOQL());
    }           
    
    /**
    * This method is used to fetch document version detail by ids
    * @param Set<String> fieldSet
    * @param Set<Id> idSet
    * @param String condition
    * @return List<Apttus__DocumentVersionDetail__c>
    */ 
    public List<Apttus__DocumentVersionDetail__c> getDocumentVersionDetailByIds(Set<String> fieldSet, Set<Id> idSet, String condition) {
        return (List<Apttus__DocumentVersionDetail__c>) Database.query(newQueryFactory(true)
            .selectFields(fieldSet).setCondition(condition).toSOQL());     
    }
}