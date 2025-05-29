public class SLT_ContentDocument extends fflib_SObjectSelector{

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            ContentDocument.Id,
            ContentDocument.CreatedById,
            ContentDocument.CreatedDate,
            ContentDocument.IsArchived,
            ContentDocument.ArchivedDate,
            ContentDocument.IsDeleted,
            ContentDocument.OwnerId,
            ContentDocument.Title,
            ContentDocument.PublishStatus,
            ContentDocument.Description,
            ContentDocument.FileExtension,
            ContentDocument.FileType,
            ContentDocument.ContentSize,
            ContentDocument.ContentModifiedDate,
            ContentDocument.LastViewedDate,
            ContentDocument.LatestPublishedVersionId
        };
    }
    
    public Schema.SObjectType getSObjectType() {
        return ContentDocument.sObjectType;
    }
    
    public List<ContentDocument> selectById(Set<ID> idSet) {
        return (List<ContentDocument>) selectSObjectsById(idSet);
    }
    
    public List<ContentDocumentLink> getDocumentsOnContentIdAndLinkedId(List<ID> caseIdList, List<ID>contentIdList) {
        return (List<ContentDocumentLink>)Database.query('SELECT Id, Visibility, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId IN :contentIdList And LinkedEntityId IN :caseIdList');
    }

    public List<ContentDocumentLink> getDocumentsOnLinkedId(Set<ID> linkedEntityIds) {
        return (List<ContentDocumentLink>)Database.query('SELECT ContentDocument.Title FROM ContentDocumentLink WHERE LinkedEntityId IN :linkedEntityIds');
    }
    /**
    * This method use to get list of ContentDocument based on condition
    * @param Set<String> fields
    * @param String condition
    * @param Set<Id> docIds
    * @return List<ContentDocument>
    */
    public List<ContentDocument> selectById(Set<String> fields, String condition, Set<Id> docIds) {
        fflib_QueryFactory factory = newQueryFactory(true);
        factory.selectFields(fields);
        if(!String.isBlank(condition)) {
            factory.setCondition(condition);
        }
        return Database.query(factory.toSOQL());
    }
    
    public List<List<ContentDocument>> getSearchResultsContentDocument(String searchText,Integer rowLimit, Integer rowOffset){        
        /*String searchQuery = 'FIND :searchText IN ALL FIELDS RETURNING ContentDocument(Title,Id,FileType,ContentSize LIMIT :rowLimit OFFSET:rowOffset)';
        List<List<SObject>> results = search.query(searchquery);*/
        
        List<List<ContentDocument>> resultF = new List<List<ContentDocument>>();
        String likeValue = '%'+searchText+'%';
        List<ContentDocument> result = [SELECT Title,Id,FileType,ContentSize FROM ContentDocument Where Title LIKE :likeValue LIMIT :rowLimit OFFSET:rowOffset];
        resultF.add(result);
        return resultF;
    }
}