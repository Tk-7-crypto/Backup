public class UTL_CSM_CopyContentDocumentFiles {
    public static String destinationFolderId='';
    public static string sourceFolderId ='';
    public static string sourceFolder='';   
    
    public static boolean CreateFiles(string sourcePath, string destinationPath){
        
        //Get Source FolderId
        PathRecursion(getLibraryId(sourcePath).RootContentFolderId,sourcePath.substring(sourcePath.indexOf('/')+1,sourcePath.length()),'',false);
        
        //Create folder at destination
        CreateDestinationFolder(destinationPath,sourceFolder);   
        
        //Create copy of source files
        List<ContentVersion> lstCV = new  List<ContentVersion>();
        List<ContentFolderMember> cfm = [Select ChildRecordId from ContentFolderMember  where  ParentContentFolderId=:sourceFolderId  limit 10];
        for(ContentFolderMember member : cfm ){
            lstCV.add(CopyContentVersion(getLibraryId(destinationPath).Id,member.ChildRecordId));                       
        }
        if(lstCV.size()>0){
            insert lstCV;        
        }
            
        //update mapping of new files with destination folder
        updateFileFolderMapping(lstCV,destinationFolderId);
        return true;
    }
    
    public static ContentVersion CopyContentVersion(string libraryId, string contentDocumentId){
        ContentVersion cv = [Select ContentDocumentId,IsLatest,ContentUrl,ContentBodyId,VersionNumber,Title,Description,ReasonForChange,
                             SharingOption,SharingPrivacy,PathOnClient,RatingCount,IsDeleted,ContentModifiedDate,ContentModifiedById,PositiveRatingCount,
                             NegativeRatingCount,FeaturedContentBoost,FeaturedContentDate,CurrencyIsoCode,OwnerId,CreatedById,CreatedDate,LastModifiedById,
                             TagCsv,FileType,PublishStatus,VersionData,ContentSize,FileExtension,FirstPublishLocationId,Origin,NetworkId,ContentLocation,
                             TextPreview,ExternalDocumentInfo1,ExternalDocumentInfo2,ExternalDataSourceId,Checksum,IsMajorVersion,IsAssetEnabled,VersionDataUrl,
                             Legacy_Attachment_Id__c,External_Content_Document_ID__c,External_Document_Id__c 
                             from ContentVersion where ContentDocumentId =: contentDocumentId];
        
        ContentVersion cvv= new ContentVersion();
        cvv.Title=cv.Title;
        cvv.Description=cv.Description;
        cvv.ReasonForChange=cv.ReasonForChange;
        cvv.SharingOption=cv.SharingOption;
        cvv.SharingPrivacy=cv.SharingPrivacy;
        cvv.PathOnClient=cv.PathOnClient;
        cvv.CurrencyIsoCode=cv.CurrencyIsoCode;
        cvv.TagCsv=cv.TagCsv;
        cvv.VersionData=cv.VersionData;
        cvv.FirstPublishLocationId=libraryId;
        cvv.Origin=cv.Origin;
        cvv.NetworkId=cv.NetworkId;
        cvv.ContentLocation=cv.ContentLocation;
        cvv.ExternalDocumentInfo1=cv.ExternalDocumentInfo1;
        cvv.ExternalDocumentInfo2 =cv.ExternalDocumentInfo2;
        cvv.ExternalDataSourceId=cv.ExternalDataSourceId;
        cvv.IsMajorVersion=cv.IsMajorVersion;
        cvv.IsAssetEnabled=cv.IsAssetEnabled;
        cvv.Legacy_Attachment_Id__c=cv.Legacy_Attachment_Id__c;
        cvv.External_Content_Document_ID__c=cv.External_Content_Document_ID__c;
        cvv.External_Document_Id__c=cv.External_Document_Id__c;
        
        //insert cvv;
        return cvv;
    }    
    
    public static void updateFileFolderMapping(List<ContentVersion> children,string parentId){
        List<string> childIds = new List<string>();
        for(ContentVersion cv: children){
            childIds.add(cv.Id);
        }
        
        List<string> childDocumentIds = new List<string>();
        List<ContentVersion> cvs = [SELECT Id,ContentDocumentId from ContentVersion where Id  IN : childIds];
        for(ContentVersion cv:cvs){
            childDocumentIds.add(cv.ContentDocumentId);
        }
        
        List<ContentFolderMember> cfms = [Select ParentContentFolderId from ContentFolderMember  where   ChildRecordId  IN :childDocumentIds ];
        for(ContentFolderMember cfm : cfms){
            cfm.ParentContentFolderId = parentId;
        }
        
        
        update cfms;
    }
    
    public static void CreateDestinationFolder(string destinationPath, string newFolder){
        string destination = destinationPath.substring(destinationPath.indexOf('/')+1,destinationPath.length());
        PathRecursion(getLibraryId(destinationPath).RootContentFolderId,destination,newFolder,true);  
    }
    
    public static void PathRecursion(string parentId,string path, string newFolder, boolean flag){
        integer i = path.indexOf('/');
        string currentFolder =getFirstFolder(path);
        ContentFolder cf =  [select ID,Name from ContentFolder where ParentContentFolderId =: parentId and Name=:currentFolder];
        if(cf!=null){
            if(i!=-1){
                string nextFolders = path.substring(i+1,path.length());
                PathRecursion(cf.Id,nextFolders,newFolder,flag);
            }
            else if (i==-1){
                if(flag){
                    ContentFolder cfolder = new ContentFolder();
                    cfolder.ParentContentFolderId = cf.Id;
                    cfolder.Name = newFolder;
                    cfolder.CurrencyIsoCode  ='USD';
                    insert cfolder;
                    destinationFolderId = cfolder.Id;
                }
                else{
                    sourceFolder = currentFolder;
                    sourceFolderId = cf.Id;
                }
                
            }
        }
    }
    
    public static string getFirstFolder(string destinationPath){
        integer i = destinationPath.indexOf('/');
        string libraryName=(i==-1)?destinationPath:destinationPath.substring(0,i);
        return libraryName;
    }
    
    public static ContentWorkspace getLibraryId(string path){
        string libraryName= getFirstFolder(path);
        ContentWorkspace cw = [SELECT ID,RootContentFolderId FROM ContentWorkspace  where Name =: libraryName limit 1];
        if(cw==null){
            return null;
        }
        return cw;
    }
    /*
    public static void Main(string libId){
        List<string> customerName = new List<string>();
        Set<Id> cfmId = new Set<Id>();
        
        
        List<ContentWorkspace> libraries =  [SELECT Id,Name,RootContentFolderId  from ContentWorkspace];// where Id =: libId];
        for(ContentWorkspace cws : libraries){
            if(ValidLibraryNamme(cws.Name)){  //Need more improvement
                //string libName = cws.Name.remove('Library').trim();
                //printf(libName);
                List<ContentFolder> folders = [SELECT ID,Name,ParentContentFolderId from Contentfolder where ParentContentFolderId =: cws.RootContentFolderId];
                for(ContentFolder folder: folders){
                    //printf(folder.Name);
                    if(ValidFolderName(cws.Name,folder.Name)){
                        printf(folder.Name);
                        //List<ContentFolder> miscFolders =  [SELECT Id,Name,ParentContentFolderId FROM Contentfolder WHERE Name in('OneKey','OneKey Reports','VR Monthly Report')];
                       
                        List<ContentFolder> f_OneKey = [SELECT Id,Name,ParentContentFolderId FROM Contentfolder WHERE Name = 'OneKey'];
                        List<ContentFolder> f_OneKey_Reports = [SELECT Id,Name,ParentContentFolderId FROM Contentfolder WHERE Name = 'OneKey Reports'];
                        List<ContentFolder> f_VR_Monthly_Report = [SELECT Id,Name,ParentContentFolderId FROM Contentfolder WHERE Name = 'VR Monthly Report'  ];
                        
                        List<ContentFolder> cf_OneKey = Apx.filterRecords(f_OneKey,ContentFolder.ParentContentFolderId,folder.Id);
                        if(cf_OneKey.size() > 0){
                            printf(cf_OneKey[0].Name);
                            List<ContentFolder> cf_OneKey_Reports = Apx.filterRecords(f_OneKey_Reports,ContentFolder.ParentContentFolderId,cf_OneKey[0].Id);
                            if(cf_OneKey_Reports.size() > 0){
                                printf(cf_OneKey_Reports[0].Name);
                                List<ContentFolder> cf_VR_Monthly_Report = Apx.filterRecords(f_VR_Monthly_Report,ContentFolder.ParentContentFolderId,cf_OneKey_Reports[0].Id);
                                if(cf_VR_Monthly_Report.size()>0){
                                    printf(cf_VR_Monthly_Report[0].Name);
                                    List<ContentFolderMember> content_Folder_Members = [Select Id, ParentContentFolderId, ChildRecordId,ChildRecord.Title, ChildRecord.FileExtension,CreatedDate FROM ContentFolderMember WHERE ParentContentFolderId =: cf_VR_Monthly_Report[0].Id];
                                    for(ContentFolderMember cfm : content_Folder_Members)
                                    {
                                        system.debug(cfm.ChildRecord.Title);
                                        cfmId.add(cfm.ChildRecordId);
                                    }                                    
                                }                               
                            }                          
                        }
                    }                    
                }
            }
        }
        List<ContentDocument> documents = [select id from contentdocument where Id IN: cfmId];
        for(ContentDocument cd: documents){
            //System.debug(cd.Id);
        }
        //delete cd2;
    }
    
    public static void DownToUp(){
        //List<Contentfolder> folders = [SELECT Id,Name,ParentContentFolderId,ParentContentFolder.Name,ParentContentFolder.ParentContentFolder.Name,ParentContentFolder.ParentContentFolder.ParentContentFolder.Name,ParentContentFolder.ParentContentFolder.ParentContentFolder.Id,ParentContentFolder.ParentContentFolder.ParentContentFolder.ParentContentFolderId FROM Contentfolder WHERE Name = 'VR Monthly Report'  AND ParentContentFolder.Name = 'OneKey Reports' AND ParentContentFolder.ParentContentFolder.Name ='OneKey' AND ParentContentFolder.ParentContentFolder.ParentContentFolder.Name like '%[__]'];
        
        Set<Id> rootContentFolderIds = new Set<Id>();
        printf('****** Folders ******');
        for(Contentfolder f: folders){
            printf(f.ParentContentFolder.ParentContentFolder.ParentContentFolder.Name);
            rootContentFolderIds.add(f.ParentContentFolder.ParentContentFolder.ParentContentFolder.ParentContentFolderId);
        }
        List<Contentfolder> filteredFolders = new List<Contentfolder>();
        List<ContentWorkspace> libraries =  filteredLibraries([SELECT Id,Name,RootContentFolderId from ContentWorkspace WHERE RootContentFolderId IN: rootContentFolderIds]);
        
        printf('******Filtered Library**************');
        for(ContentWorkspace l:libraries){
            printf(l.Name);
            for(Contentfolder f:folders){
                if(f.ParentContentFolder.ParentContentFolder.ParentContentFolder.ParentContentFolderId  == l.RootContentFolderId && ValidFolderName(l.Name,f.ParentContentFolder.ParentContentFolder.ParentContentFolder.Name) )
                    filteredFolders.add(f);
            }
        }
        
        Set<Id> FolderId = new Set<Id>();
        printf('***************Filtered Folders***************');
        for(Contentfolder f:filteredFolders){
            printf(f.ParentContentFolder.ParentContentFolder.ParentContentFolder.Name);
            FolderId.add(f.Id);
        }
        Set<Id> cfmId = new Set<Id>();
        List<ContentFolderMember> ContentFolderMembers = [Select Id, ParentContentFolderId, ChildRecordId,ChildRecord.Title, ChildRecord.FileExtension FROM ContentFolderMember WHERE ParentContentFolderId IN: FolderId];
        for(ContentFolderMember cfm : ContentFolderMembers)
        {
            cfmId.add(cfm.ChildRecordId);
        }
        List<ContentDocument> documents = [select id,Title,FileExtension,CreatedDate from contentdocument where Id IN: cfmId];
        List<ContentDocument> docToDelete = new List<ContentDocument>();
                 
        CSM_case_Trigger_Handler__c csmCustomsetting = CSM_case_Trigger_Handler__c.getOrgDefaults();
        Integer FileMaintainPeriod_hours = (Integer)csmCustomsetting.FileMaintainPeriod_hours__c;

        printf('************Documents************');
        for(ContentDocument cd: documents){
            printf(cd.Title+'.'+cd.FileExtension + '== '+cd.CreatedDate);
            Long dt1Long = cd.CreatedDate.getTime();
            Long dt2Long = DateTime.now().getTime();
            Long hours = (((dt2Long - dt1Long)/1000)/60)/60;           
            if(hours>FileMaintainPeriod_hours )
                docToDelete.add(cd);
            
        }
        
        delete docToDelete;
        printf('************ Documents to delete ************');
        //for(ContentDocument cd:docToDelete)
          //  printf(cd.Title+'.'+cd.FileExtension );
    } 
    */
    
    
    public static boolean ValidFolderName(string libName, string folderName){
         //folderName : NOVARTIS [GB]
         //libraryName : NOVARTIS
         //FolderName: ABBOTT NUTRITION  [GB]
         //Library : ABBOTT
         string libraryName = libName.remove('Library').trim();
         if(folderName.length() >=4 && folderName.charAt(folderName.length()-1) == 93 && folderName.charAt(folderName.length()-4) == 91)  
             return true;
         else
             return false;
    }
    
    public static void printf(string msg){
        System.debug(msg);
    }
    
    public static Boolean ValidLibraryNamme(string libraryName){
        //TILLOTTS Library
        if(libraryName.indexOf('Library') != -1 && libraryName.indexOf('Library') == libraryName.length() - 7) 
            return true;
        else
            return false;            
    }
    
    public static List<ContentWorkSpace> filteredLibraries(List<ContentWorkSpace> libraries){
        List<ContentWorkSpace> filtered= new List<ContentWorkSpace>();
        printf('******Libraries Name*********');
        for(ContentWorkSpace library : libraries){
            printf(library.Name);
            if(ValidLibraryNamme(library.Name))
                filtered.add(library);
        }
        return filtered;
    }
}
