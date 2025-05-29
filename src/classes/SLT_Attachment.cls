/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for Attachment
 */
public class SLT_Attachment extends fflib_SObjectSelector {
    
    /**
     * constructor to initialise CRUD and FLS
     */
    public SLT_Attachment() {
        super(false, false, false);
    }
    
    /**
     * This method used to get field list of sobject
     * @return  List<Schema.SObjectField>
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
            Attachment.Id,
            Attachment.ParentId,
            Attachment.LastModifiedBy.Name,
            Attachment.Name,
            Attachment.Body,
            Attachment.BodyLength,
            Attachment.ContentType, 
            Attachment.Parent.RecordType.Name
        };
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return Attachment.sObjectType;
    }
    
    /**
     * This method used to get Attachment by Id
     * @return  List<Attachment>
     */
    public List<Attachment> selectById(Set<ID> idSet) {
        return (List<Attachment>) selectSObjectsById(idSet);
    }
    
    /**
    * This method used to get Task by WhatId and OwnerId
    * @return  Map<Id, User>
    */
    public List<Attachment> selectAttachmentFieldsById(Set<String> fieldSet, Set<Id> idSet) {
        return new List<Attachment>((List<Attachment>) Database.query(newQueryFactory(true).selectFields(fieldSet).setCondition('Id =: idSet').toSOQL()));
    }

    /**
    * This method used to get lists of attachment
    * @return  list
    */
    public List<Attachment> getAttachmentListByParentId(Set<String> fieldSet, Id parentId) {
        fflib_QueryFactory factory = newQueryFactory();
        factory.selectFields(fieldSet);
        factory.setCondition('ParentId = :parentId');
        return Database.query(factory.toSOQL());
    }

    /**
    * This method used to get lists of attachment
    * @return  list
    */
    public List<Attachment> getAttachmentListByParentIdSet(Set<String> fieldSet, Set<Id> parentIdSet) {
        fflib_QueryFactory factory = newQueryFactory();
        factory.selectFields(fieldSet);
        factory.setCondition('ParentId In :parentIdSet');
        return Database.query(factory.toSOQL());
    }
    
    /**
    * This method used to get lists of attachment
    * @return  list
    */
    public List<Attachment> getAttachments(Set<String> fields, String condition) {
        fflib_QueryFactory factory = newQueryFactory(true);
        factory.selectFields(fields);

        if(!String.isBlank(condition)) {
            factory.setCondition(condition);
        }
        return Database.query(factory.toSOQL());
    }

    /**
    * This method used to get lists of attachment
    * @param Set<Id> idSet
    * @param String condition
    * @param String parentRecordTypeName
    * @return  list
    */
    public List<Attachment> getAttachments(Set<Id> idSet, String condition, String parentRecordTypeName) {
        fflib_QueryFactory factory = newQueryFactory(true);
        if (String.isNotBlank(condition) && !idSet.isEmpty()) {
            condition += ' AND Id IN :idSet';
        } else if(!idSet.isEmpty()) {
            condition = 'Id IN :idSet';
        }
        if(String.isNotBlank(condition) && String.isNotBlank(parentRecordTypeName)) {
            condition += ' AND Parent.RecordType.Name =:parentRecordTypeName';
        } else if(String.isNotBlank(parentRecordTypeName)) {
            condition = 'Parent.RecordType.Name =:parentRecordTypeName';
        }
        if(String.isNotBlank(condition)) {
            factory.setCondition(condition);
        }
        return Database.query(factory.toSOQL());
    }
    
    /**
     * This method used to get lists of attachment
     * @return  list
     */
    public List<Attachment> getLatestAttachments(String condition) {
        return Database.query('SELECT Id, Name, Body, ContentType, IsPrivate, CreatedDate FROM Attachment WHERE ' + condition);
    }
	
    /**
     * This method used to get lists of attachment
     * @return  list
     */
    public List<Attachment> getLatestAttachments(String condition, Set<Id> parentIds) {
        return Database.query('SELECT Id, Name, Body, ContentType, IsPrivate, ParentId, CreatedDate FROM Attachment WHERE ' + condition);
    }
	
    public List<Attachment> selectAttachmentsByParentId(Set<Id> parentIds){
        return (List<Attachment>) Database.query('SELECT Id, Name, ContentType, Body, BodyLength, OwnerId, ParentId, CreatedDate, Description FROM Attachment WHERE ParentId IN :parentIds');
    }

    /**
    * This method used to get lists of attachment
    * @param Set<String> fields
    * @param Set<Id> attachmentIds
    * @param Set<Id> parentIds
    * @param String Condition
    * @return  list
    */
    public List<Attachment> getOldAttachmentsForParent(Set<String> fields, Set<Id> attachmentIds, 
        Set<Id> parentIds, String condition) {
        fflib_QueryFactory factory = newQueryFactory(true);
        if(String.isNotBlank(condition)) {
            factory.setCondition(condition);
        }
        return Database.query(factory.toSOQL());
    }
    public List<Attachment> selectAttachmentsByCondition(Set<String> fieldSet, Id recordId, String condition, DateTime refDate){
        fflib_QueryFactory factory = newQueryFactory(true);
        factory.selectFields(fieldSet);

        if(!String.isBlank(condition)) {
            factory.setCondition(condition);
        }
        return Database.query(factory.toSOQL());
    }
}
