@isTest
private class TST_CPQ_Utility {

    @isTest
    static void testGetIdFieldSetShouldReturnFieldSet() {

        Test.startTest();
        Set<String> fieldSet = CPQ_Utility.getIdFieldSet();
        Test.stopTest();

        System.assertNotEquals(0, fieldSet.size(), 'Should Return Non-empty field set');
    }

    @isTest
    static void testGetSingleMessage(){
        
        Account testAccount = new Account(Name = 'test', CustomerSegment__c = 'GOVERNMENT', Sub_Industry__c = 'STATE');
        insert testAccount;
        
        Test.startTest();
        	Messaging.SingleEmailMessage Mail = CPQ_Utility.getSingleMessage(CON_CPQ.CPQ_PROPOSAL_ANOTHER_USER_REQUEST_TO_UNLOCK_BUDGET, testAccount.Id, UserInfo.getUserId(), new List<String>{'test@test.com'});
        	Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();
        
        System.assertNotEquals(null, Mail, 'Return Mail');
    }
    
    @isTest
    static void testGetObjectList(){
        Test.setMock(HttpCalloutMock.class, new Mock());
        Test.startTest();
            Map<String, List<UTL_CPQ_GetObjectsRest.Objects>> objectMap = CPQ_Utility.getObjectList();
        Test.stopTest();
    }
    
    @isTest
    static void testGetObjectFields(){

        Test.startTest();
            List<UTL_CPQ_GetFieldsRest.FieldsList> fieldList = CPQ_Utility.getObjectFields(CON_CPQ.USER);
        Test.stopTest();
    }

    @isTest
    static void testGetTemplateData(){
        insert UTL_TestData.createTemplateData(CON_CPQ.TEST_USER);
        Test.startTest();
            List<UTL_GetTemplateDataRest.TemplateData> templateData = CPQ_Utility.getTemplateData(CON_CPQ.TEST_USER);
        Test.stopTest();
    } 
    
    @isTest
    static void testDeleteQuoteLineItems()
    {   
        Account acc = UTL_TestData.createAccount();
        insert acc;
        
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.Line_of_Business__c = CON_CPQ.SAMPLE_LINE_OF_BUSINESS;
        opp.CurrencyIsoCode = CON_CPQ.USD;
        insert opp;
        
        Bid_History__c testClinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);

        Apttus_Proposal__Proposal__c quote = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, testClinicalBid.Id);
					 
        Apttus_Proposal__Proposal_Line_Item__c quoteLineItem = UTL_TestData.createQuoteLineItem(quote.Id);
        quoteLineItem.IQVIA_Line_Type__c = CON_CPQ.CRM_Product;
        insert quoteLineItem;
		
        Test.startTest();
            CPQ_Utility.deleteQuoteLineItems(quote.Id);
        Test.stopTest();
        
        List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemList = [SELECT Id FROM Apttus_Proposal__Proposal_Line_Item__c Limit 1];
        System.assertEquals(proposalLineItemList.size() == 0, true, 'proposalLineItemList is not null');
    }
    
    private static final String FAKE_RESPONSE_JSON = '{"sobjects":[{"triggerable":true,"custom":false,"name":"CPQ_Agreement","label":"Change Event: CPQ Agreement"},{"triggerable":true,"custom":true,"name":"Agreement__c","label":"Change Event: Agreement"}]}';

    private class Mock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody(FAKE_RESPONSE_JSON);
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest
    static void testGetCurrencyConvertedValue() {

        Test.startTest();
            Double convertedValue = CPQ_Utility.getCurrencyConvertedValue(1,1,1);
        Test.stopTest();

        System.assertEquals(1, convertedValue, 'Should Return 1');
    }

    @isTest
    static void testCreateApexErrorLogRecord() {
        Account testAccount = UTL_TestData.createAccount();
        insert testAccount;
        String errorMessage = 'errorMessage';
        
        Test.startTest();
            Apex_Error_Log__c log =  CPQ_Utility.createApexErrorLogRecord(testAccount.Id, errorMessage, CON_CPQ.APTTUS_PROPOSAL_PROPOSAL);
        Test.stopTest();

        List<Apex_Error_Log__c> listOfLogs = [SELECT Id FROM Apex_Error_Log__c Limit 1];
        System.assertEquals(listOfLogs.size() > 0 ,true, 'Should Return true');
    }
    
    @isTest
    static void testCloneClinical()
    {   
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        Bid_History__c clinicalBid = setClinicalBidData(CON_CPQ.RECORD_TYPE_CLINICAL_BID, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
		
        Test.startTest();
           Apttus_Proposal__Proposal__c quote = CPQ_Utility.cloneClinical(clinicalBid.Id, clinicalBid.Budget_Tools__c);
        Test.stopTest();
        
        System.assertEquals(clinicalBid.Id, quote.Clinical_Bid__c);
    }
    
    @isTest
    static void testCloneBudget()
    {   
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        Bid_History__c clinicalBid = setClinicalBidData(CON_CPQ.RECORD_TYPE_CLINICAL_BID, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);       
        
        Apttus_Proposal__Proposal__c quote = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, clinicalBid.Id);
        quote.Apttus_Proposal__Proposal_Category__c = CON_CPQ.CNF;
        update quote;
        
        Attachment attach = UTL_TestData.createAttachment();   	
        attach.Name = 'Test Attachment';
        attach.body = Blob.valueOf('test budget.pdf');
        attach.parentId = quote.id;
        attach.contentType = CON_CPQ.ATTACHMENT_CONTENT_TYPE;
        insert attach;
		
        Test.startTest();
           Apttus_Proposal__Proposal__c budget = CPQ_Utility.cloneBudget(clinicalBid.Id, quote.Id, clinicalBid.Budget_Tools__c, CON_CPQ.OPPORTUNITY_BALLPARK, CON_CPQ.CNF, CON_CPQ.BALLPARK, quote.Apttus_Proposal__Proposal_Category__c);
        Test.stopTest();
        
        System.assertNotEquals(null, budget, 'Should return a new budget Id');
    }
    
    @isTest
    static void testMarkAsPrimary()
    {  
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        
        Bid_History__c clinicalBid = setClinicalBidData(CON_CPQ.RECORD_TYPE_CLINICAL_BID, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
 
        Apttus_Proposal__Proposal__c quote = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, clinicalBid.Id);
        
        Test.startTest();
        CPQ_Utility.markAsPrimary(true, testOpportunity.id, quote.Id);
        Test.stopTest();
        
        System.assertNotEquals(quote.Apttus_Proposal__Primary__c, false, 'Quote is marked primary');
    }
    
    
    @isTest
    static void testSyncBudgetWithOpportunity()
    {    
        Account acc = UTL_TestData.createAccount();
        acc.DPS_Status__c = CON_CPQ.DPS_STATUS_CLEARED;
        acc.MDM_Validation_Status__c = CON_CPQ.MDM_STATUS_VALIDATED;
        insert acc;
        
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.Line_of_Business__c = CON_CPQ.SAMPLE_LINE_OF_BUSINESS;
        opp.CurrencyIsoCode = CON_CPQ.USD;
        insert opp;
        
        CPQ_Settings__c cpqSetting = new CPQ_Settings__c();
        cpqSetting.Name = 'Test CPQ Setting';
        cpqSetting.No_of_Installment_for_Schedule_Creation__c = 1;
        insert cpqSetting;
        
        Bid_History__c testClinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
        
        Apttus_Proposal__Proposal__c quote = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, testClinicalBid.Id);
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(), IsActive = true);
        update standardPricebook;
        
        Product2 testProduct = UTL_TestData.createProduct();
        testProduct.Billing_System__c = 'SAP';
        insert testProduct;
        
        PricebookEntry testPricebookEntry = UTL_TestData.createPricebookEntry(testProduct.Id);
        testPricebookEntry.CurrencyIsoCode = CON_CPQ.USD;
        insert testPricebookEntry;
        
        List<Apttus_Proposal__Proposal_Line_Item__c> budgetLineItemList = new List<Apttus_Proposal__Proposal_Line_Item__c>();   
        Apttus_Proposal__Proposal_Line_Item__c budgetLineItem = UTL_TestData.createProposalLineItem(quote.Id, testProduct.Id);
        budgetLineItem.Sale_Type__c = CON_CPQ.SALE_TYPE_NEW;
        budgetLineItem.Revenue_Type__c = CON_CPQ.AD_HOC;
        budgetLineItem.IQVIA_Line_Type__c = CON_CPQ.CRM_Product;
        budgetLineItem.BidGrid_Country__c = 'Canada';
        budgetLineItemList.add(budgetLineItem);
             
        Apttus_Proposal__Proposal_Line_Item__c budgetLineItem2 = UTL_TestData.createProposalLineItem(quote.Id, testProduct.Id);
        budgetLineItem2.Sale_Type__c = CON_CPQ.SALE_TYPE_NEW;
        budgetLineItem2.Revenue_Type__c = CON_CPQ.AD_HOC;
        budgetLineItem2.IQVIA_Line_Type__c = CON_CPQ.CRM_Product;
        budgetLineItem2.BidGrid_Country__c = 'USA';
        budgetLineItemList.add(budgetLineItem2);
        
        insert budgetLineItemList;
		
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(opp.Id, testPricebookEntry.Id);
        oppLineItem.Delivery_Country__c = 'USA';
        oppLineItem.Description = 'Testing';
        oppLineItem.Agreement_Line_Item_Id__c = budgetLineItemList[1].Id;
        insert oppLineItem;
        
        OpportunityLineItemSchedule oliSchedule = UTL_Testdata.createOpportunityLineItemSchedule(oppLineItem.ID);
        insert oliSchedule;

        Test.startTest();
            CPQ_Utility.syncBudgetWithOpportunity(quote.Id);
        Test.stopTest();

        OpportunityLineItem testOppLineItem = [SELECT ID FROM OpportunityLineItem WHERE Agreement_Line_Item_Id__c =: budgetLineItem.Id Limit 1];
        System.assertNotEquals(testOppLineItem, null, 'Opportunity Line Item Exists');
        
    }
    
    @isTest
    static void testCreateTeamMembers() {
        Account acc = UTL_OWF_TestData.createAccount();
        insert acc;
        
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        
        Contact cont = UTL_OWF_TestData.createContact(acc.Id);
        cont.pse__Is_Resource__c = true;
        cont.pse__Is_Resource_Active__c = true;
        cont.pse__Group__c = grp.Id;
        cont.FirstName = UserInfo.getFirstName();
        cont.LastName = UserInfo.getLastName();
        cont.sub_group__c = 'TSL-Japan';
        cont.available_for_triage_flag__c = true;
        cont.pse__Salesforce_User__c = UserInfo.getUserId();
        insert cont;
        
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        
        Opportunity opp = UTL_OWF_TestData.createOpportunity(acc.Id);
        opp.QI_Invited_to_Present__c = 'Yes';
        opp.Bid_Defense_Date__c = Date.newInstance(2020, 05, 08);
        opp.Presentation_Country__c = 'Armenia';
        opp.Presentation_Date_Status__c = 'Estimated';
        insert opp;
        
        Bid_History__c clinicalBid =  UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, opp.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        clinicalBid.Bid_Number__c = 0;
        clinicalBid.Opportunity_Type__c = CON_CPQ.OPPORTUNITY_TYPE_BTS_BALLPARK;
        clinicalBid.Budget_Deliverable__c= CON_CPQ.ROUNDED_BALLPARK;
        insert clinicalBid;
        
        pse__Proj__c bidProject = [Select id from pse__Proj__c  where Bid_History__c =: clinicalBid.Id Limit 1];
        
        List<pse__Schedule__c> scheduleList=new List<pse__Schedule__c>();
        for(integer i=0;i<3;i++){
            scheduleList.add(UTL_OWF_TestData.createSchedule());
        }
        insert scheduleList;
        
        List<pse__Resource_Request__c> resourceRequestList=new List<pse__Resource_Request__c>();
        pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(clinicalBid.Id, opp.Id, bidProject.Id);
        resourceRequest.pse__Group__c = grp.Id;
        resourceRequestList.add(resourceRequest);
        
        pse__Resource_Request__c resourceRequest1 = UTL_OWF_TestData.createResourceRequestForBidHistory(clinicalBid.Id, opp.Id, bidProject.Id);
        resourceRequest1.pse__Group__c = grp.Id;
        resourceRequest1.Is_Created_Automatically__c = false;
        resourceRequestList.add(resourceRequest1);
        insert resourceRequestList;
        
        List<pse__Assignment__c> assignmentList = new List<pse__Assignment__c>();
        for(integer i=0;i<3;i++){
            assignmentList.add(new pse__Assignment__c(Name = 'Test OWF Assignment', Bid_History__c = clinicalBid.Id, pse__Project__c = bidProject.Id, pse__Schedule__c = scheduleList[i].Id,
                pse__Resource__c = cont.ID, pse__Resource_Request__c = resourceRequestList[math.mod(i, 2)].Id,  
                pse__Status__c = 'Accepted', pse__Bill_Rate__c = 0 ,Assignment_Type__c = 'Days Off',
                RecordTypeId = Schema.SObjectType.pse__Assignment__c.getRecordTypeInfosByName().get('OWF Assignment').getRecordTypeId()));
        }
        insert assignmentList;
		
        Test.startTest();   
            Apttus_Proposal__Proposal__c budget = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, opp.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, clinicalBid.Id);
            budget.Apttus_Proposal__Proposal_Category__c =CON_CPQ.INITIAL;
            update budget;
        
            List<Apttus_Proposal__Proposal__c> budgetList = new List<Apttus_Proposal__Proposal__c>{budget};
            CPQ_Utility.createProposalTeamMemberRecord(budgetList, null);
            List<Team_Member__c> proposalMemberList = [SELECT Id FROM Team_Member__c Limit 1];
        Test.stopTest();
        
        System.assertNotEquals(null, proposalMemberList.size(), 'Should return team member records');
    }
    
    @isTest
    static void testCheckChallengeMatrix() {   
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        Bid_History__c testClinicalBid = UTL_TestData.setClinicalBidData(CON_CPQ.AGREEMENT_RECORDTYPE_CLINICAL_BID, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT);
        testClinicalBid.Budget_Tools__c = CON_CPQ.UNIT_PRICING_TOOL;
        update testClinicalBid;
        
        Apttus_Proposal__Proposal__c quote = UTL_TestData.setProposalData(CON_CPQ.AGREEMENT_RECORDTYPE_BUDGET, testOpportunity.Id, CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT, testClinicalBid.Id);
        
        User newUser = UTL_TestData.createUser('System Administrator', 1)[0];
        newUser.Region__c = CON_CPQ.REGION_EMEA;
        insert newUser;
     	
        List<Challenge_Matrix__c> challengeMatrixList = new List<Challenge_Matrix__c>();
        Challenge_Matrix__c testMatrix = UTL_TestData.createChallengeMatrix(CON_CPQ.TOTAL_IQVIA_FEES_CDS_0TO3, CON_CPQ.OPPORTUNITY_TYPE_FSP, CON_CPQ.REVIEW_TYPE_CHALLENGE, CON_CPQ.EMAIL, CON_CPQ.YES, '' , '' );
        testMatrix.Migration_Id__c = 'CM-01';
        challengeMatrixList.add(testMatrix);
        Challenge_Matrix__c testMatrix1 = UTL_TestData.createChallengeMatrix(CON_CPQ.TOTAL_IQVIA_FEES_CDS_5, CON_CPQ.OPPORTUNITY_TYPE_FSP, CON_CPQ.REVIEW_TYPE_CHALLENGE, CON_CPQ.CALL, CON_CPQ.NO, CON_CPQ.WIN_PROBABILITY_0, CON_CPQ.POTENTIAL_REGION_EMEA);
        testMatrix1.Migration_Id__c = 'CM-02';
        challengeMatrixList.add(testMatrix1);
        Challenge_Matrix__c testMatrix2 = UTL_TestData.createChallengeMatrix(CON_CPQ.TOTAL_IQVIA_FEES_CDS_10, CON_CPQ.OPPORTUNITY_TYPE_BTS_BALLPARK, CON_CPQ.REVIEW_TYPE_CHALLENGE, CON_CPQ.CALL, CON_CPQ.NO, CON_CPQ.WIN_PROBABILITY_0, CON_CPQ.POTENTIAL_REGION_EMEA);
        testMatrix2.Migration_Id__c = 'CM-03';
        challengeMatrixList.add(testMatrix2);
        Challenge_Matrix__c testMatrix3 = UTL_TestData.createChallengeMatrix(CON_CPQ.TOTAL_IQVIA_FEES_CDS_3, CON_CPQ.OPPORTUNITY_TYPE_FSP, CON_CPQ.REVIEW_TYPE_CHALLENGE, CON_CPQ.CALL, CON_CPQ.NO, CON_CPQ.WIN_PROBABILITY_50, CON_CPQ.REGION_ASIA_PASIFIC);
        testMatrix3.Migration_Id__c = 'CM-04';
        challengeMatrixList.add(testMatrix3);
        Challenge_Matrix__c testMatrix4 = UTL_TestData.createChallengeMatrix(CON_CPQ.TOTAL_IQVIA_FEES_CDS_7, CON_CPQ.OPPORTUNITY_TYPE_BTS_BALLPARK, CON_CPQ.REVIEW_TYPE_CHALLENGE, CON_CPQ.CALL, CON_CPQ.NO, CON_CPQ.WIN_PROBABILITY_0, CON_CPQ.REGION_ASIA_PASIFIC);
        testMatrix4.Migration_Id__c = 'CM-05';
        challengeMatrixList.add(testMatrix4);
        Challenge_Matrix__c testMatrix5 = UTL_TestData.createChallengeMatrix(CON_CPQ.TOTAL_IQVIA_FEES_CDS_5, CON_CPQ.OPPORTUNITY_TYPE_FSP, CON_CPQ.REVIEW_TYPE_CHALLENGE, CON_CPQ.CALL, CON_CPQ.NO, CON_CPQ.WIN_PROBABILITY_1TO49, CON_CPQ.REGION_ASIA_PASIFIC);
        testMatrix5.Migration_Id__c = 'CM-06';
        challengeMatrixList.add(testMatrix5);
        insert challengeMatrixList;

        Test.startTest();
            String result = CPQ_Utility.getChallengeMatrixAction(UserInfo.getUserId(), 0, CON_CPQ.OPPORTUNITY_TYPE_FSP, CON_CPQ.FINAL_SIGN_OFF, CON_CPQ.YES_TITLE_CASE,0,'','' );
            result = CPQ_Utility.getChallengeMatrixAction(UserInfo.getUserId(), 6000000, CON_CPQ.OPPORTUNITY_TYPE_FSP, CON_CPQ.CHALLENGE_REVIEW, CON_CPQ.NO_TITLE_CASE, 0 , CON_CPQ.FRANCE, CON_CPQ.POTENTIAL_REGION_EMEA);
            result = CPQ_Utility.getChallengeMatrixAction(UserInfo.getUserId(), 11000000, CON_CPQ.OPPORTUNITY_TYPE_BTS_BALLPARK, CON_CPQ.CHALLENGE_REVIEW, CON_CPQ.NO_TITLE_CASE, 0 , CON_CPQ.FRANCE, CON_CPQ.POTENTIAL_REGION_EMEA);
            result = CPQ_Utility.getChallengeMatrixAction(UserInfo.getUserId(), 40000000, CON_CPQ.OPPORTUNITY_TYPE_FSP, CON_CPQ.CHALLENGE_REVIEW, CON_CPQ.NO_TITLE_CASE, 50, CON_CPQ.CHINA, CON_CPQ.POTENTIAL_REGION_AAJ);
            result = CPQ_Utility.getChallengeMatrixAction(UserInfo.getUserId(), 80000000, CON_CPQ.OPPORTUNITY_TYPE_BTS_BALLPARK, CON_CPQ.CHALLENGE_REVIEW, CON_CPQ.NO_TITLE_CASE, 0 , CON_CPQ.CHINA, CON_CPQ.POTENTIAL_REGION_AAJ);
            result = CPQ_Utility.getChallengeMatrixAction(UserInfo.getUserId(), 60000000, CON_CPQ.OPPORTUNITY_TYPE_FSP, CON_CPQ.CHALLENGE_REVIEW, CON_CPQ.NO_TITLE_CASE, 49 , CON_CPQ.CHINA, CON_CPQ.POTENTIAL_REGION_AAJ);
        Test.stopTest();														 
    }  
    
    @isTest
    static void testGetPDLocation(){
        User newUser = UTL_TestData.createUser('System Administrator', 1)[0];
        newUser.Region__c = CON_CPQ.REGION_EMEA;
        insert newUser;
        
        Test.startTest();
        	CPQ_Utility.getPDLocation(newUser.ID);
        Test.stopTest();
      
        System.assertEquals(CON_CPQ.REGION_EMEA, newUser.Region__c, 'Should return PD Owner Region');				 
    }
    
    static Bid_History__c setClinicalBidData(String recordTypeName, Id opportunityId, String pricingTool) {
        
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        
        Id recordTypeId =
            SObjectType.Bid_History__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
        Bid_History__c testClinicalBid = UTL_TestData.createClinicalBid();
        testClinicalBid.Bid_History_Related_Opportunity__c = opportunityId;
        testClinicalBid.RecordTypeId = recordTypeId;
        testClinicalBid.Opportunity_Type__c = CON_CPQ.OPPORTUNITY_TYPE_FSP;
        testClinicalBid.Unblinded_CVs_required__c = 'None';
        testClinicalBid.Is_PPT_Format_Required__c = 'No';
        insert testClinicalBid;
        return testClinicalBid;
    }
    
    static Opportunity setOpportunityData(Id accountId) {
        
        Opportunity testOpportunity = UTL_TestData.createOpportunity(accountId);
        testOpportunity.Line_of_Business__c = CON_CPQ.SAMPLE_LINE_OF_BUSINESS;
        testOpportunity.Legacy_Quintiles_Opportunity_Number__c = CON_CPQ.TEST_OPPORTUNITY_NUMBER;
        insert testOpportunity;
        return testOpportunity;
    }
    
    static Account setAccountData() {
        
        Account testAccount = UTL_TestData.createAccount();
        insert testAccount;
        return testAccount;
    }
    
    // Get Tech Solution Record type of Proposal
    @isTest
    static void testGetTechSolutionRecordType(){
        Test.startTest();
            System.assertNotEquals(null, CPQ_Utility.proposalTechSolutionRecordTypeId, 'Tech Solution Record type mis-match');
        Test.stopTest();
    }
	
    @isTest
    static void testSyncOpportunityProductsIntoProposalCartLineItems(){
        
        Account testAccount = setAccountData();
        Opportunity testOpportunity = setOpportunityData(testAccount.Id);
        String tsRecordTypeID = Schema.SObjectType.Apttus_Proposal__Proposal__c.getRecordTypeInfosByName().get('Tech Solution').getRecordTypeId();
        Apttus_Config2__PriceList__c priceList = UTL_TestData.createPriceList(CON_CPQ.TECH_SOLUTION_JAPAN);
		
        // Create Config System Properties record
        Apttus_Config2__ConfigSystemProperties__c configSystemProperties = new Apttus_Config2__ConfigSystemProperties__c();
        configSystemProperties.Name = 'System Properties';
        configSystemProperties.Apttus_Config2__PricingBatchSize__c = 100;
        insert configSystemProperties;
        
        // Create Products
        Integer productCount = 5;
        List<Product2> products = new List<Product2>();
        for(Integer i=0; i<productCount; i++){
            Product2 product = UTL_TestData.createProduct();
            product.Name = 'Product ' + i;
            products.add(product);
        }
        insert products;
        
        // Create Price Book Entries
        List<PriceBookEntry> priceBookEntries = new List<PriceBookEntry>();
        for(Integer i=0; i<productCount; i++){
            priceBookEntries.add(UTL_TestData.createPricebookEntry(products[i].Id));
        }
        insert priceBookEntries;
        
        // Create Opportunity Line Items
        List<OpportunityLineItem> oppLineItems = new List<OpportunityLineItem>();
        for(Integer i=0; i<productCount; i++){
            oppLineItems.add(UTL_TestData.createOpportunityLineItem(testOpportunity.Id, priceBookEntries[i].Id));
        }
        insert oppLineItems;
        
        // Create Price List Entries of Opportunity Products. This step is required to create Cart Line Items
        List<Apttus_Config2__PriceListItem__c> priceListItems = new List<Apttus_Config2__PriceListItem__c>();
        for(Integer i=0; i<productCount; i++){
            priceListItems.add(UTL_TestData.createPriceListItem(products[i].id, priceList.Id, 'PLI-91' + i));
        }
        insert priceListItems;
        
       
        Apttus_Proposal__Proposal__c proposal = UTL_TestData.setTSProposalData(false, CON_CPQ.TECH_SOLUTION, testOpportunity.Id, CON_CPQ.TS_JAPAN);
        proposal.Apttus_QPConfig__PriceListId__c = priceList.Id;
        insert proposal;
        
        Test.startTest();
            CPQ_Utility.syncOpportunityProductsIntoCartLineItems(JSON.serialize(proposal));
        Test.stopTest();
        
        // Verify configuration records get created
        List<Apttus_Config2__ProductConfiguration__c> productConfigurations = [Select Id, Apttus_Config2__Status__c From Apttus_Config2__ProductConfiguration__c Where Apttus_QPConfig__Proposald__c =: proposal.Id];
        System.debug(productConfigurations);
        System.assertEquals(1, productConfigurations.size(), 'Product Configuration size mis-match');
        System.assertEquals('Saved', productConfigurations[0].Apttus_Config2__Status__c, 'Product Configuration status mis-match');
        
        // Verify Cart Line Items
        List<Apttus_Config2__LineItem__c> cartLineItems = [Select Apttus_Config2__ProductId__c,
                                                           Apttus_Config2__PriceListId__c,
                                                           Apttus_Config2__PriceListItemId__c,
                                                           Apttus_Config2__NetPrice__c
                                                           From Apttus_Config2__LineItem__c
                                                           Where Apttus_Config2__ConfigurationId__c =:productConfigurations[0].Id];
        System.assertEquals(5, cartLineItems.size(), 'Cart Line Item size mis-match');
        
        // Verify attributes of Cart Line Items
        for(Integer i=0; i<productCount; i++){
            System.assertEquals(products[i].Id, cartLineItems[i].Apttus_Config2__ProductId__c, 'Product Id mis-match');
            System.assertEquals(priceList.Id, cartLineItems[i].Apttus_Config2__PriceListId__c, 'Price List Id mis-match');
            System.assertEquals(priceListItems[i].Id, cartLineItems[i].Apttus_Config2__PriceListItemId__c, 'Price List Item Id mis-match');
            System.assertEquals(100.00, cartLineItems[i].Apttus_Config2__NetPrice__c, 'Net Price mis-match');
        }
    }
	
    @isTest
    static void testSyncBudgetWithOpportunityDynamically()
    {    
        Account acc = UTL_TestData.createAccount();
        insert acc;
        
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        opp.Line_of_Business__c = CON_CPQ.SAMPLE_LINE_OF_BUSINESS;
        opp.CurrencyIsoCode = CON_CPQ.USD;
        insert opp;
                
        Apttus_Proposal__Proposal__c quote = UTL_TestData.setTSProposalData(false, CON_CPQ.TECH_SOLUTION, opp.Id, CON_CPQ.OCE);
        quote.CurrencyIsoCode = CON_CPQ.USD;
        insert quote;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(), IsActive = true);
        update standardPricebook;

        Currency_Exchange_Rates__c currencyRate = UTL_TestData.getCurrencyExchangeRate(false);
        currencyRate.Conversion_rate__c = 1;
        currencyRate.Iso_Code__c = 'USD';
        insert currencyRate;

        
        List<Product2> prodList = new List<Product2>();
        Product2 prod1 = TST_TestGeneratorClass.buildTestProduct('OCE SALES SUBS CORPORATE SEAT', 'Option', 'OCEP_SUB_CS', '', '');
        prod1.CanUseRevenueSchedule = true;
        prod1.isActive = true;
        prod1.Billing_System__c = CON_CPQ.SAP;
        prodList.add(prod1);
        Product2 prod2 = TST_TestGeneratorClass.buildTestProduct('OCE SALES SUBS ADMIN SEAT', 'Option', 'OCEP_SUB_AS', '', '');
        prod2.CanUseRevenueSchedule = true;
        prod2.isActive = true;
        prod2.Billing_System__c = CON_CPQ.SAP;
        prodList.add(prod2);
        Product2 prod3 = TST_TestGeneratorClass.buildTestProduct('OCE_Sales_Implementation', 'Bundle', 'CES_1448A', '', '');
        prod3.CanUseRevenueSchedule = true;
        prod3.isActive = true;
        prod3.Billing_System__c = CON_CPQ.SAP;
        prodList.add(prod3);
        insert prodList;
        List<PricebookEntry> priceBookEntryList = new List<PricebookEntry>();
        for(Product2 p : prodList){
            PricebookEntry testPricebookEntry = UTL_TestData.createPricebookEntry(p.Id);
        	testPricebookEntry.CurrencyIsoCode = CON_CPQ.USD;
            priceBookEntryList.add(testPricebookEntry);
        }
        insert priceBookEntryList;
        
        List<Apttus_Proposal__Proposal_Line_Item__c> proposalLineItemList = new List<Apttus_Proposal__Proposal_Line_Item__c>();
        proposalLineItemList.add(new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = quote.Id, Apttus_QPConfig__NetPrice__c = 2000, Apttus_Proposal__Product__c= prodList[0].Id, Apttus_Proposal__Quantity__c = 1));
        proposalLineItemList.add(new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = quote.Id, Apttus_QPConfig__NetPrice__c = 3000, Apttus_Proposal__Product__c= prodList[1].Id, Apttus_Proposal__Quantity__c = 1));
        proposalLineItemList.add(new Apttus_Proposal__Proposal_Line_Item__c(Apttus_Proposal__Proposal__c = quote.Id, Apttus_QPConfig__NetPrice__c = 5000, Apttus_Proposal__Product__c= prodList[2].Id, Apttus_Proposal__Quantity__c = 1));
		insert proposalLineItemList;
        
        List<Apttus_QPConfig__ProposalProductAttributeValue__c> attributeList = new List<Apttus_QPConfig__ProposalProductAttributeValue__c>();
        attributeList.add(new Apttus_QPConfig__ProposalProductAttributeValue__c(O_Country__c = 'India', Apttus_QPConfig__LineItemId__c = proposalLineItemList[0].Id));
        attributeList.add(new Apttus_QPConfig__ProposalProductAttributeValue__c(O_Country__c = 'India', Apttus_QPConfig__LineItemId__c = proposalLineItemList[1].Id));
        attributeList.add(new Apttus_QPConfig__ProposalProductAttributeValue__c(O_Country__c = 'India', Apttus_QPConfig__LineItemId__c = proposalLineItemList[2].Id));
        insert attributeList;
        
        proposalLineItemList[0].Apttus_QPConfig__AttributeValueId__c = attributeList[0].Id;
        proposalLineItemList[1].Apttus_QPConfig__AttributeValueId__c = attributeList[1].Id;
        proposalLineItemList[2].Apttus_QPConfig__AttributeValueId__c = attributeList[2].Id;
        update proposalLineItemList;
        
        List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
        OpportunityLineItem oppLineItem1 = UTL_TestData.createOpportunityLineItem(opp.Id, priceBookEntryList[1].Id);
        oppLineItem1.Delivery_Country__c = 'India';
        oppLineItem1.Description = 'Testing';
        oppLineItem1.Revenue_Start_Date__c = opp.CloseDate;
        oppLineItem1.Revenue_End_Date__c = opp.CloseDate.addMonths(11);
        oppLineItem1.Agreement_Line_Item_Id__c = proposalLineItemList[2].Id;
        oppLineItemList.add(oppLineItem1);
        OpportunityLineItem oppLineItem2 = UTL_TestData.createOpportunityLineItem(opp.Id, priceBookEntryList[2].Id);
        oppLineItem2.Delivery_Country__c = 'India';
        oppLineItem2.Description = 'Testing';
        oppLineItem2.Revenue_Start_Date__c = opp.CloseDate;
        oppLineItem2.Revenue_End_Date__c = opp.CloseDate.addMonths(11);
        oppLineItem2.Agreement_Line_Item_Id__c = proposalLineItemList[1].Id;
        oppLineItemList.add(oppLineItem2);
        insert oppLineItemList;
        
        oppLineItem1.TotalPrice = 200;
        update oppLineItem1;
        OpportunityLineItemSchedule oliSchedule = UTL_Testdata.createOpportunityLineItemSchedule(oppLineItem2.ID);
        insert oliSchedule;

        Test.startTest();
            CPQ_Utility.syncBudgetWithOpportunityDynamically(quote.Id, quote.Select_Pricing_Tool__c);
        Test.stopTest();

        OpportunityLineItem testOppLineItem = [SELECT ID FROM OpportunityLineItem WHERE Agreement_Line_Item_Id__c =: proposalLineItemList[2].Id Limit 1];
        System.assertNotEquals(testOppLineItem, null, 'Opportunity Line Item Exists');
        
    }
    
    @isTest
    static void testInitialSyncBudgetWithOpportunity()
    {    
        Account acc = UTL_TestData.createAccount();
        insert acc;
        
        Opportunity opp = UTL_TestData.createOpportunity(acc.Id);
        
        opp.Line_of_Business__c = CON_CPQ.SAMPLE_LINE_OF_BUSINESS;
        opp.CurrencyIsoCode = CON_CPQ.USD;
        insert opp;
        
        Currency_Exchange_Rates__c currencyRate = UTL_TestData.getCurrencyExchangeRate(false);
        currencyRate.Conversion_rate__c = 1;
        currencyRate.Iso_Code__c = 'USD';
        insert currencyRate;

        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(), IsActive = true);
        update standardPricebook;
        
        List<Product2> prodList = new List<Product2>();
        Product2 prod = TST_TestGeneratorClass.buildTestProduct('OCE SALES SUBS CORPORATE SEAT', 'Option', 'OCEP_SUB_CS', '', '');       
        prod.CanUseRevenueSchedule = true;
        prod.Billing_System__c = CON_CPQ.SAP;
        prodList.add(prod);
        Product2 prod1 = TST_TestGeneratorClass.buildTestProduct('OCE SALES SUBS ADMIN SEAT', 'Option', 'OCEP_SUB_AS', '', '');
        prod1.CanUseRevenueSchedule = true;
        prod1.Billing_System__c = CON_CPQ.SAP;
        prodList.add(prod1);
        Product2 prod2 = TST_TestGeneratorClass.buildTestProduct('OCE_Sales_Implementation', 'Bundle', 'CES_1448A', '', '');
        prod2.CanUseRevenueSchedule = true;
        prod2.Billing_System__c = CON_CPQ.SAP;
        prodList.add(prod2);
        insert prodList;
        Apttus_Proposal__Proposal__c proposal = UTL_TestData.setTSProposalData(false, CON_CPQ.TECH_SOLUTION, opp.Id, CON_CPQ.OCE);
        proposal.CurrencyIsoCode = CON_CPQ.USD;
        insert proposal;
        Id cartId = buildTestConfiguration(proposal.Id).Id;
        
        List<PricebookEntry> priceBookEntryList = new List<PricebookEntry>();
        for(Product2 p : prodList){
            PricebookEntry testPricebookEntry = UTL_TestData.createPricebookEntry(p.Id);
        	testPricebookEntry.CurrencyIsoCode = CON_CPQ.USD;
            priceBookEntryList.add(testPricebookEntry);
        }
        insert priceBookEntryList;
        
        List<Apttus_Config2__LineItem__c> lineItemList = new List<Apttus_Config2__LineItem__c>();
        Apttus_Config2__LineItem__c lineItem = TST_TestGeneratorClass.createOptionConfigLineItem(cartId, 1, 1, prod2.id, prod1.Id, 1, 100);
        lineItemList.add(lineItem);
        Apttus_Config2__LineItem__c lineItem1 = TST_TestGeneratorClass.createOptionConfigLineItem(cartId, 1, 1, prod2.Id, prod.Id, 1, 200);
        lineItemList.add(lineItem1);
        insert lineItemList;
        
        List<Apttus_Config2__ProductAttributeValue__c> attributeList = new List<Apttus_Config2__ProductAttributeValue__c>();
        attributeList.add(new Apttus_Config2__ProductAttributeValue__c(O_Country__c = 'India', Apttus_Config2__LineItemId__c = lineItemList[0].Id));
        attributeList.add(new Apttus_Config2__ProductAttributeValue__c(O_Country__c = 'India', Apttus_Config2__LineItemId__c = lineItemList[1].Id));
        insert attributeList;
        
        lineItemList[0].Apttus_Config2__AttributeValueId__c = attributeList[0].Id;
        lineItemList[1].Apttus_Config2__AttributeValueId__c = attributeList[1].Id;
        update lineItemList;
        
        List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
        OpportunityLineItem oppLineItem1 = UTL_TestData.createOpportunityLineItem(opp.Id, priceBookEntryList[0].Id);
        oppLineItem1.Delivery_Country__c = 'India';
        oppLineItem1.Description = 'Testing';
        oppLineItem1.Agreement_Line_Item_Id__c = lineItemList[1].Id;
        oppLineItem1.Revenue_Start_Date__c = Date.today();
        oppLineItem1.Revenue_End_Date__c = Date.today().addYears(1);
        oppLineItemList.add(oppLineItem1);
        OpportunityLineItem oppLineItem2 = UTL_TestData.createOpportunityLineItem(opp.Id, priceBookEntryList[1].Id);
        oppLineItem2.Delivery_Country__c = 'India';
        oppLineItem2.Description = 'Testing';
        oppLineItem2.Revenue_Start_Date__c = Date.today();
        oppLineItem2.Revenue_End_Date__c = Date.today().addYears(1);
        oppLineItem2.Agreement_Line_Item_Id__c = lineItemList[0].Id;
        oppLineItemList.add(oppLineItem2);
        insert oppLineItemList;
        
        OpportunityLineItemSchedule oliSchedule = UTL_Testdata.createOpportunityLineItemSchedule(oppLineItem2.ID);
        insert oliSchedule;

        Test.startTest();
            CPQ_Utility.initialSyncBudgetWithOpportunity(proposal.Id, proposal.Select_Pricing_Tool__c);
        Test.stopTest();

        OpportunityLineItem testOppLineItem = [SELECT ID FROM OpportunityLineItem WHERE Agreement_Line_Item_Id__c =: lineItemList[1].Id Limit 1];
        System.assertNotEquals(testOppLineItem, null, 'Opportunity Line Item Exists');
        
    }
    private static Apttus_Config2__ProductConfiguration__c buildTestConfiguration(id proposal) {
        Apttus_Config2__ProductConfiguration__c pc = new Apttus_Config2__ProductConfiguration__c();
        pc.Apttus_QPConfig__Proposald__c = proposal;
        insert pc;
        return pc;
    }

    @isTest
    static void testGetDependentValuesByControllingValue() {
        Test.startTest();
            Map<String, List<String>> result = CPQ_Utility.getDependentValuesByControllingValue(CON_CPQ.APTTUS_PROPOSAL_PROPOSAL, CON_CPQ.RFP_SCENARIO);
        Test.stopTest();

        Assert.areEqual(true, result.keySet().size() > 0, 'result should not be null or empty');
    }

    @isTest
    static void testgetQuoteType() {
        Account acc = UTL_TestData.createAccount();
        acc.AccountCountry__c = 'AL';
        insert acc;

        Opportunity testOpportunity= UTL_TestData.createOpportunity(acc.id);
        testOpportunity.Line_of_Business__c = 'Clinical';
        testOpportunity.Is_this_IQVIA_Biotech__c = CON_CPQ.YES_TITLE_CASE;
        testOpportunity.CurrencyIsoCode = CON_CPQ.USD;
        testOpportunity.Legacy_Quintiles_Opportunity_Number__c = 'MVP123';
        testOpportunity.Potential_Regions__c = CON_CPQ.REGION_ASIA_PASIFIC;
        testOpportunity.Number_of_Potential_Regions__c = 0;
        insert testOpportunity;

        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        OWF_Config__c owfConfig = UTL_OWF_TestData.createOWFConfig(grp.Id);
        insert owfConfig;
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;

        Bid_History__c bidHistory = UTL_OWF_TestData.createBidHistoryByRecordType(acc.Id, testOpportunity.Id, CON_OWF.OWF_CLINICAL_BID_BID_HISTORY_RECORD_TYPE_ID);
        bidHistory.Bid_Number__c = 0;
        bidHistory.Total_Bid_Value_Labor_Direct_Discount__c = 1000;
        bidHistory.Bid_Sent_Date__c = Date.Today().addDays(-1);
        bidHistory.Bid_Sent__c = 'Yes';
        bidHistory.Number_of_Scenarios__c = 2;
        bidHistory.Final_Number_of_Scenarios__c  = 2;
        bidHistory.Additional_Explanation__c = 'test';
        bidHistory.Pricing_Under_MSA__c = 'Yes';
        bidHistory.Link_to_Budget_Files__c = 'test';
        bidHistory.Bid_Type__c = CON_CPQ.INITIAL;
        bidHistory.Budget_Tools__c = CON_CPQ.UNIT_PRICING_TOOL;
        insert bidHistory;

        Quote__c quote = new Quote__c();
        quote.Pricing_Tools__c = CON_CPQ.Complete_Consent;
        quote.Scenario__c = 2;
        quote.Related_Bid__c = bidHistory.Id;
        quote.Related_Opportunity__c = testOpportunity.Id;
        quote.Related_Account__c = acc.Id;
        quote.GBU__c = CON_CPQ.GBU_DPS;
        insert quote;
        
        Test.startTest();
            String result = CPQ_Utility.getQuoteType(bidHistory.Id, CON_CPQ.Complete_Consent);
        Test.stopTest();
		
        System.assertEquals(result, CON_CPQ.INITIAL, 'Quote type value is Initial');
    }
    @isTest
    static void test_getObjectApiNameFromLookupField() {
        Test.startTest();
            Template_Data__c tempData = UTL_TestData.createTemplateData('1.24.10');
            tempData.Name = '1.24.10';
            tempData.DML_Type__c = 'Read';
            tempData.Field_Name__c = 'Apttus_Proposal__Opportunity__r.Protocol_Number__c';
            tempData.Object_Name__c = 'Apttus_Proposal__Proposal__c';
            tempData.Package_Name__c = 'Apttus';
            tempData.Pricing_Tool__c	= 'UPT Quote';
            tempData.Status__c = 'Active';
            insert tempData ;
            List<UTL_GetTemplateDataRest.TemplateData> templateData = CPQ_Utility.getTemplateData(tempData.Name);
        Test.stopTest();
            
    }

    @isTest
    static void testGetFields() {
        Test.startTest();
            Map<String, Schema.SObjectField> result = CPQ_Utility.getFields('Account');
            Map<String, Schema.SObjectField> invalidFields = CPQ_Utility.getFields('NonExistentObject');
        Test.stopTest();
        System.assertNotEquals(null, result, 'Expected reslut should not be null');
        System.assertEquals(true, result.containsKey('Name'), 'Expected Account fields to contain Name');
        System.assertEquals(true, result.containsKey('Id'), 'Expected Account fields to contain Id');
        System.assertEquals(null, invalidFields, 'Expected null result for non-existent object');
    }

    @isTest
    static void testParseFieldValue() {
        Test.startTest();
            Object dateValue = CPQ_Utility.parseFieldValue('Date', '2023-01-01');
            Object booleanValue = CPQ_Utility.parseFieldValue('Boolean', 'true');
            Object integerValue = CPQ_Utility.parseFieldValue('Integer', '42');
            Object decimalValue = CPQ_Utility.parseFieldValue('Decimal', '99.99');
            Object stringValue = CPQ_Utility.parseFieldValue('String', 'Hello');
        Test.stopTest();
        System.assertEquals(Date.newInstance(2023, 1, 1), dateValue, 'Expected Date value to be 2023-01-01');
        System.assertEquals(true, booleanValue, 'Expected Boolean value to be true');
        System.assertEquals(42, integerValue, 'Expected Integer value to be 42');
        System.assertEquals(Decimal.valueOf('99.99'), decimalValue, 'Expected Decimal value to be 99.99');
        System.assertEquals('Hello', stringValue, 'Expected String value to be "Hello"');
    }
}