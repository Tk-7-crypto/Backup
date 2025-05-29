/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Knowledge__kav
 */
 
public class SLT_Knowledge extends fflib_SObjectSelector {
    /**
     * This method used to get field list of sobject
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            Knowledge__kav.Id,
            Knowledge__kav.Case_CategorizationId__c,
            Knowledge__kav.ProductName__c,
            Knowledge__kav.SubType1__c,
            Knowledge__kav.SubType2__c,
            Knowledge__kav.SubType3__c,
            Knowledge__kav.PublishStatus,
            Knowledge__kav.Pillar__c,
            Knowledge__kav.Title,
            Knowledge__kav.Content__c,
            Knowledge__kav.Question__c,
            Knowledge__kav.Answer__c,
            Knowledge__kav.Article_Chapter__c,
            Knowledge__kav.RecordTypeId,
            Knowledge__kav.KnowledgeArticleId,
            Knowledge__kav.LastPublishedDate
        };
    }
    
     /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Knowledge__kav.sObjectType;
    }
    
    /**
     * This method used to get Knowledge by Id
     * @return  List<Knowledge__kav>
     */
    public List<Knowledge__kav> selectById(Set<ID> idSet) {
        return (List<Knowledge__kav>) selectSObjectsById(idSet);
    }
    
    /**
     * This method used to get Knowledge by topicId where article is visible on CHS and Pulished;
     * @return  List<Knowledge__kav>
     */
    public List<Knowledge__kav> selectByTopicId(String topicId) {
        return (List<Knowledge__kav>) [select Id, KnowledgeArticleId, Article_Chapter__c, PublishStatus, VersionNumber, IsLatestVersion, IsVisibleInApp, IsVisibleInPkb, IsVisibleInCsp, IsVisibleInPrm, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Language, Title, UrlName, CurrencyIsoCode, ArchivedDate, ArchivedById, Summary, ArticleNumber, FirstPublishedDate, LastPublishedDate, ArticleCreatedDate, SourceId, RecordTypeId, Answer__c, Content__c, L1Answer__c, L1Content__c, Question__c, ReviewDate__c, Test__c, Article_Link__c, SubType3__c, ProductName__c, SubType1__c, SubType2__c  from Knowledge__kav where id in (select EntityId from TopicAssignment where TopicId =: topicId and EntityType ='Knowledge') and PublishStatus ='Online' and IsVisibleInCsp = true  order By Article_Chapter__c , LastPublishedDate desc ];
    }
    
    /**
     * This method used to get Knowledge by topicId;
     * @return  List<Knowledge__kav>
     */
    public List<Knowledge__kav> selectByTopicId2(String topicId) {
        return (List<Knowledge__kav>) [select Id, KnowledgeArticleId, Article_Chapter__c, PublishStatus, VersionNumber, IsLatestVersion, IsVisibleInApp, IsVisibleInPkb, IsVisibleInCsp, IsVisibleInPrm, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Language, Title, UrlName, CurrencyIsoCode, ArchivedDate, ArchivedById, Summary, ArticleNumber, FirstPublishedDate, LastPublishedDate, ArticleCreatedDate, SourceId, RecordTypeId, Answer__c, Content__c, L1Answer__c, L1Content__c, Question__c, ReviewDate__c, Test__c, Article_Link__c, SubType3__c, ProductName__c, SubType1__c, SubType2__c  from Knowledge__kav where id in (select EntityId from TopicAssignment where TopicId =: topicId and EntityType ='Knowledge') and PublishStatus ='Online' order By Article_Chapter__c , LastPublishedDate desc ];
    }
    
    /**
     * This method used to get Knowledge by productName;
     * @return  List<Knowledge__kav>
     */
    public List<Knowledge__kav> selectByProductName(String productName) {
        return (List<Knowledge__kav>) [select Id, KnowledgeArticleId, Article_Chapter__c, PublishStatus, VersionNumber, IsLatestVersion, IsVisibleInApp, IsVisibleInPkb, IsVisibleInCsp, IsVisibleInPrm, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Language, Title, UrlName, CurrencyIsoCode, ArchivedDate, ArchivedById, Summary, ArticleNumber, FirstPublishedDate, LastPublishedDate, ArticleCreatedDate, SourceId, RecordTypeId, Answer__c, Content__c, L1Answer__c, L1Content__c, Question__c, ReviewDate__c, Test__c, Article_Link__c, SubType3__c, ProductName__c, SubType1__c, SubType2__c  from Knowledge__kav where ProductName__c =: productName and PublishStatus ='Online' and IsMasterLanguage = true order By Article_Chapter__c , LastPublishedDate desc ];
    }
    
    public List<Knowledge__kav> selectByCategory(String category,String partnerType,String pillar,Id userAccountId,Boolean salesCollateral)
    {
        String query='SELECT Id,(select id from ContentDocumentLinks), Product__r.Community_Topic__r.Name, KnowledgeArticleId, Article_Chapter__c, Title, UrlName, Summary, ArticleNumber, RecordTypeId,LastPublishedDate,VersionNumber,End_date_of_display_as_new_or_updated__c,Language,IsMasterLanguage  FROM Knowledge__kav Where PublishStatus =\'Online\' AND Partner_Type__c INCLUDES ('+partnerType+') AND Pillar__c IN ('+pillar+') AND Product__r.Community_Topic__r.Name  =\''+category+'\' AND (IsVisibleInPrm=true OR IsVisibleInCsp = true) AND Id IN  (SELECT Knowledge__c FROM Knowledge_Account_RelationShip__c where Account__c =\'' + userAccountId +'\' )';        
        return (List<Knowledge__kav>)Database.query(query);
    }
    
    public List<Knowledge__kav> selectByCategoryAndAccount(String category,String partnerType,String pillar,Id userAccountId,Boolean salesCollateral)
    {
        String query='SELECT Id,(select id from ContentDocumentLinks), Product__r.Community_Topic__r.Name, KnowledgeArticleId, Article_Chapter__c, Title, UrlName, Summary, ArticleNumber, RecordTypeId,LastPublishedDate,VersionNumber,End_date_of_display_as_new_or_updated__c,Language,IsMasterLanguage  FROM Knowledge__kav Where PublishStatus =\'Online\' AND Partner_Type__c INCLUDES ('+partnerType+') AND Pillar__c IN ('+pillar+') AND Product__r.Community_Topic__r.Name  =\''+category+'\' AND (IsVisibleInPrm=true OR IsVisibleInCsp = true) AND Id NOT IN  (SELECT Knowledge__c FROM Knowledge_Account_RelationShip__c where Account__c =\'' + userAccountId +'\' )';        
        return (List<Knowledge__kav>)Database.query(query);      
    }

    public List<Knowledge__kav> selectByArticleId(String articleId)
    {
        return [SELECT Id, Case_CategorizationId__c, ProductName__c, SubType1__c, SubType2__c, SubType3__c, PublishStatus, Pillar__c, Title, Content__c, Question__c, Answer__c, RecordTypeId, LastPublishedDate, KnowledgeArticleId, PRM_Sales_Collateral__c FROM Knowledge__kav WHERE ID=:articleId];        
    }

    public List<Knowledge__kav> getArticlesByKnowledgeArticleIds(Set<String> knowledgeArticleIds){
        return (List<Knowledge__kav>)Database.query('SELECT Id, Title, UrlName, KnowledgeArticleId, Article_Chapter__c, ProductName__c, Language, IsMasterLanguage FROM Knowledge__kav WHERE KnowledgeArticleId IN :knowledgeArticleIds AND PublishStatus =\'Online\'');
    }

    public List<List<SObject>> getSearchResults(String searchText,Set<String> pillar,String accountId,Set<String> ids, String productName){
        List<List<SObject>> results= [FIND :searchText IN ALL FIELDS RETURNING
                                             Knowledge__kav(Id, ArticleNumber, Title, LastPublishedDate, ProductName__c, SubType1__c, SubType2__c, SubType3__c, UrlName, Contact_Role__c WHERE ProductName__c = :productName AND Product__c in :ids AND Pillar__c in :pillar AND PublishStatus ='Online' AND Language = 'en_US' AND IsVisibleInPRM = true AND Id in  (select Knowledge__c from Knowledge_Account_RelationShip__c where Account__c =: accountId)),
                                             Knowledge__kav(Id, ArticleNumber, Title, LastPublishedDate, ProductName__c, SubType1__c, SubType2__c, SubType3__c, UrlName, Contact_Role__c WHERE ProductName__c = :productName AND Product__c in :ids AND Pillar__c in :pillar AND PublishStatus ='Online' AND Language = 'en_US' AND IsVisibleInPRM = true AND Id NOT in  (select Knowledge__c from Knowledge_Account_RelationShip__c)) LIMIT 10];
        return results;
    }
   
    /**
    * This method is used to get list of Knowledge__kav
    * @return  list
    */
    public List<Knowledge__kav> getArticlesById(Set<ID> idSet, Set<String> fieldSet) {
        String fields = String.join(new List<String>(fieldSet), ', ');
        String selectQuery = 'SELECT ' + fields + ' FROM Knowledge__kav WHERE ';
        return (List<Knowledge__kav>)Database.query(selectQuery + 'Id IN :idSet');
    }

    public List<Knowledge__kav> getArticlesToUpdate(Set<String> knowId)
    {
        return (List<Knowledge__kav>)Database.query('SELECT ID, ArticleNumber,IsVisibleInCsp,IsVisibleInPrm,Partner_Type__c FROM Knowledge__kav WHERE ArticleNumber IN : knowId AND PublishStatus = \'Draft\'');
    }


    /**
    * This method is used to get list of translated Knowledge__kav
    * @return  list
    */
    public List<Knowledge__kav> getTranslationsByKnowledgeId(Set<Id> knowledgeIdSet, Set<String> fieldSet) {
        String fields = String.join(new List<String>(fieldSet), ', ');
        String query = 'SELECT ' + fields + ' FROM Knowledge__kav WHERE KnowledgeArticleId IN : knowledgeIdSet AND IsMasterLanguage = FALSE';
        return (List<Knowledge__kav>)Database.query(query);
    }

    public List<List<SObject>> getSearchResultsPRM1(String searchText,Set<String> pillar,String accountId,Set<String> ids, String partnerType, Integer rowLimit, Integer rowOffset){        
        String searchQuery = 'FIND :searchText IN ALL FIELDS RETURNING Knowledge__kav(Id, ArticleNumber, Title, LastPublishedDate, ProductName__c, SubType1__c, SubType2__c, SubType3__c, UrlName, Contact_Role__c WHERE Partner_Type__c INCLUDES ('+partnerType+') AND Pillar__c IN :pillar AND Product__c in :ids AND PublishStatus =\'Online\' AND IsVisibleInPrm = true  AND Language = \'en_US\' AND Id in  (select Knowledge__c from Knowledge_Account_RelationShip__c where Account__c= '+'\''+accountId+'\''+') LIMIT :rowLimit OFFSET:rowOffset)';
        List<List<SObject>> results = search.query(searchquery);
        return results;
    }
    
    public List<List<SObject>> getSearchResultsPRM2(String searchText,Set<String> pillar,String accountId,Set<String> ids, String partnerType, Integer rowLimit, Integer rowOffset){
        String searchQuery = 'FIND :searchText IN ALL FIELDS RETURNING Knowledge__kav(Id, ArticleNumber, Title, LastPublishedDate, ProductName__c, SubType1__c, SubType2__c, SubType3__c, UrlName, Contact_Role__c WHERE Partner_Type__c INCLUDES ('+partnerType+') AND Product__c in :ids AND Pillar__c in :pillar AND PublishStatus =\'Online\' AND IsVisibleInPrm = true  AND Language = \'en_US\' AND Id NOT in  (select Knowledge__c from Knowledge_Account_RelationShip__c) LIMIT :rowLimit OFFSET:rowOffset)';
        List<List<SObject>> results = search.query(searchquery);
        return results;
    }
}