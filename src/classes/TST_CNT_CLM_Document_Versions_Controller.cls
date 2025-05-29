@isTest
public class TST_CNT_CLM_Document_Versions_Controller {
    
    @testSetup
    static void dataSetup() {
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.RWS_RECORDTYPEID, false);
        agreement.Name = 'Test RWS';
        agreement.Apttus__Status_Category__c = 'Request';
        agreement.Apttus__Status__c = 'Request';
        insert agreement;

        IQVIA_Agreement__c iqAGR = TST_CLM_TestDataFactory.createIQAgreement(CON_CLM.USBU_IQVIA_RECORDTYPEID, false);
        iqAGR.Name = 'Test IQVIA AGR';
        iqAGR.Conga_Agreement_Id__c = agreement.Id;
        insert iqAGR;
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Content1';      
        cv.PathOnClient = 'abc.jpg';
        cv.VersionData = Blob.valueOf('Test Content1'); 
        insert cv;
        ContentDocument contDocs = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument WHERE Title = 'Test Content1' LIMIT 1]; 
        
        Apttus__DocumentVersion__c docVer = new Apttus__DocumentVersion__c();
        docVer.Apttus__AgreementId__c = agreement.Id;
        docVer.Name = 'Generate Document';
        docVer.Apttus__Title__c = 'Test.docx';
        docVer.Apttus__LatestVersion__c = '1.0.0';
        insert docVer;
        
        Apttus__DocumentVersionDetail__c docVerDetail = new Apttus__DocumentVersionDetail__c();
        docVerDetail.Apttus__DocumentVersionId__c = docVer.Id;
        docVerDetail.Apttus__ContentId__c = contDocs.Id;
        docVerDetail.Name = '1.0.0';
        docVerDetail.Apttus__Title__c = 'Test.docx';
        docVerDetail.Apttus__Action2__c = 'Generate Agreement';
        docVerDetail.Apttus__VersionMajor__c = 1;
        docVerDetail.Apttus__VersionMinor__c = 0;
        docVerDetail.Apttus__VersionRevision__c = 0;
        insert docVerDetail;
        
        docVer.Apttus__LatestVersionId__c = docVerDetail.Id;
        docVer.Apttus__CheckoutById__c = UserInfo.getUserId();
        docVer.Apttus__CheckoutDate__c = System.today();
        docVer.Apttus__CheckoutVersionDetailId__c = docVerDetail.Id;
        update docVer;
    }
    
    @isTest
    private static void testGetAllDocVersions() {
        Apttus__APTS_Agreement__c agreement = [SELECT Id FROM Apttus__APTS_Agreement__c LIMIT 1];
        
        Test.startTest();
            List<Apttus__DocumentVersion__c> docVerList = CNT_CLM_Document_Versions_Controller.getAllDocVersions(agreement.Id);
        Test.stopTest();
        
        System.assertNotEquals(0, docVerList.size(), 'The document versions should not be empty');
    }

    @isTest
    private static void testGetAllDocVersionsIQAGR() {
        IQVIA_Agreement__c agreement = [SELECT Id,Conga_Agreement_Id__c FROM IQVIA_Agreement__c WHERE Name = 'Test IQVIA AGR' LIMIT 1];
        
        Test.startTest();
            List<Apttus__DocumentVersion__c> docVerList = CNT_CLM_Document_Versions_Controller.getAllDocVersions(agreement.Id);
        Test.stopTest();
        
        System.assertNotEquals(0, docVerList.size(), 'The document versions should not be empty');
    }
    
    @isTest
    private static void testUpdateDocumentTitle() {
        Apttus__DocumentVersion__c docVer = [SELECT Id FROM Apttus__DocumentVersion__c WHERE Apttus__Title__c = 'Test.docx' LIMIT 1];
        
        Test.startTest();
            CNT_CLM_Document_Versions_Controller.updateDocumentTitle((String)docVer.Id, 'Title.docx');
        Test.stopTest();   
        
        ContentDocument contDoc = [SELECT Id, Title FROM ContentDocument LIMIT 1];
        Assert.areEqual('Title.docx', contDoc.Title, 'The title should be updated');
    }
    
    @isTest
    private static void testDeleteDocumentVersions() {
        Apttus__DocumentVersion__c docVer = [SELECT Id FROM Apttus__DocumentVersion__c WHERE Apttus__Title__c = 'Test.docx' LIMIT 1];
            
        Test.startTest();
            CNT_CLM_Document_Versions_Controller.deleteDocumentVersions(new List<Id>{docVer.Id});
        Test.stopTest();   
        
        Apttus__DocumentVersion__c result = [SELECT Apttus__AgreementId__c FROM Apttus__DocumentVersion__c WHERE Apttus__Title__c = 'Test.docx' LIMIT 1];   
        Assert.areEqual(null, result.Apttus__AgreementId__c, 'The value should be null');
    }
    
    @isTest
    private static void testUnlockDocumentVersion() {
        Apttus__DocumentVersion__c docVer = [SELECT Id, Apttus__CheckoutById__c, Apttus__CheckoutDate__c, Apttus__CheckoutVersionDetailId__c FROM Apttus__DocumentVersion__c WHERE Apttus__Title__c = 'Test.docx' LIMIT 1];
        
        Test.startTest();
            CNT_CLM_Document_Versions_Controller.unlockDocumentVersion(docVer.Id);
        Test.stopTest();
        
        Apttus__DocumentVersion__c result = [SELECT Id, Apttus__CheckoutById__c, Apttus__CheckoutDate__c, Apttus__CheckoutVersionDetailId__c FROM Apttus__DocumentVersion__c WHERE Apttus__Title__c = 'Test.docx' LIMIT 1];
        Assert.areEqual(null, result.Apttus__CheckoutById__c, 'should be equal null');
        Assert.areEqual(null, result.Apttus__CheckoutDate__c, 'should be equal null');
        Assert.areEqual(null, result.Apttus__CheckoutVersionDetailId__c, 'should be equal null');
    }
}