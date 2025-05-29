@isTest
public class TST_AgreementLifeCycle{

    @testsetup
    static void setupTestData(){
    
        UTL_ExecutionControl.stopTriggerExecution_OWF = true;
        
        CLM_Configuration__c clmConfiguration = TST_CLM_TestDataFactory.createClmConfigurationSetting(false);
        clmConfiguration.RecordTypeForStatusAutomation__c = 'PSA;MSA;AMESA';
        insert clmConfiguration;

        Account accountObj = new Account(Name = 'Foundation 2.0 Test Account',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert accountObj;

        List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c parentAgreementPSA = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, true);
        parentAgreementPSA.Name = 'Test Parent Agreement';
        parentAgreementPSA.Apttus__Account__c = accountObj.Id;
        parentAgreementPSA.Agreement_Cloned_From__c = null;
        agreementList.add(parentAgreementPSA);

        Apttus__APTS_Agreement__c childAgreementPSA = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        childAgreementPSA.Name = 'Test Parent Agreement';
        childAgreementPSA.Apttus__Account__c = accountObj.Id;
        childAgreementPSA.Agreement_Cloned_From__c = parentAgreementPSA.Id;
        agreementList.add(childAgreementPSA);

        Apttus__APTS_Agreement__c agreementAMA = TST_CLM_TestDataFactory.createAgreement(CON_CLM.AMA_RECORDTYPEID, false);
        agreementAMA.Name = 'Test AMA Agreement';
        agreementAMA.Apttus__Account__c = accountObj.Id;
        agreementList.add(agreementAMA);

        Apttus__APTS_Agreement__c agreementAMAAmend = TST_CLM_TestDataFactory.createAgreement(CON_CLM.AMA_RECORDTYPEID, false);
        agreementAMAAmend.Name = 'Test AMA Agreement';
        agreementAMAAmend.Apttus__Account__c = accountObj.Id;
        agreementAMAAmend.Apttus__Version_Number__c = 1;
        agreementList.add(agreementAMAAmend);
        upsert agreementList;
    }

    @isTest
    private static void testAfterAmend() {
        Test.startTest();
        List <Apttus__APTS_Agreement__c> agreements = [SELECT Id, Name, Agreement_Cloned_From__c, RecordTypeId, Apttus__Version_Number__c
            FROM Apttus__APTS_Agreement__c WHERE RecordType.DeveloperName = 'PSA'];
        Apttus__APTS_Agreement__c parentAgreement;
        Apttus__APTS_Agreement__c childAgreement;
        for(Apttus__APTS_Agreement__c record : agreements) {
            if (record.Agreement_Cloned_From__c == null) {
                parentAgreement = record;
            } else {
                childAgreement = record;
            }
        }
        AgreementLifecycle objAgreementLifecycle = new AgreementLifecycle();

        objAgreementLifecycle.afterAmend(parentAgreement, childAgreement);
        Test.stopTest();
        
        System.assertEquals(childAgreement.Agreement_Cloned_From__c, parentAgreement.Id, 
            'Agreement amend from field of child agreement should be updated to parent agreement');
    }

    @isTest
    private static void testAfterRenew() {
        Test.startTest();
        List <Apttus__APTS_Agreement__c> agreements = [SELECT Id, Name, Agreement_Cloned_From__c, RecordTypeId 
            FROM Apttus__APTS_Agreement__c WHERE RecordType.DeveloperName = 'PSA'];
        Apttus__APTS_Agreement__c parentAgreement;
        Apttus__APTS_Agreement__c childAgreement;
        for(Apttus__APTS_Agreement__c record : agreements) {
            if (record.Agreement_Cloned_From__c == null) {
                parentAgreement = record;
            } else {
                childAgreement = record;
            }
        }
        AgreementLifecycle objAgreementLifecycle = new AgreementLifecycle();

        objAgreementLifecycle.afterRenew(parentAgreement, childAgreement);
        Test.stopTest();
        
        System.assertEquals(childAgreement.Agreement_Cloned_From__c, parentAgreement.Id, 
            'Agreement renew from field of child agreement should be updated to parent agreement');
    }

    @isTest
    private static void testAfterActivationOriginal() {
        
        List <Apttus__APTS_Agreement__c> agreements = [SELECT Id, Name, Apttus__Version_Number__c, RecordTypeId
            FROM Apttus__APTS_Agreement__c WHERE RecordType.DeveloperName = 'AMA' AND Apttus__Version_Number__c = 0];
        AgreementLifecycle objAgreementLifecycle = new AgreementLifecycle();

        Test.startTest();
            objAgreementLifecycle.afterActivate(agreements.get(0), null);
        Test.stopTest();
        
        System.assertEquals(Date.today(), agreements.get(0).Original_Effective_Date__c,  
            'Original Effective Date is not set to current date when expected');
    }

    @isTest
    private static void testAfterActivationAmend() {
        
        List <Apttus__APTS_Agreement__c> agreements = [SELECT Id, Name, Apttus__Version_Number__c, RecordTypeId
            FROM Apttus__APTS_Agreement__c WHERE RecordType.DeveloperName = 'AMA' AND Apttus__Version_Number__c = 1];
        AgreementLifecycle objAgreementLifecycle = new AgreementLifecycle();

        Test.startTest();
            objAgreementLifecycle.afterActivate(agreements.get(0), null);
        Test.stopTest();
        
        System.assertEquals(Date.today(), agreements.get(0).Apttus__Amendment_Effective_Date__c,  
            'Amendment Effective Date is not set to current date when expected');
    }

    @isTest
    private static void testAfterAmendMSA() {
        
        Apttus__APTS_Agreement__c parentAgreement = new Apttus__APTS_Agreement__c(RecordTypeId = CON_CLM.MSA_RECORDTYPEID, Name = 'Test MSA');
        Apttus__APTS_Agreement__c childAgreement = new Apttus__APTS_Agreement__c(RecordTypeId = CON_CLM.MSA_RECORDTYPEID, Apttus__Version_Number__c = 1);
       
        AgreementLifecycle objAgreementLifecycle = new AgreementLifecycle();

        Test.startTest();
            objAgreementLifecycle.afterAmend(parentAgreement, childAgreement);
        Test.stopTest();
        
        System.assertEquals(childAgreement.Name, 'Amendment 1 to Test MSA',  
            'MSA Amendment Name is incorrect');
    }
}