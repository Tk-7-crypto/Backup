public with sharing class SLT_Document extends fflib_SObjectSelector{
    public SLT_Document() {
        super(false, false, false);
    }

    /**
    * This method used to get field list of sobject
    * @return  List<Schema.SObjectField>
    */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Document.Id,
            Document.Name,
            Document.body,
            Document.contenttype,
            Document.type,
            Document.DeveloperName
        };
    }

    /**
    * This method used to set up type of sobject
    * @return  Schema.SObjectType
    */
    public Schema.SObjectType getSObjectType() {
        return Document.sObjectType;
    }

    /**
    * This method used to get Document by Id
    * @return  List<Document>
    */
    public List<Document> selectById(Set<ID> idSet) {
        return (List<Document>) selectSObjectsById(idSet);
    }

    /**
    * This method used to get ContentVersion by Id
    * @return  List<ContentVersion>
    */
    public List<Document> selectUserByName(String name) {
        return Database.query('SELECT Id, Name, Body, ContentType, Type, DeveloperName from Document WHERE Name LIKE \'' + name + '\'');
    }
    
    /**
    * This method used to get Document record by DevloperName
    * @param String devName
    * @return  List<Document>
    */
    public List<Document> selectByDeveloperName(String devName) {
        return Database.query('SELECT Id FROM Document WHERE DeveloperName = : devName');
    }
}