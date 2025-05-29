@isTest
public class TST_UTL_CSM_CopyContentDocumentFiles {
    @TestSetup
    static void testCreateFiles(){      
        
        ContentWorkspace testWorkspacee = new ContentWorkspace(Name='sourceLib', DeveloperName='TEST_CLASS');
        insert testWorkspacee;

		ContentWorkspace testWorkspacefinal = new ContentWorkspace(Name='destinationLib', DeveloperName='TEST_CLASS_Dev');
        insert testWorkspacefinal;        
        
    }
    @isTest public static void testCopyFiles(){
        ContentWorkspace testWorkspace = [Select Id from ContentWorkspace where Name = 'sourceLib'];
        
        ContentFolder workspaceFolder = [Select Id from ContentFolder where Name =: testWorkspace.Id];
        
        ContentWorkspace testWorkspace1 = [Select Id from ContentWorkspace where Name = 'destinationLib'];
        
        ContentFolder workspaceFolder1 = [Select Id from ContentFolder where Name =: testWorkspace1.Id];
        
        
        
        ContentFolder testFolderRecord = new ContentFolder(Name='TESTFOLDER', ParentContentFolderId=workspaceFolder.Id);
        insert testFolderRecord;
        
        ContentFolder testFolderRecordDestination = new ContentFolder(Name='TESTFOLDERDestination', ParentContentFolderId=workspaceFolder1.Id);
        insert testFolderRecordDestination;
        
         List<ContentVersion> contentVersions = new List<ContentVersion>();

        
        for(Integer i = 1; i <= 12; i++) {
            String fileExtension = '';
            Switch on i {
                when 1 {
                    fileExtension='csv';
                }
                when 2 {
                    fileExtension='jpg';
                }
                when 3 {
                    fileExtension='gif';
                }
                when 4 {
                    fileExtension='tiff';
                }
                when 5 {
                    fileExtension='ppt';
                }
                when 6 {
                    fileExtension='xls';
                }
                when 7 {
                    fileExtension='xlsx';
                }
                when 8 {
                    fileExtension='doc';
                }
                when 9 {
                    fileExtension='docx';
                }
                when 10 {
                    fileExtension='pdf';
                }
                when 11 {
                    fileExtension='pptx';
                }
                when else {
                    fileExtension='json';
                }
            }
            ContentVersion cv = new ContentVersion();
            cv.title = 'test content'+i;        
            cv.VersionData = Blob.valueOf('Unit Test Attachment Body'+i);
            cv.PathOnClient = 'test content'+i+'.'+fileExtension;
            contentVersions.add(cv);
        }
        
        
        insert contentVersions;
        
        List<ContentDocumentLink> documentLinks = new List<ContentDocumentLink>();
        List<ContentFolderMember> folderMembers = new List<ContentFolderMember>();
        
        for(ContentVersion cv : [Select Id, ContentDocumentId from ContentVersion]) {
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = cv.ContentDocumentId;
            cdl.LinkedEntityId = testWorkspace.Id;   
            cdl.Sharetype = 'I';
            documentLinks.add(cdl);
        }
        
        insert documentLinks;
        
        for(ContentFolderMember cfm : [Select Id, ChildRecordId, ParentContentFolderId
                                       from ContentFolderMember
                                       where ParentContentFolderId =: workspaceFolder.Id]) {
                                           cfm.ParentContentFolderId = testFolderRecord.Id;
                                           folderMembers.add(cfm);
                                       }
        
        update folderMembers;
        System.assertEquals(UTL_CSM_CopyContentDocumentFiles.CreateFiles('sourceLib/TESTFOLDER','destinationLib/TESTFOLDERDestination'),true,'Files are moved to destination.');
    }
    
}