@isTest
public class TST_DAOH_CLM_ContentDocumentLink {

    @testSetup
    static void dataSetup() {    
        User salesUser = UTL_TestData.createUser('Sales User', 1).get(0);
        insert salesUser;
        
        List<PermissionSetAssignment> lstPSA = new List<PermissionSetAssignment>();
        lstPSA.add(UTL_TestData.createPermissionSetAssignmentRecord('CLM_USBU', salesUser.Id));
        lstPSA.add(UTL_TestData.createPermissionSetAssignmentRecord('CLM_IQVIA_Licensed_User', salesUser.Id));
        lstPSA.add(UTL_TestData.createPermissionSetAssignmentRecord('CLM_IQVIA_Base', salesUser.Id));
        lstPSA.add(UTL_TestData.createPermissionSetAssignmentRecord('CLM_IQVIA_DocuSign_Permission_Set', salesUser.Id));
        insert lstPSA;
        
        System.runAs(salesUser) {
            IQVIA_Agreement__c agr = TST_CLM_TestDataFactory.createIQAgreement(CON_CLM.USBU_IQVIA_RECORDTYPEID, false);
            agr.Name = 'Test IQVIA Agreement';
            insert agr;
            
            IQ_DocuSignEnvelope__c docusignEnvelope = new IQ_DocuSignEnvelope__c();
            docusignEnvelope.Status__c = 'Sent';
            docuSignEnvelope.Agreement__c = agr.Id;
            insert docusignEnvelope;
            
            Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.GENERIC_RECORDTYPEID, false);
            agreement.Name = 'Test Agreement';
            agreement.IQVIA_Agreement__c = agr.Id;
            insert agreement;
            
            Apttus__DocumentVersion__c dv = new Apttus__DocumentVersion__c();
            dv.Name = 'Test Doc';
            dv.Apttus__AgreementId__c = agreement.Id;
            dv.Apttus__LatestVersion__c = '1.0.0';
            dv.Apttus__Title__c ='Test';
            insert dv;
            
            Apttus__DocumentVersionDetail__c dvd = new Apttus__DocumentVersionDetail__c();
            dvd.Name = 'Test Version';
            dvd.Apttus__DocumentVersionId__c = dv.Id;
            dvd.Apttus__Title__c = 'Test';
            dvd.Apttus__VersionMajor__c = 1;
            dvd.Apttus__VersionMinor__c = 0;
            dvd.Apttus__VersionRevision__c = 0;
            dvd.Apttus__Action2__c = CON_CLM.GENERATE_AGREEMENT;
            insert dvd;
            
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Test';      
            cv.PathOnClient = 'abc.jpg';
            cv.VersionData = Blob.valueOf('Test Content'); 
            insert cv;
            
            List<ContentDocument> contDocs = [SELECT Id, Title FROM ContentDocument WHERE Title = 'Test'];
            ContentDocumentLink contentDocLink = new ContentDocumentLink();
            contentDocLink.LinkedEntityId = dvd.Id;
            contentDocLink.ContentDocumentId = contDocs[0].Id; 
            insert contentDocLink;
        }
    }
    
    @isTest
    private static void testCloneGeneratedFileForRequestor() {
        User salesUser = [SELECT Id FROM User WHERE Email = 'testuser3133@iqvia.com' LIMIT 1];
        System.runAs(salesUser) {
            Apttus__DocumentVersionDetail__c dvd = [SELECT Id FROM Apttus__DocumentVersionDetail__c WHERE Name = 'Test Version' LIMIT 1];
            List<ContentDocumentLink> lstConDocLink = [SELECT LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: dvd.Id];
                
            Test.startTest();
                DAOH_CLM_ContentDocumentLink.cloneGeneratedFileForRequestor(lstConDocLink);
            Test.stopTest();
                
            List<ContentDocument> lstConDoc = [SELECT Id FROM ContentDocument WHERE Description =: CON_CLM.GENERATED_FILE];
            Assert.isTrue(!lstConDoc.isEmpty(), 'The file must be cloned.');
        }
    }
    
    @isTest
    private static void testShareDocusignDocumentsWithAgreement() {
        User salesUser = [SELECT Id FROM User WHERE Email = 'testuser3133@iqvia.com' LIMIT 1];
        System.runAs(salesUser) {
            IQ_DocuSignEnvelope__c docEnv = [SELECT Id, Agreement__c FROM IQ_DocuSignEnvelope__c LIMIT 1];     
            ContentDocumentLink contentDocLink = new ContentDocumentLink();
            contentDocLink.LinkedEntityId = docEnv.Id;
            
            Test.startTest();
                DAOH_CLM_ContentDocumentLink.shareDocusignDocumentsWithAgreement(new List<ContentDocumentLink>{contentDocLink});
            Test.stopTest();
            
            Assert.areEqual(docEnv.Agreement__c, contentDocLink.LinkedEntityId, 'The ids must match.');
        } 
    }
}