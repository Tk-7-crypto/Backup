@IsTest
private class TST_CNT_CPQ_QuoteWorkflow {

    @TestSetup
    static void dataSetup() {
        CPQ_Proposal_Create_Settings__c customSettingsObj = new CPQ_Proposal_Create_Settings__c();
        customSettingsObj.Name = CON_CPQ.GBU_DPS;
        customSettingsObj.Permission_Set_Name__c = CON_CPQ.DPS_Permission_Set;
        customSettingsObj.Proposal_Record_Type_Name__c = CON_CPQ.TECH_SOLUTION;
        customSettingsObj.Flow_Name__c = CON_CPQ.GBU_DPS;
        customSettingsObj.Available_Pricing_Tools__c = CON_CPQ.Complete_Consent;
        customSettingsObj.Conga_Setup__c = true;
        insert customSettingsObj;
        
        Account acc = UTL_TestData.createAccount();
        acc.AccountCountry__c = CON_CPQ.AL;
        insert acc;
        
        List<Product2> prodList = new List<Product2>();
        Product2 prod = TST_TestGeneratorClass.buildTestProduct('SL-Development Metabolism', CON_CPQ.BUNDLE, 'Q_111813', 'US', 'Go Blue');
        prodList.add(prod);
        Product2 prod1 = TST_TestGeneratorClass.buildTestProduct('Tablet Initiation', CON_CPQ.OPTION, 'CES_2076D', '', '');
        prod1.CanUseRevenueSchedule = true;
        prod1.Billing_System__c = CON_CPQ.SAP;
        prodList.add(prod1);
        Product2 prod2 = TST_TestGeneratorClass.buildTestProduct('COMPLETE CONSENT SERVICES', CON_CPQ.BUNDLE, 'CES_2077H', '', '');
        prod2.CanUseRevenueSchedule = true;
        prod2.Billing_System__c = CON_CPQ.SAP;
        prodList.add(prod2);
        insert prodList;

        Opportunity testOpportunity= UTL_TestData.createOpportunityData(acc.id, CON_CPQ.CLINICAL, null, CON_CPQ.REGION_ASIA_PASIFIC, CON_CPQ.USD, false);
        insert testOpportunity;
        
        Quote__c quote = UTL_TestData.createIqviaQuote(acc.Id, testOpportunity.Id, null, CON_CPQ.Complete_Consent, CON_CPQ.GBU_DPS, false);
        quote.Approval_Stage__c = CON_CPQ.DRAFT;
        quote.Document_Type__c = CON_CPQ.PDF_INDIVIDUAL_DOCUMENTS;
        quote.License_Type__c = 'Per Study';
        quote.Contracting_Country__c  = 'India';
        insert quote;
        
        Quote_Requisites__c quoteRequisite = UTL_TestData.createQuoteRequisites(quote.Id, CON_CPQ.STUDY_TYPE, false);
        quoteRequisite.Service_Line_Product__c = prodList[0].Id;
        insert quoteRequisite;
        
        Id recordTypeId  = UTL_TestData.getProposalRecordtypeId(CON_CPQ.TECH_SOLUTION);

        Apttus_Proposal__Proposal__c proposal = UTL_TestData.createProposalData(acc.Id, testOpportunity.Id, quote.Id, recordTypeId, CON_CPQ.COMPLETE_CONSENT, CON_CPQ.FINALIZED, false);
        proposal.Apttus_QPConfig__ConfigurationFinalizedDate__c = Datetime.now().addMinutes(-20);
        insert proposal;
        
        Quote_Line_Item__C testQLI = UTL_TestData.createIqviaQuoteLineItem(quote.Id, CON_CPQ.COMPLETE_CONSENT, false);
        testQLI.Option_Product__c = prodList[1].Id;
        insert testQLI;
        
        Quote_Requisites__c countryInput = UTL_TestData.createQuoteRequisites(quote.Id, 'Country Input', false);
        insert countryInput;

        CPQ_Country_Master_Data__c countryMdt = new CPQ_Country_Master_Data__c(Country__c = 'Mexico', Language__c = 'Test Language');
        insert countryMdt;	
        
        Quote__c quote1 = UTL_TestData.createIqviaQuote(acc.Id, testOpportunity.Id, null, CON_CPQ.Complete_Consent, CON_CPQ.GBU_DPS, false);
        quote1.Approval_Stage__c = CON_CPQ.DRAFT;
        quote1.Document_Type__c = CON_CPQ.PDF_INDIVIDUAL_DOCUMENTS;
        quote1.License_Type__c = 'Per Study';
        quote1.Related_Quote__c = quote.Id;
        quote1.Selected_Languages__c = CON_CPQ.INDIA;
        quote1.Contracting_Country__c  = 'India';
        insert quote1;
        
        Id userId = userInfo.getUserId();
        
        List<Approval_Matrix__c> approvalMatrixList = new List<Approval_Matrix__c>();
        Approval_Matrix__c approvalMatrix = new Approval_Matrix__c(
            Object_Name__c = 'Quote__c',
            levels__c = 'Level 1',
            priority__c = 1,
            Min_Amount__c = 200,
            Approver_1__c = userId,
            Approver_2__c = userId,
            Approver_3__c = userId,
            Approver_4__c = userId,
            Approver_5__c = userId,
            Notifier_1__c = 'test@gmail.com',
            Notifier_2__c = 'test@gmail.com',
            Notifier_3__c = 'test@gmail.com',
            Notifier_4__c = 'test@gmail.com',
            Notifier_5__c = 'test@gmail.com',
            Approve_On_First_Response__c = false,
            Auto_Approve__c = false,
            Track_Name__c = CON_CPQ.CPQ,
            Process_Type__c = CON_CPQ.APPROVAL_PROCESS,
            Country__c = 'India'
        );
        approvalMatrixList.add(approvalMatrix);
        
        Approval_Matrix__c approvalMatrix2 = new Approval_Matrix__c(
            Object_Name__c = 'Quote__c',
            levels__c = 'Level 1',
            priority__c = 2,
            Min_Amount__c = 200,
            Notifier_1__c = 'test@gmail.com',
            Notifier_2__c = 'test@gmail.com',
            Notifier_3__c = 'test@gmail.com',
            Notifier_4__c = 'test@gmail.com',
            Notifier_5__c = 'test@gmail.com',
            Approve_On_First_Response__c = false,
            Auto_Approve__c = true,
            Track_Name__c = CON_CPQ.CPQ,
            Process_Type__c = CON_CPQ.APPROVAL_PROCESS,
            Country__c = 'India'
        );
        approvalMatrixList.add(approvalMatrix2);
        
        Approval_Matrix__c approvalMatrix3 = new Approval_Matrix__c(
            Object_Name__c = 'Quote__c',
            levels__c = 'Level 2',
            priority__c = 3,
            Min_Amount__c = 200,
            Approver_1__c = userId,
            Approver_2__c = userId,
            Approver_3__c = userId,
            Approver_4__c = userId,
            Approver_5__c = userId,
            Notifier_1__c = 'test@gmail.com',
            Notifier_2__c = 'test@gmail.com',
            Notifier_3__c = 'test@gmail.com',
            Notifier_4__c = 'test@gmail.com',
            Notifier_5__c = 'test@gmail.com',
            Approve_On_First_Response__c = false,
            Auto_Approve__c = false,
            Track_Name__c = CON_CPQ.CPQ,
            Process_Type__c = CON_CPQ.APPROVAL_PROCESS,
            Country__c = 'India'
        );
        approvalMatrixList.add(approvalMatrix3);
        
        insert approvalMatrixList;

        ContentVersion contentVersion = new ContentVersion(
            Title = 'Draft_Test Document',
            PathOnClient = 'TestDocument.pdf',
            VersionData = Blob.valueOf('Test Content'),
            FirstPublishLocationId = quote.Id
        );
        insert contentVersion;

        CPQ_Settings__c cus1 =  new CPQ_Settings__c();
        cus1.Name =  CON_CPQ.NAMESPACE_PREFIX;
        cus1.Package_Namespace_Prefix__c = CON_CPQ.CONGA_PACKAGE_NAMESPACE_PREFIX;
        cus1.Document_Package_Namespace_Prefix__c = CON_CPQ.CONGA_PACKAGE_NAMESPACE_PREFIX;
        cus1.EMEA_Phase_2_Go_Live__c = Date.Today()-10;
        insert cus1;
        Criteria_Matrix__c apm = new Criteria_Matrix__c(
            Object_Name__c = 'Quote__c',
            Field_Name__c = 'Contracting_Country__c',
            Condition__c = 'In',
            Order__c = 1,
            Approval_Matrix_Field_Name__c = 'Country__c',
            Field_Type__c = 'country'
        );
        insert apm;
    }
    
    @isTest static void testGetQuoteDetails() {
        Quote__c quote = [SELECT Id FROM Quote__c LIMIT 1];
        quote.Selected_Languages__c = 'Hindi';
        update quote;
        
        Test.startTest();
            CNT_CPQ_QuoteWorkflow.IQVIA_CPQ_QuoteDetails quoteDetails = CNT_CPQ_QuoteWorkflow.getQuoteDetails(quote.Id);
            System.assertEquals(false, quoteDetails.isApprover, 'isApprover should be false');
            System.assertEquals(null, quoteDetails.approverDetails, 'Approver Details should be null');
            System.assertEquals(null, quoteDetails.description, 'Description should be null');
            String jobId = CNT_CPQ_QuoteWorkflow.syncQLIWithOpportunity(quote.Id, CON_CPQ.Complete_Consent, CON_CPQ.IN_PROGRESS_STATUS);
            System.assertNotEquals(null, jobId, 'Job Id should not be null');
            CNT_CPQ_QuoteWorkflow.syncQLIWithOpportunity(quote.Id, CON_CPQ.Complete_Consent, CON_CPQ.IN_PROGRESS_STATUS);
        Test.stopTest();
    }

    @isTest
    static void testFinalizeQuote() {
        Quote__c quote = [SELECT Id FROM Quote__c LIMIT 1];
        Integer numberOfCongaQuoteIds = 1;
        Integer numberOfExcelTool = 0;
        List<String> congaTools = new List<String>{CON_CPQ.Complete_Consent};
        Test.startTest();
            String result = CNT_CPQ_QuoteWorkflow.finalizeQuote(numberOfCongaQuoteIds, numberOfExcelTool, quote.Id, congaTools, 'EUR');
        Test.stopTest();
        System.assertEquals(CON_CPQ.SUCCESS, result, 'The desired result should be Success.');
    }
    
    @isTest static void testGetApproverDetails() {
        User runningUser = [Select Id from User LIMIT 1];
        Quote__c quote = [SELECT Id FROM Quote__c LIMIT 1];
        quote.Approval_Stage__c = CON_CPQ.FINALIZED;
        quote.Approver_1__c = runningUser.Id;
        quote.Approver_2__c = runningUser.Id;
        quote.Approver_3__c = runningUser.Id;
        quote.Approver_4__c = runningUser.Id;
        quote.Approver_5__c = runningUser.Id;
        quote.Priority__c = 1;
        update quote;
        
        List<Approval.ProcessSubmitRequest> approvalRequests = new List<Approval.ProcessSubmitRequest>();
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for first level of approval');
        req1.setObjectId(quote.id);
        approvalRequests.add(req1);
        Approval.process(approvalRequests);
        quote = [SELECT Id FROM Quote__c WHERE Id =: quote.Id];
        quote.Approval_Stage__c = CON_CPQ.PENDING_APPROVAL;
        update quote;
        
        Test.startTest();
            CNT_CPQ_QuoteWorkflow.getQuoteDetails(quote.Id);
            List<ProcessInstanceWorkitem> workItemList = CNT_CPQ_QuoteWorkflow.getProcessInstanceWorkItems(quote, new Set<String>{runningUser.Id});
            CNT_CPQ_QuoteWorkflow.getProcessInstanceWorkItems(quote, null);
            List<CNT_CPQ_QuoteWorkflow.ApproverDetails> approverDetails = CNT_CPQ_QuoteWorkflow.getApproverDetails(quote.Id, null, workItemList);
            String result = CNT_CPQ_QuoteWorkflow.updateApprovers(JSON.serialize(approverDetails), quote.Id);
            System.assertNotEquals(null, approverDetails, 'Approver details should not be null');
            try {
                result = CNT_CPQ_QuoteWorkflow.updateApprovers('test approver', quote.Id);
            } catch(Exception e) {
                System.assertNotEquals(null, e, 'Exception is handled');
            }
        Test.stopTest();
    }
    
    @isTest
    static void testGetLanguagesByCountry() {
        Quote__c quote = [SELECT Id FROM Quote__c LIMIT 1];

        Test.startTest();
            List<String> result = CNT_CPQ_QuoteWorkflow.getLanguagesByCountry(quote.Id);
        Test.stopTest();

        System.assertEquals(true, result.size() > 0, 'Result must be returned as true.');
    }
    
    @isTest
    static void testUpdateLanguages() {
        Quote__c quote = [SELECT Id FROM Quote__c WHERE Related_Quote__c = null LIMIT 1];
        Test.startTest();
            String result = CNT_CPQ_QuoteWorkflow.updateLanguages(quote.Id, new List<String>{'Test Language'});
        Test.stopTest();
        
        System.assertEquals(CON_CPQ.SUCCESS, result, 'The desired result should be Success.');
    }

    @isTest
    static void testUpdateQuoteStageMethod() {
        Quote__c quote = [SELECT Id FROM Quote__c LIMIT 1];
        Test.startTest();
            String result = CNT_CPQ_QuoteWorkflow.updateQuoteStage(quote.Id, CON_CPQ.ACCEPTED);
            System.assertEquals(CON_CPQ.SUCCESS, result, 'The desired result should be Success.');

            String result2 = CNT_CPQ_QuoteWorkflow.updateQuoteStage(quote.Id, null);
            System.assertEquals('Fail', result2, 'The desired result should be Fail.');
        Test.stopTest();
    }

    @isTest
    static void testMarkQuoteAsPrimary() {
        Quote__c quote = [SELECT Id, Related_Opportunity__c FROM Quote__c LIMIT 1];
        Test.startTest();
            Boolean result = CNT_CPQ_QuoteWorkflow.markQuoteAsPrimary(quote.Id, quote.Related_Opportunity__c);
            System.assertEquals(true, result, 'Result must be returned as true.');
            CNT_CPQ_QuoteWorkflow.markQuoteAsPrimary(null, null);
            try {
                CNT_CPQ_QuoteWorkflow.markQuoteAsPrimary(quote.Related_Opportunity__c, quote.Related_Opportunity__c);
            } catch(Exception e) {
                System.assertNotEquals(null, e, 'Exception is handled');
            }
        Test.stopTest();
    }
    
    @isTest
    static void testGetGuidanceFileURL() {
        ContentVersion testContentVersion = new Contentversion();
        testContentVersion.Title = 'DND-CPQ-DPS-GuidanceFile';
        testContentVersion.PathOnClient = 'test';
        testContentVersion.VersionData = EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert testContentVersion;
        
        Test.startTest();
            String guidanceFilURL = CNT_CPQ_QuoteWorkflow.getGuidanceFileURL();
        Test.stopTest(); 
        System.assertEquals(true, guidanceFilURL.contains(testContentVersion.Id), 'Guidance file exit');
    }

    @isTest
    static void testGetStudyInformation() {
        Quote__c quote = [SELECT Id FROM Quote__c LIMIT 1];
        Quote_Requisites__c quoteRequisite = [SELECT Id FROM Quote_Requisites__c WHERE Quote__c =: quote.Id LIMIT 1];
        String studyNumber = '1';
        Test.startTest();
            List<Quote_Requisites__c> studyInformation = CNT_CPQ_QuoteWorkflow.getStudyInformation(studyNumber, quote.Id);
            CNT_CPQ_QuoteWorkflow.getStudyInformation(null, quote.Id);
        Test.stopTest();
        System.assertEquals(quoteRequisite.Id, studyInformation[0].Id, 'Related Study not found');
    }
    
    @isTest
    static void testAddBundleProductInCart () {
        Test.startTest();
            Apttus_Config2__PriceList__c priceList = UTL_TestData.createPriceList(CON_CPQ.COMPLETE_CONSENT);
            Apttus_Proposal__Proposal__c proposal = [SELECT Id, IQVIA_Quote__c FROM Apttus_Proposal__Proposal__c LIMIT 1];
            Product2 prod = [SELECT Id FROM Product2 LIMIT 1];
            proposal.Apttus_QPConfig__PriceListId__c = priceList.Id;
            update proposal;
            Apttus_Config2__PriceListItem__c priceListItem = UTL_TestData.createPriceListItem(prod.id, priceList.Id, 'PLI-01'); 
            insert priceListItem;
            Apttus_Config2__ProductConfiguration__c pc = new Apttus_Config2__ProductConfiguration__c();
            pc.Apttus_QPConfig__Proposald__c = proposal.Id;
            insert pc;
            CNT_CPQ_QuoteWorkflow.addBundleProductInCart(proposal.IQVIA_Quote__c, proposal.Id, null);
        Test.stopTest();
    }
    
    @isTest
    static void finalizeQuoteForSingleTool_test() {
        Test.startTest();
            Apttus_Proposal__Proposal__c proposal = [SELECT Id, IQVIA_Quote__c FROM Apttus_Proposal__Proposal__c LIMIT 1];
            String result = CNT_CPQ_QuoteWorkflow.finalizeQuoteForSingleTool(proposal.Id);
            result = CNT_CPQ_QuoteWorkflow.finalizeQuoteForSingleTool(proposal.Id);
            result = CNT_CPQ_QuoteWorkflow.finalizeAndSetAmountOnQuote(null, null, null);
        Test.stopTest();
        System.assertNotEquals('Fail', result, 'The desired result should be Fail.');
    }
    
    @isTest
    static void testAddBundleProductInCartOnClone() {
        Quote__c quote = [SELECT Id, Name, Related_Quote__c FROM Quote__c WHERE Related_Quote__c != null LIMIT 1];
         
        Apttus_Config2__PriceList__c priceList = UTL_TestData.createPriceList(CON_CPQ.COMPLETE_CONSENT);

        Apttus_Proposal__Proposal__c proposal = [SELECT Id, IQVIA_Quote__c FROM Apttus_Proposal__Proposal__c LIMIT 1];
        proposal.IQVIA_Quote__c = quote.Id;
        update proposal;

        Product2 prod = [SELECT Id, Name, ProductCode FROM Product2 LIMIT 1];
        Product2 prod1 = TST_TestGeneratorClass.buildTestProduct('SL-PCR', CON_CPQ.BUNDLE, 'Q_11181', 'US', 'Go Blue');
        insert prod1;

        Quote_Requisites__c quoteRequisite = UTL_TestData.createQuoteRequisites(quote.Id, CON_CPQ.STUDY_TYPE, false);
        quoteRequisite.Service_Line_Product__c = prod1.Id;
        insert quoteRequisite;

        Apttus_Config2__PriceListItem__c priceListItem = UTL_TestData.createPriceListItem(prod1.id, priceList.Id, 'PLI-01'); 
        insert priceListItem;

        proposal.Apttus_QPConfig__PriceListId__c = priceList.Id;
        update proposal;

        Apttus_Config2__PriceListItem__c priceListItem1 = UTL_TestData.createPriceListItem(prod.id, priceList.Id, 'PLI-02'); 
        insert priceListItem1;

        Apttus_Config2__ProductConfiguration__c pc = UTL_TestData.createProductConfiguration (proposal.Id,  CON_CPQ.PRODUCT_CONFIG_STATUS_SAVED);
        insert pc;

        Apttus_Config2__LineItem__c lineItem = TST_TestGeneratorClass.createOptionConfigLineItem(pc.Id, 1, 1, prod1.id, Prod.Id, 1, 987);
        insert lineItem;

        Apttus_Config2__ProductAttributeValue__c aValue = UTL_TestData.createProductAttribute (lineItem.Id, '', false);
        insert aValue;

        lineItem.Apttus_Config2__AttributeValueId__c = aValue.Id;
        update lineItem;

        Test.startTest();
            CNT_CPQ_QuoteWorkflow.addBundleProductInCart(proposal.IQVIA_Quote__c, proposal.Id, quote.Related_Quote__c);
        Test.stopTest();
    }
    
    @isTest
    static void testRejectRestQuotes() {
        Quote__c quote = [SELECT Id, Related_Opportunity__c, Approval_Stage__c, Priority__c FROM Quote__c LIMIT 1];
        quote.Approval_Stage__c = CON_CPQ.ACCEPTED;
        quote.Priority__c = 1;
        update quote;
        Test.startTest();
            String res = CNT_CPQ_QuoteWorkflow.rejectRestQuotes(quote.Related_Opportunity__c, quote.Id, CON_CPQ.RECORD_TYPE_TECH_SOLUTION);
        Test.stopTest();
        System.assertEquals(res, CON_CPQ.SUCCESS, 'The desired result should be Success.');
    }

    @isTest
    static void testGetProcessInstance() {
        Quote__c quote = [SELECT Id FROM Quote__c LIMIT 1];
        Test.startTest();
            List<ProcessInstance> processInstances = CNT_CPQ_QuoteWorkflow.getProcessInstance(quote.Id);
        Test.stopTest();
        Assert.areEqual(0, processInstances.size(), 'The list size must be 0');
    }
    
    @isTest
    static void testRecallApprovalProcess() {
        Quote__c quote = [SELECT Id FROM Quote__c LIMIT 1];
        quote.Approval_Stage__c = CON_CPQ.FINALIZED;
        quote.Approver_1__c = quote.Approver_2__c = quote.Approver_3__c = quote.Approver_4__c = quote.Approver_5__c = UserInfo.getUserId();
        quote.Priority__c = 1;
        update quote;
        
        List<Approval.ProcessSubmitRequest> approvalRequests = new List<Approval.ProcessSubmitRequest>();
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Submitting request for first level of approval');
        req1.setObjectId(quote.id);
        approvalRequests.add(req1);
        Approval.process(approvalRequests);
        
        Test.startTest();
            String result = CNT_CPQ_QuoteWorkflow.recallApprovalProcess(quote.Id);
        Test.stopTest();
        
        Assert.areEqual('Success', result, 'Return message should be success');
    }

    @isTest
    static void testcheckAlreadyAccepted() {
        Quote__c quote = [SELECT Id, Related_Opportunity__c FROM Quote__c LIMIT 1];
        Test.startTest();
            boolean result = CNT_CPQ_QuoteWorkflow.checkAlreadyAccepted(quote.Related_Opportunity__c);
        Test.stopTest();
        System.assertEquals(false, result, 'Return value should be false when the quote is not accepted.');
    }

    @IsTest
    static void testUpdateProposal() {
        Apttus_Proposal__Proposal__c proposal = [SELECT Id FROM Apttus_Proposal__Proposal__c LIMIT 1];
        Test.startTest();
            CNT_CPQ_QuoteWorkflow.updateProposal(proposal.Id);
        Test.stopTest();
        proposal = [SELECT Apttus_Proposal__Approval_Stage__c FROM Apttus_Proposal__Proposal__c WHERE Id = :proposal.Id];
        System.assertEquals('In-Progress', proposal.Apttus_Proposal__Approval_Stage__c);
    }
    
    @isTest
    static void testCheckNonZPubProducts() {
        Quote__c quote = [SELECT Id, Related_Opportunity__c, GBU__c FROM Quote__c LIMIT 1];
        quote.GBU__c = CON_CPQ.RECORD_TYPE_TECH_SOLUTION;
        update quote;
        Product2 prod = [SELECT Id, Material_Type__c FROM Product2 LIMIT 1];
        prod.Material_Type__c = 'ZPUB';
        update prod;
        Quote_Line_Item__c qli = new Quote_Line_Item__c(Bundle_Product__c = prod.Id, BasePrice__c = 10,  Revenue_Type__c = 'Ad Hoc', Quote__c = quote.Id, Pathway__c = 'Manual', Pricing_Tool__c ='EMEA');
        Boolean haveNonZPubProduct = false;
        Test.startTest();
            haveNonZPubProduct = CNT_CPQ_QuoteWorkflow.checkNonZPubProducts(quote.Id);
        Test.stopTest();
        System.assertEquals(true, haveNonZPubProduct, 'Non ZPUB product available for this quote.');
    }
	
    @isTest
    static void testZrepProducts() {     
        Quote__c quote = [SELECT Id, Related_Opportunity__c, Related_Opportunity__r.Business_Unit__c,Related_Opportunity__r.Exclude_from_Pricing_Assistant__c, GBU__c FROM Quote__c LIMIT 1];
        Opportunity opportunity = [SELECT Id FROM Opportunity WHERE Id = :quote.Related_Opportunity__c];
        opportunity.Business_Unit__c = 'EMEA';
        update opportunity;
        Product2 prod = [SELECT Id, Material_Type__c FROM Product2 WHERE ProductCode ='Q_111813'  LIMIT 1];
        prod.Material_Type__c = 'ZREP';
        prod.Excluded_From_Pricing_Assistant__c = true;
        update prod;
        Quote_Line_Item__c qli = new Quote_Line_Item__c(bundle_Product__r = prod, Bundle_Product__c = prod.Id, BasePrice__c = 10,  Revenue_Type__c = 'Ad Hoc', Quote__c = quote.Id, Pathway__c = 'Manual', Pricing_Tool__c ='EMEA');
        insert qli;
        Boolean haveNonZREPProduct = false;
        Test.createSoqlStub(PC_Global_Setting_c__x.sObjectType, new PC_GLobal_Setting_Stub_Provider(1, 'EMEA Region All'));
        Test.startTest();
        Boolean havePaAssistant = CNT_CPQ_QuoteWorkflow.checkZrepProducts(quote.Id);
        Test.stopTest();
        System.assertEquals(true, havePaAssistant, 'Quote Do not have Pa Assistant');
    }

    @isTest
    static void testCheckTechSolutionProducts() {
        Quote_Line_Item__c qli = [SELECT Id, Quote__c FROM Quote_Line_Item__c LIMIT 1];
        qli.BasePrice__c = 0;
        update qli;

        Test.startTest();
            String res = CNT_CPQ_QuoteWorkflow.checkTechSolutionProducts(qli.Quote__c);
            Assert.areNotEqual('Success', res, 'result should not be success.');
        Test.stopTest();
    }
    @isTest
    static void testGetApproverDetailsMethod() {
     List<User> listOfUser = UTL_TestData.createUser('System Administrator', 2);
        INSERT listOfUser;
        String jsonInput = '{ "1": ["' + listOfUser[0].Id + '"], "2": ["' + listOfUser[1].Id + '"] }';
        List<CNT_CPQ_QuoteWorkflow.UserWrapper> result = CNT_CPQ_QuoteWorkflow.getPriorityUserDetails(jsonInput);
        System.assertEquals(2, result.size(), 'The result size should be 2.');
    }
    @isTest
    static void testIsLaunchFiles() {
        Account acc = [Select Id from Account LIMIT 1];
        Opportunity testOpportunity = [Select Id from Opportunity LIMIT 1];
        Quote__c quoteData = UTL_TestData.createIqviaQuote(acc.Id, testOpportunity.Id, null, CON_CPQ.Q2_Solutions, CON_CPQ.GBU_RDS, false);
        quoteData.Approval_Stage__c = CON_CPQ.DRAFT;
        quoteData.Tool_Launched_Already__c = false;
        insert quoteData;

        Boolean isLaunch = CNT_CPQ_QuoteWorkflow.isLaunchFiles(quoteData.Id);
        Assert.areEqual(true, isLaunch, 'isLaunchFiles did not return the expected result');
    }
    @isTest
    static void testAttachDocumentToFiles() {
        Document doc = new Document(
            Name = 'Test Document',
            Body = Blob.valueOf('Sample file content'),
            FolderId = UserInfo.getUserId()
        );
        insert doc;
        Account acc = [Select Id from Account LIMIT 1];
        Opportunity testOpportunity = [Select Id from Opportunity LIMIT 1];
        Quote__c quoteData = UTL_TestData.createIqviaQuote(acc.Id, testOpportunity.Id, null, CON_CPQ.Q2_Solutions, CON_CPQ.GBU_RDS, false);
        quoteData.Approval_Stage__c = CON_CPQ.DRAFT;
        quoteData.Tool_Launched_Already__c = false;
        insert quoteData;
        Id attachedDocumentId = CNT_CPQ_QuoteWorkflow.attachDocumentToFiles(doc.Name, quoteData.Id);
        Assert.areNotEqual(null, attachedDocumentId, 'Document attachment failed');
    }
    @isTest
    static void testAttachDocumentToFiles2() {
        Account acc = [Select Id from Account LIMIT 1];
        Opportunity testOpportunity = [Select Id from Opportunity LIMIT 1];
        Quote__c quoteData = UTL_TestData.createIqviaQuote(acc.Id, testOpportunity.Id, null, CON_CPQ.Q2_Solutions, CON_CPQ.GBU_RDS, false);
        quoteData.Approval_Stage__c = CON_CPQ.DRAFT;
        quoteData.Tool_Launched_Already__c = false;
        insert quoteData;
        try{
            Id attachedDocumentId = CNT_CPQ_QuoteWorkflow.attachDocumentToFiles('Test Doc', quoteData.Id);
        } catch (AuraHandledException e) {
            Assert.isNotNull(e.getMessage(), 'Result should be error');
        }
    }
}