@isTest
private class TST_BCH_CSM_DeleteOldFiles {
    @testSetup
    static void setup() {
        //Library : Test Library
        ContentWorkspace Test_Library = new ContentWorkspace(Name='Pak Library', DeveloperName='PAK_CLASS');
        insert Test_Library;
        //main();
        
    }
    
    @IsTest
    static void testDeleteOldFiles() {
        ContentWorkspace Test_Library_Workspace = [Select Id from ContentWorkspace where Name = 'Pak Library'];
        ContentFolder workspaceFolder = [Select Id from ContentFolder where Name =: Test_Library_Workspace.Id];
        
        //Folder : Test Library[GB]
        ContentFolder testFolderRecord = new ContentFolder(Name='Pak [GB]', ParentContentFolderId=workspaceFolder.Id);
        insert testFolderRecord;
        
        //Folder : OneKey
        ContentFolder oneKey = [SELECT Id FROM ContentFolder WHERE Name = 'Pak [GB]'];
        ContentFolder oneKey_Folder = new ContentFolder(Name='OneKey', ParentContentFolderId=oneKey.Id);
        insert oneKey_Folder;
        
        //Folder : OneKey Reports
        ContentFolder OneKey_Reports = [SELECT Id FROM ContentFolder WHERE Name = 'OneKey' and ParentContentFolderId=: oneKey.Id];
        ContentFolder OneKey_Reports_Folder = new ContentFolder(Name='OneKey Reports', ParentContentFolderId=OneKey_Reports.Id);
        insert OneKey_Reports_Folder;
        
        //Folder : VR Monthly Report
        ContentFolder VR_Monthly_Report = [SELECT Id FROM ContentFolder WHERE Name = 'OneKey Reports' and ParentContentFolderId=:OneKey_Reports.Id];
        ContentFolder VR_Monthly_Report_Folder = new ContentFolder(Name='VR Monthly Report', ParentContentFolderId=VR_Monthly_Report.Id);
        insert VR_Monthly_Report_Folder;
        
        // Folder : VR Monthly Report
        ContentFolder VR_Monthly_Report_F = [SELECT Id FROM ContentFolder WHERE Name = 'VR Monthly Report' and ParentContentFolderId=:VR_Monthly_Report.Id];
       
        //Content Document
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
            cdl.LinkedEntityId = Test_Library_Workspace.Id;   
            cdl.Sharetype = 'I';
            documentLinks.add(cdl);
        }
        
        insert documentLinks;
        
        List<ContentDocument> cv = [Select Id from ContentDocument];
        set<id> ids = new set<id>();
        for(ContentDocument c : cv){
            ids.add(c.Id);
            //printf(c.Id);
        }
        
        for(ContentFolderMember cfm : [Select Id, ChildRecordId, ParentContentFolderId
                                       from ContentFolderMember
                                       where ChildRecordId =: ids]) {
                                           cfm.ParentContentFolderId = VR_Monthly_Report_F.Id;
                                           folderMembers.add(cfm);
                                       }
        
        update folderMembers;
        Test.startTest();
        Database.executeBatch(new BCH_CSM_DeleteOldFiles());
        Test.stopTest();
    }
    
}
