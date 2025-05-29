/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for ContentFolderMember
 */
public class SLT_ContentFolderMember extends fflib_SObjectSelector {
	
	/**
     * This method used to get field list of sobject
     */

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            ContentFolderMember.Id,
            ContentFolderMember.ParentContentFolderId
        };
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return ContentFolderMember.sObjectType;
    }
        
    /**
     * This method used to get  ContentFolderMember by ParentContentFolderId
     * @return  List<ContentFolderMember>
     */
    public List<ContentFolderMember> selectByParentContentFolderId(Set<id> ParentContentFolderId) {
         return [ Select Id, ParentContentFolderId, ChildRecordId,ChildRecord.Title, ChildRecord.FileExtension, ChildRecord.LastModifiedDate, CreatedBy.Name  FROM ContentFolderMember WHERE ParentContentFolderId = :ParentContentFolderId];
    }
    
    /**
     * This method used to get  ContentFolderMember by ChildRecordId
     * @return  List<ContentFolderMember>
     */
    public List<ContentFolderMember> selectByChildRecordId(Set<id> childRecordId) {
         return [ Select Id, ParentContentFolderId, ChildRecordId,ChildRecord.Title, ChildRecord.FileExtension, ChildRecord.LastModifiedDate, CreatedBy.Name  FROM ContentFolderMember WHERE ChildRecordId =:childRecordId];
    }
    
        /**
     * This method used to get  ContentFolderMember by ChildRecordId
     * @return  List<ContentFolderMember>
     */
    public List<ContentFolderMember> selectByChildRecordId(Set<String> childRecordId) {
         return [ Select Id, ParentContentFolderId, ChildRecordId,ChildRecord.Title, ChildRecord.FileExtension, ChildRecord.LastModifiedDate, CreatedBy.Name  FROM ContentFolderMember WHERE ChildRecordId IN :childRecordId];
    }
    
    
    
}