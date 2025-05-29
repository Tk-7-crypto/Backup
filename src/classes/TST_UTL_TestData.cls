@isTest
public class TST_UTL_TestData{
    
    static Account setAccountData() {
        Account testAccount = UTL_TestData.createAccount();
        insert testAccount;
        return testAccount;
    }
    
    static Opportunity setOpportunityData(Id accountId){
        Opportunity testOpportunity= UTL_TestData.createOpportunity(accountId);
        testOpportunity.Line_of_Business__c = 'Data Sciences';
        testOpportunity.Potential_Regions__c = 'Asia Pacific';
        insert testOpportunity;
        return testOpportunity;
    }
    
    static Bid_History__c setClinicalBidData(String recordTypeName, Id opportunityId, String pricingTool) {
        
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        
        Id recordTypeId =
            SObjectType.Bid_History__c.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
        Bid_History__c testClinicalBid = UTL_TestData.createClinicalBid();
        testClinicalBid.Bid_History_Related_Opportunity__c = opportunityId;
        testClinicalBid.RecordTypeId = recordTypeId;
        testClinicalBid.Opportunity_Type__c = CON_CPQ.OPPORTUNITY_TYPE_BTS_BALLPARK;
        //testClinicalBid.Mark_as_Primary__c = false;
        testClinicalBid.DTE_Study__c = CON_CPQ.YES_TITLE_CASE;
        testClinicalBid.Budget_Tools__c = CON_CPQ.UNIT_PRICING_TOOL;
        //testClinicalBid.Mark_as_Primary__c = true;
        testClinicalBid.Is_PPT_Format_Required__c='No';
        testClinicalBid.Number_of_Scenarios__c = 10;
        insert testClinicalBid;
        return testClinicalBid;
    }
    
    @isTest
    public static void testMethod1() {
        Opportunity testOpp = new Opportunity();
        testOpp.CloseDate = Date.newInstance(2019, 07, 13);
        testOpp.AccountId = new Account().Id;
        Test.startTest();
        UTL_TestData.createAccount();
        UTL_TestData.createContact(null);
        UTL_TestData.createContacts(null,null);
        UTL_TestData.createLead();
        UTL_TestData.createContractInOutLog(new Contract());
        UTL_TestData.createContract(testOpp, 'MSA_Consolidation');
        Test.stopTest();
    }
    
    @isTest
    public static void testMethod2() {
        Test.startTest();
        UTL_TestData.createOpportunity(null);
        UTL_TestData.createOpportunityContactRole(null,null);
        UTL_TestData.createProduct();
        UTL_TestData.createFavoriteProduct(new Product2());
        UTL_TestData.createPricebookEntry(null);
        UTL_TestData.createOpportunityLineItem(null,null);
        UTL_TestData.createBillingSchedule(null);
        Test.stopTest();
    }
    
    @isTest
    public static void testMethod3() {
        Test.startTest();
        UTL_TestData.createBillingSchedule(null);
        UTL_TestData.createDefaultProductSearch(null);
        UTL_TestData.createOpportunitySplit(null,null,null);
        UTL_TestData.createOpportunityTeamMember(null,null);
        UTL_TestData.createUser('system administrator',2);
        UTL_TestData.createOpportunityLineItemSchedule(null);
        UTL_TestData.createCompetitor();
        Test.stopTest();
    }
    
    @isTest
    public static void testMethod4() {
        Opportunity testOpp = new Opportunity();
        List<Address__c> testAddList = new List<Address__c>();
        for(Integer i = 0 ; i < 5;  i++){
            testAddList.add(new Address__c());
        }
        Test.startTest();
        UTL_TestData.createOpportunityLineItemSchedule(null);
        UTL_TestData.createMIBNF(new Opportunity(),new Revenue_Analyst__c());
        UTL_TestData.createMIBNF_Comp(new MIBNF2__c(),testAddList);
        UTL_TestData.createAddresses(new Account());
        UTL_TestData.createSAPContacts(testAddList);
        UTL_TestData.createRevenueAnalyst();
        UTL_TestData.createCPQSettings();
        UTL_TestData.createClientSatSurveyRecord('','','a138E000000N9dr',testOpp.Id);
        UTL_TestData.createDeclinedSurveyApproverGroup('','','','','',1.0);
        UTL_TestData.createCase();
        UTL_TestData.cpqProposalCreateSettings();
        Test.stopTest();
    }
    
    @isTest
    public static void testMethod5() {
        Test.startTest();
        UTL_TestData.createMulesoftIntegrationControl(null);
        UTL_TestData.createLegacyOrgLink();
        UTL_TestData.createProxySCMAgreement(null);
        UTL_TestData.createProxyProject(null);
        UTL_TestData.createUserContactSync();
        UTL_TestData.createMergeQueue();
        UTL_TestData.createAgreement();
        UTL_TestData.createApplication();
        UTL_TestData.createContractExternal();
        UTL_TestData.createGroup('','');
        UTL_TestData.createGroupMember(null,null);
        UTL_TestData.createEmailTemplate('','','');
        UTL_TestData.createAttachment();
        UTL_TestData.createAgreementLineItem(null, null);
        UTL_TestData.createChallengeMatrix(null, null, null, null, null, null, null);
        UTL_TestData.createApproverGroup(null, null);
        UTL_TestData.createTemplateData('test template');
        UTL_TestData.createContract(new Account().Id);
        UTL_TestData.createAccountDirectoryData(CON_CPQ.ROLE_ADDITIONAL, new Account(), CON_CPQ.CUSTOMER_NAME);
        UTL_TestData.createCountrySalesHeadData(CON_CPQ.SALE_TYPE_LARGE,CON_CPQ.COUNTRY,CON_CPQ.CUSTOMER_NAME);
        Test.stopTest();
    }
    
    @isTest
    public static void testMethod6() {
        Test.startTest();
        UTL_TestData.createBillingScheduleItem(null);
        UTL_TestData.createQCCheckListItem();
        UTL_TestData.createProposalQASelfCheckList();
        UTL_TestData.createSalesTeamHierarchy();
        UTL_TestData.createIQVIALegalEntity();
        UTL_TestData.createCampaign();
        UTL_TestData.createDocument('Test','Test','Test');
        UTL_TestData.createTask('Test',null,'Test','Test');
        UTL_TestData.createSalesTeamHierarchyVP('12345');
        UTL_TestData.createContacts(null,1);
        UTL_TestData.createOneKeyConfig();
        UTL_TestData.createPermissionSetAssignmentRecord('Test',null);
        Test.stopTest();
    }
    
    @isTest
    public static void testMethod7() {
        
        Apttus__APTS_Agreement__c agreement = UTL_TestData.createAgreement();
        agreement.RecordTypeId = CON_CLM.MSA_RECORDTYPEID;
        insert agreement;
        Test.startTest();
        UTL_TestData.createSObjectSharingParentData('Apttus__APTS_Agreement__c', 'Apttus__APTS_Agreement__Share','Agreement_Territory__c',
                                                    'Agreement_Team__c', 'Derived', 'Agreement__c', 'Account_Country__c', 'Record_Type__c', '', '');
        UTL_TestData.createSObjectSharingChildData('Apttus__APTS_Agreement__c', 'Apttus__APTS_Agreement__Share', 'Agreement_Child_Object__c',
                                                   '', 'Agreement__c', 'Parent_Agreement_Territory__c', 'Parent_Agreement_Team__c', 
                                                   'Parent_Agreement_Owner__c', 'Agreement_Team__c', 'Agreement_Territory__c','');
        List<Group> groupList = [Select Id FROM Group LIMIT 1];
        UTL_TestData.createTerritorySharingData(groupList[0].Id, 'Apttus__APTS_Agreement__c');
        UTL_TestData.createFailRecordSharing(agreement.Id, null);
        UTL_TestData.createTeamSharingData('', '', '','');
        Test.stopTest();
    }
    
    @isTest
    public static void testMethod8() {
        Test.startTest();
            Approver_Group__c approverGroup = UTL_TestData.createApproverGroup(CON_CPQ.APPROVER_GROUP_PL, null);
            insert approverGroup;
            Account testAccount = setAccountData();
            Opportunity testopportunity = setOpportunityData(testAccount.Id);
            Product2 testProduct = UTL_TestData.createProduct();
            insert testProduct;
            Bid_History__c testClinicalBid = setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
            Apttus_Proposal__Proposal__c budget = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, testClinicalBid.Id);   
            update budget;
        	Apttus_Proposal__Proposal__c proposal = UTL_TestData.setTSProposalData(true, CON_CPQ.TECH_SOLUTION, testopportunity.Id, CON_CPQ.TS_JAPAN);
            UTL_TestData.createApprovalMatrix(approverGroup, CON_CPQ.OPPORTUNITY_RFP, CON_CPQ.REGION_ASIA_PASIFIC, CON_CPQ.ONCOLOGY, '', '', '','', '', CON_CPQ.APPROVER_SALES_EMERGING_BIOPHARMA,
                CON_CPQ.MD, CON_CPQ.ROLE_PRIMARY1, CON_CPQ.ONCOLOGY, CON_CPQ.CUSTOMER_NAME);
            UTL_TestData.createAgreementLineItem(testClinicalBid.Id, testProduct.Id);
            UTL_TestData.createProposalLineItem(budget.Id, testProduct.Id);
            UTL_TestData.createQuoteCountryInputs(budget.Id);
            UTL_TestData.createTeamMember(CON_CPQ.APPROVER, CON_CPQ.TSL, UserInfo.getUserId(), budget.Id);
            UTL_TestData.createQuoteTimelines(budget.Id);
            UTL_TestData.createAgreementLineItems(testClinicalBid.Id);
            UTL_TestData.createProposalLineItems(budget.Id);
            UTL_TestData.createProposalLineItemsForClinicalVisitFrequency(budget.Id);
            UTL_TestData.createClinicalVisitFrequencyData(budget.Id);
            UTL_TestData.createAdminTimeEntryData(budget.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void testMethodForBudget() {
        Test.startTest();
            Apttus_Proposal__Proposal__c budget = UTL_TestData.createQuote();
            UTL_TestData.createQuoteLineItem(budget.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void testCreateCustomerProfileRecord() {
        Test.startTest();
        Customer_Profile__c cProfile = UTL_TestData.createCustomerProfileRecord('Description', true, 1, false, null);
        Test.stopTest();
    }
    public static void testCreateLevelUpRecord() {
        Test.startTest();
        Level_Up__c lvl = UTL_TestData.createLevelUpRecord('Description', true, 1, false, null);
        Test.stopTest();
    }
    
    @isTest
    public static void testCreatePriceList() {
        Test.startTest();
            Apttus_Config2__PriceList__c priceList = UTL_TestData.createPriceList();
        Test.stopTest();
    }
    
    @isTest
    public static void testCreateProductConfiguration() {
        Test.startTest();
            Apttus_Proposal__Proposal__c budget = UTL_TestData.createQuote();
            Apttus_Config2__ProductConfiguration__c productConfig = UTL_TestData.createProductConfiguration(budget.Id, CON_CPQ.SALE_TYPE_NEW);
        Test.stopTest();
    }
    
    @isTest
    public static void testCreateCPQTSPriceListSelectionCustomSettings() {
        Test.startTest();
            UTL_TestData.createCPQTSPriceListSelectionCustomSettings();
        Test.stopTest();
    }
    
    @isTest
    public static void testCreatePriceListByName() {
        Test.startTest();
            UTL_TestData.createPriceList(CON_CPQ.TECH_SOLUTION_JAPAN);
        Test.stopTest();
    }
    
    @isTest
    public static void testCreatePriceListItem() {
        Product2 product = UTL_TestData.createProduct();
        insert product;
        
        Apttus_Config2__PriceList__c priceList = UTL_TestData.createPriceList(CON_CPQ.TECH_SOLUTION_JAPAN);
        
        Test.startTest();
            UTL_TestData.createPriceListItem(product.Id, priceList.Id, 'PLI-91');
        Test.stopTest();
    }

    @isTest
    public static void testBuildTestConfiguration() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        Apttus_Proposal__Proposal__c proposal = UTL_TestData.setTSProposalData(true, CON_CPQ.TECH_SOLUTION, opp.Id, CON_CPQ.COMPLETE_CONSENT);
        Test.startTest();
            UTL_TestData.buildTestConfiguration(proposal.Id, true);
        Test.stopTest();
    }

    @isTest
    public static void testCreateProposalProductAttribute() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        Apttus_Proposal__Proposal__c proposal = UTL_TestData.setTSProposalData(true, CON_CPQ.TECH_SOLUTION, opp.Id, CON_CPQ.COMPLETE_CONSENT);
        Apttus_Proposal__Proposal_Line_Item__c proposalLineItem = UTL_TestData.createQuoteLineItem(proposal.Id);
        insert proposalLineItem;
        Test.startTest();
            UTL_TestData.createProposalProductAttribute(proposalLineItem.Id, CON_CPQ.INDIA, true);
        Test.stopTest();
    }

    @isTest
    public static void testCreateProductAttribute() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        Apttus_Proposal__Proposal__c proposal = UTL_TestData.setTSProposalData(true, CON_CPQ.TECH_SOLUTION, opp.Id, CON_CPQ.COMPLETE_CONSENT);
        Id cartId = UTL_TestData.buildTestConfiguration(proposal.Id, true).Id;
        Apttus_Config2__LineItem__c lineItem = TST_TestGeneratorClass.createOptionConfigLineItem(cartId, 1, 1, null, null, 1, 100);
        insert lineItem;
        Test.startTest();
            UTL_TestData.createProductAttribute(lineItem.Id, CON_CPQ.INDIA, true);
        Test.stopTest();
    }

    @isTest
    public static void testCreateQuoteRequisites() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        Quote__c testQuote = UTL_TestData.createIqviaQuote(acc.Id, opp.Id, null, CON_CPQ.Complete_Consent, CON_CPQ.GBU_DPS, true);
        Test.startTest();
            UTL_TestData.createQuoteRequisites(testQuote.Id, CON_CPQ.COUNTRY_INPUT, true);
        Test.stopTest();
    }

    @isTest
    public static void testCreateBidHistoryData() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        Id recordTypeId = UTL_TestData.getRecordType(CON_CPQ.Q2_Solutions_BID_HISTORY_RECORD_TYPE_NAME, CON_CPQ.BID_HISTORY).Id;
        Test.startTest();
            UTL_TestData.createBidHistoryData(acc.Id, opp.Id, recordTypeId, true);
        Test.stopTest();
    }

    @isTest
    public static void testCreateProposalData() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        Quote__c testQuote = UTL_TestData.createIqviaQuote(acc.Id, opp.Id, null, CON_CPQ.Complete_Consent, CON_CPQ.GBU_DPS, true);
        Id recordTypeId = UTL_TestData.getRecordType(CON_CPQ.TECH_SOLUTION, CON_CPQ.APTTUS_PROPOSAL_PROPOSAL).Id;
        Test.startTest();
            UTL_TestData.createProposalData(acc.Id, opp.Id, testQuote.Id, recordTypeId, CON_CPQ.Complete_Consent, CON_CPQ.IN_PROGRESS_STATUS, true);
        Test.stopTest();
    }
    
    @isTest
    public static void testCreateIqviaQuoteLineItem() {
        Account acc = UTL_TestData.createAccount();
        insert acc;
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        insert opp;
        Site_Submission__c ss = UTL_TestData.creatSiteSubmissionRecord(opp.Id, null, null);
        insert ss;
        Quote__c testQuote = UTL_TestData.createIqviaQuote(acc.Id, opp.Id, null, CON_CPQ.Complete_Consent, CON_CPQ.GBU_DPS, true);
        Test.startTest();
            UTL_TestData.createIqviaQuoteLineItem(testQuote.Id, CON_CPQ.Complete_Consent, true);
        Test.stopTest();
    }
    
    @isTest
    public static void testTempDataCreation() {
        Test.startTest();
            Account acc = UTL_TestData.createAccount();
            insert acc;
            UTL_TestData.tempDataCreation('Quote', 'Quote__c', 'Quote_Line_Item__c');
        	UTL_TestData.getCurrencyExchangeRate(false);
        	UTL_TestData.createOpportunityData(acc.Id, 'Other', '', 'Global', 'US', false);
        Test.stopTest();
    }
}