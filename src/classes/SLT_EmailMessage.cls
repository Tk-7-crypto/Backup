public class SLT_EmailMessage  extends fflib_SObjectSelector {
    
    /**
     * constructor to initialise CRUD and FLS
     */
    public SLT_EmailMessage() {
        super(false, true, true);
    }
    
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>();
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return EmailMessage.sObjectType;
    }
    
    /**
     * This method used to get EmailMessage by Id
     * @return  Map<Id, User>
     */
    
    public List<EmailMessage> selectById(Set<ID> idSet, Set<String> fieldSet) {
        return (List<EmailMessage>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id in :idSet').toSOQL());
    }
    
    
    public List<EmailMessage> getEmailRecordsById(Set<Id> emailIds){
        return (List<EmailMessage>)Database.query('SELECT Id, ParentId,Parent.RecordTypeName__c, CreatedDate, MessageDate, Incoming, Subject, TextBody, HasAttachment, ToAddress, FromAddress FROM EmailMessage WHERE Id IN :emailIds');
    }
    
    public List<EmailMessage> getCaseAttachmentListOnEmails(Set<Id> emailIds){
        return (List<EmailMessage>)Database.query('SELECT Incoming, ParentId, Parent.Attachments__c, (SELECT Id, BodyLength, ContentType FROM Attachments) FROM EmailMessage WHERE Id IN :emailIds');
    }
    
    public List<AggregateResult> getCountOnParentIds(Set<Id> parentIds){
        return (List<AggregateResult>)Database.query('SELECT COUNT(Id) Total, ParentId CaseId FROM EmailMessage WHERE ParentId IN :parentIds GROUP BY ParentId');
    }

    public List<EmailMessage> getEmailsByParendIds(Set<Id> parentIds){
        return (List<EmailMessage>)Database.query('SELECT Id,ToAddress,FromAddress,Subject,Incoming,MessageDate,ParentId,Status FROM EmailMessage WHERE ParentId IN :parentIds AND parentId != null');
    }
    
    public List<EmailMessage> getEmailTextBodyByParendIds(Set<Id> parentIds){
        return (List<EmailMessage>)Database.query('SELECT Id,ParentId,TextBody,ToAddress,FromAddress,CcAddress,HtmlBody FROM EmailMessage WHERE ParentId IN :parentIds AND parentId != null AND Incoming = false AND Status=\'3\' order by LastModifiedDate desc LIMIT 1');
    }
}