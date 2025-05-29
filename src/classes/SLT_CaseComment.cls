/*
 * Version       : 1.0
 * Description   : This Apex class is selector for CaseComment
 */
public class SLT_CaseComment extends fflib_SObjectSelector {
    
    /**
     * This method used to get field list of sobject
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            CaseComment.Id,
            CaseComment.ParentId,
            CaseComment.IsPublished,
            CaseComment.CommentBody,
            CaseComment.CreatedDate
        };
    }
    
    /**
     * This method used to set up type of sobject
     * @return  Schema.SObjectType
     */
    public Schema.SObjectType getSObjectType() {
        return CaseComment.sObjectType;
    }
    
    /**
     * This method used to get CaseComment by Id
     * @return  List<CaseComment>
     */
    public List<CaseComment> selectById(Set<ID> idSet) {
        return (List<CaseComment>) selectSObjectsById(idSet);
    }
    
    /**
     * This method used to get CaseComment by parentId
     * @return  List<CaseComment>
     */
    public List<CaseComment> selectByParentId(Set<ID> parentId) {
         return [SELECT Id, ParentId, IsPublished, CommentBody, CreatedById, CreatedDate, SystemModstamp, CreatedBy.Name, LastModifiedBy.Name, LastModifiedDate, LastModifiedById, IsDeleted FROM CaseComment  where ParentId=:ParentId order by CreatedDate desc];
    }
    
}