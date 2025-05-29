@isTest
private  class TST_CNT_CLM_CreateAgreementFromOpp {

    @testSetup
    private static void dataSetup() {
        Account acc = new Account(Name = 'Test Account', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        acc.CurrencyIsoCode = 'USD';
        acc.ShippingStreet = 'Test';
        insert acc;

        Opportunity opp = TST_CLM_TestDataFactory.createOpportunity(false);
        opp.AccountId = acc.Id;
        opp.Legacy_Quintiles_Opportunity_Number__c = '22222';
        opp.Global_project_unit__c = 'Biogen';
        insert opp;
        
        Site_Submission__c siteSubmission = new Site_Submission__c();
        siteSubmission.Name = 'Test Site Submission';
        siteSubmission.Opportunity__c = opp.id;
        siteSubmission.Status__c = 'PSV Scheduled';
        insert siteSubmission;

        Finance_IQVIA_Legal_Entity__c financeLegalEntity = new Finance_IQVIA_Legal_Entity__c();
        financeLegalEntity.Legacy_Entity_Code__c = CON_CLM.LEGAL_ENTITY_2_CODE;
        financeLegalEntity.Address_Line_1__c = 'Test Address';
        financeLegalEntity.Country_Description__c = 'USA';
        financeLegalEntity.Effective_Status__c = 'Active';
        financeLegalEntity.Incorporation__c = 'Test Corp';
        financeLegalEntity.RecordTypeId = CON_CLM.FINANCE_LEGAL_ENTITY_ORACLE_RECORDTYPEID;
        insert financeLegalEntity;

        Apttus_Proposal__Proposal__c budget = TST_CLM_TestDataFactory.createProposalQuote(false);
        budget.RecordTypeId = CON_CLM.QUOTE_TECH_SOLN_RECORDTYPE;
        budget.Apttus_Proposal__Opportunity__c = opp.Id;
        budget.Apttus_Proposal__Primary__c = true;
        budget.Apttus_Proposal__Proposal_Category__c = CON_CLM.PROPOSAL_INITIAL;
        budget.Scenario_Number__c = 123.0;
        budget.Budget_Iteration__c = 1;
        budget.Select_Pricing_Tool__c = 'AMESA';
        budget.Apttus_QPConfig__ConfigurationFinalizedDate__c = Date.today();
        budget.Apttus_Proposal__Approval_Stage__c = CON_CLM.DRAFT;
        insert budget;
    }

    @isTest
    private static void testGetRecordTypesShouldReturnValidList() {
        List<Account> account = [Select Id, Name From Account Where account.Name = 'Test Account' LIMIT 1];
        List<RecordType> listRecordType = new List<RecordType>();
        User adminUser = UTL_TestData.createUser('System Administrator', 1).get(0);
        insert adminUser;
        
        Test.startTest();
            System.runAs(adminUser) {
                listRecordType = CNT_CLM_CreateAgreementFromOpp.getRecordTypes(account[0].Id);
            }
        Test.stopTest();

        System.assertNotEquals(true, listRecordType.isEmpty(), 'No record type return when expected');  
    }

    @isTest
    private static void testGetDefaultFieldValuesShouldReturnValidString(){
        Id recordTypeId = 
            Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get(CON_CLM.PSA_RECORD_TYPE_NAME).getRecordTypeId();
        Opportunity opportunity = [Select Id FROM Opportunity LIMIT 1];

        Test.startTest();
            String jsonStr = CNT_CLM_CreateAgreementFromOpp.getDefaultFieldValues(opportunity.Id,recordTypeId);
        Test.stopTest();
        
        System.assertNotEquals(null,jsonStr,'Json String is null when not expected');
    }


    @isTest
    private static void testGetDefaultFieldValuesShouldReturnValidStringForPSA() {
        Opportunity opportunity = [Select Id FROM Opportunity LIMIT 1];

        Test.startTest();
            String jsonStr = CNT_CLM_CreateAgreementFromOpp.getDefaultFieldValues(opportunity.Id, CON_CLM.PSA_RECORDTYPEID);
        Test.stopTest();
        
        System.assertNotEquals(null, jsonStr, 'Json String is null when not expected.');
    }
    
    @isTest
    private static void testGetDefaultFieldValuesForAvacare() {
        Site_Submission__c siteSubmission = [Select Id FROM Site_Submission__c LIMIT 1];

        Test.startTest();
            String jsonStr = CNT_CLM_CreateAgreementFromOpp.getDefaultFieldValues(
                siteSubmission.Id, CON_CLM.AVACARE_IQVIA_RECORDTYPEID);
        Test.stopTest();
        
        System.assertNotEquals(null, jsonStr, 'Json String is null when not expected.');
    }
         
    @isTest
    private static void testGetDefaultFieldValuesShouldReturnValidStringForPreliminary() {
        Opportunity opportunity = [Select Id FROM Opportunity LIMIT 1];

        Test.startTest();
            String jsonStr = CNT_CLM_CreateAgreementFromOpp.getDefaultFieldValues(opportunity.Id, CON_CLM.PRELIMINARY_RECORDTYPEID);
        Test.stopTest();
        
        System.assertNotEquals(null, jsonStr, 'Json String is null when not expected.');
    }       
    
    @isTest
    private static void testSetDefaultLegalEntityValuesForGCE() {
        Map<String, Id> mapFinanceIQVIAEntity = new Map<String, Id>();
        
        Test.startTest();
            mapFinanceIQVIAEntity = CNT_CLM_CreateAgreementFromOpp.setDefaultLegalEntityValuesForGCE();
        Test.stopTest();
         
        System.assertEquals(1, mapFinanceIQVIAEntity.size(), 'The size of the map returned should be 1');
    }

    @isTest
    private static void testGetDefaultFieldValuesForAMESA() {
        Opportunity opportunity = [Select Id FROM Opportunity LIMIT 1];

        Test.startTest();
            String jsonStr = CNT_CLM_CreateAgreementFromOpp.getDefaultFieldValues(opportunity.Id, CON_CLM.AMESA_RECORDTYPEID);
        Test.stopTest();

        System.assertNotEquals(null, jsonStr, 'Json String is null when not expected.');
    }

    @isTest
    private static void testValidateQuoteDetails() {
        Opportunity opportunity = [Select Id FROM Opportunity LIMIT 1];

        Test.startTest();
            Boolean quoteExists = CNT_CLM_CreateAgreementFromOpp.validateQuoteDetails(opportunity.Id);
        Test.stopTest();

        System.assertEquals(true, quoteExists, 'Quote/Proposal is not created for this Opportunity.');
    }

    @isTest
    private static void testGetDefaultFieldValuesMSA() {
        Account account = [Select Id FROM Account  Where account.Name = 'Test Account' LIMIT 1];

        Test.startTest();
            String jsonStr = CNT_CLM_CreateAgreementFromOpp.getDefaultFieldValues(account.Id, CON_CLM.MSA_RECORDTYPEID);
        Test.stopTest();

        System.assertNotEquals(null, jsonStr, 'Json String is null when not expected.');
    }

    @isTest
    private static void testGetDefaultLegalEntityValuesForMSA() {

        Test.startTest();
            Map<String, Id> defaultLEs = CNT_CLM_CreateAgreementFromOpp.getDefaultLegalEntityValuesForMSA();
        Test.stopTest();

        System.assertNotEquals(null, defaultLEs, 'Default legal entity not returned when not expected.');
    }
    
    @isTest
    static void testgetCLMRecordTypeIdsForMVP() 
	{
		test.startTest();
			CNT_CLM_CreateAgreementFromOpp.getCLMRecordTypeIdsForMVP();
		test.stopTest(); 
		
        List<String> actual = CNT_CLM_CreateAgreementFromOpp.getCLMRecordTypeIdsForMVP();
        system.assertNotEquals(null, actual,'Verifying getCLMRecordTypeIdsForMVP');
    }
    
    @isTest
    public static void testGetAccountCurrency() 
    {
        Account acc = [Select id from Account limit 1];
        
        Test.startTest();
            String accountCurrency = CNT_CLM_CreateAgreementFromOpp.getAccountCurrency(acc.Id);
        Test.stopTest(); 

        System.assertEquals('USD', accountCurrency, 'correct currency should return');
    }
    
    @isTest
    private static void testCheckAdminUser() {
        User adminUser = UTL_TestData.createUser('System Administrator', 1).get(0);
        insert adminUser;
        Boolean isAdminUser = false;
        
        Test.startTest();
            System.runAs(adminUser) {
                isAdminUser = CNT_CLM_CreateAgreementFromOpp.checkAdminUser();
            }
        Test.stopTest();

        System.assertEquals(true, isAdminUser);  
    }
    
    @isTest
    private static void testGetAccessibleRecordTypeId() {
        User adminUser = UTL_TestData.createUser('System Administrator', 1).get(0);
        insert adminUser;
        Id recordTypeId;
        
        Test.startTest();
            System.runAs(adminUser) {
                recordTypeId = CNT_CLM_CreateAgreementFromOpp.getAccessibleRecordTypeId();
            }
        Test.stopTest();

        System.assertNotEquals(null, recordTypeId, 'No record type return when expected');   
    }
}