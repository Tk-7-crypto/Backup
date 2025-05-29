/**
* Selector class for ContentDocumentLink 
*/
public class SLT_ContentDocumentLink extends fflib_SObjectSelector {
    /**
    * constructor to initialize CRUD and FLS
    */
    public SLT_ContentDocumentLink() {
        super(false, true, true);
    }
    
    /**
    * constructor to initialize CRUD and FLS
    */
    public SLT_ContentDocumentLink(Boolean enforceCRUD, Boolean enforceFLS) {
        super(false, enforceCRUD, enforceFLS);
    }

    /**
    * overriding getOrderBy
    */    
    public override String getOrderBy() {
        return 'IsDeleted DESC';
    }
    
    /**
    * This method used to set up type of sobject.
    */
    public Schema.SObjectType getSObjectType() {
        return ContentDocumentLink.sObjectType;
    }
    
    /**
    * This method gives the list of SObjectField of ContentDocumentLink object.
    */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            ContentDocumentLink.Id,
            ContentDocumentLink.ContentDocumentId,
            ContentDocumentLink.LinkedEntityId,
            ContentDocumentLink.IsDeleted,
            ContentDocumentLink.ShareType,
            ContentDocumentLink.Visibility
        };
    }
    
    /**
    * getContentDocumentLinkDetailByContentDocumentId method fetches the detail of ContentDocumentLink on basis of ContentDocument Id.
    * @param  ContentDocumentIds is the set of Ids of ContentDocument.
    * @param  fieldSet is the set of fields 
    * @return List<ContentDocumentLink> 
    */
    public List<ContentDocumentLink> getContentDocumentLinkDetailByContentDocumentId(Set<Id> ContentDocumentIds, Set<String> fieldSet) {
        fflib_QueryFactory queryFactory = newQueryFactory(true);
        return (
            List<ContentDocumentLink>) Database.query(queryFactory.selectFields(fieldSet)
                .setCondition('ContentDocumentId IN: ContentDocumentIds').toSOQL()
        );
    }
    
    public List<ContentDocumentLink> getContentDocumentBasedOnLinkedEntity(Set<Id> linkedEntityIds){
        return Database.query('SELECT Id, ContentDocumentId, LinkedEntityId, ShareType, Visibility FROM ContentDocumentLink WHERE LinkedEntityId IN :linkedEntityIds');
    }
    
    /**
    * fetch ContentDocument by LinkedEntityId.
    * @param  LinkedEntityId and fieldSet is the set of fields
    * @return List<ContentDocumentLink>
    */
    public List<ContentDocumentLink> getContentDocumentLinkDetailByLinkedEntityId(Id linkedEntityId, Set<String> fieldSet) {
        return (List<ContentDocumentLink>) Database.query(
            newQueryFactory(true).selectFields(fieldSet).setCondition('LinkedEntityId = :linkedEntityId').toSOQL()); 
    }
    public List<ContentDocumentLink> getContentDocumentBasedOnLinkedEntityids(Set<Id> linkedEntityIds){
        return Database.query('SELECT Id, ContentDocumentId, LinkedEntityId, ShareType, Visibility FROM ContentDocumentLink WHERE ContentDocumentId IN :linkedEntityIds');
    }
    public List<ContentDocumentLink> getContentDocumentLinkByLinkedEntityAndTitle(Set<String> linkedEntityIdList, String titleRegex, Set<String> fieldSet){
        return (List<ContentDocumentLink>) Database.query(
            newQueryFactory(true)
            .selectFields(fieldSet)
            .setCondition('LinkedEntityId = :linkedEntityIdList AND ContentDocument.Title LIKE :titleRegex')
            .toSOQL()
        );
    }
    
    /**
    * fetch ContentDocument by Condition with Limit and Order by Clause.
    * @param  Set<String> fields is the set of fields
    * @param Set<Id> linkedEntityIds
    * @param Integer limitRecords
    * @param String OrderBy
    * @return List<ContentDocumentLink>
    */
    public List<ContentDocumentLink> getCDLByLinkedEntityWithLimitAndOrder(Set<String> fields, Set<Id> linkedEntityIds,
        Integer limitRecords, String OrderBy ) {
        fflib_QueryFactory factory = newQueryFactory(true);
        factory.selectFields(fields);

        factory.setCondition('LinkedEntityId IN :linkedEntityIds');
            
        if (limitRecords>0) {
            factory.setLimit(limitRecords);
        }
        if(!String.isBlank(OrderBy)) {
            factory.addOrdering(OrderBy, fflib_QueryFactory.SortOrder.DESCENDING);
        }
        return Database.query(factory.toSOQL());
    }
}
