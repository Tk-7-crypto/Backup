/*
 * Version       : 1.0
 * Description   : Test Class for SLT_ContentFolder
 */
@isTest
private class TST_SLT_ContentFolder {
    /**
     * This method used to set up testdata
     */ 
    @testSetup
    static void dataSetup() {

        ContentFolder cf = new ContentFolder(Name='TestContentFolder');
        insert cf;
        
        ContentFolder cf2 = new ContentFolder(Name='TestContentFolder2', ParentContentFolderId=cf.Id );
        insert cf2;
        
    }
    
    testmethod static void selectContentFolder(){
        SLT_ContentFolder slt = new SLT_ContentFolder();
        slt.getSObjectFieldList();
        slt.getSObjectType();
        ContentFolder cf = [SELECT ParentContentFolderId FROM ContentFolder WHERE Name='TestContentFolder2'];
        slt.selectById(new Set<Id> {cf.Id});
        slt.selectByName(new Set<String>{'TestContentFolder2'}, new Set<Id> {cf.ParentContentFolderId});
    }

    /**
     * This method used to get ContentFolder by name
     */    
    @IsTest
    static void testSelectByName() {
    	List<ContentFolder> contentFolders = new  List<ContentFolder>();
        Test.startTest();
        Set<String> folderName = new Set<String>();
		folderName.add('TestContentFolder');
    	contentFolders = new SLT_ContentFolder().selectByName(folderName);
        Test.stopTest();
        Integer expected = 1;
        Integer actual = contentFolders.size();
        System.assertEquals(expected, actual);
    }
    
    /**
     * This method used to get ContentFolder by ParentContentFolderId
     */    
    @IsTest
    static void testSelectByParentContentFolderId() {
    	List<ContentFolder> contentFolders = new  List<ContentFolder>();
    	ContentFolder f = [SELECT id FROM ContentFolder WHERE Name = 'TestContentFolder'];
        Test.startTest();
    	contentFolders = new SLT_ContentFolder().selectByParentContentFolderId(new Set<id>{f.Id});
        Test.stopTest();
        Integer expected = 1;
        Integer actual = contentFolders.size();
        System.assertEquals(expected, actual);
    }

    @IsTest
    static void testSelectLibFolders() {
    	List<ContentFolder> contentFolders = new  List<ContentFolder>();
    	ContentFolder f = [SELECT id FROM ContentFolder WHERE Name = 'TestContentFolder'];
        Test.startTest();
    	contentFolders = new SLT_ContentFolder().selectAll();
        Test.stopTest();
    }
    
    @IsTest
    static void testSelectByParentContentFolderIdForCLM() {
    	List<ContentFolder> contentFolders = new  List<ContentFolder>();
    	ContentFolder cf = [SELECT id FROM ContentFolder WHERE Name = 'TestContentFolder'];
        Test.startTest();
    	contentFolders = new SLT_ContentFolder().selectByParentContentFolderIdForCLM(new Set<id>{cf.Id});
        Test.stopTest();
    }
}