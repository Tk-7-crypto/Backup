/*
 * Version       : 1.0
 * Description   : Apex Controller for MikadoFiles component.
 */
public with sharing class CNT_CSM_MikadoFiles {
    
    @AuraEnabled
    public static void updateContentFolderMember (String parentContentFolderId, String childRecordId,String csmFolderId ){
       List<ContentFolderMember> cfm = new SLT_ContentFolderMember().selectByChildRecordId(new Set<id> {childRecordId});
        if(cfm != null && !cfm.isEmpty()){
            cfm[0].ParentContentFolderId = parentContentFolderId;
            update cfm;
        }
        
       CSM_QI_Folder_File_Relationship__c ffr = new CSM_QI_Folder_File_Relationship__c();
       ffr.CSM_Folder__c=csmFolderId;
       ffr.File_Id__c=childRecordId;
       insert ffr;
    }
    
    @AuraEnabled
    public static List<ContentFolderMember> getFiles(String csmFolderId ){
        List<CSM_QI_Folder_File_Relationship__c> ffrList = [ select Id, CSM_Folder__c, File_Id__c from CSM_QI_Folder_File_Relationship__c where CSM_Folder__c= :csmFolderId ];
        Set<String> fileIds = new Set<String>();
        for (Integer i=0; i<ffrList.size();i++)
            fileIds.add(ffrList[i].File_Id__c);
        return new SLT_ContentFolderMember().selectByChildRecordId(fileIds);
    }
    
    @AuraEnabled
    public static void deleteContentDocumentById(String contentDocumentId){
        List<CSM_QI_Folder_File_Relationship__c> ffrList = [ select Id, CSM_Folder__c, File_Id__c from CSM_QI_Folder_File_Relationship__c where File_Id__c= :contentDocumentId ];
        delete ffrList[0];
        ContentDocument cd = New ContentDocument (Id=contentDocumentId);
        delete cd;
    }
}