@isTest
private class TST_SRV_GBL_ContentDocument {
    @isTest
    private static void testDeleteRecordShouldReturnTrue(){
        ContentVersion objContentVersion = TST_UTL_SharepointFactory.createContentVersion(true);
        List<ContentDocument> lstContentDocument = [SELECT Id FROM ContentDocument];

        Test.startTest();
            Boolean result = SRV_GBL_ContentDocument.deleteRecord(new Set<Id>{lstContentDocument[0].Id});
        Test.stopTest();

        System.assertEquals(true, result, 'Error in Deleting Record');
    }

    @isTest
    private static void testDeleteRecordShouldThrowException(){
        try{
            Test.startTest();
                Boolean result = SRV_GBL_ContentDocument.deleteRecord(null);
            Test.stopTest();
        }catch(Exception e){
            System.assertEquals(e.getTypeName(), 'SRV_GBL_ContentDocument.SRV_GBL_ContentDocument_Exception', 'It should throw Exception');
        }
    }
}