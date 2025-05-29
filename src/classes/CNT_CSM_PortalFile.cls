/*
 * Version       : 1.0
 * Description   : Apex Controller for PortalFile component.
 */
public with sharing class CNT_CSM_PortalFile {
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
     * Return List of ContentFolder for current user
     */
    @AuraEnabled
    public static List<ContentFolder> getFolders(){
        List<User> users = new List<User>();
        Map<Id, User> userMap = new SLT_User().selectByUserId(new Set<Id> {userInfo.getUserId()},new Set<String>{'Id','AccountId','ContactId'});
        if(userMap != null && !userMap.isEmpty()) users = userMap.values();
        
        if(users != null && !users.isEmpty()){
            Set<String> fieldSet = new Set<String>{'Id','Name','Community_Topic__c','Community_Topic__r.Name'};
            String filterCondition ='';
            String prodIds = '',removeProd = '';
            List<CSM_QI_Data_Portal_Queue_User_details__c> dataList = new SLT_CSMDataPortalQueueUserdetails().getDataWithFilter(new Set<String> {'ProductId__c'},'ProductId__c != null AND Account__c=\''+ users[0].AccountId +'\' AND Type__c =\'Product Level Restriction\' AND ClientContact__c=\''+ users[0].ContactId +'\'');
            if(dataList != null && !dataList.isEmpty()){
                for (Integer i=0; i<dataList.size(); i++) {
                    if(dataList[i].ProductId__c != null ){
                        prodIds += '\''+ dataList[i].ProductId__c+'\'';
                        if(i < dataList.size()-1) prodIds += ',';
                    }
                }
                filterCondition = 'Id in(SELECT Product2Id FROM asset WHERE AccountId=\''+ users[0].AccountId +'\' AND Status !=\'Obsolete\' AND Product2Id in ('+ prodIds +'))';
            }else{
                List<CSM_QI_Case_Categorization__c> prodDataList = new SLT_CaseCategorization().getProductLevelRestrict();
                    for (Integer i=0; i<prodDataList.size(); i++) {
                        removeProd += '\''+ prodDataList[i].Product__c+'\'';
                        if(i < prodDataList.size()-1) removeProd += ',';
                    }
                if(removeProd.length()>1){
                    filterCondition = 'Id in(SELECT Product2Id FROM asset WHERE AccountId=\''+ users[0].AccountId +'\' AND Status !=\'Obsolete\' AND Product2Id not in ('+ removeProd +'))';
                }else{
                    filterCondition = 'Id in(SELECT Product2Id FROM asset WHERE AccountId=\''+ users[0].AccountId +'\' AND Status !=\'Obsolete\')';
                }
            }
            List<Product2> products =  new SLT_Product2().getProductWithFilter(fieldSet,filterCondition);
            Set<String> folderName = new Set<String>();
            for (Integer i=0; i<products.size();i++){
                if (products[i].Community_Topic__c != null)
                    folderName.add(products[i].Community_Topic__r.Name);
            }
            return new SLT_ContentFolder().selectByName(folderName);
        }else{
            return null;
        }
    }
    
     /*
     * Return List of ContentFolder by topic id
     * @id 
     */
    @AuraEnabled
    public static List<ContentFolder> getFolderByTopicId(String id){
        List<Topic> topics = new SLT_Topic().selectById(new Set<id> {id});
        List<ContentFolder> cf;
        List<ContentWorkspace> cws = new SLT_ContentWorkspace().selectByName(new Set<String>{'Community Lib'});
        if(cws.size() > 0){
            cf = new SLT_ContentFolder().selectByName(new Set<String>{topics[0].Name}, new Set<Id> {cws[0].RootContentFolderId});
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

    @AuraEnabled
    public static ContentWorkspace getContentWorkspaceByRootContentFolderId(String rootContentFolderId){
        ContentWorkspace cw =  new ContentWorkspace();
        cw = new SLT_ContentWorkspace().selectByRootContentFolderId(new Set<iD>{rootContentFolderId})[0];
        return cw;
    }
    
    /*
     * Return List of ContentFolder by parentContentFolderId
     * @parentContentFolderId 
     */
    @AuraEnabled
    public static List<ContentFolder> getFoldersByParentId(String parentContentFolderId){
        return new SLT_ContentFolder().selectByParentContentFolderId(new Set<id> {parentContentFolderId});
    }
    

    @AuraEnabled
    public static void updateContentFolderMember (String parentContentFolderId, String childRecordId){
       List<ContentFolderMember> cfm = new SLT_ContentFolderMember().selectByChildRecordId(new Set<id> {childRecordId});
       cfm[0].ParentContentFolderId = parentContentFolderId;
       update cfm;
    }
    
    /*
     * Return List of CSM_QI_Folder__c by contactId
     */
    @AuraEnabled
    public static List<CSM_QI_Folder__c> getMikadoFoldersByContact(){
        List<CSM_QI_Folder__c> mikadoFolders =  new List<CSM_QI_Folder__c> ();
        List<User> users = new SLT_User().selectById(new Set<Id> {userInfo.getUserId()});
        mikadoFolders =  [select Id, Name  from CSM_QI_Folder__c  where id in( select CSM_Folder__c  from CSM_QI_Folder_Contact_Relationship__c where Contact__c =: users[0].ContactId)];
        return mikadoFolders;
    }
    
    
    @AuraEnabled
    public static List<ContentFolderMember> getMikadoContentFolderMember(){
        List<CSM_QI_Folder__c> mikadoFolders =  new List<CSM_QI_Folder__c> ();
        List<User> users = new SLT_User().selectById(new Set<Id> {userInfo.getUserId()});
        mikadoFolders =  [select Id, Name  from CSM_QI_Folder__c  where id in( select CSM_Folder__c  from CSM_QI_Folder_Contact_Relationship__c where Contact__c =: users[0].ContactId)];
        Set<String> mikadoFoldersIds = new Set<String>();
        for (Integer i=0; i<mikadoFolders.size();i++)
            mikadoFoldersIds.add(mikadoFolders[i].Id);
            
        List<CSM_QI_Folder_File_Relationship__c> ffrList = [ select Id, CSM_Folder__c, File_Id__c from CSM_QI_Folder_File_Relationship__c where CSM_Folder__c in :mikadoFoldersIds ];
        Set<String> fileIds = new Set<String>();
        for (Integer i=0; i<ffrList.size();i++)
            fileIds.add(ffrList[i].File_Id__c);
        return new SLT_ContentFolderMember().selectByChildRecordId(fileIds);
    }
    
    @AuraEnabled
    public static void insertNewFolder (String name,String  parentContentFolderId){
        ContentFolder cf = new ContentFolder(Name=name, ParentContentFolderId=parentContentFolderId);
        insert cf;
    }
    
     /*
     * Return List of ContentFolderMember by parentContentFolderId
     * @parentContentFolderId 
     */
    @AuraEnabled
    public static List<ContentFolderMember> getFolderMemberByParentId(String parentContentFolderId){
        return new SLT_ContentFolderMember().selectByParentContentFolderId(new Set<id> {parentContentFolderId});
    }
    
    @AuraEnabled
    public static void deleteContentDocumentById(String contentDocumentId){
        ContentDocument cd = New ContentDocument (Id=contentDocumentId);
        delete cd;
    }
}