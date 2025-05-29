@isTest
public class TST_BCH_CLM_AttachmentToSalesforceFiles {
    @testSetup
    static void dataSetup() {
        Apttus__APTS_Agreement__c testAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        testAgreement.Name = 'Test Agreement';
        insert testAgreement;
        
        Attachment attachment = TST_CLM_TestDataFactory.createAttachment(
            testAgreement.Id, 'GeneratedDocument_' + testAgreement.Name + '.docx', false);
        attachment.OwnerId = UserInfo.getUserId();
        attachment.body= Blob.valueOf('Test Body');
        insert attachment;
        
        upsert new  Mulesoft_Integration_Control__c(Enable_OLIS_JSON__c = true, 
            Is_Mulesoft_User__c = true, Enable_OLI_Sync_Validation__c = true, Enable_Opportunity_Sync_Validation__c = true);
    }
    
    @isTest
    private static void testAttachmentToSalesforceFileBatch() {
        Log_Setting__c logSetting = new Log_Setting__c();
        logSetting.Name = 'CLM';
        logSetting.Severity_Level__c = 'INFO';
        logSetting.Log_Data_to_keep_for__c = 10;
        insert logSetting;
        
        Test.startTest();
            BCH_CLM_AttachmentToSalesforceFiles attachmentToSalesforceFilesBatch = 
                new BCH_CLM_AttachmentToSalesforceFiles(
                'SELECT Id, Name, Body, Description, ParentId, IsPrivate, OwnerId, CreatedDate, LastModifiedById,' +
                'LastModifiedDate FROM Attachment WHERE Parent.Type IN (\'Apttus__APTS_Agreement__c\')');
            Id batchId = Database.executeBatch(attachmentToSalesforceFilesBatch);
        Test.stopTest();
        
        System.assertEquals(1, [SELECT count() FROM ContentVersion LIMIT 1]);
        System.assertEquals(1, [SELECT count() FROM Attachment LIMIT 1]);//not deleting from batch
    }
}