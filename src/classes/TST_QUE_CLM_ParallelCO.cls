@isTest
public class TST_QUE_CLM_ParallelCO {

    @testSetup
    static void dataSetup() {
        List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c parentAgreementPSA = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, true);
        parentAgreementPSA.Name = 'Test Parent Agreement';
        parentAgreementPSA.Apttus__Agreement_Number__c = '12345';
        parentAgreementPSA.Agreement_Cloned_From__c = null;
        agreementList.add(parentAgreementPSA);

        Apttus__APTS_Agreement__c childAgreementPSA1 = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        childAgreementPSA1.Name = 'Test Child Agreement1';
        childAgreementPSA1.Agreement_Cloned_From__c = parentAgreementPSA.Id;     
        childAgreementPSA1.Apttus__Workflow_Trigger_Created_From_Clone__c = false;
        agreementList.add(childAgreementPSA1);
        
        Apttus__APTS_Agreement__c childAgreementPSA2 = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        childAgreementPSA2.Name = 'Test Child Agreement2';
        childAgreementPSA2.Agreement_Cloned_From__c = parentAgreementPSA.Id;
        agreementList.add(childAgreementPSA2);      
        
        Apttus__APTS_Agreement__c childAgreementPSA3 = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        childAgreementPSA3.Name = 'Test Child Agreement3';
        agreementList.add(childAgreementPSA3);         
        upsert agreementList;
        
        Apttus__APTS_Related_Agreement__c relatedAgr = new Apttus__APTS_Related_Agreement__c();
        relatedAgr.Name = 'Current Agreement';
        relatedAgr.Apttus__Relationship_From_Type__c = 'Is Amended By';
        relatedAgr.Apttus__APTS_Contract_From__c = parentAgreementPSA.Id; 
        relatedAgr.Apttus__Relationship_To_Type__c = 'Is Amendment For';
        relatedAgr.Apttus__APTS_Contract_To__c = childAgreementPSA1.Id;
        insert relatedAgr;        
    }
    
    @isTest
    private static void testParallelCOQueueable() {        
        Apttus__APTS_Agreement__c agr1 = [SELECT Id, Agreement_Cloned_From__c FROM Apttus__APTS_Agreement__c WHERE Name = 'Test Child Agreement1' LIMIT 1];        
        Apttus__APTS_Agreement__c agr2 = [SELECT Id, Agreement_Cloned_From__c FROM Apttus__APTS_Agreement__c WHERE Name = 'Test Child Agreement2' LIMIT 1]; 
        
        Test.startTest(); 
            System.enqueueJob(new QUE_CLM_ParallelCO(new Map<Id, Id>{agr1.Id => agr2.Id}));
        Test.stopTest();
        
        Apttus__APTS_Related_Agreement__c relatedAgreement = [SELECT Id, Apttus__APTS_Contract_From__c FROM Apttus__APTS_Related_Agreement__c WHERE Name = 'Current Agreement' LIMIT 1];
        System.assertEquals(agr2.Id, relatedAgreement.Apttus__APTS_Contract_From__c, 'Value should be matched'); 
    }
}