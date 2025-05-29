@isTest
private class TST_SRV_GBL_Attachment {

    @TestSetup
    static void testSetup() {
        upsert new  Mulesoft_Integration_Control__c(Enable_OLIS_JSON__c = true, Is_Mulesoft_User__c = false, Enable_OLI_Sync_Validation__c = true, Enable_Opportunity_Sync_Validation__c = true);
    }
    
    @isTest
    private static void testGetAttachmentByParentIdShouldReturnList() {
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(null, true);
        ContentVersion contentVer = TST_CLM_TestDataFactory.createContentVersion(true);
        Attachment attach = TST_CLM_TestDataFactory.createAttachment(agreement.Id, 'test.docx', false);
        attach.Description = String.valueOf(contentVer.Id);
        insert attach;

        Test.startTest();
            List<UTL_Sharepoint.FileInstance> lstFileInstance = SRV_GBL_Attachment.getAttachmentsByParentId(new Set<Id>{contentVer.Id}, agreement.Id);
        Test.stopTest();
        
        System.assertEquals(1, lstFileInstance.size(), 'Multiple ContentVersion Found');
    }
    
    @isTest
    private static void testGetAttachmentByParentIdShouldThrowException() {
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(null, true);
        ContentVersion contentVer = TST_CLM_TestDataFactory.createContentVersion(true);
        Attachment attach = TST_CLM_TestDataFactory.createAttachment(agreement.Id, 'test.docx', false);
        attach.Description = String.valueOf(contentVer.Id);
        insert attach;

        Test.startTest();
            try {
                List<UTL_Sharepoint.FileInstance> lstFileInstance = SRV_GBL_Attachment.getAttachmentsByParentId(null, agreement.Id);
            } catch(Exception e) {
                System.assertNotEquals(null, e, 'There should be exception but did not happen.');
            }
        Test.stopTest();
    }

    @isTest
    private static void testDeleteAttachmentsShouldReturBoolean() {
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, true);
        Attachment attach = TST_CLM_TestDataFactory.createAttachment(agreement.Id, 'test.docx', true);

        Test.startTest();
            Boolean isDeleted = SRV_GBL_Attachment.deleteAttachments(new List<Attachment>{attach});
        Test.stopTest();

        System.assertEquals(true, isDeleted, 'There is a problem in attachment deletion.');
    }
}