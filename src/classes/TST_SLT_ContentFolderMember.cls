/*
 * Version       : 1.0
 * Description   : Test Class for SLT_ContentFolderMember
 */
@isTest
private class TST_SLT_ContentFolderMember {
	/**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() {
        ContentFolder cf = new ContentFolder(Name='TestContentFolder');
        insert cf;
        ContentVersion cv  = new ContentVersion(Title = 'Penguins', PathOnClient = 'Penguins.jpg',  VersionData = Blob.valueOf('Test Content'), IsMajorVersion = true);
        insert cv;       
    }
    
 
    
    /**
     * This method used to get ContentFolderMember by ParentContentFolderId
     */    
    @IsTest
    static void testSelectByParentContentFolderId() {
    	List<ContentFolderMember> contentFolderMembers = new  List<ContentFolderMember>();
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        List<ContentFolderMember> cfm = [select Id ,ParentContentFolderId from ContentFolderMember where ChildRecordId=:documents[0].Id];
        Test.startTest();
        new SLT_ContentFolderMember().getSObjectFieldList();
        new SLT_ContentFolderMember().getSObjectType();
        new SLT_ContentFolderMember().selectByChildRecordId(new Set<id>{documents[0].Id});
        new SLT_ContentFolderMember().selectByChildRecordId(new Set<String>{documents[0].Id});
    	contentFolderMembers = new SLT_ContentFolderMember().selectByParentContentFolderId(new Set<id>{cfm[0].ParentContentFolderId});
        Test.stopTest();
    }
    
}