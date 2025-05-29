@isTest
public class TST_CNT_CLM_CommonController {
    
    @testSetup
    static void dataSetup() {
        Account testAccount = UTL_TestData.createAccount();
        insert testAccount;
        
        IQVIA_Agreement__c iqagreement = TST_CLM_TestDataFactory.createIQAgreement(CON_CLM.USBU_IQVIA_RECORDTYPEID, false);
        iqagreement.Name = 'Test USBU';
        iqagreement.Status_Category__c = 'Request';
        iqagreement.Status__c = 'Request';
        iqagreement.Subtype__c = 'SOW';
        insert iqagreement;
        
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.RWS_RECORDTYPEID, false);
        agreement.Name = 'Test RWS';
        agreement.Apttus__Status_Category__c = 'Request';
        agreement.Apttus__Status__c = 'Request';
        agreement.Apttus__Subtype__c = 'ATP';
        agreement.Apttus__Account__c = testAccount.Id;
        agreement.IQVIA_Agreement__c = iqagreement.Id;
        insert agreement;
        
        Apttus__APTS_Agreement__c msaAgr = TST_CLM_TestDataFactory.createAgreement(CON_CLM.MSA_RECORDTYPEID, false);
        msaAgr.Name = 'Test MSA';
        msaAgr.Apttus__Status_Category__c = CON_CLM.IN_EFFECT;
        msaAgr.Apttus__Status__c = CON_CLM.ACTIVATED;
        msaAgr.Apttus__Account__c = testAccount.Id;
        insert msaAgr;
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test';      
        cv.PathOnClient = 'abc.jpg';
        cv.VersionData = Blob.valueOf('Test Content'); 
        insert cv;                
    }
    
    @isTest
    private static void testGetServiceList() {
        List<String> result = new List<String>();
        
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TST_Mock_UTL_PickListOptions());
            result = CNT_CLM_CommonController.getServiceList(CON_CLM.AGREEMENT_OBJECT_API_NAME, 'Services__c', CON_CLM.PRELIMINARY_RECORDTYPEID, CON_CLM.OSA_PATHWAY);
        Test.stopTest();
        
        System.assertEquals(false, result.isEmpty(), 'The list should not be null.');
    } 
    
    @isTest
    private static void testRedirectToIQVIAAgreement() {
        Apttus__APTS_Agreement__c agreement = [SELECT Id, IQVIA_Agreement__c FROM Apttus__APTS_Agreement__c LIMIT 1];
        
        Test.startTest();
            String redirectToIQVAgreement = CNT_CLM_CommonController.redirectToIQVIAAgreement(agreement.Id);
        Test.stopTest();
        
        System.assertEquals(agreement.IQVIA_Agreement__c, redirectToIQVAgreement, 'The agreement not redirect to IQVIA Agreement');
    }
    
    @isTest
    private static void testDeleteFile() {
        List<ContentVersion> cvList = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title = 'Test'];
        
        Test.startTest();
            CNT_CLM_CommonController.deleteFile(cvList.get(0).ContentDocumentId);
        Test.stopTest();
        
        List<ContentVersion> cvFinalList = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title = 'Test'];
        System.assertEquals(cvFinalList.isEmpty(), true, 'File should be deleted');
    }
    
    @isTest
    private static void testGetRecords() {
        Apttus__APTS_Agreement__c agr = [SELECT Id FROM Apttus__APTS_Agreement__c LIMIT 1];
                
        Test.startTest();
            List<Apttus__APTS_Agreement__c> finalAgrList = CNT_CLM_CommonController.getRecords(agr.Id);
        Test.stopTest();
        
        Assert.isTrue(!finalAgrList.isEmpty(), 'The list should not be null.');
    }
}