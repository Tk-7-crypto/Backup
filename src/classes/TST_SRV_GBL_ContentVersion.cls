@isTest
private class TST_SRV_GBL_ContentVersion {
    @isTest
    private static void testGetFileInstanceList(){
        ContentVersion objContentVersion = TST_UTL_SharepointFactory.createContentVersion(true);
        List<ContentDocument> lstContentDocument = [SELECT Id FROM ContentDocument];
        Test.startTest();
            List<UTL_Sharepoint.FileInstance> lstFileInstance = SRV_GBL_ContentVersion.getFileInstanceList(new Set<Id>{lstContentDocument[0].Id}, '123123123123123');
        Test.stopTest();
        
        System.assertEquals(1, lstFileInstance.size(), 'Multiple ContentVersion Found');
    }
}