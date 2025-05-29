/*
* Description   : Apex Test class for UTL_CLM_Flow_ActionHandler 
*/ 
@isTest
public class TST_UTL_CLM_Flow_ActionHandler {

    @testSetup
    static void dataSetUp() {
        Account testAccount = new Account(Name = 'Avacare',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert testAccount;
        
        Account acc = new Account(Name = 'PI-Account', Type2__c = 'Clinical Site', ParentId = testAccount.Id, CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert acc;
        
        Opportunity testOpportunity= UTL_TestData.createOpportunity(testAccount.id);
        testOpportunity.Line_of_Business__c = 'Clinical';
        testOpportunity.Is_this_IQVIA_Biotech__c = 'Yes';
        testOpportunity.CurrencyIsoCode = 'USD';
        testOpportunity.Legacy_Quintiles_Opportunity_Number__c = 'MVP123';
        insert testOpportunity;
        
        Product2 product = UTL_TestData.createProduct();
        product.Hierarchy_Level__c = CON_CRM.MATERIAL_LEVEL_HIERARCHY_OLI;
        product.ProductCode='1';
        product.Global_Product_Code__c = 'GP8MAS';
        insert product;
        
        PricebookEntry pbEntry = UTL_TestData.createPricebookEntry(product.Id);
        insert pbEntry;
        
        OpportunityLineItem oppLineItem = UTL_TestData.createOpportunityLineItem(testOpportunity.Id, pbEntry.Id);
        oppLineItem.Description = 'Testing';
        oppLineItem.Update_Type__c = CON_CRM.UPDATE_TYPE_MULESOFT_SLAVE;
        oppLineItem.LI_OpportunityLineItem_Id__c = testOpportunity.id;
        insert oppLineItem;

        Contact testContact1 = UTL_TestData.createContact(testAccount.Id);
        testContact1.EmailBouncedDate = System.today();
        testContact1.EmailBouncedReason = 'Invalid Email';
        testContact1.Email = 'xyz@gmail.com';    
        testContact1.RecordTypeId = CON_CLM.IQVIA_USER_CONTACT_RECORDTYPEID;
        testContact1.EmployeeNumber__c = '1';
        insert testContact1; 

        Finance_IQVIA_Legal_Entity__c testLegalEntity = new Finance_IQVIA_Legal_Entity__c(Name = 'Test Legal Entity 1', RecordTypeId = CON_CLM.FINANCE_LEGAL_ENTITY_ORACLE_RECORDTYPEID,
        Effective_Status__c = 'Active');
        
        List<Apttus__APTS_Agreement__c> lstAgreement = new List<Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c testAgreementRWLP = TST_CLM_TestDataFactory.createAgreement(CON_CLM.RWLP_RECORDTYPEID, false);
        testAgreementRWLP.Name = 'Test RWLP Agreement';
        testAgreementRWLP.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_WO;
        testAgreementRWLP.Apttus__Activated_Date__c = System.today();
        testAgreementRWLP.Apttus__Contract_Start_Date__c = System.today();
        testAgreementRWLP.Apttus__Contract_End_Date__c = System.today();
        testAgreementRWLP.Client_Address__c  = 'xyz';
        testAgreementRWLP.Legal_Entity_Customer__c  = 'test';
        testAgreementRWLP.Legal_Entity_1__c  = testLegalEntity.Id;
        testAgreementRWLP.Services__c = 'RBU IMC';
        lstAgreement.add(testAgreementRWLP);
        
        Apttus__APTS_Agreement__c testAgreementRWSSOW = TST_CLM_TestDataFactory.createAgreement(CON_CLM.RWS_RECORDTYPEID, false);
        testAgreementRWSSOW.Name = 'Test RWSSOW Agreement';
        testAgreementRWSSOW.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_WO;
        testAgreementRWSSOW.Apttus__Activated_Date__c = System.today();
        testAgreementRWSSOW.Apttus__Contract_Start_Date__c = System.today();
        testAgreementRWSSOW.Apttus__Contract_End_Date__c = System.today();
        testAgreementRWSSOW.Apttus__Agreement_Category__c = CON_CLM.FULL_SERVICE;
        testAgreementRWSSOW.First_Patient_In_Date__c = System.today();
        testAgreementRWSSOW.Last_Patient_Out_Date__c = System.today();
        lstAgreement.add(testAgreementRWSSOW);
        insert lstAgreement;
        
        Agreement_Contacts__c agreementContact1 = TST_CLM_TestDataFactory.createAgreementContacts(testAgreementRWLP.Id, false);
        agreementContact1.Role__c = 'Project Manager';
        agreementContact1.Contact__c = testContact1.Id;
        agreementContact1.Type__c = 'IQVIA User Contact';
        insert agreementContact1;
                
        IQVIA_Agreement__c iqagreement = TST_CLM_TestDataFactory.createIQAgreement(CON_CLM.USBU_IQVIA_RECORDTYPEID, false);
        iqagreement.Name = 'Test USBU';
        iqagreement.Status_Category__c = 'Request';
        iqagreement.Status__c = 'Request';
        iqagreement.Subtype__c = 'SOW';
        insert iqagreement;
        
        Apttus_Proposal__Proposal__c proposal = TST_CLM_TestDataFactory.createProposalQuote(false);
        proposal.Apttus_QPComply__MasterAgreementId__c = lstAgreement[0].Id;
        proposal.Apttus_Proposal__Proposal_Name__c = 'TestPr';
        proposal.Scenario_Description__c = 'Ready to Accept Budget';
        proposal.RecordTypeId = CON_CLM.QUOTE_RDS_BUDGET_RECORDTYPE;
        proposal.Apttus_Proposal__Opportunity__c = testOpportunity.Id;
        proposal.Apttus_Proposal__Primary__c = true;
        proposal.Apttus_Proposal__Proposal_Category__c = CON_CLM.PROPOSAL_INITIAL;
        proposal.Scenario_Number__c = 123.0;
        proposal.Budget_Iteration__c = 1;
        proposal.Select_Pricing_Tool__c = 'CPQ_UPT';
        proposal.Apttus_QPConfig__ConfigurationFinalizedDate__c = Date.today();
        insert proposal;
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test';      
        cv.PathOnClient = 'abc.jpg';
        cv.VersionData = Blob.valueOf('Test Content'); 
        insert cv;             
    }
    
    @isTest
    private static void testAmendRWLP(){
        Apttus__APTS_Agreement__c agreementRWLP = [SELECT Id, Name FROM Apttus__APTS_Agreement__c WHERE Name = 'Test RWLP Agreement'];
        UTL_CLM_Flow_ActionHandler.FlowInputs flowInputs = new UTL_CLM_Flow_ActionHandler.FlowInputs();
        flowInputs.agreementId = agreementRWLP.Id;
        flowInputs.action = CON_CLM.AMEND_BY_FLOW;
        flowInputs.recordTypeDeveloperName = CON_CLM.RWLP_RECORD_TYPE_NAME;

        Test.startTest();
            List<UTL_CLM_Flow_ActionHandler.FlowOutputs> flowOutputs = UTL_CLM_Flow_ActionHandler.apexFlowAction(
                new List<UTL_CLM_Flow_ActionHandler.FlowInputs>{flowInputs});
        Test.stopTest();

        System.assertNotEquals(null, flowOutputs[0].flowOutputRecordId, 'Amended Agreement Id should not be null');
    }
    
    @isTest
    private static void testGetContactRoleInList(){
        UTL_CLM_Flow_ActionHandler.FlowInputs flowInputs = new UTL_CLM_Flow_ActionHandler.FlowInputs();
        flowInputs.inputString = 'CSS-CD Contract Analyst;Additional Project Manager;Project Manager';
        flowInputs.action = CON_CLM.GET_CONTACT_ROLE_IN_LIST_ACTION;
        
        Test.startTest();
            List<UTL_CLM_Flow_ActionHandler.FlowOutputs> flowOutput = UTL_CLM_Flow_ActionHandler.apexFlowAction(
                new List<UTL_CLM_Flow_ActionHandler.FlowInputs>{flowInputs});
        Test.stopTest();

        System.assertEquals(3, flowOutput[0].flowOutput.size(), 'Role List should Returned');
    }

    @isTest
    private static void testGetPicklistValues(){
        UTL_CLM_Flow_ActionHandler.FlowInputs flowInputs = new UTL_CLM_Flow_ActionHandler.FlowInputs();
        flowInputs.action = CON_CLM.GET_PICKLIST_VALUES_IN_LIST;
        flowInputs.agreementId = 'Quote';
        flowInputs.inputString = 'Pricing_Tool__c';

        Test.startTest();
            List<UTL_CLM_Flow_ActionHandler.FlowOutputs> flowOutput = UTL_CLM_Flow_ActionHandler.apexFlowAction(
                new List<UTL_CLM_Flow_ActionHandler.FlowInputs>{flowInputs});
        Test.stopTest();

        System.assertNotEquals(0, flowOutput.size(), 'No Picklist Values Found');
    }
    
    @isTest
    private static void testAmendRWSSOW(){
        Apttus__APTS_Agreement__c agreementRWSSOW = [SELECT Id, Name FROM Apttus__APTS_Agreement__c WHERE Name = 'Test RWSSOW Agreement'];
        Apttus__APTS_Agreement__c clinicalAgr = [SELECT Id, Name, Planned_Execution_Date__c, Legal_Entity_Customer__c, Legal_Entity_1__c, Client_Address__c FROM Apttus__APTS_Agreement__c WHERE Name = 'Test RWLP Agreement']; 
        Opportunity selectedOpp = [SELECT Id, AccountId, CurrencyIsoCode, Global_project_unit__c FROM Opportunity LIMIT 1];
        UTL_CLM_Flow_ActionHandler.FlowInputs flowInputs = new UTL_CLM_Flow_ActionHandler.FlowInputs();
        flowInputs.agreementId = agreementRWSSOW.Id;
        flowInputs.action = CON_CLM.AMEND_BY_FLOW;
        flowInputs.recordTypeDeveloperName = CON_CLM.RWSSOW_RECORD_TYPE_NAME;
        flowInputs.agreement = clinicalAgr;
        flowInputs.opportunity = selectedOpp;

        Test.startTest();
            List<UTL_CLM_Flow_ActionHandler.FlowOutputs> flowOutputs = UTL_CLM_Flow_ActionHandler.apexFlowAction(
                new List<UTL_CLM_Flow_ActionHandler.FlowInputs>{flowInputs});
        Test.stopTest();

        System.assertNotEquals(null, flowOutputs[0].flowOutputRecordId, 'Amended Agreement Id should not be null');
    }

    @isTest
    private static void testSendEmailByFlow() {
        Apttus__APTS_Agreement__c agreementRWLP = [SELECT Id, Name FROM Apttus__APTS_Agreement__c WHERE Name = 'Test RWLP Agreement'];
        UTL_CLM_Flow_ActionHandler.FlowInputs flowInputs = new UTL_CLM_Flow_ActionHandler.FlowInputs();
        flowInputs.action = CON_CLM.SEND_EMAIL_BY_FLOW;
        flowInputs.agreementId = agreementRWLP.Id;
        flowInputs.inputString = 'AGR_ET28_Email_For_PSA_In_Signature';
        flowInputs.toAddress = new List<String>{'test@gmail.com'};
        
        Test.startTest();
            List<UTL_CLM_Flow_ActionHandler.FlowOutputs> flowOutputs = UTL_CLM_Flow_ActionHandler.apexFlowAction(
                new List<UTL_CLM_Flow_ActionHandler.FlowInputs>{flowInputs});
        Test.stopTest();
        
        System.assertEquals('Success', flowOutputs[0].flowOutputRecordId, 'Should Return Success');
    }
    
    @isTest
    private static void testAmendPSAAgreement() {
        Apttus_Proposal__Proposal__c proposal = [SELECT Id, Apttus_QPComply__MasterAgreementId__c, Apttus_Proposal__Proposal_Category__c, Apttus_Proposal__Opportunity__c, 
            Contract__c, Clinical_Bid__c, Select_Pricing_Tool__c, Project_Expense__c, Actual_Quote_Amount__c, Total_Quote_Amount__c, CurrencyIsoCode FROM Apttus_Proposal__Proposal__c LIMIT 1];
        UTL_CLM_Flow_ActionHandler.FlowInputs request = new UTL_CLM_Flow_ActionHandler.FlowInputs();
        request.action = CON_CLM.PSA_AMENDMENT;
        request.proposalRecord = proposal;
        
        Test.startTest();
            List<UTL_CLM_Flow_ActionHandler.FlowOutputs> response = UTL_CLM_Flow_ActionHandler.apexFlowAction(new List<UTL_CLM_Flow_ActionHandler.FlowInputs>{request});
        Test.stopTest();
        
        System.assertEquals('Success', response[0].flowOutputRecordId, 'The values should match');
    }    
    
    @isTest
    private static void testSetString() {
        String bL = 'TechData;;Complaince';
        UTL_CLM_Flow_ActionHandler.FlowInputs flowInputs = new UTL_CLM_Flow_ActionHandler.FlowInputs();
        flowInputs.inputString = bL;
        flowInputs.action = CON_CLM.REMOVE_COL;
        
        Test.startTest();
            List<UTL_CLM_Flow_ActionHandler.FlowOutputs> flowOutputs = UTL_CLM_Flow_ActionHandler.apexFlowAction(
                new List<UTL_CLM_Flow_ActionHandler.FlowInputs>{flowInputs});
        Test.stopTest();
        
        System.assertEquals('TechData;Complaince', flowOutputs[0].flowOutputRecordId, 'should remove semicolon');      
    }
    
    @isTest
    private static void testCreateConDoc() {
        IQVIA_Agreement__c agreementUSBU = [SELECT Id, Name FROM IQVIA_Agreement__c WHERE Name = 'Test USBU' LIMIT 1];        
        AgreementWrapper agrWrapper = new AgreementWrapper();
        agrWrapper.iqviaAgreement = agreementUSBU;
        agrWrapper.contentVersionIds = new List<Id>{TST_CLM_TestDataFactory.createContentVersion(true).Id};
        agrWrapper.docType = 'Test Document';
        
        UTL_CLM_Flow_ActionHandler.FlowInputs flowInputs = new UTL_CLM_Flow_ActionHandler.FlowInputs();
        flowInputs.agreementWrapper = agrWrapper;
        flowInputs.action = 'CreateContentDocument';
        
        Test.startTest();
            List<UTL_CLM_Flow_ActionHandler.FlowOutputs> flowOutputs = UTL_CLM_Flow_ActionHandler.apexFlowAction(
                new List<UTL_CLM_Flow_ActionHandler.FlowInputs>{flowInputs});
        Test.stopTest();
        
        ContentDocumentLink cdl = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: agreementUSBU.Id LIMIT 1][0];
        System.assertEquals(cdl.ContentDocumentId, flowOutputs[0].contentVersions[0].ContentDocumentId, 'content document should get created');      
    }
    
    @isTest
    private static void testGetFiles() {
        IQVIA_Agreement__c agr = [SELECT Id, Name FROM IQVIA_Agreement__c WHERE Name = 'Test USBU' LIMIT 1];        
        ContentVersion cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title = 'Test' LIMIT 1];
        FileWrapper fileWrp = new FileWrapper();
        String str = 'TestData';      
        fileWrp.title = 'Title';       
        fileWrp.id = cv.ContentDocumentId;
        fileWrp.conVerId = cv.Id;     
        UTL_CLM_Flow_ActionHandler.FlowInputs flowInput = new  UTL_CLM_Flow_ActionHandler.FlowInputs();
        flowInput.action = CON_CLM.FILE;
        flowInput.fileList = new List<String>{JSON.serialize(new List<FileWrapper>{fileWrp}) + '~descr'};  
        flowInput.agreementId = agr.Id;
        
        Test.startTest();
            List<UTL_CLM_Flow_ActionHandler.FlowOutputs> flowOutputs = UTL_CLM_Flow_ActionHandler.apexFlowAction(
                new List<UTL_CLM_Flow_ActionHandler.FlowInputs>{flowInput});
        Test.stopTest();
        
        System.assertEquals('Success', flowOutputs[0].flowOutputRecordId, 'The value should match');    
    }    

    @isTest
    public static void testGetTocEntry() {
        UTL_CLM_Flow_ActionHandler.FlowInputs flowInputs = new UTL_CLM_Flow_ActionHandler.FlowInputs();
        flowInputs.ISDP = 'PayerTrak;';
        flowInputs.CSCQ = 'Polaris;';
        flowInputs.CSBM = '';
        flowInputs.RWSTD = '';
        flowInputs.action = 'Get_TOC';
        
        Test.startTest();
             List<UTL_CLM_Flow_ActionHandler.FlowOutputs> flowOutputs = UTL_CLM_Flow_ActionHandler.apexFlowAction(
                new List<UTL_CLM_Flow_ActionHandler.FlowInputs>{flowInputs});
        Test.stopTest();

        System.assertEquals('Polaris', flowOutputs[0].CSCQ, 'Should Return Polaris');
        System.assertEquals('PayerTrak', flowOutputs[0].ISDP, 'Should Return PayerTrak');
    }
    
    @isTest
    public static void testRecallEsignature() {
        IQVIA_Agreement__c agr = [SELECT Id, Name, DocuSign_Envelope_Id__c FROM IQVIA_Agreement__c WHERE Name = 'Test USBU' LIMIT 1];  
        AgreementWrapper agreementWrapper = new AgreementWrapper();
        agreementWrapper.iqviaAgreement = agr;
        UTL_CLM_Flow_ActionHandler.FlowInputs flowInput = new  UTL_CLM_Flow_ActionHandler.FlowInputs();
        flowInput.action = CON_CLM.RECALL_ESIGNATURE;
        flowInput.agreementWrapper = agreementWrapper;

        Test.startTest();
            List<UTL_CLM_Flow_ActionHandler.FlowOutputs> flowOutputs = UTL_CLM_Flow_ActionHandler.apexFlowAction(
                new List<UTL_CLM_Flow_ActionHandler.FlowInputs>{flowInput});
        Test.stopTest();
        
        System.assertEquals('Success', flowOutputs[0].flowOutputRecordId, 'Status should not be blank');
    }

    @isTest
    private static void testGetServicesFromOpportunity(){
        Opportunity opportunity = [SELECT Id FROM Opportunity LIMIT 1];
        UTL_CLM_Flow_ActionHandler.FlowInputs flowInputs = new UTL_CLM_Flow_ActionHandler.FlowInputs();
        flowInputs.action = CON_CLM.GET_SERVICES_FROM_OPPORTUNITY;
        flowInputs.opportunity = opportunity;

        Test.startTest();
            List<UTL_CLM_Flow_ActionHandler.FlowOutputs> flowOutputs = UTL_CLM_Flow_ActionHandler.apexFlowAction(
                new List<UTL_CLM_Flow_ActionHandler.FlowInputs>{flowInputs});
        Test.stopTest();

        System.assertNotEquals('', flowOutputs[0].flowOutputRecordId, 'Services should not be null');
    }
    
    @isTest
    private static void testGetFilteredAccounts() {
        UTL_CLM_Flow_ActionHandler.FlowInputs flowInputs = new UTL_CLM_Flow_ActionHandler.FlowInputs();
        flowInputs.type = CON_CLM.CLINIC_CONTRACT;
        flowInputs.action = CON_CLM.GET_ACCOUNT;
        
        Test.startTest();
            List<UTL_CLM_Flow_ActionHandler.FlowOutputs> flowOutput = UTL_CLM_Flow_ActionHandler.apexFlowAction(
                new List<UTL_CLM_Flow_ActionHandler.FlowInputs>{flowInputs});
        Test.stopTest();
        
        Assert.isTrue(!flowOutput[0].accList.isEmpty(), 'The list should not be empty.');
    }

    @isTest
    private static void testCreateAgreementRepository() {
        AgreementWrapper agreementWrapper = new AgreementWrapper();
        UTL_CLM_Flow_ActionHandler.FlowInputs flowInputs = new UTL_CLM_Flow_ActionHandler.FlowInputs();
        flowInputs.agreementWrapper = agreementWrapper;
        flowInputs.action = CON_CLM.CREATE_AGREEMENT_REPOSITORY;
        
        Test.startTest();
            List<UTL_CLM_Flow_ActionHandler.FlowOutputs> flowOutput = UTL_CLM_Flow_ActionHandler.apexFlowAction(
                new List<UTL_CLM_Flow_ActionHandler.FlowInputs>{flowInputs});
        Test.stopTest();
        
        System.assertNotEquals(null, flowOutput, 'Output should not be null');    }
}