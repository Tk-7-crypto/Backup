@isTest
private class TST_SRV_CLM_Attachment {
    @TestSetup
    static void testSetup() {
        upsert new  Mulesoft_Integration_Control__c(Enable_OLIS_JSON__c = true, Is_Mulesoft_User__c = false, Enable_OLI_Sync_Validation__c = true, Enable_Opportunity_Sync_Validation__c = true);
    }


    @isTest
    private static void testGetAttachmentByParentShouldReturnAttachmentList() {
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(null, true);
        Attachment attach = UTL_TestData.createAttachment();
        attach.Name = 'Test Attachment';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.Body = bodyBlob;
        attach.ParentId = agreement.Id;
        insert attach;

        Test.startTest();
            List<Attachment> attachmentList = SRV_CLM_Attachment.getAttachmentByParent(new Set<String>{'Id', 'Name'}, agreement.Id);
        Test.stopTest();
        
        System.assertEquals(1, attachmentList.size(), 'Attachment list size should be 1 but it is not.');
    }

    @isTest
    private static void testGetAttachmentsShouldReturnAttachmentList(){
        Apttus__APTS_Agreement__c objAgreement = TST_CLM_TestDataFactory.createAgreement(null, true);
        Attachment objAttachment = TST_CLM_TestDataFactory.createAttachment(objAgreement.Id, 'Test Attachment.pdf', true);
        Set<String> fieldsForAttachment = new Set<String>{'Id','Description','Body','Name','ContentType','BodyLength'};
        String conditionForAttachment= 'parentId = \'' + objAgreement.id +'\'' ;
        
        Test.startTest();
            List<Attachment> lstAttachment = SRV_CLM_Attachment.getAttachments(fieldsForAttachment, conditionForAttachment);
        Test.stopTest();

        System.assertEquals(1, lstAttachment.size(), 'Should Return List of Attachment.');
    }

    @isTest
    private static void testUpdateListOfAttachmentsShouldReturnTrue(){
        Apttus__APTS_Agreement__c objAgreement = TST_CLM_TestDataFactory.createAgreement(null, true);
        Attachment objAttachment = TST_CLM_TestDataFactory.createAttachment(objAgreement.Id, 'Test Attachment.pdf', true);

        Test.startTest();
            Boolean result = SRV_CLM_Attachment.updateListOfAttachments(new List<Attachment>{objAttachment});
        Test.stopTest();

        System.assertEquals(true, result, 'Should Update Attachments');
    }


    @isTest
    private static void testUpdateListOfAttachmentsShouldThrowException(){
        Apttus__APTS_Agreement__c objAgreement = TST_CLM_TestDataFactory.createAgreement(null, true);
        Attachment objAttachment = TST_CLM_TestDataFactory.createAttachment(objAgreement.Id, 'Test Attachment.pdf', true);
        objAttachment.Name = null;

         Test.startTest();
            try{
                Boolean result =
                    SRV_CLM_Attachment.updateListOfAttachments(new List<Attachment>{objAttachment});
            }catch(Exception ex){
                System.assertEquals('SRV_CLM_Attachment.SRV_CLM_Attachment_Exception', ex.getTypeName());
            }
        Test.stopTest();
    }

    @isTest
    private static void testDeleteListOfAttachmentsShouldThrowException(){
        Apttus__APTS_Agreement__c objAgreement = TST_CLM_TestDataFactory.createAgreement(null, true);
        Attachment objAttachment = TST_CLM_TestDataFactory.createAttachment(objAgreement.Id, 'Test Attachment.pdf', true);
        objAttachment.Name = null;

        Test.startTest();
            try{
                Boolean result =
                    SRV_CLM_Attachment.deleteListOfAttachments(new List<Attachment>{objAttachment});
            }catch(Exception ex){
                System.assertEquals('SRV_CLM_Attachment.SRV_CLM_Attachment_Exception', ex.getTypeName());
            }
        Test.stopTest();
    }

    @isTest
    private static void testGetAttachmentByIdShouldReturnList() {
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(null, true);
        Attachment attach = TST_CLM_TestDataFactory.createAttachment(agreement.Id, 'Test Attachment', true);

        Test.startTest();
            List<Attachment> attachmentList = SRV_CLM_Attachment.getAttachmentById(new Set<String>{'Id'}, new Set<Id>{attach.Id});
        Test.stopTest();

        System.assertNotEquals(0, attachmentList.size(), 'Attachment list is empty when not expected.');
    }

    @isTest
    private static void testUpdateAttachmentShouldReturnAttachment() {
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(null, true);
        Attachment attach = TST_CLM_TestDataFactory.createAttachment(agreement.Id, 'Test Attachment', true);
        attach.Name = 'Updated Test Attachment';

        Test.startTest();
            Attachment result = SRV_CLM_Attachment.updateAttachment(attach);
        Test.stopTest();

        System.assertEquals('Updated Test Attachment', result.Name, 'Attachment not updated.');
    }

    @isTest
    private static void testUpdateAttachmentShouldThrowException() {
        Test.startTest();
            try {
                SRV_CLM_Attachment.updateAttachment(null);
            } catch(Exception ex) {
                System.assertNotEquals(null, ex, 'Must throw an exception.');
            }
        Test.stopTest();
    }

    @isTest
    private static void testUpdateListOfAttachmentsShouldReturnFalse(){
        Apttus__APTS_Agreement__c objAgreement = TST_CLM_TestDataFactory.createAgreement(null, true);
        
        Test.startTest();
            Boolean result = SRV_CLM_Attachment.updateListOfAttachments(new List<Attachment>());
        Test.stopTest();

        System.assertEquals(false, result, 'List of Attachment must be empty');
    }

    @isTest
    private static void testDeleteListOfAttachmentsShouldReturnTrue(){
        Apttus__APTS_Agreement__c objAgreement = TST_CLM_TestDataFactory.createAgreement(null, true);
        Attachment objAttachment = TST_CLM_TestDataFactory.createAttachment(objAgreement.Id, 'Test Attachment.pdf', true);
        
        Test.startTest();
            Boolean result = SRV_CLM_Attachment.deleteListOfAttachments(new List<Attachment>{objAttachment});
        Test.stopTest();

        System.assertEquals(true, result, 'Should Update Attachments');
    }

    @isTest
    private static void testDeleteListOfAttachmentsShouldReturnFalse(){
        Apttus__APTS_Agreement__c objAgreement = TST_CLM_TestDataFactory.createAgreement(null, true);
        
        Test.startTest();
            Boolean result = SRV_CLM_Attachment.deleteListOfAttachments(new List<Attachment>());
        Test.stopTest();

        System.assertEquals(false, result, 'List of Attachment must be empty');
    }

    @isTest
    private static void testUpdateAttachmentsShouldReturnAttachment(){
        Apttus__APTS_Agreement__c objAgreement = TST_CLM_TestDataFactory.createAgreement(null, true);
        Attachment objAttachment = TST_CLM_TestDataFactory.createAttachment(objAgreement.Id, 'Test Attachment.pdf', true);

        Test.startTest();
            Attachment attach = SRV_CLM_Attachment.updateAttachment(objAttachment);
        Test.stopTest();

        System.assertNotEquals(null, attach, 'Should Update Attachment');
    }
    
    @isTest
    private static void testGetLatestAttachments() {
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(null, true);
        Attachment attach = TST_CLM_TestDataFactory.createAttachment(agreement.Id, 'Test Attachment', true);
        String condition = ' Name like \'%Test Attachment%\''+
            'and ParentId IN :parentIds';

        Test.startTest();
            List<Attachment> attachmentList = SRV_CLM_Attachment.getLatestAttachments(condition, new Set<Id>{agreement.Id});
        Test.stopTest();

        System.assertNotEquals(0, attachmentList.size(), 'Attachment list is empty when not expected.');
        System.assertEquals(1, attachmentList.size(), 'Attachment list should have one Attachment.');
    }
}