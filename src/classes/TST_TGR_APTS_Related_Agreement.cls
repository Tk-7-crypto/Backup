/**
 * This test class is used to test Related Agreement Trigger.
 * version : 1.0
 */
@isTest
public class TST_TGR_APTS_Related_Agreement {
    @testSetup
    static void dataSetup() 
	{
        List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c testAgreementPSA1 = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        testAgreementPSA1.Name = 'Test PSA agreement 1';
        agreementList.add(testAgreementPSA1);
        
        Apttus__APTS_Agreement__c testAgreementPSA2 = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        testAgreementPSA2.Name = 'Test PSA agreement 2';
        agreementList.add(testAgreementPSA2);
        
        insert agreementList;
        
        Apttus__APTS_Related_Agreement__c relatedAgreement = new Apttus__APTS_Related_Agreement__c();
        relatedAgreement.Name = 'Current Agreement';
        relatedAgreement.Apttus__Relationship_From_Type__c = 'Is Amended By';
        relatedAgreement.Apttus__APTS_Contract_From__c = testAgreementPSA1.Id;
        relatedAgreement.Apttus__Relationship_To_Type__c = 'Is Amendment For';
        relatedAgreement.Apttus__APTS_Contract_To__c = testAgreementPSA2.Id;
        insert relatedAgreement;
    }
        
    @IsTest
    static void testInsertOnRelatedAgreement() 
    {
        List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c testAgreementPSA1 = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        testAgreementPSA1.Name = 'Test PSA agreement 1';
        agreementList.add(testAgreementPSA1);
        
        Apttus__APTS_Agreement__c testAgreementPSA2 = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        testAgreementPSA2.Name = 'Test PSA agreement 2';
        agreementList.add(testAgreementPSA2);
        
        insert agreementList;
        
        Apttus__APTS_Related_Agreement__c relatedAgreement = new Apttus__APTS_Related_Agreement__c();
        relatedAgreement.Name = 'Current Agreement 1';
        relatedAgreement.Apttus__Relationship_From_Type__c = 'Is Amended By';
        relatedAgreement.Apttus__APTS_Contract_From__c = testAgreementPSA1.Id;
        relatedAgreement.Apttus__Relationship_To_Type__c = 'Is Amendment For';
        relatedAgreement.Apttus__APTS_Contract_To__c = testAgreementPSA2.Id;
        
        Test.startTest();
            insert relatedAgreement;
        Test.stopTest();
        
        List<Apttus__APTS_Related_Agreement__c> relatedAgreementList = [SELECT Id, Name, Apttus__Relationship_From_Type__c
            FROM Apttus__APTS_Related_Agreement__c WHERE Name = 'Current Agreement 1'];
        System.assertEquals(1, relatedAgreementList.size());
    }
    
    @IsTest
    static void testUpdateOnRelatedAgreement() 
    {
        Apttus__APTS_Related_Agreement__c relatedAgreement = [SELECT Id, Name, Apttus__Relationship_From_Type__c
            FROM Apttus__APTS_Related_Agreement__c WHERE Name = 'Current Agreement'][0];
        relatedAgreement.Apttus__Relationship_From_Type__c = 'Is Master Of';
        
        Test.startTest();
            update relatedAgreement;
        Test.stopTest();
        
       Apttus__APTS_Related_Agreement__c updatedRelatedAgreement = [SELECT Id, Name, Apttus__Relationship_From_Type__c
            FROM Apttus__APTS_Related_Agreement__c WHERE Name = 'Current Agreement'][0];
        System.assertEquals('Is Master Of', updatedRelatedAgreement.Apttus__Relationship_From_Type__c);    
    }
    
    @IsTest
    static void testDeleteOnRelatedAgreement() 
    {
        Apttus__APTS_Related_Agreement__c relatedAgreement = [SELECT Id, Name, Apttus__Relationship_From_Type__c
            FROM Apttus__APTS_Related_Agreement__c WHERE Name = 'Current Agreement'][0];
        
        Test.startTest();
            delete relatedAgreement;
        Test.stopTest();
        
        List<Apttus__APTS_Related_Agreement__c> relatedAgreementList = [SELECT Id, Name, Apttus__Relationship_From_Type__c
            FROM Apttus__APTS_Related_Agreement__c WHERE Name = 'Current Agreement'];
        System.assertEquals(0, relatedAgreementList.size());
    }
    
    @IsTest
    static void testUnDeleteOnRelatedAgreement() 
    {
        Apttus__APTS_Related_Agreement__c relatedAgreement = [SELECT Id, Name, Apttus__Relationship_From_Type__c
            FROM Apttus__APTS_Related_Agreement__c WHERE Name = 'Current Agreement'][0];
        delete relatedAgreement;
        
        Test.startTest();
            undelete relatedAgreement;
        Test.stopTest();
        
        List<Apttus__APTS_Related_Agreement__c> relatedAgreementList = [SELECT Id, Name, Apttus__Relationship_From_Type__c
            FROM Apttus__APTS_Related_Agreement__c WHERE Name = 'Current Agreement'];
        System.assertEquals(1, relatedAgreementList.size());
    }
}