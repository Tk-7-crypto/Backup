public class SLT_ContentWorkspace extends fflib_SObjectSelector {
    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField>{
            ContentWorkspace.Id,
            ContentWorkspace.Name,
            ContentWorkspace.RootContentFolderId
        };
    }

    public Schema.SObjectType getSObjectType() {
        return ContentWorkspace.sObjectType;
    }

    public List<ContentWorkspace> selectByName( Set<String> libraryName) {
    	return[SELECT Id, Name, RootContentFolderId FROM ContentWorkspace WHERE Name =:libraryName];
    }

    public List<ContentWorkspace> selectByRootContentFolderId( Set<id> rootContentFolderId) {
    	return[SELECT Id, Name, RootContentFolderId FROM ContentWorkspace WHERE RootContentFolderId =:rootContentFolderId];
    }
}