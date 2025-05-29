@isTest
private class TST_DAO_APTS_Agreement_Clause {
    @testSetup
    private static void testSetupData() { 
        Apttus__APTS_Agreement__c testAgreement = UTL_TestData.createAgreement();
        testAgreement.Name = 'Test MSA';
        testAgreement.Apttus__Requestor__c = UserInfo.getUserId();
        testAgreement.RecordTypeId = CON_CLM.MSA_RECORDTYPEID;
        testAgreement.Apttus__Auto_Renewal__c = true;
        testAgreement.Renewal_Term_Years__c = 'one (1)';
        testAgreement.Renewal_Notification_Days__c = 'ninety (90)';
        insert testAgreement;
        
        CLM_Agreement_Clause_Field_Mapping__c testAgrmntClauseMapSetting = new CLM_Agreement_Clause_Field_Mapping__c();
        testAgrmntClauseMapSetting.Name = '001';
        testAgrmntClauseMapSetting.Clause_Name__c = 'MSA Indemnification Japan';
        testAgrmntClauseMapSetting.Field_To_Update__c = 'Comprehensive_Indemnification_Provision__c';
        insert testAgrmntClauseMapSetting;
    }
    
    @isTest
    private static void testAgreementClauseInsert() {
        CLM_Configuration__c clmConfiguration = TST_CLM_TestDataFactory.createClmConfigurationSetting(false);
        clmConfiguration.RecordTypeForStatusAutomation__c = 'PSA;MSA';
        insert clmConfiguration;
        
        Apttus__APTS_Agreement__c agreement = [SELECT Id,Apttus__Related_Opportunity__c 
            FROM Apttus__APTS_Agreement__c WHERE Name = 'Test MSA' LIMIT 1];
        
        CLM_Agreement_Clause_Field_Mapping__c testCaluseMapSetting = [SELECT Id,Clause_Name__c, Field_To_Update__c 
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
        
        agreementClause = [SELECT Id, Apttus__Action__c FROM Apttus__Agreement_Clause__c  LIMIT 1];
        System.assertEquals(CON_CLM.MODIFIED, agreementClause.Apttus__Action__c, 
                            'Agreement Clause action should be Modified.');
    }

    @isTest
    private static void testAgreementClauseBulkInsert() {
        CLM_Configuration__c clmConfiguration = TST_CLM_TestDataFactory.createClmConfigurationSetting(false);
        clmConfiguration.RecordTypeForStatusAutomation__c = 'PSA;MSA';
        insert clmConfiguration;
        
        Apttus__APTS_Agreement__c agreement = [SELECT Id,Apttus__Related_Opportunity__c 
            FROM Apttus__APTS_Agreement__c WHERE Name = 'Test MSA' LIMIT 1];
        
        CLM_Agreement_Clause_Field_Mapping__c testCaluseMapSetting = [SELECT Id,Clause_Name__c, Field_To_Update__c 
            FROM CLM_Agreement_Clause_Field_Mapping__c LIMIT 1];
        
        User adminUser = UTL_TestData.createUser('System Administrator', 1).get(0);
        adminUser.User_Country__c = 'USA';
        insert adminUser;

        List<Apttus__Agreement_Clause__c> lstAgreementClause = new List<Apttus__Agreement_Clause__c>();
        Apttus__Agreement_Clause__c agreementClause = new Apttus__Agreement_Clause__c();
        agreementClause.Apttus__Agreement__c = agreement.Id;
        agreementClause.Apttus__Action__c = CON_CLM.MODIFIED;
        agreementClause.Apttus__Clause__c = 'MSA Indemnification Japan';
        lstAgreementClause.add(agreementClause);

        Apttus__Agreement_Clause__c agreementClause1 = new Apttus__Agreement_Clause__c();
        agreementClause1.Apttus__Agreement__c = agreement.Id;
        agreementClause1.Apttus__Action__c = CON_CLM.MODIFIED;
        agreementClause1.Apttus__Clause__c = 'MSA Indemnification Japan';
        lstAgreementClause.add(agreementClause1);
        
        Test.startTest();
            System.runAs(adminUser) {
                insert lstAgreementClause;
            }
        Test.stopTest();
        
        agreementClause = [SELECT Id, Apttus__Action__c FROM Apttus__Agreement_Clause__c  LIMIT 1];
        System.assertEquals(CON_CLM.MODIFIED, agreementClause.Apttus__Action__c, 
                            'Agreement Clause action should be Modified.');
    }
    
    @isTest
    private static void testUpdateAutoRenewCheckboxOnAgreementAfterInsert() {
        Apttus__APTS_Agreement__c agreement = [SELECT Id, Name, Renewal_Notification_Days__c, Renewal_Term_Years__c 
            FROM Apttus__APTS_Agreement__c WHERE Name = 'Test MSA' LIMIT 1];
        
        Apttus__Agreement_Clause__c agreementClause = new Apttus__Agreement_Clause__c();
        agreementClause.Apttus__Agreement__c = agreement.Id;
        agreementClause.Apttus__Action__c = CON_CLM.DELETED;
        agreementClause.Apttus__Clause__c = CON_CLM.MSA_TERM_AND_TERMINATION;
        agreementClause.Apttus__Active__c = true;
        agreementClause.Apttus__Text__c = 'The Agreement will automatically renew each year thereafter for a period of ' + 
            agreement.Renewal_Term_Years__c + ' years, unless either party notifies the other party in ' +
            'writing at least ' + agreement.Renewal_Notification_Days__c 
            + ' days prior to the renewal date that the notifying party does not want to renew the Agreement.';
        
        Test.startTest();
            insert agreementClause;
        Test.stopTest();
        
        Apttus__APTS_Agreement__c updateAgreement = [SELECT Id,Apttus__Auto_Renewal__c 
            FROM Apttus__APTS_Agreement__c WHERE Name = 'Test MSA' LIMIT 1];
        System.assertEquals(false, updateAgreement.Apttus__Auto_Renewal__c, 'Auto Renew Checkbox should be Modified.');
    }
}