@isTest
private class TST_CNT_GBL_ViewSharepointFile {
    @isTest
    private static void testLoadAttachment() {
        TST_UTL_SharepointFactory.createCustomSetting();
        Sharepoint_File__c objSharepoint = TST_UTL_SharepointFactory.createSharepointFile(true);
        
        Test.startTest(); 
            Test.setMock(HttpCalloutMock.class, new TST_Mock_UTL_Sharepoint());
            
            PageReference pageRef = Page.VFP_GBL_ViewSharepointFile;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('sharepointFileId', String.valueOf(objSharepoint.Id));
            ApexPages.currentPage().getParameters().put('parentId', objSharepoint.Parent_Id__c);
            CNT_GBL_ViewSharepointFile controller = new CNT_GBL_ViewSharepointFile();
            controller.loadAttachment();
        Test.stopTest();

        System.assertEquals(true, controller.isCallCompleted, 'Error in Viewing File');
    }

    @isTest
    private static void testLoadAttachmentWithFolder() {
        TST_UTL_SharepointFactory.createCustomSetting();
        Sharepoint_File__c objSharepoint = TST_UTL_SharepointFactory.createSharepointFile(false);
        objSharepoint.File_Name__c = 'test.doc';
        objSharepoint.File_Url__c = '/shared documents/test/test.doc';
        insert objSharepoint;
        
        Test.startTest(); 
            Test.setMock(HttpCalloutMock.class, new TST_Mock_UTL_Sharepoint());
            PageReference pageRef = Page.VFP_GBL_ViewSharepointFile;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('sharepointFileId', String.valueOf(objSharepoint.Id));
            ApexPages.currentPage().getParameters().put('parentId', objSharepoint.Parent_Id__c);
            ApexPages.currentPage().getParameters().put('folderName', 'Customer Deliverable');
            CNT_GBL_ViewSharepointFile controller = new CNT_GBL_ViewSharepointFile();
            controller.loadAttachment();
        Test.stopTest();

        System.assertEquals(true, controller.isCallCompleted, 'Error in Viewing File');
    }
}