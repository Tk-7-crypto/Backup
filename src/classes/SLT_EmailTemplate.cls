public without sharing class SLT_EmailTemplate extends fflib_SObjectSelector{
    /**
    * constructor to initialise CRUD and FLS
    */
    public SLT_EmailTemplate() {
        super(false, false, false);
    }

    /**
    * This method used to get field list of sobject
    * @return  List<Schema.SObjectField>
    */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
        EmailTemplate.Id,
        EmailTemplate.Name
        };
    }

    /**
    * This method used to set up type of sobject
    * @return  Schema.SObjectType
    */
    public Schema.SObjectType getSObjectType() {
        return EmailTemplate.sObjectType;
    }

    /**
    * This method used to get EmailTemplate by Id
    * @return  List<EmailTemplate>
    */
    public List<EmailTemplate> selectById(Set<ID> idSet) {
        return (List<EmailTemplate>) selectSObjectsById(idSet);
    }

    /**
    * This method used to get Email Template by developer name
    * @return  List<EmailTemplate>
    */
    public List<EmailTemplate> selectEmailDTemplateByDeveloperName(String developerName, Set<String> fieldSet) {
        return (List<EmailTemplate>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('developerName =: developerName ').toSOQL());
    }

    /**
    * This method used to get EmailTemplate by Id
    * @return  List<EmailTemplate>
    */
    public List<EmailTemplate> selectEmailDTemplateByName(String Name, Set<String> fieldSet) {
        return (List<EmailTemplate>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Name =: Name ').toSOQL());
    }
    
    /**
    * This method used to get Email Templates by set of developer name
    * @return  List<EmailTemplate>
    */
    public List<EmailTemplate> selectEmailTemplatesByDeveloperNames(Set<String> developerNames) {
        return Database.query('Select Id, DeveloperName from EmailTemplate where DeveloperName in :developerNames limit 10');
    }
        /**
    * This method used to get Email Template by templateId
    * @author Anup Kage  | 5/21/2020 
    * @param recId 
    * @return EmailTemplate 
    **/
    public EmailTemplate selectEmailTemplatesById(String recId) {
        return Database.query('SELECT Id, body, Subject,HtmlValue, Name FROM EmailTemplate WHERE Id =: recId');
    }
    /**
    * This method used to get Email Templates by folder Id 
    * @author Anup Kage  | 5/21/2020 
    * @param folderId 
    * @return List<EmailTemplate> 
    **/
    public List<EmailTemplate> selectEmailTemplatesByFolderId(String folderName, String templateName) {
        return (List<EmailTemplate>)Database.query('SELECT Id, Name, DeveloperName FROM EmailTemplate WHERE Name LIKE :templateName AND folder.Name =: folderName '+ 
        ' ORDER BY Name LIMIT 10');
    }
    
    /**
    * This method used to get EmailTemplates by set of developer names and condition
    * @return  List<EmailTemplate>
    */
    public List<EmailTemplate> selectEmailTemplatesByCondition(Set<String> developerNames, Set<String> fieldSet, String condition) {
        return (List<EmailTemplate>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition(condition).toSOQL());
    }

    /**
    * This method used to get EmailTemplates and it's fields on basis of developer names
    * @return  List<EmailTemplate>
    */
    public List<EmailTemplate> selectEmailTemplatesByDeveloperNameAndFields(Set<String> developerNames, Set<String> fieldSet) {
        return (List<EmailTemplate>)Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('DeveloperName IN :developerNames').toSOQL());
    }
}