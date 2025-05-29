public with sharing class CNT_BOX_NestedFoldersCreation {
    public static String oppId = null;
    public static String bidHistoryId = null;
    public static box.Toolkit boxToolkit = new box.Toolkit();
    public static String RFPFolderId = '';
    public static String folderId = '';
    public static String RFPFolderLink;
    static String Meeting_Minutes = Box_End_Point__c.getOrgDefaults().Meeting_Minutes_folder_id__c;
    static String Budget_Source_folder_Id = Box_End_Point__c.getOrgDefaults().Budget_Source_folder_Id__c;
    /**
    * @description : Method invoke Creating folders based on JSON structure
    * @author Anup Kage | 4/15/2020 
    * @return void 
    **/
    public static void creatingNestedFolders( String recId, String opportunityId, String ObjectName){
        if(String.IsNotBlank(opportunityId)){
            oppId = opportunityId;
        }
        bidHistoryId = recId;
        LIST<string> jsObj = new List<String>();
        //We are querying from Metadata, we can't use selector classes here
        Box_Parent_Folder__mdt rootFolder = new SLT_BoxParentFolder().getParentFolder(ObjectName);
        folderCreation(rootFolder.QualifiedApiName, rootFolder.Folder_Name__c, recId, true, oppId, ObjectName);
    }
    /**
    * @description : Method to create folders
    * @author Anup Kage  | 4/15/2020 
    * @param folderName 
    * @param parentId 
    * @return String 
    **/
    @future(Callout = true)
    public static void folderCreation(String folderApiName, String folderName, String parentId, Boolean isRootFolder, String opportunityId, String ObjectName){

        List<Opportunity> oppRec = new List<Opportunity>();
        Bid_History__c bidHsitoryRecord = new Bid_History__c();
        if(isRootFolder){
            oppRec = new SLT_Opportunity().getLegacyQuintilesByOpportunityById(new Set<Id>{opportunityId}, new Set<String>{'Id','Legacy_Quintiles_Opportunity_Number__c', 'Line_of_Business__c'});
            bidHsitoryRecord = new SLT_Bid_History().getBidHistoryDetails(parentId,new Set<String>{'Bid_Number__c'});
        }
        String rootFolderId =''; 
        try{
            rootFolderId = boxToolkit.createFolderForRecordId(parentId, oppRec[0].Legacy_Quintiles_Opportunity_Number__c+' - Bid '+bidHsitoryRecord.Bid_Number__c, true);
            creatingFoldersRecursively(folderApiName, folderName, rootFolderId, true, opportunityId, oppRec[0].Line_of_Business__c);
        }
        catch(Exception excpObj){
            System.debug('===>'+excpObj);
        }

        Id userId = UserInfo.getUserId();
        box.Toolkit.CollaborationType collabType = box.Toolkit.CollaborationType.EDITOR;
        String collabId = boxToolkit.createCollaborationOnRecord(userId, parentId, collabType, false);
        boxToolkit.commitChanges();
        if(String.IsNotBlank(RFPFolderId)){ 
            Box_End_Point__c boxEndpoint = Box_End_Point__c.getOrgDefaults();
            Bid_History__c bidRecord = new Bid_History__c();
            bidRecord.Id = parentId;
            bidRecord.RFP_Folder_Link__c = boxEndpoint.End_Point__c+'/folder/'+RFPFolderId;
            //bidRecord.RFP_Folder_Link__c = RFPFolderLink;
            UPDATE bidRecord;
        }
    }
    public static void creatingFoldersRecursively(String folderapiName, String folderName, String parentId, Boolean isRootFolder, String opportunityId, String lineOfBusiness){
        String folderId  = parentId;
        Set<String> specificLOBSet = new Set<String>{'Safety & Med Info', 'Regulatory & Drug Development Solutions'};
        if(!isRootFolder){
            if(specificLOBSet.contains(lineOfBusiness) && folderName.contains('Budget') && String.isNotEmpty(Budget_Source_folder_Id)) {
                folderId = UTL_BOX.copyAllFoldersAndFilesFromSourceToDestination(Budget_Source_folder_Id, parentId, null);
            } else if(specificLOBSet.contains(lineOfBusiness) && folderName.contains('Meeting Minutes') && String.isNotEmpty(Meeting_Minutes)) {
                folderId = UTL_BOX.copyAllFoldersAndFilesFromSourceToDestination(Meeting_Minutes, parentId, null);
            } else {
                folderId = boxToolkit.createFolder(folderName, parentId, null);
            }
        }
        if(folderName.contains('RFP')){
            RFPFolderId = folderId;            
            box__FRUP__c  frupRecord;
            try{
                frupRecord = new SLT_FRUP().getFolderId(opportunityId, new Set<String>{'box__Folder_ID__c'});
            }catch(Exception e){
                System.debug('Exception=>'+e);
            }
            if(String.IsNotBlank(folderId)&& frupRecord != null && String.IsNotBlank(frupRecord.box__Folder_ID__c)){
                moveFilesToRFP(folderId, frupRecord.box__Folder_ID__c);
            }
        }
        //We are querying from Metadata, we can't use selector classes here
        List<Box_Folder__mdt> childFolders = new SLT_BoxChildFolder().getChildFolders(folderapiName);
            if(childFolders.isEmpty() || childFolders.size() == 0){
                return ;
            }
        Set<String> specificLOBsSet = new Set<String>{'Safety & Med Info', 'Regulatory & Drug Development Solutions'};
        String allLOB = 'ALL';
        for(Box_Folder__mdt obj : childFolders){
            List<String> lobList = obj.Line_of_Business__c.split(',');
            if(lineOfBusiness != null && specificLOBsSet.contains(lineOfBusiness) && lobList.contains(lineOfBusiness)) {
                creatingFoldersRecursively(obj.QualifiedApiName, obj.Folder_Name__c, folderId, false, opportunityId, lineOfBusiness);
            } else if((lineOfBusiness == null || !specificLOBsSet.contains(lineOfBusiness)) && lobList.contains(AllLOB)) {
                creatingFoldersRecursively(obj.QualifiedApiName, obj.Folder_Name__c, folderId, false, opportunityId, lineOfBusiness);
            }
        }   
        
    }
    /**
    * @description : Method to Move files from Opportunity Folder to RFP Folder
    * @author Anup Kage  | 6/27/2020 
    * @param RFPFolderId 
    * @param OppFolderId 
    * @return void 
    **/
    public static void moveFilesToRFP(String RFPFolderId, String OppFolderId){
        Box_End_Point__c boxEndpoint = Box_End_Point__c.getOrgDefaults();
            box.Toolkit toolkit = new box.Toolkit();
            // Callout to get items inside the folder
            String endpoint = boxEndpoint.End_Point_for_Folders__c+'/folders/'+OppFolderId+'/items';
            // Create a new HttpRequest object and set appropriate values
            HttpRequest request = new HttpRequest();
            request.setMethod('GET');
            request.setEndpoint(endpoint);
            // toolkit.commitChanges();
            HttpResponse response;
            try{
                if(Test.isRunningTest()) {
                    Http h = new Http();
                    response = h.send(Request);
                    }
                // If not running a test, use box sendRequest object
                else {
                    response = toolkit.sendRequest(request);
                }
                Map<String,Object> folderItems = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                for(Object files: (List<Object>)folderItems.get('entries')){
                    map<String,Object> fileInfo = (map<String,Object>) files;
                    if(fileInfo.get('type') == 'file' ){
                            String fileMoveEndPoint = boxEndpoint.End_Point_for_Folders__c+'/files/'+fileInfo.get('id');
                            Map<String, Object> destinationFolderId = new Map<String, Object>{
                                'id'=> RFPFolderId };
                            Map<String, Object> parent = new Map<String, Object>{
                                'parent'=> destinationFolderId,
                                'id'=> fileInfo.get('id')};                      
                            HttpRequest fileMoveRequest = new HttpRequest();
                            fileMoveRequest.setMethod('PUT');
                            fileMoveRequest.setBody(JSON.serialize(parent));
                            fileMoveRequest.setEndpoint(fileMoveEndPoint);
                            HttpResponse fileMoveResponse = toolkit.sendRequest(fileMoveRequest);
                    }
                }
            }
            catch(Exception e){
                system.debug('request=11===>'+e);
            }     
    }   
}