@isTest
private class TST_TGR_Attachment {
    
    @isTest
    private static void testBeforeInsertCLMGCEAgreementAttachment() {
        Log_Setting__c logSetting = new Log_Setting__c();
        logSetting.Name = 'CLM';
        logSetting.Severity_Level__c = 'INFO';
        logSetting.Log_Data_to_keep_for__c = 10;
        insert logSetting;
        
        CLM_Configuration__c clmConfiguration = TST_CLM_TestDataFactory.createClmConfigurationSetting(false);
        clmConfiguration.RecordTypeForStatusAutomation__c = 'PSA;MSA;Preliminary_Agreement';
        insert clmConfiguration;
        
        List<Attachment> attachmentList = new List<Attachment>();
        Account acct = new Account(Name = 'TestAcc',RDCategorization__c = 'Site',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert acct;
        
        Apttus__APTS_Agreement__c gceAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        gceAgreement.Name = 'Test Agreement';
        gceAgreement.Apttus__Account__c = acct.Id;
        insert gceAgreement ;
        dsfs__DocuSign_Status__c docuStatus = new dsfs__DocuSign_Status__c();
        docuStatus.Agreement__c = gceAgreement.Id;
        docuStatus.dsfs__Envelope_Status__c = 'Completed';
        docuStatus.Recipient_Signed_on_Paper__c = 'yes';
        insert docuStatus;
        
        Attachment completedAttachmentForGCE = new Attachment();
        completedAttachmentForGCE.OwnerId = UserInfo.getUserId();
        completedAttachmentForGCE.Name= 'docusignEnv-123.pdf';
        completedAttachmentForGCE.body= Blob.valueOf('Test Body GCE');
        completedAttachmentForGCE.ParentId = gceAgreement.Id;
        
        Test.startTest();
        	insert completedAttachmentForGCE; 
        Test.stopTest();
        
        System.assertNotEquals(null, completedAttachmentForGCE.Id, 'Attachment not created, when expected');
    }
		
}
