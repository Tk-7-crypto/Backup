@isTest
public class TST_SLT_Document_Version_Detail {

    @testSetup
    static void dataSetup() {
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        agreement.Name = 'Test Agreement';
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
        insert dvd;
    }
    
    @isTest
    private static void testGetDocumentVersionDetailByAgreementId() {
        Apttus__APTS_Agreement__c agreement = [SELECT Id FROM Apttus__APTS_Agreement__c LIMIT 1];
        
        Test.startTest();
            List<Apttus__DocumentVersionDetail__c> result = new SLT_Document_Version_Detail().getDocumentVersionDetailByAgreementId(new Set<Id>{agreement.Id}, 
                new Set<String>{'Id'});
        Test.stopTest();
        
        System.assertNotEquals(0, result.size(), 'The list should not be empty');
    }
    
    @isTest
    private static void testGetDocumentVersionDetailById() {
        Apttus__DocumentVersionDetail__c dvd = [SELECT Id, Apttus__Title__c FROM Apttus__DocumentVersionDetail__c LIMIT 1];
        
        Test.startTest();
            Apttus__DocumentVersionDetail__c result = new SLT_Document_Version_Detail().getDocumentVersionDetailById(dvd.Id, 
                new Set<String>{'Apttus__Title__c'});
        Test.stopTest();
                    
        System.assertEquals('Test', result.Apttus__Title__c, 'The title should match');
    }     
    
    @isTest
    private static void testGetDocumentVersionDetailByIds() {
        Apttus__DocumentVersionDetail__c dvd = [SELECT Id, Apttus__Title__c FROM Apttus__DocumentVersionDetail__c LIMIT 1];
        
        Test.startTest();
            List<Apttus__DocumentVersionDetail__c> dvdList = new SLT_Document_Version_Detail().getDocumentVersionDetailByIds(new Set<String>{'Id'}, new Set<Id>{dvd.Id}, 'Id IN: idSet');
        Test.stopTest();
        
        System.assertEquals(false, dvdList.isEmpty(), 'The list must not be null');
    }
}