/**
* This test class is used to test Queueable class QUE_CLM_UpdateAgreement.
* version : 1.0
*/
@IsTest
public class TST_QUE_CLM_UpdateAgreement {
    
    @TestSetup
    private static void dataSetup() {
        Account acc = UTL_TestData.createAccount();
        acc.AccountCountry__c = 'AL';
        insert acc;
        
        Apttus__APTS_Agreement__c agr = TST_CLM_TestDataFactory.createAgreement(CON_CLM.MSA_RECORDTYPEID, false);
        agr.Name = 'Test Agreement';
        agr.Apttus__Account__c = acc.Id;
        agr.Apttus__Status__c = 'Request';
        agr.Apttus__Status_Category__c = 'Request';
        insert agr;
    }
    
    @isTest
    private static void testUpdateIQVIAAgreementToActivated() {
        Apttus__APTS_Agreement__c agreement = [SELECT Id, Apttus__Status_Category__c, Apttus__Status__c FROM Apttus__APTS_Agreement__c 
            WHERE Name = 'Test Agreement'];
        agreement.Apttus__Perpetual__c = true;
        agreement.Apttus__Contract_End_Date__c = Date.today();
        agreement.Apttus__Status_Category__c = CON_CLM.IN_EFFECT;
        agreement.Apttus__Status__c = CON_CLM.ACTIVATED;
        
        Test.startTest();
            System.enqueueJob(new QUE_CLM_UpdateAgreement(new List<Apttus__APTS_Agreement__c>{agreement}));
        Test.stopTest();
    }

    @isTest
    private static void testUpdateIQVIAAgreement() {
        Apttus__APTS_Agreement__c agreement = [SELECT Id, Apttus__Status_Category__c, Apttus__Status__c FROM Apttus__APTS_Agreement__c 
            WHERE Name = 'Test Agreement'];
        agreement.Apttus__Status__c = CON_CLM.ASSIGNED;
        
        Test.startTest();
            System.enqueueJob(new QUE_CLM_UpdateAgreement(new List<Apttus__APTS_Agreement__c>{agreement}));
        Test.stopTest();
        
        Apttus__APTS_Agreement__c updatedAgreement = [SELECT Id, Apttus__Status_Category__c, Apttus__Status__c FROM Apttus__APTS_Agreement__c 
            WHERE Name = 'Test Agreement'][0];
        System.assertEquals(CON_CLM.ASSIGNED, updatedAgreement.Apttus__Status__c, 'Agreement should be Assigned');
    }
}