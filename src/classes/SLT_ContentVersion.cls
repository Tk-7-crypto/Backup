/*  ===============================================================================
        Created:        Jyoti Agrawal
        Date:           04/08/2019
        Version       : 1.0
        Description   : This Apex class is selector layer for ContentVersion
    ===============================================================================
*/

public with sharing class SLT_ContentVersion extends fflib_SObjectSelector{
    public SLT_ContentVersion() {
	    super(false, false, false);
	}

    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            ContentVersion.Id,
            ContentVersion.Title,
            ContentVersion.VersionData,
            ContentVersion.FileExtension,
            ContentVersion.FileType,
            ContentVersion.ContentSize,
            ContentVersion.ContentDocumentId,
            ContentVersion.ContentModifiedDate,
            ContentVersion.VersionNumber,
            ContentVersion.PathOnClient   
        };
    }

    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return ContentVersion.sObjectType;
    }

    /**
    * This method used to get Document by Id
    * @return  List<ContentVersion>
    */
    public List<ContentVersion> selectById(Set<ID> idSet) {
        return (List<ContentVersion>) selectSObjectsById(idSet);
    }
    
    /**
     * This method used to get ContentVersion by DocumentId
     * @return  List<ContentVersion>
     */
    public List<ContentVersion> getContentVersionByDocumentIds(Set<ID> documentIds, Set<String> fieldSet) {
            return (List<ContentVersion>) Database.query(
                newQueryFactory(false).selectFields(fieldSet).setCondition('ContentDocumentId in: documentIds').toSOQL());
    }

    /**
     * This method used to get ContentVersion by ContentDocumentId
     * @return  List<ContentVersion>
     */
    public List<ContentVersion> getContentVersionByContentDocumentId(Set<Id> setContentDocumentId){
        return (List<ContentVersion>) Database.query(newQueryFactory(true).setCondition('ContentDocumentId IN: setContentDocumentId').toSOQL());
    }
    public List<ContentVersion> getContentVersionFromDocumentId(Set<String> contentDocumentIdList, Set<String> fieldSet){
        return (List<ContentVersion>) Database.query(
            newQueryFactory(true)
            .selectFields(fieldSet)
            .setCondition('ContentDocumentId = :contentDocumentIdList')
            .setOrdering(ContentVersion.CreatedDate, fflib_QueryFactory.SortOrder.DESCENDING, true)
            .toSOQL()
        );
    }
    
    /**
     * This method used to get ContentVersion by Ids and a condition
     * @param String condition
     * @param Set<Id> docIds
     * @return  List<ContentVersion>
     */
    public List<ContentVersion> getContentVersions(String condition, Set<Id> docIds) {
        fflib_QueryFactory factory = newQueryFactory(true);
        if(String.isNotBlank(condition)) {
            factory.setCondition(condition);
        }
        return Database.query(factory.toSOQL());
    }
    
    /**
    * This method is used to get Content Versions by Id
    * @param Set<Id> idSet
    * @param Set<String> fieldSet
    * @return List<ContentVersion>
    */ 
    public List<ContentVersion> getContentVersionByIds(Set<Id> idSet, Set<String> fieldSet) {
        return (List<ContentVersion>) Database.query(newQueryFactory(false).selectFields(fieldSet).setCondition('Id IN: idSet').toSOQL());
    }
    /**
    * This method is used to get Content Versions by deve
    * @param Set<Id> fieldSet
    * @return List<ContentVersion>
    */ 
    public List<ContentVersion> getContentVersionByCondition(Set<String> fieldSet, String Condition) {
        fflib_QueryFactory queryFactory = newQueryFactory(true);
        queryFactory.selectFields(fieldSet);
        queryFactory.setCondition(Condition);
        return (List<ContentVersion>) Database.query(queryFactory.toSOQL());
    }

    /**
    * This method is used to get Content Versions by deve
    * @param Set<String> fieldSet
    * @param String Condition
    * @param Set<Id> IdSet
    * @return List<ContentVersion>
    */
    public List<ContentVersion> getContentVersionByCondition(Set<String> fieldSet, String Condition, Set<Id> IdSet) {
        fflib_QueryFactory queryFactory = newQueryFactory(true);
        queryFactory.selectFields(fieldSet);
        if(!String.isBlank(condition)) {
            queryFactory.setCondition(Condition);
        }
        return (List<ContentVersion>) Database.query(queryFactory.toSOQL());
    }
}