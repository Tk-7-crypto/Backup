@isTest
private class TST_SRV_GBL_SharepointFile {
    @testSetup
    private static void testSetupData(){
        TST_UTL_SharepointFactory.createCustomSetting();
    }

    @isTest
    private static void testCreateRecordShouldReturnSharepointRec() {
        Apttus__APTS_Agreement__c objAgreement = TST_UTL_SharepointFactory.createAgreement(null, true);
        List<Sharepoint_File__c> lstSharepointFile;
        UTL_Sharepoint.FileInstance objFileInstance = new UTL_Sharepoint.FileInstance();
        objFileInstance.fileName = 'Test.pdf';
        objFileInstance.fileBody = Blob.valueOf('Test');
        objFileInstance.fileLength = Blob.valueOf('Test').size();
        objFileInstance.parentId = objAgreement.Id;
        objFileInstance.fileUrl = 'test/test.pdf';
        
        Test.startTest();
            lstSharepointFile = SRV_GBL_SharepointFile.createRecord(new List<UTL_Sharepoint.FileInstance>{objFileInstance});
        Test.stopTest();

        System.assertNotEquals(null, lstSharepointFile, 'No Record created');
    }

    @isTest
    private static void testCreateRecordShouldThrowException(){
        Apttus__APTS_Agreement__c objAgreement = TST_UTL_SharepointFactory.createAgreement(null, true);
        List<Sharepoint_File__c> lstSharepointFile;
        UTL_Sharepoint.FileInstance objFileInstance = new UTL_Sharepoint.FileInstance();
        objFileInstance.fileName = 'Test.pdf';
        objFileInstance.fileBody = Blob.valueOf('Test');
        objFileInstance.fileLength = Blob.valueOf('Test').size();
        objFileInstance.fileUrl = '/test.pdf';
        
        try{
            Test.startTest();
                lstSharepointFile = SRV_GBL_SharepointFile.createRecord(new List<UTL_Sharepoint.FileInstance>{objFileInstance});
            Test.stopTest();
        }
        catch(Exception e){
            System.assertEquals('SRV_GBL_SharepointFile.SRV_GBL_SharepointFile_Exception', e.getTypeName(), 'Error in Required Field Missing');
        }
        System.assertEquals(null, lstSharepointFile, 'Exception Throw');
    }

    @isTest
    private static void testGetSharepointFilesByAgreementIdShouldReturnRec(){
        Sharepoint_File__c objSharepoint = TST_UTL_SharepointFactory.createSharepointFile(true);
        
        Test.startTest();
            List<Sharepoint_File__c> lstSharepoint = SRV_GBL_SharepointFile.getSharepointFilesByParentId(new Set<Id>{objSharepoint.Parent_Id__c});
        Test.stopTest();

        System.assertEquals(1, lstSharepoint.size(), 'No Record Found By Agreement');
    }

    @isTest
    private static void testGetSharepointFilesByAgreementIdShouldReturnRecWithFolder() {
        Sharepoint_File__c objSharepoint = TST_UTL_SharepointFactory.createSharepointFile(true);
        
        Test.startTest();
            List<Sharepoint_File__c> lstSharepoint = SRV_GBL_SharepointFile.getSharepointFilesByParentIdAndFolder(
                new Set<Id>{objSharepoint.Parent_Id__c}, 1, 'File_Url__c LIKE \'%test%\'');
        Test.stopTest();

        System.assertEquals(1, lstSharepoint.size(), 'No Record Found.');
    }

    @isTest
    private static void testdeleteRecordShouldReturnTrue() {
        Sharepoint_File__c objSharepoint = TST_UTL_SharepointFactory.createSharepointFile(true);
        
        Test.startTest();
            Boolean result = SRV_GBL_SharepointFile.deleteRecord(new Set<Id>{objSharepoint.Id}, null);
        Test.stopTest();

        System.assertEquals(true, result, 'Record not deleted');
    }

    @isTest
    private static void testdeleteRecordShouldThrowException(){
        Sharepoint_File__c objSharepoint = TST_UTL_SharepointFactory.createSharepointFile(true);
        Boolean result;

        try{
            Test.startTest();
                result = SRV_GBL_SharepointFile.deleteRecord(null, null);
            Test.stopTest();
        }
        catch(Exception e){
            System.assertEquals('SRV_GBL_SharepointFile.SRV_GBL_SharepointFile_Exception', e.getTypeName(), 'Error in Required Field Missing');
        }
        
        System.assertEquals(null, result, 'Record not deleted');
    }
}