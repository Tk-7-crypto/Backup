@isTest
private class TST_SLT_DocumentVersion {
    @testSetup
    static void dataSetup() {
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        agreement.Name = 'Test Agreement';
        insert agreement;

        Apttus__DocumentVersion__c documentVersion = new Apttus__DocumentVersion__c();
        documentVersion.Apttus__IsTransient__c = false;
        documentVersion.Apttus__AgreementId__c = agreement.Id;
        documentVersion.Apttus__Title__c = 'test document';
        documentVersion.Apttus__LatestVersion__c = '1.0.0';
        insert documentVersion;

        Apttus__DocumentVersionDetail__c documentVersionDetail = new Apttus__DocumentVersionDetail__c();
        documentVersionDetail.Apttus__DocumentVersionId__c = documentVersion.Id;
        documentVersionDetail.Apttus__IsTransient__c = false;
        documentVersionDetail.Apttus__Title__c = 'test document';
        documentVersionDetail.Apttus__VersionMajor__c = 1;
        documentVersionDetail.Apttus__VersionMinor__c = 0;
        documentVersionDetail.Apttus__VersionRevision__c = 0;
        insert documentVersionDetail;
    }
    
    @isTest
    static void testGetDocumentVersionByDocumentVersionDetail() {
        SLT_DocumentVersion sltDocumentVersion = new SLT_DocumentVersion();
        List<Apttus__DocumentVersionDetail__c> documentVersionDetailRecord = [SELECT Id, Apttus__DocumentVersionId__c FROM Apttus__DocumentVersionDetail__c WHERE Apttus__Title__c = 'test document' LIMIT 1];
        Set<String> fieldSet = new Set<String> {'Id', 'Apttus__Title__c'};

        Test.startTest();
            Apttus__DocumentVersion__c documentVersionRecord = sltDocumentVersion.getDocumentVersionById(documentVersionDetailRecord[0].Apttus__DocumentVersionId__c, fieldSet);
        Test.stopTest();

        System.assertEquals(true, documentVersionRecord != null, 'Document Version record is not returned.');
    }

    @isTest
    private static void testGetDocumentVersionByAgreementId() {
        Apttus__APTS_Agreement__c agreement = [SELECT Id FROM Apttus__APTS_Agreement__c LIMIT 1];
        
        Test.startTest();
            List<Apttus__DocumentVersion__c> result = new SLT_DocumentVersion().getDocumentVersionByAgreementId(new Set<Id>{agreement.Id}, 
                new Set<String>{'Id'});
        Test.stopTest();
        
        System.assertNotEquals(0, result.size(), 'The list should not be empty');
    }

    @isTest
    private static void testGetDocumentVersionByConditions() {
        Apttus__APTS_Agreement__c agreement = [SELECT Id FROM Apttus__APTS_Agreement__c LIMIT 1];
        String condition = 'Apttus__AgreementId__c IN: agreementIds';
        Test.startTest();
            List<Apttus__DocumentVersion__c> result = new SLT_DocumentVersion().getDocumentVersionByConditions(new Set<Id>{agreement.Id}, 
                new Set<String>{'Id'}, condition);
        Test.stopTest();
        
        System.assertNotEquals(0, result.size(), 'The list should not be empty');
    }
    
    @isTest
    private static void testGetDocumentVersionWithDetails() {
        Apttus__DocumentVersion__c docVersion = [SELECT Id FROM Apttus__DocumentVersion__c LIMIT 1];
        
        Test.startTest();
            List<Apttus__DocumentVersion__c> docVersionList = new SLT_DocumentVersion().getDocumentVersionWithDetails(new Set<Id>{docVersion.Id}, new Set<String>{'Id', 'Name'}, new Set<String>{'Id'});
        Test.stopTest();
        
        System.assertEquals(1, docVersionList.size(), 'Returned Document Versions List size is not 1');
    }
}