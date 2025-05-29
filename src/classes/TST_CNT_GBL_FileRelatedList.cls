@isTest
private class TST_CNT_GBL_FileRelatedList {
    
    @isTest
    private static void testInitDataShouldReturnString() {
        Sharepoint_File__c objSharepoint = TST_UTL_SharepointFactory.createSharepointFile(true);
        Map<String, String> mapJsonData = new Map<String, String>();
        mapJsonData.put('recordId', objSharepoint.Parent_Id__c);
        mapJsonData.put('numberOfRecords', '6');
        String strJsonData = JSON.serialize(mapJsonData);

        Test.startTest();
            String jsonResData = CNT_GBL_FileRelatedList.initData(strJsonData);
        Test.stopTest();

        System.assertNotEquals(null, jsonResData, 'Should return some Response Data');
    }

    @isTest
    private static void testInitDataShouldReturnStringWithFolder() {
        Sharepoint_File__c objSharepoint = TST_UTL_SharepointFactory.createSharepointFile(true);
        Map<String, String> mapJsonData = new Map<String, String>();
        mapJsonData.put('recordId', objSharepoint.Parent_Id__c);
        mapJsonData.put('numberOfRecords', '6');
        mapJsonData.put('folderName', 'Other,Approvals');
        String strJsonData = JSON.serialize(mapJsonData);

        Test.startTest();
            String jsonResData = CNT_GBL_FileRelatedList.initData(strJsonData);
        Test.stopTest();

        System.assertNotEquals(null, jsonResData, 'Should return some Response Data');
    }

    @isTest
    private static void testDeleteRecordShouldReturnTrue() {
        TST_UTL_SharepointFactory.createCustomSetting();
        Sharepoint_File__c objSharepoint = TST_UTL_SharepointFactory.createSharepointFile(true);
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TST_Mock_UTL_Sharepoint());
            Boolean result = CNT_GBL_FileRelatedList.deleteRecord(objSharepoint.Id, null);
        Test.stopTest();

        System.assertEquals(true, result, 'Error in Deleting File');
    }


    @isTest
    private static void testGetParentRecordNameShouldReturnString() {
        TST_UTL_SharepointFactory.createCustomSetting();
        Sharepoint_File__c objSharepoint = TST_UTL_SharepointFactory.createSharepointFile(true);
        
        Test.startTest();
            String parentRecordName = CNT_GBL_FileRelatedList.getParentRecordName(objSharepoint.Parent_Id__c);
        Test.stopTest();

        System.assertEquals('Test Agreement', parentRecordName, 'Should Return Parent Object Record Name');
    }
}