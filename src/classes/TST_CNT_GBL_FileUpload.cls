@isTest
public class TST_CNT_GBL_FileUpload {
    @isTest
    private static void testUploadFileToSharepoint() {
        TST_UTL_SharepointFactory.createCustomSetting();
        ContentVersion objContentVersion = TST_UTL_SharepointFactory.createContentVersion(true);
        List<ContentDocument> lstContentDocument = [SELECT Id FROM ContentDocument];
        Apttus__APTS_Agreement__c objAgreement = TST_UTL_SharepointFactory.createAgreement(null, true);

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TST_Mock_UTL_Sharepoint());
            CNT_GBL_FileUpload.uploadFileToSharepoint(new List<Id>{lstContentDocument[0].Id}, objAgreement.Id, false, null);
            List<Sharepoint_File__c> lstSharepointFile = [SELECT Id FROM Sharepoint_File__c];
        Test.stopTest();
        
        System.assertEquals(1, lstSharepointFile.size(), 'Error in Uploading file');
    }

    @isTest
    private static void testUploadFileToSharepointForAttachment(){
        TST_UTL_SharepointFactory.createCustomSetting();
        ContentVersion objContentVersion = TST_UTL_SharepointFactory.createContentVersion(true);
        Apttus__APTS_Agreement__c objAgreement = TST_UTL_SharepointFactory.createAgreement(null, true);
        Attachment attach = TST_CLM_TestDataFactory.createAttachment(objAgreement.Id, 'test.docx', false);
        attach.Description = String.valueOf(objContentVersion.ContentDocumentId);
        insert attach;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TST_Mock_UTL_Sharepoint());
            CNT_GBL_FileUpload.uploadFileToSharepoint(new List<Id>{objContentVersion.ContentDocumentId}, objAgreement.Id, true, null);
            List<Sharepoint_File__c> lstSharepointFile = [SELECT Id FROM Sharepoint_File__c];
        Test.stopTest();
        
        System.assertNotEquals(null, lstSharepointFile, 'Error in Uploading file');
    }

    @isTest
    private static void testUploadFileToSharepointForAttachmentWithFolder() {
        TST_UTL_SharepointFactory.createCustomSetting();
        ContentVersion objContentVersion = TST_UTL_SharepointFactory.createContentVersion(true);
        Apttus__APTS_Agreement__c objAgreement = TST_UTL_SharepointFactory.createAgreement(null, true);
        Attachment attach = TST_CLM_TestDataFactory.createAttachment(objAgreement.Id, 'test.docx', false);
        attach.Description = String.valueOf(objContentVersion.ContentDocumentId);
        insert attach;

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TST_Mock_UTL_Sharepoint());
            CNT_GBL_FileUpload.uploadFileToSharepoint(new List<Id>{objContentVersion.ContentDocumentId}, objAgreement.Id, 
                true, 'Customer Deliverable');
            List<Sharepoint_File__c> lstSharepointFile = [SELECT Id FROM Sharepoint_File__c];
        Test.stopTest();
        
        System.assertNotEquals(null, lstSharepointFile, 'Error in Uploading file');
    }
}