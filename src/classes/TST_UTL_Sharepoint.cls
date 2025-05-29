@isTest
private class TST_UTL_Sharepoint {
    @testSetup
    private static void testSetupData() {
        TST_UTL_SharepointFactory.createCustomSetting();
    }
    
    @isTest
    private static void testGetSharepointConfigShouldReturnObject(){
        Test.startTest();
            Sharepoint_Config__c config =UTL_Sharepoint.getSharepointConfig();
        Test.stopTest();

        System.assertNotEquals(null, config, 'No Custom Setting Found.');
    }

    @isTest
    private static void testGetSharepointConfigShouldReturnThrowException(){
        String errorMsg;
        try{
            Test.startTest();
                Sharepoint_Config__c config =UTL_Sharepoint.getSharepointConfig('Invalid Module');
            Test.stopTest();
        }
        catch(Exception e){
            errorMsg = e.getMessage();
        }
        System.assertNotEquals(null, errorMsg, 'No Exception Thrown');
    }

    @isTest
    private static void testSetInitialsShouldReturnAccessTokenVal(){
        Sharepoint_Config__c config =UTL_Sharepoint.getSharepointConfig();
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TST_Mock_UTL_Sharepoint());
            UTL_Sharepoint.SetInitials(config);
        Test.stopTest();

        System.assertNotEquals(null, UTL_Sharepoint.accessTokenVal,'No AccessToken found');
        System.assertNotEquals(null, UTL_Sharepoint.formDigestValue,'No FormDigestValue found');
    }
    
    @isTest
    private static void testCreateFolderShouldReturnString(){
        Sharepoint_Config__c config =UTL_Sharepoint.getSharepointConfig();
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TST_Mock_UTL_Sharepoint());
            String folderUrl = UTL_Sharepoint.createFolder('test', config);
        Test.stopTest();

        System.assertNotEquals(null, folderUrl,'Invalid Folder Url');
    }

    @isTest
    private static void testDeleteFolderShouldReturnString(){
        Sharepoint_Config__c config =UTL_Sharepoint.getSharepointConfig();
        Apttus__APTS_Agreement__c objAgreement = TST_UTL_SharepointFactory.createAgreement(null, true);
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TST_Mock_UTL_Sharepoint());
            HttpResponse res = UTL_Sharepoint.deleteFolder(objAgreement.Id, config);
        Test.stopTest();

        System.assertEquals(200, res.getStatusCode(),'No Folder Deleted');
    }

    @isTest
    private static void testCreateFileShouldReturnString(){
        Apttus__APTS_Agreement__c objAgreement = TST_UTL_SharepointFactory.createAgreement(null, true);
        UTL_Sharepoint.FileInstance objFileInstance = new UTL_Sharepoint.FileInstance();
        objFileInstance.fileName = 'test.pdf';
        objFileInstance.fileBody = Blob.valueOf('Test String');
        objFileInstance.fileLength = Blob.valueOf('Test String').size(); 
        objFileInstance.parentId = objAgreement.Id;
        Sharepoint_Config__c config =UTL_Sharepoint.getSharepointConfig();
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TST_Mock_UTL_Sharepoint());
            objFileInstance = UTL_Sharepoint.createFile(objFileInstance, config);
        Test.stopTest();

        System.assertNotEquals(null, objFileInstance.fileUrl,'Invalid Folder Url');
    }

    @isTest
    private static void testCreateFileWithFolderShouldReturnString() {
        Apttus__APTS_Agreement__c objAgreement = TST_UTL_SharepointFactory.createAgreement(null, true);
        UTL_Sharepoint.FileInstance objFileInstance = new UTL_Sharepoint.FileInstance();
        objFileInstance.fileName = 'test.pdf';
        objFileInstance.fileBody = Blob.valueOf('Test String');
        objFileInstance.fileLength = Blob.valueOf('Test String').size();
        objFileInstance.parentId = objAgreement.Id;
        objFileInstance.folderName = 'Other';
        Sharepoint_Config__c config = UTL_Sharepoint.getSharepointConfig();
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TST_Mock_UTL_Sharepoint());
            objFileInstance = UTL_Sharepoint.createFile(objFileInstance, config);
        Test.stopTest();

        System.assertNotEquals(null, objFileInstance.fileUrl,'Invalid Folder Url');
    }

    @isTest
    private static void testDeleteFileShouldReturnStatusOK() {
        Sharepoint_Config__c config =UTL_Sharepoint.getSharepointConfig();
        Apttus__APTS_Agreement__c objAgreement = TST_UTL_SharepointFactory.createAgreement(null, true);
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TST_Mock_UTL_Sharepoint());
            HttpResponse res = UTL_Sharepoint.deleteFile(objAgreement.Id, 'test.pdf', config, null);
        Test.stopTest();

        System.assertEquals(200, res.getStatusCode(),'No File Deleted');
    }

    @isTest
    private static void testReadFileShouldReturnValidRes() {
        Sharepoint_File__c objSharepointFile = TST_UTL_SharepointFactory.createSharepointFile(true);
        Sharepoint_Config__c config = UTL_Sharepoint.getSharepointConfig();
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TST_Mock_UTL_Sharepoint());
            HttpResponse res = UTL_Sharepoint.readFile(objSharepointFile, config, null);
            String contentDisposition = res.getHeader('attachment');
        Test.stopTest();

        System.assertEquals(null, contentDisposition, 'No Content Found');
    }

    @isTest
    private static void testReadFileFromFolderShouldReturnValidRes() {
        Sharepoint_File__c objSharepointFile = TST_UTL_SharepointFactory.createSharepointFile(true);
        Sharepoint_Config__c config = UTL_Sharepoint.getSharepointConfig();
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TST_Mock_UTL_Sharepoint());
            HttpResponse res = UTL_Sharepoint.readFile(objSharepointFile, config, 'Other');
            String contentDisposition = res.getHeader('attachment');
        Test.stopTest();

        System.assertEquals(null, contentDisposition, 'No Content Found');
    }

    @isTest
    private static void testGetParentByIdShouldNotReturnNull(){
        Sharepoint_File__c objSharepointFile = TST_UTL_SharepointFactory.createSharepointFile(true);
        
        Test.startTest();
            List<SObject> lstSObject = UTL_Sharepoint.getParentById(objSharepointFile.Parent_Id__c);
        Test.stopTest();

        System.assertNotEquals(null, lstSObject, 'No Parent Found');
    }

    @isTest
    private static void testDeleteRelatedFileShouldReturnTrue(){
        Sharepoint_File__c objSharepointFile = TST_UTL_SharepointFactory.createSharepointFile(true);
        
        Test.startTest();
            Boolean result = UTL_Sharepoint.deleteRelatedFile(new List<Sharepoint_File__c>{objSharepointFile}, null);
        Test.stopTest();
        
        System.assertEquals(true, result, 'No Record Deleted.');
    }
    @isTest
    private static void testGetParentObjectApiNameShouldReturnValidLabel(){
        Sharepoint_File__c objSharepointFile = TST_UTL_SharepointFactory.createSharepointFile(true);
        
        Test.startTest();
            Map<String, String> result = UTL_Sharepoint.getParentObjectApiName(objSharepointFile.Parent_Id__c);
        Test.stopTest();

        System.assertEquals('Agreement', result.get('objLabel'), 'Invalid Parent Object Name');
    }
}