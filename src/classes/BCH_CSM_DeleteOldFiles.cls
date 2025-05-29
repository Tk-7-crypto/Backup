global class BCH_CSM_DeleteOldFiles implements Database.Batchable<sObject>{
    global Integer FileMaintainPeriod_hours = (Integer)CSM_case_Trigger_Handler__c.getOrgDefaults().FileMaintainPeriod_hours__c;
    global Database.QueryLocator start(Database.BatchableContext BC){
        List<Contentfolder> folders = [SELECT Id,Name,ParentContentFolderId,ParentContentFolder.Name,ParentContentFolder.ParentContentFolder.Name,ParentContentFolder.ParentContentFolder.ParentContentFolder.Name,ParentContentFolder.ParentContentFolder.ParentContentFolder.Id,ParentContentFolder.ParentContentFolder.ParentContentFolder.ParentContentFolderId FROM Contentfolder WHERE Name = 'VR Monthly Report'  AND ParentContentFolder.Name = 'OneKey Reports' AND ParentContentFolder.ParentContentFolder.Name ='OneKey' AND ParentContentFolder.ParentContentFolder.ParentContentFolder.Name like '%[__]'];
        
        Set<Id> rootContentFolderIds = new Set<Id>();
        for(Contentfolder f: folders){
            rootContentFolderIds.add(f.ParentContentFolder.ParentContentFolder.ParentContentFolder.ParentContentFolderId);
        }
        List<Contentfolder> filteredFolders = new List<Contentfolder>();
        List<ContentWorkspace> libraries =  UTL_CSM_CopyContentDocumentFiles.filteredLibraries([SELECT Id,Name,RootContentFolderId from ContentWorkspace WHERE RootContentFolderId IN: rootContentFolderIds]);
        
        for(ContentWorkspace l:libraries){
            for(Contentfolder f:folders){
                if(f.ParentContentFolder.ParentContentFolder.ParentContentFolder.ParentContentFolderId  == l.RootContentFolderId && UTL_CSM_CopyContentDocumentFiles.ValidFolderName(l.Name,f.ParentContentFolder.ParentContentFolder.ParentContentFolder.Name) )
                    filteredFolders.add(f);
            }
        }
        
        Set<Id> FolderId = new Set<Id>();
        
        for(Contentfolder f:filteredFolders){
            FolderId.add(f.Id);
        }
        Set<Id> cfmId = new Set<Id>();
        List<ContentFolderMember> ContentFolderMembers = [Select Id, ParentContentFolderId, ChildRecordId,ChildRecord.Title, ChildRecord.FileExtension FROM ContentFolderMember WHERE ParentContentFolderId IN: FolderId];
        for(ContentFolderMember cfm : ContentFolderMembers)
        {
            cfmId.add(cfm.ChildRecordId);
        }
        string query = 'select id,Title,FileExtension,CreatedDate from contentdocument where Id IN: cfmId';
        
        
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<ContentDocument> documents){
        //UTL_CSM_CopyContentDocumentFiles.DownToUp();
        
        List<ContentDocument> docToDelete = new List<ContentDocument>();
                 
        //CSM_case_Trigger_Handler__c csmCustomsetting = CSM_case_Trigger_Handler__c.getOrgDefaults();
        //Integer FileMaintainPeriod_hours = (Integer)csmCustomsetting.FileMaintainPeriod_hours__c;

        
        for(ContentDocument cd: documents){
            Long dt1Long = cd.CreatedDate.getTime();
            Long dt2Long = DateTime.now().getTime();
            Long hours = (((dt2Long - dt1Long)/1000)/60)/60;           
            if(hours>=FileMaintainPeriod_hours )
                docToDelete.add(cd);
            
        }
        
        if(!docToDelete.isEmpty()){
            delete docToDelete;
        }
        
    }

    global void finish(Database.BatchableContext BC){
    }
}