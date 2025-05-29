@isTest
private class TST_SLT_Agreement {

    static Apttus__APTS_Agreement__c setAgreementData(Id OpportuntiyId){

        Id recordTypeId = CON_CLM.PRELIMINARY_RECORDTYPEID;
        Apttus__APTS_Agreement__c testAgreement = UTL_TestData.createAgreement();
        testAgreement.Apttus__Related_Opportunity__c = OpportuntiyId;				 
        testAgreement.RecordTypeId = recordTypeId;
        return testAgreement;
    }

    static Opportunity setOpportunityData(Id accountId){

        Opportunity testOpportunity= UTL_TestData.createOpportunity(accountId);
        testOpportunity.Line_of_Business__c = CON_CPQ.SAMPLE_LINE_OF_BUSINESS;
        testOpportunity.Is_this_IQVIA_Biotech__c = CON_CPQ.YES_TITLE_CASE;
        insert testOpportunity;
        return testOpportunity;
    }

    static Account setAccountData(){

        Account testAccount = UTL_TestData.createAccount();
        insert testAccount;
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        OWF_Config__c owfConfig = UTL_OWF_TestData.createOWFConfig(grp.Id);
        insert owfConfig;
        return testAccount;
    }
    
    static Contract setContractData(Id accountId,Opportunity testOpportunity){        
        Contract testCntrt = UTL_TestData.createContract(testOpportunity, CON_CPQ.CONTRACT_RECORDTYPE_PRELIMINARY_GBO);
        testCntrt.AccountId = accountId;
        testCntrt.Status = 'Draft';
        testCntrt.CurrencyIsoCode = 'INR';
        testCntrt.Status = 'Analyst Preparing Customer Budget Deliverable';
        testCntrt.StartDate = System.today();
        testCntrt.ContractTerm = 12; 
        testCntrt.Planned_Execution_Date__c = System.today();
        testCntrt.Anticipated_date_for_1st_SIV__c = System.today();
        insert testCntrt;
        return testCntrt;
    }
    
    static Apttus__DocumentVersion__c setDocumentVersionData(Id agreementId) {
        Apttus__DocumentVersion__c docVer = new Apttus__DocumentVersion__c();
        docVer.Apttus__AgreementId__c = agreementId;
        docVer.Name = 'Generate Document';
        docVer.Apttus__Title__c = 'Test.docx';
        docVer.Apttus__LatestVersion__c = '1.0.0';
        return docVer;
    }

    @isTest
    static void testSelectAgreementById() {

        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        Apttus__APTS_Agreement__c testAgreement = setAgreementData(testOpportunity.Id);
        insert testAgreement;
        Set<Id> idSet = new Set<Id>{testAgreement.Id};

        Test.startTest();
            List<Apttus__APTS_Agreement__c> agreementList = new SLT_Agreement().selectById(idSet);
        Test.stopTest();
        
        System.assertEquals(1, agreementList.size(), 'Should return one agreement');
    }
    

    @isTest
    static void testGetAgreementDetailsByIdAndPricingTool() {

        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        Apttus__APTS_Agreement__c testAgreement = setAgreementData(testOpportunity.Id);
		testAgreement.Select_Pricing_Tool__c = CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT;
        insert testAgreement;

        Set<String> fieldSet = new Set<String> {CON_CPQ.ID, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL};

        Test.startTest();
            Apttus__APTS_Agreement__c agreement = new
            SLT_Agreement().getAgreementDetails(testAgreement.Id, fieldSet);
        Test.stopTest();

        System.assertEquals(CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, agreement.Select_Pricing_Tool__c, 'Should Return QIP');
    }
    
    @isTest
    static void testgetAgreementDetailsByIdAndRecorType() {

        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        Apttus__APTS_Agreement__c testAgreement = setAgreementData(testOpportunity.Id);
        insert testAgreement;
        Set<String> fieldSet = new Set<String> {CON_CPQ.ID, CON_CPQ.AGREEMENT_BId_HISTORY_NUMBER};
        Set<Id> recordtypeIds = new Set<Id>{CON_CLM.PRELIMINARY_RECORDTYPEID};

        Test.startTest();
            List<Apttus__APTS_Agreement__c> agreementList = new
                SLT_Agreement().getAgreementDetailsByIdAndRecorType(testAgreement.Id, recordtypeIds, fieldSet);
        Test.stopTest();

        System.assertEquals(1, agreementList.size(), 'Should Return Agreement');
    }
    
    @isTest
    static void testgetAgreementDetailsByIdsAndRecorType() {

        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        Apttus__APTS_Agreement__c testAgreement = setAgreementData(testOpportunity.Id);
        insert testAgreement;
        Set<String> fieldSet = new Set<String> {CON_CPQ.ID, CON_CPQ.AGREEMENT_BId_HISTORY_NUMBER};
        Set<Id> recordtypeIds = new Set<Id>{CON_CLM.PRELIMINARY_RECORDTYPEID};

        Test.startTest();
            List<Apttus__APTS_Agreement__c> agreementList = new
                SLT_Agreement().getAgreementDetailsByIdsAndRecorType(new set<Id>{testAgreement.Id}, recordtypeIds, fieldSet);
        Test.stopTest();

        System.assertEquals(1, agreementList.size(), 'Should Return Agreement');
    }

    @isTest
    private static void testGetAgreementDetailsByIdWithReletedFieldsShouldReturnList(){
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(null,true);

        Test.startTest();
            List<Apttus__APTS_Agreement__c> agreementList = new SLT_Agreement().getAgreementDetailsByIdWithReletedFields(agreement.Id,
                new Set<Id>{CON_CLM.PSA_RECORDTYPEID},new Set<String>{'Id','Name'});
        Test.stopTest();
        
        System.assertEquals(1, agreementList.size(), 'Should Return Agreement');
    }
    
    @isTest
    static void testselectAgreementById1() {
        new SLT_Agreement(false, false).selectAgreementById(new Set<Id>(), new Set<String>{'Id'});
        new SLT_Agreement(false, false).getAgreementDetailsByIdWithReletedFields(new Set<Id>(), new Set<Id>(), new Set<String>{'Id'});
    }

    @isTest
    private static void testGetAgreementByOpportunityAndRecordTypeIdShouldReturnMap() {
        Account testAccount = setAccountData();
        Opportunity opp = setOpportunityData(testAccount.Id);
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(
            CON_CLM.PRELIMINARY_RECORDTYPEID, false);
        agreement.Apttus__Related_Opportunity__c = opp.Id;
        insert agreement;

        Test.startTest();
            Map<Id, Apttus__APTS_Agreement__c> resultMap = new SLT_Agreement().getAgreementByOpportunityAndRecordTypeId(
                new Set<Id>{opp.Id}, new Set<Id>{CON_CLM.PRELIMINARY_RECORDTYPEID}, new Set<String>{'Id', 'Name'});
        Test.stopTest();

        System.assertEquals(1, resultMap.size(), 
            'Agreement map must contain that inserted agreement but it is not.');
    }

    @isTest
    private static void testGetAgreementListByConditionShouldReturnList() {
        Account acc = setAccountData();
        Opportunity opp = setOpportunityData(acc.Id);
        Apttus_Proposal__Proposal__c proposal = TST_CLM_TestDataFactory.createProposalQuote(false);
        proposal.Apttus_Proposal__Opportunity__c = opp.Id;
        insert proposal;
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(
            CON_CLM.PSA_RECORDTYPEID, false);
        agreement.Apttus_QPComply__RelatedProposalId__c = proposal.Id;
        insert agreement;

        Set<String> agreementFields = new Set<String>{'Id', 'Name', 'Apttus_QPComply__RelatedProposalId__c', 'Special_Terms_Included__c'};
        String conditionForAgreement = 'Id IN : agreementIds AND Special_Terms_Included__c EXCLUDES (\''+CON_CLM.QUOTE_UPDATED+'\')';
        Set<Id> agreementIds = new Set<Id>{agreement.Id};

        Test.startTest();
            List<Apttus__APTS_Agreement__c> agreementList = new SLT_Agreement().getAgreementListByCondition(
                agreementFields, conditionForAgreement, agreementIds);
        Test.stopTest();

        System.assertNotEquals(0, agreementList.size(), 'Agreement list size cannot be zero.');
    }

    @isTest
    private static void testGetAgreementListByCondition() {
        Account acc = setAccountData();
        Opportunity opp = setOpportunityData(acc.Id);
        Apttus_Proposal__Proposal__c proposal = TST_CLM_TestDataFactory.createProposalQuote(false);
        proposal.Apttus_Proposal__Opportunity__c = opp.Id;
        insert proposal;
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        agreement.Apttus_QPComply__RelatedProposalId__c = proposal.Id;
        agreement.Special_Terms_Included__c = CON_CLM.QUOTE_UPDATED;
        insert agreement;

        Set<String> agreementFields = new Set<String>{'Id', 'Name', 'Apttus_QPComply__RelatedProposalId__c', 'Special_Terms_Included__c'};
        String conditionForAgreement = 'Id IN : agreementIds AND Special_Terms_Included__c INCLUDES (\'' + CON_CLM.QUOTE_UPDATED + '\')' +
            ' AND Special_Terms_Included__c EXCLUDES (\''+CON_CLM.QUOTE_ACCEPTED+'\')';
        Set<Id> agreementIds = new Set<Id>{agreement.Id};

        Test.startTest();
            List<Apttus__APTS_Agreement__c> agreementList = new SLT_Agreement().getAgreementListByCondition(
                agreementFields, conditionForAgreement, agreementIds);
        Test.stopTest();

        System.assertNotEquals(0, agreementList.size(), 'Agreement list size can not be zero.');
    }
    
    @isTest
    private static void testGetAgreementListByAgreementNumbers() {
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        agreement.Name = 'Test Agreement';
        agreement.Apttus__Agreement_Number__c = '12345';
        insert agreement;

        Test.startTest();
            List<Apttus__APTS_Agreement__c> agreementList = new SLT_Agreement().getAgreementListByAgreementNumbers(
                new Set<String>{'Id', 'Name'}, new Set<String>{agreement.Apttus__Agreement_Number__c});
        Test.stopTest();

        System.assertEquals(1, agreementList.size(), 'Agreement list size should be 1.');
    }

    @isTest
    private static void testGetAgreementListByQuoteId() {
        String agreementCondition = 'Apttus_QPComply__RelatedProposalId__c IN : quoteIds';
        Account acc = setAccountData();
        Opportunity opp = setOpportunityData(acc.Id);
        Apttus_Proposal__Proposal__c proposal = TST_CLM_TestDataFactory.createProposalQuote(false);
        proposal.Apttus_Proposal__Opportunity__c = opp.Id;
        insert proposal;
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        agreement.Apttus_QPComply__RelatedProposalId__c = proposal.Id;
        insert agreement;

        Test.startTest();
            List<Apttus__APTS_Agreement__c> agreementList = new SLT_Agreement().getAgreementListByQuoteId(
                new Set<Id>{proposal.Id}, new Set<String>{'Id', 'Name'},agreementCondition);
        Test.stopTest();

        System.assertEquals(1, agreementList.size(), 'Agreement list size should be 1.');
    }
    
    @isTest
    private static void testGetAgreementListWithDocumentVersions() {
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        agreement.Name = 'Test Agreement PSA';
        agreement.Apttus__Agreement_Number__c = '00012345';
        insert agreement;
        
        Apttus__DocumentVersion__c docVersion = setDocumentVersionData(agreement.Id);
        insert docVersion;
        
        Test.startTest();
            List<Apttus__APTS_Agreement__c> agreementList = new SLT_Agreement().getAgreementListWithDocumentVersions(
                new Set<Id>{agreement.Id}, new Set<String>{'Id', 'Name'});
        Test.stopTest();
        
        System.assertEquals(1,agreementList.size(), 'Returned Agreement List size is not 1');
        
    }
    
    @isTest
    private static void testGetAgreementListByConditions() {
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        agreement.Name = 'Test Agreement PSA';
        insert agreement;
        String condition = 'Id IN: agrIds';
        
        Test.startTest();
            List<Apttus__APTS_Agreement__c> agreementList = new SLT_Agreement().getAgreementListByConditions(new Set<String>{'Id'}, null, 
                new Set<Id>{agreement.Id}, condition, '');
        Test.stopTest();
        
        System.assertNotEquals(0, agreementList.size(), 'The size must not be 0');         
    }
}