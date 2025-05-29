@isTest
private class TST_DAOH_CLM_Agreement_Clause {
    @testSetup
    private static void testSetupData() {
        Apttus__APTS_Agreement__c testAgreementMSA = TST_CLM_TestDataFactory.createAgreement(CON_CLM.MSA_RECORDTYPEID, false);
        testAgreementMSA.Name = 'Test MSA';
        testAgreementMSA.Apttus__Status__c = CON_CLM.REQUEST;
        testAgreementMSA.Comprehensive_Indemnification_Provision__c = 'No change'; 
        insert testAgreementMSA;
        
        CLM_Agreement_Clause_Field_Mapping__c testAgrmntClauseMapSetting = new CLM_Agreement_Clause_Field_Mapping__c();
        testAgrmntClauseMapSetting.Name = '001';
        testAgrmntClauseMapSetting.Clause_Name__c = 'MSA Indemnification Japan';
        testAgrmntClauseMapSetting.Field_To_Update__c = 'Comprehensive_Indemnification_Provision__c';
        insert testAgrmntClauseMapSetting;
                
        List<Apttus__Agreement_Clause__c> lstAgreementClause = new List<Apttus__Agreement_Clause__c>();
        Apttus__Agreement_Clause__c agreementClause = new Apttus__Agreement_Clause__c();
        agreementClause.Apttus__Agreement__c = testAgreementMSA.Id;
        agreementClause.Apttus__Action__c = CON_CLM.MODIFIED;
        agreementClause.Apttus__Clause__c = 'MSA Indemnification Japan';
        lstAgreementClause.add(agreementClause); 
        insert lstAgreementClause;
    }
    
    @isTest
    private static void testAgreementClauseInsert() {
        CLM_Configuration__c clmConfiguration = TST_CLM_TestDataFactory.createClmConfigurationSetting(false);
        clmConfiguration.RecordTypeForStatusAutomation__c = 'PSA;MSA';
        insert clmConfiguration;
        
        Apttus__APTS_Agreement__c agreement = [SELECT Id, Apttus__Related_Opportunity__c 
            FROM Apttus__APTS_Agreement__c WHERE Name = 'Test MSA' LIMIT 1];
        
        CLM_Agreement_Clause_Field_Mapping__c testClauseMapSetting = [SELECT Id, Clause_Name__c, Field_To_Update__c 
            FROM CLM_Agreement_Clause_Field_Mapping__c LIMIT 1];
        
        User adminUser = UTL_TestData.createUser('System Administrator', 1).get(0);
        adminUser.User_Country__c = 'USA';
        insert adminUser;
        
        Apttus__Agreement_Clause__c agreementClause = new Apttus__Agreement_Clause__c();
        agreementClause.Apttus__Agreement__c = agreement.Id;
        agreementClause.Apttus__Action__c = CON_CLM.MODIFIED;
        agreementClause.Apttus__Clause__c = 'MSA Indemnification Japan';
        
        Test.startTest();
            System.runAs(adminUser) {
                insert agreementClause;
            }
        Test.stopTest();
        
        agreementClause = [SELECT Id, Apttus__Action__c FROM Apttus__Agreement_Clause__c LIMIT 1];
        System.assertEquals(CON_CLM.MODIFIED, agreementClause.Apttus__Action__c, 
                            'Agreement Clause action should be Modified.');
    }

    @isTest
    private static void testUpdateQuestionnaireTabDetails() {
        List<Apttus__Agreement_Clause__c> lstAgreementClause = [SELECT Id, Apttus__Agreement__c, Apttus__Action__c, Apttus__Clause__c FROM Apttus__Agreement_Clause__c LIMIT 1];
        
        Test.startTest();
            DAOH_CLM_Agreement_Clause.updateQuestionnaireTabDetails(lstAgreementClause);
        Test.stopTest();
        
        Apttus__APTS_Agreement__c agreementResult = [SELECT Id, Comprehensive_Indemnification_Provision__c FROM Apttus__APTS_Agreement__c WHERE Name = 'Test MSA' LIMIT 1]; 
        System.assertEquals(CON_CLM.WITHIN_FALLBACKS, agreementResult.Comprehensive_Indemnification_Provision__c, 'The value should match');
    }
    
    @isTest
    private static void testUpdateAutoRenewCheckboxOnAgreement() {
        Apttus__APTS_Agreement__c agreement = [SELECT Id, Name 
            FROM Apttus__APTS_Agreement__c WHERE Name = 'Test MSA' LIMIT 1];
        
        Apttus__Agreement_Clause__c agreementClause = new Apttus__Agreement_Clause__c();
        agreementClause.Apttus__Agreement__c = agreement.Id;
        agreementClause.Apttus__Action__c = CON_CLM.MODIFIED;
        agreementClause.Apttus__Clause__c = CON_CLM.MSA_TERM_AND_TERMINATION;
        agreementClause.Apttus__Active__c = true;
        
        Test.startTest();
            DAOH_CLM_Agreement_Clause.updateAutoRenewCheckboxOnAgreement(new List<Apttus__Agreement_Clause__c>{agreementClause});
        Test.stopTest();
        
        Apttus__APTS_Agreement__c updateAgreement = [SELECT Id,Apttus__Auto_Renewal__c 
            FROM Apttus__APTS_Agreement__c WHERE Name = 'Test MSA' LIMIT 1];
        System.assertEquals(false, updateAgreement.Apttus__Auto_Renewal__c, 'Auto Renew Checkbox should be Modified.');
    }
}