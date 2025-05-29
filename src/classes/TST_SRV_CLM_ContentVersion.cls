@isTest
private class TST_SRV_CLM_ContentVersion {

    @isTest
    private static void testGetContentVersionByContentDocumentIdShouldReturnList() {
        ContentVersion contentVersionInsert = [SELECT Id, Title, ContentDocumentId FROM ContentVersion 
            WHERE Id= :TST_CLM_TestDataFactory.createContentVersion(true).Id LIMIT 1];

        Test.startTest();
            List<ContentVersion> contentVersionList = SRV_CLM_ContentVersion.getContentVersionByContentDocumentId(
                new Set<Id>{contentVersionInsert.ContentDocumentId}, new Set<String>{'Id'}
            );
        Test.stopTest();

        System.assertNotEquals(0, contentVersionList.size(), 'ContentVersion list is empty when not expected.');
    }

    @isTest
    private static void testGetContentVersionByIdShouldReturnList() {
        ContentVersion contentVersionInsert = [SELECT Id, Title, ContentDocumentId FROM ContentVersion 
            WHERE Id= :TST_CLM_TestDataFactory.createContentVersion(true).Id LIMIT 1];

        Test.startTest();
            List<ContentVersion> contentVersionList = SRV_CLM_ContentVersion.getContentVersionById(
                new Set<Id>{contentVersionInsert.Id});
        Test.stopTest();

        System.assertNotEquals(0, contentVersionList.size(), 'ContentVersion list is empty when not expected.');
    }

    @isTest
    private static void testInsertContentVersionShouldReturnContentVersion() {
        ContentVersion contentVersionInsert = TST_CLM_TestDataFactory.createContentVersion(false);

        Test.startTest();
            ContentVersion contVersion = SRV_CLM_ContentVersion.insertContentVersion(contentVersionInsert);
        Test.stopTest();

        System.assertNotEquals(null, contVersion, 'ContentVersion is null when not expected.');
    }
    
    @isTest
    private static void testGetContentVersions() {
        ContentVersion contentVersion = [SELECT Id, Title, ContentDocumentId FROM ContentVersion 
            WHERE Id= :TST_CLM_TestDataFactory.createContentVersion(true).Id LIMIT 1];
        String condition = 'ContentDocumentId IN :docIds';

        Test.startTest();
            List<ContentVersion> contentVersions = SRV_CLM_ContentVersion.getContentVersions(condition, 
                new Set<Id>{contentVersion.ContentDocumentId});
        Test.stopTest();

        System.assertEquals(1, contentVersions.size(), 'Should return ContentVersion');
    }
}