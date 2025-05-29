/*
* Version       : 1.0
* Description   : Apex Controller for PortalFile component.
*/
public with sharing class CNT_PEP_PortalFile {
    
    @AuraEnabled
    public static List<ContentFolder> getFolders(){
        
        return new SLT_ContentFolder().selectAll();
    }
/*
     * Return List of Account for current user
     */
    @AuraEnabled
    public static List<Account> getUserAccount(){
        List<User> users = new SLT_User().selectById(new Set<Id> {userInfo.getUserId()});
        List<Account> accounts = new SLT_Account().selectById(new Set<Id> {users[0].AccountId});
        return accounts;        
    }

    /*
     * Return List of ContentFolder by Fodler Name
     * @id 
     */
    @AuraEnabled
    public static List<ContentFolder> getFolderByFolderNameForCurrentUser(String folderName){
        List<ContentFolder> cf;
        List<ContentWorkspace> cws = new SLT_ContentWorkspace().selectByName(new Set<String>{'Community Lib'});
        if(cws.size() > 0){
            cf = new SLT_ContentFolder().selectByName(new Set<String>{folderName}, new Set<Id> {cws[0].RootContentFolderId});
        }
        return cf;
    }
	

     /*
     * Return List of ContentFolder by topic id
     * @id 
     */
    @AuraEnabled
    public static List<ContentFolder> getFolderByTopicId(String categoryName){
        List<ContentFolder> cf=new List<ContentFolder>();
        List<ContentWorkspace> cws = new SLT_ContentWorkspace().selectByName(new Set<String>{'Community Lib'});
        if(cws.size() > 0){
            cf = new SLT_ContentFolder().selectByName(new Set<String>{categoryName});
        }
        return cf;
    }
    
    /*
     * Return List of ContentFolder for current user
     */
    @AuraEnabled
    public static List<ContentFolder> getSharedFolderByUserParentAccount(){
        List<User> users = new SLT_User().selectById(new Set<Id> {userInfo.getUserId()});
        List<Account> accounts = new SLT_Account().selectById(new Set<Id> {users[0].AccountId});
        String folderName='';
        if (accounts[0].Shared_Folder_Type__c != 'Local Account' && accounts[0].ParentId != null){
            List<Account> accounts2 = new List<Account>(); 
            accounts2 =new SLT_Account().selectById(new Set<Id> {accounts[0].ParentId});
            if (accounts2.size()>0)
                folderName = accounts2[0].Name;
        } else {
            folderName = accounts[0].Name;
        }
        return new SLT_ContentFolder().selectByName(new Set<String> {folderName});
    }
    
    /*
     * Return List of ContentFolder by parentContentFolderId
     * @parentContentFolderId 
     */
    @AuraEnabled
    public static List<ContentFolder> getFoldersByParentId(String parentContentFolderId){
    	Id userInfo = UserInfo.getUserId();
        User contactUser = new SLT_User().selectUserByLoggedInUser(userInfo);
        String partnerType = contactUser.Contact.Partner_Type__c;
        
        if(partnerType.contains('CLM Agency'))
        {
            return new SLT_ContentFolder().selectByParentContentFolderIdForCLM(new Set<id> {parentContentFolderId});            
        }
        else
        {
            return new SLT_ContentFolder().selectByParentContentFolderId(new Set<id> {parentContentFolderId});
        }
    }
     /*
     * Return List of ContentFolderMember by parentContentFolderId
     * @parentContentFolderId 
     */
    @AuraEnabled
    public static List<ContentFolderMember> getFolderMemberByParentId(String parentContentFolderId){
    	return new SLT_ContentFolderMember().selectByParentContentFolderId(new Set<id> {parentContentFolderId});
    }
	
	//Created method to create View Stat record when user clicks on the file.
    @AuraEnabled
    public static Object logViewStat(String ContentVersionId, String FileTitle){
        
        CSM_QI_View_Stat__c logRecord = new CSM_QI_View_Stat__c();
        logRecord.ObjectApiName__c = 'ContentDocument';
        logRecord.Source__c = 'PRM';
        logRecord.Title__c = FileTitle;//Article_Reviewer__c
        
        insert logRecord;
        return logRecord;
    }
}