/*
 * Version       : 1.0
 * Description   : This Apex class is selector layer for ContentFolder
 */
public class SLT_ContentFolder extends fflib_SObjectSelector {

    /**
    * This method used to get field list of sobject
    */

    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> {
                ContentFolder.Id,
                ContentFolder.ParentContentFolderId,
                ContentFolder.Name,
                ContentFolder.LastModifiedDate
        };
    }

    /**
    * This method used to set up type of sobject
    * @return  Schema.SObjectType
    */
    public Schema.SObjectType getSObjectType() {
        return ContentFolder.sObjectType;
    }

    /**
    * This method used to get ContentFolder by Id
    * @return  List<ContentFolder>
    */
    public List<ContentFolder> selectById(Set<ID> idSet) {
        return (List<ContentFolder>) selectSObjectsById(idSet);
    }


    /**
    * This method used to get  ContentFolder by name
    * @return  List<ContentFolder>
    */
    public List<ContentFolder> selectByName(Set<String> name) {
        return [SELECT Name, Id, ParentContentFolderId,LastModifiedDate,CreatedBy.Name FROM ContentFolder WHERE Name IN : name];
    }

    public List<ContentFolder> selectByName(Set<String> name, Set<id> ParentContentFolderId) {
        return [SELECT Name, Id, ParentContentFolderId,LastModifiedDate,CreatedBy.Name FROM ContentFolder WHERE Name IN : name AND ParentContentFolderId = : ParentContentFolderId];
    }

    /**
    * This method used to get  ContentFolder by ParentContentFolderId
    * @return  List<ContentFolder>
    */
    public List<ContentFolder> selectByParentContentFolderId(Set<id> ParentContentFolderId) {
        return [SELECT Name, Id, ParentContentFolderId, LastModifiedDate, CreatedBy.Name FROM ContentFolder WHERE ParentContentFolderId = : ParentContentFolderId];
    }

    public List<ContentFolder> selectAll() {
        return [SELECT Name, Id, ParentContentFolderId,LastModifiedDate,CreatedBy.Name FROM ContentFolder];
    }
    
    public List<ContentFolder> selectByParentContentFolderIdForCLM(Set<id> ParentContentFolderId) {
        return [SELECT Name, Id, ParentContentFolderId, LastModifiedDate, CreatedBy.Name FROM ContentFolder WHERE ParentContentFolderId = : ParentContentFolderId AND Name !=: CON_PEP.S_PEP_CLM_FOLDER];
    }
}