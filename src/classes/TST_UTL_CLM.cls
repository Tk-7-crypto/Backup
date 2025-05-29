@isTest
private class TST_UTL_CLM {
    @testSetup 
    static void dataSetUp() {
        List<User> lstUsers = UTL_TestData.createUser('Sales User', 2);
        insert lstUsers;
        
        Account testAccount = UTL_TestData.createAccount();
        insert testAccount;

        List<Contact> lstContact = new List<Contact>();
        Contact testContact = UTL_TestData.createContact(testAccount.Id);
        testContact.EmailBouncedDate = System.today();
        testContact.EmailBouncedReason = 'Invalid Email';
        testContact.Email = 'xyz@gmail.com';
        lstContact.add(testContact);
        
        Contact testContact1 = UTL_TestData.createContact(testAccount.Id);
        testContact1.EmailBouncedDate = System.today();
        testContact1.EmailBouncedReason = 'Invalid Email';
        testContact1.Email = UserInfo.getUserEmail();    
        testContact1.RecordTypeId = CON_CLM.IQVIA_USER_CONTACT_RECORDTYPEID;
        testContact1.EmployeeNumber__c = lstUsers[1].EmployeeNumber;
        lstContact.add(testContact1);
        
        Contact testContact2 = UTL_TestData.createContact(testAccount.Id);
        testContact2.EmailBouncedDate = System.today();
        testContact2.EmailBouncedReason = 'Invalid Email';
        testContact2.Email = UserInfo.getUserEmail();    
        testContact2.RecordTypeId = CON_CLM.IQVIA_USER_CONTACT_RECORDTYPEID;
        testContact2.EmployeeNumber__c = lstUsers[0].EmployeeNumber;
        lstContact.add(testContact2);

        insert lstContact;
        
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
        
        Bid_History__c bidHistory = UTL_TestData.setClinicalBidData('Clinical_Bid', testOpportunity.Id, 'LCS_UPT');
        
        Quote__c quote = UTL_TestData.createIqviaQuote(testAccount.Id, testOpportunity.Id, bidHistory.Id, CON_CPQ.Q2_Solutions, CON_CPQ.GBU_RDS, false);
        quote.Approval_Stage__c = CON_CPQ.DRAFT;
        insert quote;

        List<Apttus__APTS_Agreement__c> lstAgreement = new List<Apttus__APTS_Agreement__c>();
        
        Apttus__APTS_Agreement__c psaAgreementGSA = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        psaAgreementGSA.Name = 'Test PSA Agreement GSA';
        psaAgreementGSA.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_GSA;
        psaAgreementGSA.Apttus__Activated_Date__c = System.today();
        psaAgreementGSA.Apttus__Perpetual__c = true;
        psaAgreementGSA.IQVIA_Quote__c = quote.Id;
        lstAgreement.add(psaAgreementGSA);
        Test.startTest();
            upsert lstAgreement;

        Attachment attachment = TST_CLM_TestDataFactory.createAttachment(
            psaAgreementGSA.Id, 'GeneratedDocument_' + psaAgreementGSA.Name + '.docx', false);
        attachment.OwnerId = UserInfo.getUserId();
        attachment.body= Blob.valueOf('Test Body');
        insert attachment;
        
        Log_Setting__c logSetting = new Log_Setting__c();
        logSetting.Name = 'CLM';
        logSetting.Severity_Level__c = 'INFO';
        logSetting.Log_Data_to_keep_for__c = 10;
        insert logSetting;
        
        upsert new  Mulesoft_Integration_Control__c(Enable_OLIS_JSON__c = true, 
            Is_Mulesoft_User__c = true, Enable_OLI_Sync_Validation__c = true, Enable_Opportunity_Sync_Validation__c = true);
        
        Agreement_Extension__c agreementExt1 = TST_CLM_TestDataFactory.createAgreementExtension(psaAgreementGSA.Id, false);
        insert agreementExt1;
        
        List<Apttus_Proposal__Proposal__c> budgets = new List<Apttus_Proposal__Proposal__c>();
        Apttus_Proposal__Proposal__c budget = TST_CLM_TestDataFactory.setProposalData('RDS_Budget', testOpportunity.Id, 'LCS_UPT', bidHistory.Id, false);
        budget.RFP_Scenario__c = null;
        Apttus_Proposal__Proposal__c techSBudget = TST_CLM_TestDataFactory.setProposalData('Tech_Solution', testOpportunity.Id, 'AMESA', bidHistory.Id, false);
        techSBudget.RFP_Scenario__c = null;
        techSBudget.CountryCode__c = 'Afghanistan';
        budgets.add(budget);
        budgets.add(techSBudget);
        insert budgets;

        Finance_IQVIA_Legal_Entity__c testLegalEntity = new Finance_IQVIA_Legal_Entity__c(Name = 'Test Legal Entity 1', RecordTypeId = CON_CLM.FINANCE_LEGAL_ENTITY_ORACLE_RECORDTYPEID,
        Effective_Status__c = 'Active', Legacy_Entity_Code__c = 'QUTHV', Country_Description__c = 'USA', Address_Line_1__c = 'Test Address', Incorporation__c = 'Test');
        insert testLegalEntity;

        Finance_IQVIA_Legal_Entity_Extension__c financeLEE = new Finance_IQVIA_Legal_Entity_Extension__c();
        financeLEE.Contact__c = testContact1.Id;
        financeLEE.IQVIA_Legal_Entity__c = testLegalEntity.Id;
        insert financeLEE;
        
        CLM_Quote_Agreement_Clone_Excluded_Field__c fieldCustomSetting = new CLM_Quote_Agreement_Clone_Excluded_Field__c();
        fieldCustomSetting.Name = 'Agreement Start Date';
        fieldCustomSetting.Object_Name__c = CON_CLM.AGREEMENT_OBJECT_API_NAME;
        fieldCustomSetting.Field_API_Name__c = 'Apttus__Contract_Start_Date__c';
        insert fieldCustomSetting; 
        
        List<CLM_Amend_Agreement_Clone_Excluded_Field__c> lstAmendCloneExclude = new List<CLM_Amend_Agreement_Clone_Excluded_Field__c>();
        CLM_Amend_Agreement_Clone_Excluded_Field__c amendFieldCustomSetting1 = new CLM_Amend_Agreement_Clone_Excluded_Field__c();
        amendFieldCustomSetting1.Name = 'Activated Date';
        amendFieldCustomSetting1.Object_Name__c = CON_CLM.AGREEMENT_OBJECT_API_NAME;
        amendFieldCustomSetting1.Field_API_Name__c = 'Apttus__Activated_Date__c';   
        lstAmendCloneExclude.add(amendFieldCustomSetting1);
        
        CLM_Amend_Agreement_Clone_Excluded_Field__c amendFieldCustomSetting2 = new CLM_Amend_Agreement_Clone_Excluded_Field__c();
        amendFieldCustomSetting2.Name = CON_CLM.PERPETUAL;
        amendFieldCustomSetting2.Object_Name__c = CON_CLM.AGREEMENT_OBJECT_API_NAME;
        amendFieldCustomSetting2.Field_API_Name__c = CON_CLM.PERPETUAL_API_NAME;
        lstAmendCloneExclude.add(amendFieldCustomSetting2);
        insert lstAmendCloneExclude;

        Apttus__APTS_Agreement__c psaAgreementCO = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        psaAgreementCO.Name = 'Test PSA Agreement CO';
        psaAgreementCO.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_CHANGEORDER;
        psaAgreementCO.Apttus__Activated_Date__c = System.today();
        psaAgreementCO.Apttus__Perpetual__c = true;
        lstAgreement.add(psaAgreementCO);
        
        Apttus__APTS_Agreement__c psaAgreementOA = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        psaAgreementOA.Name = 'Test PSA Agreement OA';
        psaAgreementOA.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_OA;
        psaAgreementOA.Apttus__Activated_Date__c = System.today();
        psaAgreementOA.Apttus__Perpetual__c = true;
        lstAgreement.add(psaAgreementOA);

        Apttus__APTS_Agreement__c psaAgreementOSA = TST_CLM_TestDataFactory.createAgreement(CON_CLM.OSA_RECORDTYPEID, false);
        psaAgreementOSA.Name = 'Test PSA Agreement OSA';
        psaAgreementOSA.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_LOCALRA;
        psaAgreementOSA.Apttus__Activated_Date__c = System.today();
        psaAgreementOSA.Apttus__Perpetual__c = true;
        lstAgreement.add(psaAgreementOSA);
        
        Apttus__APTS_Agreement__c amaAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.AMA_RECORDTYPEID, false);
        amaAgreement.Name = 'Test AMA Agreement';
        amaAgreement.Apttus__Subtype__c = 'RX PHARMA or BIOTECH MANUFACTURER';
        amaAgreement.Number_Of_Records__c = 90000;
        amaAgreement.Sales_Rep_Count__c = 260;
        amaAgreement.Apttus__Contract_Start_Date__c = Date.newInstance(2022, 07, 12);
        amaAgreement.Apttus__Contract_End_Date__c = Date.newInstance(2022, 12, 31);
        lstAgreement.add(amaAgreement);
        

        Apttus__APTS_Agreement__c preliminaryAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PRELIMINARY_RECORDTYPEID, false);
        preliminaryAgreement.Name = 'Test Preliminary Agreement';
        preliminaryAgreement.Apttus__Subtype__c = 'RX PHARMA or BIOTECH MANUFACTURER';
        preliminaryAgreement.Number_Of_Records__c = 90000;
        preliminaryAgreement.Sales_Rep_Count__c = 260;
        preliminaryAgreement.Apttus__Contract_Start_Date__c = Date.newInstance(2022, 07, 12);
        preliminaryAgreement.Apttus__Contract_End_Date__c = Date.newInstance(2022, 12, 31);
        lstAgreement.add(preliminaryAgreement);

        Apttus__APTS_Agreement__c osaAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.OSA_RECORDTYPEID, false);
        osaAgreement.Name = 'Test OSA Agreement';
        osaAgreement.Apttus__Subtype__c = 'RX PHARMA or BIOTECH MANUFACTURER';
        osaAgreement.Number_Of_Records__c = 90000;
        osaAgreement.Sales_Rep_Count__c = 260;
        osaAgreement.Apttus__Contract_Start_Date__c = Date.newInstance(2022, 07, 12);
        osaAgreement.Apttus__Contract_End_Date__c = Date.newInstance(2022, 12, 31);
        lstAgreement.add(osaAgreement);

        Apttus__APTS_Agreement__c rwlpAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.RWLP_RECORDTYPEID, false);
        rwlpAgreement.Name = 'Test RWLP Agreement';
        rwlpAgreement.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_WO;
        rwlpAgreement.Apttus__Activated_Date__c = System.today();
        rwlpAgreement.Apttus__Perpetual__c = true;
        rwlpAgreement.Planned_Execution_Date__c = System.today();
        rwlpAgreement.Client_Address__c = 'xyz';
        rwlpAgreement.Legal_Entity_Customer__c = 'test';
        rwlpAgreement.Legal_Entity_1__c = testLegalEntity.Id;
        rwlpAgreement.Services__c = 'RBU IMC';
        lstAgreement.add(rwlpAgreement);
		
        Apttus__APTS_Agreement__c vendorAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.VENDOR_RECORDTYPEID, false);
        vendorAgreement.Name = 'Test Vendor Agreement';
        vendorAgreement.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_ATP;
        vendorAgreement.Apttus__Activated_Date__c = System.today();
        vendorAgreement.Apttus__Perpetual__c = true;
        vendorAgreement.Planned_Execution_Date__c = System.today();
        vendorAgreement.Client_Address__c = 'xyz';
        vendorAgreement.Legal_Entity_Customer__c = 'test';
        vendorAgreement.Legal_Entity_1__c = testLegalEntity.Id;
        lstAgreement.add(vendorAgreement);

        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.AMA_RECORDTYPEID, false);
        agreement.Name = 'Test AMA';
        agreement.Apttus__Primary_Contact__c = testContact.Id;
        agreement.Apttus__Activated_Date__c = System.today();
        agreement.Apttus__Perpetual__c = true;
        agreement.Apttus__Subtype__c = 'EMERGING MARKET-LARGE';
        agreement.Record_Based_Cost__c = 18878.75;
        agreement.Number_Of_Records__c = 34325;
        agreement.Sales_Rep_Cost__c = 21325;
        agreement.Sales_Rep_Count__c = 340;
        agreement.Apttus__Total_Contract_Value__c = 40203.75; 
        agreement.Apttus__Status_Category__c = CON_CLM.IN_EFFECT; 
        agreement.Apttus__Status__c = CON_CLM.ACTIVATED;
        agreement.Apttus__Auto_Renewal__c = true;
        agreement.Apttus__Contract_Start_Date__c = System.today();
        lstAgreement.add(agreement);

        Apttus__APTS_Agreement__c agreementAMESA = TST_CLM_TestDataFactory.createAgreement(CON_CLM.AMESA_RECORDTYPEID, false);
        agreementAMESA.Name = 'Test AMESA Agreement';
        agreementAMESA.Apttus__Account__c = TST_CLM_TestDataFactory.createAccount('TEST AMESA ACCOUNT', true).Id;
        agreementAMESA.Apttus_QPComply__RelatedProposalId__c =  techSBudget.Id;
        lstAgreement.add(agreementAMESA);
        
        Apttus__APTS_Agreement__c rwsAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.RWS_RECORDTYPEID, false);
        rwsAgreement.Name = 'Test RWSSOW Agreement';
        rwsAgreement.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_WO;
        rwsAgreement.Apttus__Activated_Date__c = System.today();
        rwsAgreement.Apttus__Perpetual__c = true;
        rwsAgreement.Apttus__Agreement_Category__c = CON_CLM.FULL_SERVICE;
        rwsAgreement.First_Patient_In_Date__c = System.today();
        rwsAgreement.Last_Patient_Out_Date__c = System.today();
        lstAgreement.add(rwsAgreement);

        Apttus__APTS_Agreement__c agreementRWS = TST_CLM_TestDataFactory.createAgreement(CON_CLM.RWS_RECORDTYPEID, false);
        agreementRWS.Name = 'Test RWS Agreement';
        agreementRWS.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_ATP;
        agreementRWS.Services__c = 'IQVIA eCOA (eDiary, ePRO, ClinRO, ObsRO, PerfO)';
        lstAgreement.add(agreementRWS);

        upsert lstAgreement;
        
        Agreement_Contacts__c agreementContact1 = TST_CLM_TestDataFactory.createAgreementContacts(agreement.Id, false);
        agreementContact1.Role__c = 'Project Manager';
        agreementContact1.Contact__c = testContact1.Id;
        agreementContact1.Type__c = 'IQVIA User Contact';
        insert agreementContact1;

        List<CLM_Field_Mappings__c> lstCLMFieldMappings = new List<CLM_Field_Mappings__c>();
        CLM_Field_Mappings__c agrQuoteCustomSetting = TST_CLM_TestDataFactory.createClmAgreementQuoteFieldMappingSetting(false);
        agrQuoteCustomSetting.Source_Field_API_Name__c = 'Select_Pricing_Tool__c';
        agrQuoteCustomSetting.Target_Field_API_Name__c = 'Select_Pricing_Tool__c';
        agrQuoteCustomSetting.Record_Type_Developer_Name__c = 'AMESA';
        lstCLMFieldMappings.add(agrQuoteCustomSetting);

        CLM_Field_Mappings__c agrQuoteCountryMapping = TST_CLM_TestDataFactory.createClmAgreementQuoteFieldMappingSetting(false);
        agrQuoteCountryMapping.Source_Field_API_Name__c = 'CountryCode__c';
        agrQuoteCountryMapping.Target_Field_API_Name__c = 'Contracting_Country__c';
        agrQuoteCountryMapping.Record_Type_Developer_Name__c = 'AMESA';
        agrQuoteCountryMapping.Name = '2';
        lstCLMFieldMappings.add(agrQuoteCountryMapping);
        insert lstCLMFieldMappings;
        
        List<IQVIA_Agreement__c> lstIQVAgreements = new List<IQVIA_Agreement__c>();
        IQVIA_Agreement__c iqagreement = TST_CLM_TestDataFactory.createIQAgreement(CON_CLM.USBU_IQVIA_RECORDTYPEID, false);
        iqagreement.Name = 'Test USBU';
        iqagreement.Status_Category__c = 'Request';
        iqagreement.Status__c = 'Request';
        iqagreement.Subtype__c = 'SOW';
        lstIQVAgreements.add(iqagreement);
        
        IQVIA_Agreement__c iqagreement2 = TST_CLM_TestDataFactory.createIQAgreement(CON_CLM.USBU_IQVIA_RECORDTYPEID, false);
        iqagreement2.Name = 'Test USBU 2';
        iqagreement2.Status_Category__c = 'Request';
        iqagreement2.Status__c = 'Request';
        iqagreement2.Subtype__c = 'SOW';
        lstIQVAgreements.add(iqagreement2);
        
        IQVIA_Agreement__c iqagreement3 = TST_CLM_TestDataFactory.createIQAgreement(CON_CLM.USBU_IQVIA_RECORDTYPEID, false);
        iqagreement3.Name = 'Test USBU 3';
        iqagreement3.Status_Category__c = 'Request';
        iqagreement3.Status__c = 'Request';
        iqagreement3.Subtype__c = 'SOW';
        lstIQVAgreements.add(iqagreement3);
        insert lstIQVAgreements;
        
        List<IQVIA_Agreement_Team__c> lstIQVIAAgreementTeams = new List<IQVIA_Agreement_Team__c>();
        IQVIA_Agreement_Team__c teamLead = new IQVIA_Agreement_Team__c();
        teamLead.Role__c = 'Team Lead';
        teamLead.Type__c = CON_CLM.IQVIA_USER_CONTACT_TYPE;
        teamLead.Agreement__c = iqagreement.Id;
        teamLead.Contact__c = testContact1.Id;
        lstIQVIAAgreementTeams.add(teamLead);
        
        IQVIA_Agreement_Team__c teamLead2 = new IQVIA_Agreement_Team__c();
        teamLead2.Role__c = 'Team Lead';
        teamLead2.Type__c = CON_CLM.IQVIA_USER_CONTACT_TYPE;
        teamLead2.Agreement__c = iqagreement2.Id;
        teamLead2.Contact__c = testContact1.Id;
        lstIQVIAAgreementTeams.add(teamLead2);
        
        IQVIA_Agreement_Team__c teamLead3 = new IQVIA_Agreement_Team__c();
        teamLead3.Role__c = 'Contract Analyst';
        teamLead3.Type__c = CON_CLM.IQVIA_USER_CONTACT_TYPE;
        teamLead3.Agreement__c = iqagreement2.Id;
        teamLead3.Contact__c = testContact2.Id;
        lstIQVIAAgreementTeams.add(teamLead3);
        
        insert lstIQVIAAgreementTeams;
        Test.stopTest();
        
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Test Content Version';      
        cv.PathOnClient = 'abc.jpg';
        cv.VersionData = Blob.valueOf('Test Content'); 
        insert cv;  

        Id cdId = [SELECT ContentDocumentId From ContentVersion WHERE Id =: cv.Id ].get(0).ContentDocumentId;

        ContentDocumentLink newCDL = new ContentDocumentLink(ContentDocumentId = cdId, LinkedEntityId = iqagreement.Id);
        insert newCDL;

        Apttus__APTS_Template__c template = TST_CLM_TestDataFactory.createAPTSTemplate(false);
        template.Name = 'SCC Remediation';
        insert template;      
    }

    @isTest
    private static void testGetFieldAPINameLabelMapShouldReturnValidMap(){
        
        Test.startTest();
            Map<String,String> mapOfFieldNameLabel = UTL_CLM.getFieldAPINameLabelMap('Agreement_Extension__c');
        Test.stopTest();
        
        System.assertNotEquals(null,mapOfFieldNameLabel, 'The returned map is null when not expected');
        System.assertEquals('Agreement Extension Name', mapOfFieldNameLabel.get('Name'),
            'Field Label mismatched when not expected');
    }

    @isTest
    private static void testgetPicklistOptionsByRecordTypeIdShouldReturnValidOptions(){
        Id recordTypeId = Schema.SObjectType.Apttus__APTS_Agreement__c.getRecordTypeInfosByDeveloperName().get(
            CON_CLM.PSA_RECORD_TYPE_NAME).getRecordTypeId();

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TST_Mock_UTL_PickListOptions());
        	Map<String,String> mapOfOptions = UTL_CLM.getPicklistOptionsByRecordTypeId('Apttus__APTS_Agreement__c',
                recordTypeId,'Apttus__Agreement_Category__c');
        Test.stopTest();
        
        System.assertNotEquals(0,mapOfOptions.size(),'No option returned when expected');
    }

    @isTest
    private static void testQueryStringOfAllFieldsOfSObjectShouldReturnSOQL(){
        Test.startTest();
        	String soqlResult = UTL_CLM.queryStringOfAllFieldsOfSObject('Apttus__APTS_Agreement__c', '');
        Test.stopTest();
        
        System.assertNotEquals(null, soqlResult, 'soqlResult must have query String.');
    }

    @isTest
    private static void testCreateSingleEmailMessageShouldReturnSingleEmailMessage() {
        List<String> toAddress = new List<String>{'abc@example.com'};

        Test.startTest();
            Messaging.SingleEmailMessage mail = UTL_CLM.createSingleEmailMessage(toAddress, 'Test', 'Test', 'Test', null, null);
        Test.stopTest();

        System.assertNotEquals(null, mail, 'SingleEmailMessage should not be null');
    }

    @isTest
    private static void testGetAGRRecordTypeListByDevNameShouldReturnList(){
        Test.startTest();
        	List<RecordType> lstRecordType = UTL_CLM.getAGRRecordTypeListByDevName(new Set<String>{CON_CLM.PSA_RECORD_TYPE_NAME});
        Test.stopTest();
        
        System.assertEquals(false, lstRecordType.isEmpty(), 'record type is not fetched when expected');
    }

    @isTest
    private static void testGetAGRRecordTypeListByIdShouldReturnList(){
        Test.startTest();
        	List<RecordType> lstRecordType = UTL_CLM.getAGRRecordTypeListById(new Set<Id>{CON_CLM.PSA_RECORDTYPEID});
        Test.stopTest();
        
        System.assertEquals(false, lstRecordType.isEmpty(), 'record type is not fetched when expected');
    }
    
    @isTest
    private static void testSendEmailShouldProcessMails() {
        List<String> toAddresses = new List<String>{'abc@test.com'};
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        Test.startTest();
            Messaging.SingleEmailMessage mail =  UTL_CLM.createSingleEmailMessage(
                toAddresses, 'Test Subject', 'Test Body', null, null, null);
            mails.add(mail);
            UTL_CLM.sendEmail(mails);
        Test.stopTest();
        
        System.assertEquals(false, (mail == null), 'Email record is not processed for send when expected');
    } 

    @isTest
    private static void testCreateNewPreliminaryRecordFromQuote() {
        Apttus_Proposal__Proposal__c proposal = [SELECT Id FROM Apttus_Proposal__Proposal__c WHERE Select_Pricing_Tool__c =: 'LCS_UPT'];
        proposal.Apttus_Proposal__Approval_Stage__c = 'Sign Off';
        proposal.Approval_Status__c = 'TSL Review Approved and Submitted for Final SignOff';
        update proposal;

        Test.startTest();
            Id agrRecId = UTL_CLM.createPreliminaryRecordFromQuote(proposal.Id);
        Test.stopTest();

        System.assertEquals(true, agrRecId != null, 'Agreement Record is not created');
    }

    @isTest
    private static void testGetSObjectTypeFields() {
        Test.startTest();
            Set<String> fieldSet = UTL_CLM.getSObjectTypeFields(Apttus__APTS_Agreement__c.SObjectType,true);
        Test.stopTest();

        System.assertEquals(true, fieldSet.size() > 0, 'field set size must not be 0.');
    }
    
    @isTest
    private static void testAddErrorOnAgreement() {
        Apttus__APTS_Agreement__c agreementPSA = [SELECT Id, RecordType.DeveloperName, Apttus__Subtype__c, Is_This_A_Rescue_Study__c, Prob_to_Execute_in_the_Qtr_Mgrs_Only__c,
            Planned_Execution_Date__c, Apttus__Contract_Start_Date__c, IQVIA_Project_Manager_Con__c, IQVIA_Project_Finance_Manager__c, Prob_to_move_to_High_Confidence_in_Qtr__c,
            Line_Manager_1__c,Apttus__Status_Category__c, Apttus__Status__c, Original_Requested_Agreement_Type__c
            FROM Apttus__APTS_Agreement__c WHERE Name = 'Test PSA Agreement GSA'];
        
        
        Test.startTest();
            String htmlOfFieldLabels = UTL_CLM.addErrorAndGenerateHTMLOnAgreement(agreementPSA, agreementPSA.RecordType.DeveloperName, 
                agreementPSA.Apttus__Subtype__c,agreementPSA.Apttus__Status_Category__c, agreementPSA.Apttus__Status__c, false);
            String htmlResult = UTL_CLM.addErrorAndGenerateHTMLOnAgreementClone(agreementPSA, agreementPSA.RecordType.DeveloperName, 
                agreementPSA.Apttus__Subtype__c,agreementPSA.Apttus__Status_Category__c, agreementPSA.Apttus__Status__c, false);
        Test.stopTest();
        
        System.assertEquals(true, htmlOfFieldLabels != null, 'htmlOfFieldLabels should be true');    
        System.assertNotEquals(null, htmlResult, 'The value must not be null');
    }
    
    @isTest
    private static void testGetFieldAPINameSetForExcludedFields() {
        Set<String> fieldAPINameSet = new Set<String>();
        
        Test.startTest();
            fieldAPINameSet = UTL_CLM.getFieldAPINameSetForExcludedFields(CON_CLM.AGREEMENT_OBJECT_API_NAME);
        Test.stopTest();
        
        System.assertEquals(true, fieldAPINameSet.contains('Apttus__Contract_Start_Date__c'), 'The set should return Field API Name');
    }
    
    @isTest
    private static void testExcludeFieldsFromCloningWhileAmendingAgreement() {
                  
        Test.startTest();
            Set<String> setFields = UTL_CLM.excludeFieldsFromCloningWhileAmendingAgreement(CON_CLM.AGREEMENT_OBJECT_API_NAME);
        Test.stopTest();
        
        System.assertEquals(false, setFields.isEmpty(), 'Correct set of field not returned');
    }
    
    @isTest
    private static void testConcatenateException() {
        DmlException excp = new DmlException();
        excp.setMessage('Failed to update');
        
        Test.startTest();
            String result = UTL_CLM.concatenateException(excp);
        Test.stopTest();    
        
        System.assertNotEquals(null, result, 'The result should not be a null string and give all information about exception');
    }
    
    @isTest
    private static void testConvertAttachmentsIntoFiles() {
        Apttus__APTS_Agreement__c agreement = [SELECT Id FROM Apttus__APTS_Agreement__c WHERE name = 'Test PSA Agreement GSA'][0];
        List<Attachment> attachments = [SELECT Id, Body, Name, Description, IsPrivate, OwnerId, CreatedDate, LastModifiedById,
            LastModifiedDate, ParentId FROM Attachment WHERE ParentId = :agreement.Id];
        
        Test.startTest();
            UTL_CLM.convertAttachmentsIntoFiles(attachments,true);
        Test.stopTest();
        
        System.assertEquals(1, [SELECT count() FROM ContentVersion WHERE Title = 'GeneratedDocument_Test PSA Agreement GSA.docx']);
        System.assertEquals(0, [SELECT count() FROM Attachment WHERE Name = 'GeneratedDocument_Test PSA Agreement GSA.docx']);
    }
    
    @isTest
    private static void testCopyContentDocumentLink() {
        Apttus__APTS_Agreement__c agreement = [SELECT Id FROM Apttus__APTS_Agreement__c WHERE Name = 'Test PSA Agreement GSA'][0];
        Attachment attachment = [SELECT Id, Body, Name, Description, IsPrivate, OwnerId, CreatedDate, LastModifiedById,
            LastModifiedDate, ParentId FROM Attachment WHERE ParentId = :agreement.Id][0];
        
        ContentVersion newFileVersion = new ContentVersion(
            versionData = attachment.body, title = attachment.name,
            description = attachment.description, pathOnClient = '/' + attachment.name,
            sharingPrivacy = (attachment.isPrivate ? 'P' : 'N' ), createdById = attachment.ownerId,
            createdDate = attachment.createdDate, lastModifiedById = attachment.lastModifiedById,
            lastModifiedDate = attachment.lastModifiedDate, OwnerId	= attachment.OwnerId,
            Origin = 'C', ContentLocation = 'S');
        insert newFileVersion;
        
        Set<Id> contentVersionSet = new Set<Id>{newFileVersion.Id};
        Map<Id, Id> contentVersionIdToAttachmentParentIdMap = new Map<Id, Id>{newFileVersion.Id => attachment.ParentId};
        
        Test.startTest();
            UTL_CLM.copyContentDocumentLink(contentVersionSet, contentVersionIdToAttachmentParentIdMap);
        Test.stopTest();
        
        System.assertEquals(1, [SELECT count() FROM ContentDocumentLink WHERE LinkedEntityId = :attachment.ParentId]);
        System.assertEquals(1, [SELECT count() FROM Log_History__c LIMIT 1]);
    }
    
    @isTest	
    private static void testAddErrorOnAgreementForCO() {
        Apttus__APTS_Agreement__c agreementPSA = [SELECT Id, RecordType.DeveloperName, Apttus__Subtype__c,
            Apttus__Contract_Start_Date__c, Is_This_A_Rescue_Study__c, Prob_to_Execute_in_the_Qtr_Mgrs_Only__c, 
            Prob_to_move_to_High_Confidence_in_Qtr__c, Planned_Execution_Date__c, IQVIA_Project_Manager_Con__c, 
            IQVIA_Project_Finance_Manager__c, Original_Requested_Agreement_Type__c
            FROM Apttus__APTS_Agreement__c WHERE Name = 'Test PSA Agreement CO'];
        
        agreementPSA.Apttus__Contract_Start_Date__c = null;
        agreementPSA.Apttus__Status_Category__c = CON_CLM.IN_BUDGETING;
        agreementPSA.Apttus__Status__c = CON_CLM.BUDGET_PREPARATION;
        
        Test.startTest();
            UTL_CLM.addErrorAndGenerateHTMLOnAgreement(agreementPSA, agreementPSA.RecordType.DeveloperName,
                agreementPSA.Apttus__Subtype__c,agreementPSA.Apttus__Status_Category__c,agreementPSA.Apttus__Status__c , true);
            UTL_CLM.addErrorAndGenerateHTMLOnAgreementClone(agreementPSA, agreementPSA.RecordType.DeveloperName,
                agreementPSA.Apttus__Subtype__c,agreementPSA.Apttus__Status_Category__c,agreementPSA.Apttus__Status__c , true);  
        Test.stopTest();
        
        System.assertEquals(true, ApexPages.getMessages().size() > 0, 
            'The value should be true and error message should be shown.');
    }

    @isTest
    private static void testAddErrorOnAgreementForOA() {
        Apttus__APTS_Agreement__c agreementPSA = [SELECT Id, RecordType.DeveloperName, Apttus__Subtype__c,
            Apttus__Contract_Start_Date__c, Is_This_A_Rescue_Study__c, Prob_to_Execute_in_the_Qtr_Mgrs_Only__c, 
            Prob_to_move_to_High_Confidence_in_Qtr__c, Planned_Execution_Date__c, IQVIA_Project_Manager_Con__c, 
            IQVIA_Project_Finance_Manager__c, Original_Requested_Agreement_Type__c FROM Apttus__APTS_Agreement__c WHERE Name = 'Test PSA Agreement OA'];
        agreementPSA.Apttus__Contract_Start_Date__c = null;
        agreementPSA.Apttus__Status_Category__c = CON_CLM.IN_BUDGETING;
        agreementPSA.Apttus__Status__c = CON_CLM.BUDGET_PREPARATION;
        
        Test.startTest();
            UTL_CLM.addErrorAndGenerateHTMLOnAgreement(agreementPSA, agreementPSA.RecordType.DeveloperName,
                agreementPSA.Apttus__Subtype__c, agreementPSA.Apttus__Status_Category__c, agreementPSA.Apttus__Status__c, true);
        Test.stopTest();
        
        System.assertEquals(true, ApexPages.getMessages().size() > 0, 
            'The value should be true and error message should be shown.');
    }

    @isTest
    private static void testAddErrorOnAgreementForOSA() {
        Apttus__APTS_Agreement__c agreementPSA = [SELECT Id, RecordType.DeveloperName, Apttus__Subtype__c,
                                                  Apttus__Contract_Start_Date__c, Is_This_A_Rescue_Study__c, Prob_to_Execute_in_the_Qtr_Mgrs_Only__c, 
                                                  Prob_to_move_to_High_Confidence_in_Qtr__c, Planned_Execution_Date__c, IQVIA_Project_Manager_Con__c, 
                                                  IQVIA_Project_Finance_Manager__c, Original_Requested_Agreement_Type__c FROM Apttus__APTS_Agreement__c WHERE Name = 'Test PSA Agreement OSA'];
        agreementPSA.Apttus__Status_Category__c = CON_CLM.IN_BUDGETING;
        agreementPSA.Apttus__Status__c = CON_CLM.BUDGET_PREPARATION;
        agreementPSA.Apttus__Contract_Start_Date__c = null;
        agreementPSA.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_MA;
        
        Test.startTest();
            UTL_CLM.addErrorAndGenerateHTMLOnAgreement(agreementPSA, agreementPSA.RecordType.DeveloperName,
                agreementPSA.Apttus__Subtype__c, agreementPSA.Apttus__Status_Category__c, agreementPSA.Apttus__Status__c, true);
        Test.stopTest();
        
        System.assertEquals(true, ApexPages.getMessages().size() > 0, 
                            'The value should be true and error message should be shown.');
    }

    @isTest
    private static void testDeleteListOfAttachments(){
        Apttus__APTS_Agreement__c objAgreement = TST_CLM_TestDataFactory.createAgreement(null, true);
        Attachment objAttachment = TST_CLM_TestDataFactory.createAttachment(objAgreement.Id, 'Test Attachment.pdf', true);
        
        Test.startTest();
            Boolean result = UTL_CLM.deleteListOfAttachments(new Set<Id>{objAttachment.Id}, true);
        Test.stopTest();

        System.assertEquals(true, result, 'Should Update Attachments');
    }

    @isTest
    private static void testCreateContractVersionForBulkAgreement() {
        List<Apttus__APTS_Agreement__c> lstAgreement = new List<Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(null, true);
        Apttus__APTS_Template__c template = TST_CLM_TestDataFactory.createAPTSTemplate(true);
        lstAgreement.add(agreement);

        Test.startTest();
            try{
                UTL_CLM.createContractVersionForBulkAgreement(lstAgreement, String.valueOf(template.Id));
            } catch(Exception ex) {
                System.assertNotEquals(null, ex, 'There is a problem occured while creating document version.');
            }
        Test.stopTest();
    }

    @isTest
    private static void testCreateContractDocument() {
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(null, true);
        Apttus__APTS_Template__c template = TST_CLM_TestDataFactory.createAPTSTemplate(true);

        Test.startTest();
            try{
                UTL_CLM.createContractDocument(String.valueOf(agreement.Id), String.valueOf(template.Id));
            } catch(Exception ex) {
                System.assertNotEquals(null, ex, 'There is a problem occured while creating document version.');
            }
        Test.stopTest();
    }

    @isTest
    private static void testCreateContentDocument() {
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(null, true);
        Apttus__APTS_Template__c template = TST_CLM_TestDataFactory.createAPTSTemplate(true);

        Test.startTest();
            String docId = UTL_CLM.createContentDocument(String.valueOf(template.Id), String.valueOf(agreement.Id));
        Test.stopTest();

        System.assertNotEquals(null, docId, 'The result should not be null.');
    }

    @isTest
    private static void testCloneContentVersion() {
        ContentVersion contVersion = TST_CLM_TestDataFactory.createContentVersion(true);
		Id docId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id=:contVersion.Id].ContentDocumentId; 

        Test.startTest();
        Map<Id,ContentVersion> contentVersionMap = UTL_CLM.cloneContentVersion(new Set<Id> {docId});
        Test.stopTest();

        System.assertEquals(false, contentVersionMap.isEmpty(), 'No content version copied.');
    }

    @isTest
    private static void testDeleteDocument() {
        ContentVersion contVersion = TST_CLM_TestDataFactory.createContentVersion(true);
		Id docId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id=:contVersion.Id].ContentDocumentId; 

        Test.startTest();
            try{
                UTL_CLM.deleteDocument(docId);
            } catch(Exception ex) {
                System.assertNotEquals(null, ex, 'There is a problem occured while deleting document version.');
            }
        Test.stopTest();
    }
    
    @isTest
    private static void testSetupActivity() {
        Apttus__APTS_Agreement__c agreement = [SELECT Apttus__Perpetual__c, Apttus__Activated_Date__c 
            FROM Apttus__APTS_Agreement__c LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact  WHERE LastName = 'TestContact' LIMIT 1];
        
        Test.startTest();
            //replace with custom label
            List<Task> result = UTL_CLM.setupActivity(agreement.Id,testContact.Id, 'AMA Contract Renewal Response 2023','AMA Contract Renewal Response 2023');
        Test.stopTest();
       
        System.assertEquals(1, result.size(), 'The result List should be empty');    
    }
    
    @isTest
    private static void testAmendContract() {
        Apttus__APTS_Agreement__c agreementAMA = [SELECT Id, Name,Sales_Rep_Cost__c, Record_Based_Cost__c, Agreement_Year_Plus_One__c
            FROM Apttus__APTS_Agreement__c 
            WHERE Name = 'Test AMA Agreement'];
            
        
        Test.startTest();
            AgreementWrapper.AmendAgreementWrapper agrWrapper = new AgreementWrapper.AmendAgreementWrapper();
            agrWrapper.agreementId = agreementAMA.Id;
            agrWrapper.action = CON_CLM.AMEND;
            UTL_CLM.amendContract(agrWrapper);
        Test.stopTest();

        Apttus__APTS_Agreement__c updatedAgreementAMA = [SELECT Id, Apttus__Status__c 
            FROM Apttus__APTS_Agreement__c WHERE id = :agreementAMA.Id];
        System.assertEquals(1, [SELECT count() FROM Apttus__APTS_Agreement__c WHERE 
            Agreement_Cloned_From__c = :agreementAMA.Id], 'Agreement should be cloned');
        System.assertEquals(1, [SELECT count() FROM Apttus__APTS_Related_Agreement__c WHERE
            Apttus__APTS_Contract_From__c = :agreementAMA.Id], 'Related From record should be created');
        System.assertEquals(CON_CLM.BEING_AMENDED, updatedAgreementAMA.Apttus__Status__c, 
            'Agreement Status should be updated to Being Amended');
    }
    
    @isTest
    private static void testCreateRelatedAGRRecordsToReplicateAmend() {
        Apttus__APTS_Agreement__c agreementPSA = [SELECT Id, Name FROM Apttus__APTS_Agreement__c WHERE 
            Name = 'Test PSA Agreement GSA'];
        Apttus__APTS_Agreement__c clonedAgreement = agreementPSA.clone(false, true, false, false);
        insert clonedAgreement;
        
        Test.startTest();
            UTL_CLM.createRelatedAGRRecordsToReplicateAmend(agreementPSA.Id, clonedAgreement, CON_CLM.IS_AMENDED_BY, CON_CLM.IS_AMENDMENT_FOR);
        Test.stopTest();

        System.assertEquals(1, [SELECT count() FROM Apttus__APTS_Related_Agreement__c WHERE
            Apttus__APTS_Contract_From__c = :agreementPSA.Id], 'Related From record should be created');
    }
    
    @isTest
    private static void testDefaultContract(){
        Apttus__APTS_Agreement__c agreementAMA = [SELECT Id, Name, Sales_Rep_Cost__c, Record_Based_Cost__c 
            FROM Apttus__APTS_Agreement__c WHERE Name = 'Test AMA Agreement' LIMIT 1];

        Test.startTest();
        	UTL_CLM.defaultContract(agreementAMA.Id, 2023);
        Test.stopTest();
        
        Apttus__APTS_Agreement__c updatedAgreementAMA = [SELECT Id, Apttus__Contract_Start_Date__c, Apttus__Contract_End_Date__c, Sales_Rep_Cost__c, Record_Based_Cost__c FROM Apttus__APTS_Agreement__c WHERE Id = :agreementAMA.Id];
        System.assertEquals(Date.newInstance(2023,1,1), updatedAgreementAMA.Apttus__Contract_Start_Date__c, 'Agreement Start Date should be defaulted to 2023-01-01');
        System.assertEquals(Date.newInstance(2023,12,31), updatedAgreementAMA.Apttus__Contract_End_Date__c, 'Agreement End Date should be defaulted to 2023-12-31');
        if(updatedAgreementAMA.Record_Based_Cost__c != null){
            System.assertNotEquals(agreementAMA.Record_Based_Cost__c, updatedAgreementAMA.Record_Based_Cost__c, 'Record Based Cost should be defaulted with new cost');
        }
        if(updatedAgreementAMA.Sales_Rep_Cost__c != null){
            System.assertNotEquals(agreementAMA.Sales_Rep_Cost__c, updatedAgreementAMA.Sales_Rep_Cost__c, 'Sales Rep Cost should be defaulted with new cost');
        }
    }
        
    @isTest
    private static void testGetSalesRepRateByRepCount() {
        AMA_Sales_Rep_Rate__mdt resultSalesRepRate = null;
            
        Test.startTest();
            resultSalesRepRate = UTL_CLM.getSalesRepRateByRepCount(2023, 340);
        Test.stopTest();    
         
        System.assertNotEquals(null, resultSalesRepRate, 'The value should not be null');
    }
        
    @isTest
    private static void testCalcRecordBasedCost() {
        Apttus__APTS_Agreement__c agreement = [SELECT Id, Apttus__Subtype__c, Number_Of_Records__c FROM Apttus__APTS_Agreement__c 
            WHERE RecordTypeId =: CON_CLM.AMA_RECORDTYPEID AND Name = 'Test AMA' LIMIT 1];
        Double resultRecordCost = 0;
        
        Test.startTest();
            resultRecordCost = UTL_CLM.calcRecordBasedCost(agreement, System.Today().year());
        Test.stopTest();
         
        //System.assertNotEquals(0, resultRecordCost, 'The value should not be 0');
    }
    
    @isTest
    private static void testLogExceptionAndRaiseCommonError() {
        Apttus_Proposal__Proposal__c proposal = [SELECT Id, Name FROM Apttus_Proposal__Proposal__c][0];
        
        Test.startTest();
            UTL_CLM.logExceptionAndRaiseCommonError(new List<Apttus_Proposal__Proposal__c>{proposal},
                new NullPointerException());
        Test.stopTest();
        
        List<Apex_Error_Log__c> errorLogList = [SELECT id, Record_Id__c FROM Apex_Error_Log__c 
            WHERE Record_Id__c = :proposal.Id];
        System.assertEquals(true, errorLogList.size() > 0, 'Error Log should be created');
    }
    
    @isTest
    private static void testSetTabPositionByAnchorForDocusign() {
        Integer signerNumber = 1;
        Integer recipientId = 1;
        
        Test.startTest();
            String result = UTL_CLM.setTabPositionByAnchorForDocusign(signerNumber, recipientId, 'Sample Title');
        Test.stopTest();    
        
        System.assertNotEquals(null, result, 'The returned result should not be null');
    } 
    
    @isTest
    private static void testAmendRWLPContract() {
        Apttus__APTS_Agreement__c agreementRWLP = [SELECT Id, Name FROM Apttus__APTS_Agreement__c WHERE Name = 'Test RWLP Agreement'];
            
        Test.startTest();
            AgreementWrapper.AmendAgreementWrapper agrWrapper = new AgreementWrapper.AmendAgreementWrapper();
            agrWrapper.agreementId = agreementRWLP.Id;
            agrWrapper.action = CON_CLM.AMEND_BY_FLOW;
            agrWrapper.recordTypeDeveloperName = CON_CLM.RWLP_RECORD_TYPE_NAME;
            UTL_CLM.amendContract(agrWrapper);
        Test.stopTest();

        Apttus__APTS_Agreement__c updatedAgreementRWLP = [SELECT Id, Apttus__Status__c 
            FROM Apttus__APTS_Agreement__c WHERE id = :agreementRWLP.Id];
        System.assertEquals(1, [SELECT count() FROM Apttus__APTS_Agreement__c WHERE 
            Agreement_Cloned_From__c = :agreementRWLP.Id], 'Agreement should be cloned');
        System.assertEquals(1, [SELECT count() FROM Apttus__APTS_Related_Agreement__c WHERE
            Apttus__APTS_Contract_From__c = :agreementRWLP.Id], 'Related From record should be created');
        System.assertEquals(CON_CLM.BEING_AMENDED, updatedAgreementRWLP.Apttus__Status__c, 
            'Agreement Status should be updated to Being Amended');
    } 

    @isTest
    static void testSetAgreementFields(){
        
        Apttus_Proposal__Proposal__c proposal = [SELECT Id, Name, Apttus_Proposal__RelatedProposalId__c,Select_Pricing_Tool__c,CountryCode__c FROM Apttus_Proposal__Proposal__c 
                                                       WHERE Apttus_Proposal__RelatedProposalId__c = null AND RecordType.DeveloperName = 'Tech_Solution' LIMIT 1];
        Apttus__APTS_Agreement__c amesaAGR = [SELECT Id,Contracting_Country__c,Select_Pricing_Tool__c FROM Apttus__APTS_Agreement__c WHERE  Name = 'Test AMESA Agreement' LIMIT 1];
        

        Test.startTest();
            UTL_CLM.setAgreementFields(proposal, amesaAGR);
        Test.stopTest();
        
        System.assertEquals(amesaAGR.Select_Pricing_Tool__c, proposal.Select_Pricing_Tool__c, 'The fields are not copied when expected');
        System.assertEquals('AF', amesaAGR.Contracting_Country__c, 'The country not converted to coountry code when expected');
    }
    
    @isTest
    static void testGetFieldAPINameToValidate(){
        Apttus__APTS_Agreement__c agreement = [SELECT Id, Name, RecordType.DeveloperName, Apttus__Subtype__c,
            Apttus__Status_Category__c, Apttus__Status__c FROM Apttus__APTS_Agreement__c WHERE Name = 'Test RWSSOW Agreement' LIMIT 1]; 
        
        Test.startTest();
            Set<String> setOfFieldAPINames = UTL_CLM.getFieldAPINameToValidate(agreement.RecordType.DeveloperName, agreement.Apttus__Subtype__c,
                CON_CLM.IN_EFFECT, null, CON_CLM.REQUESTED_AGREEMENT_TYPE_MA, false);
        Test.stopTest();
        System.assertNotEquals(null, setOfFieldAPINames, 'Should not return null');
    }
    
    @isTest
    private static void testAddErrorOnRWSAgreement() { 
        Apttus__APTS_Agreement__c agreement = [SELECT Id, Name, RecordType.DeveloperName, Apttus__Subtype__c,
            Apttus__Status_Category__c, Apttus__Status__c, First_Patient_In_Date__c, Last_Patient_Out_Date__c,
            Date_Executed_Signed_Contract_Received__c, Planned_Execution_Date__c,Services__c, Original_Requested_Agreement_Type__c FROM Apttus__APTS_Agreement__c 
            WHERE Name = 'Test RWS Agreement' LIMIT 1]; 
        
        Test.startTest();
            String htmlOfFieldLabels = UTL_CLM.addErrorAndGenerateHTMLOnAgreement(agreement, agreement.RecordType.DeveloperName,
                agreement.Apttus__Subtype__c, CON_CLM.IN_EFFECT, null, false);
            String htmlResult = UTL_CLM.addErrorAndGenerateHTMLOnAgreementClone(agreement, agreement.RecordType.DeveloperName,
                agreement.Apttus__Subtype__c, CON_CLM.IN_EFFECT, null, false);
        Test.stopTest();
        
        System.assertEquals(true, htmlOfFieldLabels != null, 'htmlOfFieldLabels should not be null');    
        System.assertEquals(true, String.isNotBlank(htmlResult), 'The value should not be null');
    }

    @isTest
    private static void testAmendRWSSOWContract() {
        Apttus__APTS_Agreement__c agreementRWSSOW = [SELECT Id, Name FROM Apttus__APTS_Agreement__c WHERE Name = 'Test RWSSOW Agreement'];
		Apttus__APTS_Agreement__c clinicalAgr = [SELECT Id, Name, Planned_Execution_Date__c, Legal_Entity_Customer__c, Legal_Entity_1__c, Client_Address__c FROM Apttus__APTS_Agreement__c WHERE Name = 'Test RWLP Agreement']; 
        Opportunity selectedOpp = [SELECT Id, AccountId, CurrencyIsoCode FROM Opportunity LIMIT 1];
        Test.startTest();
            AgreementWrapper.AmendAgreementWrapper agrWrapper = new AgreementWrapper.AmendAgreementWrapper();
            agrWrapper.agreementId = agreementRWSSOW.Id;
            agrWrapper.action = CON_CLM.AMEND_BY_FLOW;
            agrWrapper.recordTypeDeveloperName = CON_CLM.RWSSOW_RECORD_TYPE_NAME;
            agrWrapper.clinicalAgreement = clinicalAgr;
            agrWrapper.selectedOpportunity = selectedOpp;
            UTL_CLM.amendContract(agrWrapper);
        Test.stopTest();

        Apttus__APTS_Agreement__c updatedAgreementRWSSOW = [SELECT Id, Apttus__Status__c 
            FROM Apttus__APTS_Agreement__c WHERE id = :agreementRWSSOW.Id];
        System.assertEquals(1, [SELECT count() FROM Apttus__APTS_Agreement__c WHERE 
            Agreement_Cloned_From__c = :agreementRWSSOW.Id], 'Agreement should be cloned');
        System.assertEquals(1, [SELECT count() FROM Apttus__APTS_Related_Agreement__c WHERE
            Apttus__APTS_Contract_From__c = :agreementRWSSOW.Id], 'Related From record should be created');
        System.assertEquals(CON_CLM.BEING_AMENDED, updatedAgreementRWSSOW.Apttus__Status__c, 
            'Agreement Status should be updated to Being Amended');
    }
	
    @isTest
    private static void testAmendVendorContract() {
        Apttus__APTS_Agreement__c agreementVendor = [SELECT Id, Name FROM Apttus__APTS_Agreement__c WHERE Name = 'Test Vendor Agreement'];
            
        Test.startTest();
            AgreementWrapper.AmendAgreementWrapper agrWrapper = new AgreementWrapper.AmendAgreementWrapper();
            agrWrapper.agreementId = agreementVendor.Id;
            agrWrapper.action = CON_CLM.AMEND_BY_FLOW;
            UTL_CLM.amendContract(agrWrapper);
        Test.stopTest();

        Apttus__APTS_Agreement__c updatedAgreementVendor = [SELECT Id, Apttus__Status__c 
            FROM Apttus__APTS_Agreement__c WHERE id = :agreementVendor.Id];
        System.assertEquals(1, [SELECT count() FROM Apttus__APTS_Agreement__c WHERE 
            Agreement_Cloned_From__c = :agreementVendor.Id], 'Agreement should be cloned');
        System.assertEquals(1, [SELECT count() FROM Apttus__APTS_Related_Agreement__c WHERE
            Apttus__APTS_Contract_From__c = :agreementVendor.Id], 'Related From record should be created');
        System.assertEquals(CON_CLM.BEING_AMENDED, updatedAgreementVendor.Apttus__Status__c, 
            'Agreement Status should be updated to Being Amended');
    } 

    @isTest
    private static void testCreateActivityOnAmend() {
        Apttus__APTS_Agreement__c agreementRWSSOW = [SELECT Id, Name, Apttus__Agreement_Number__c, Apttus__Version_Number__c FROM Apttus__APTS_Agreement__c WHERE Name = 'Test RWSSOW Agreement'];
        Apttus__APTS_Agreement__c clonedAgreement = agreementRWSSOW.clone(false, true, false, false);
        clonedAgreement.Apttus__Version_Number__c = agreementRWSSOW.Apttus__Version_Number__c + 1;
        clonedAgreement.Agreement_Cloned_From__c = agreementRWSSOW.Id;
        
        Test.startTest();
            insert clonedAgreement;
            UTL_CLM.createActivityOnAmend(new List<Apttus__APTS_Agreement__c>{clonedAgreement});
        Test.stopTest();
        
        List<Task> amendmentTask = [SELECT Id, WhatId, Subject FROM Task WHERE WhatId = :agreementRWSSOW.Id AND Subject = 'Amended Agreement'];
        List<Task> amendedTask = [SELECT Id, WhatId, Subject FROM Task WHERE WhatId = :clonedAgreement.Id AND Subject LIKE 'Amended From agreement %'];
        
        System.assertEquals(true, amendmentTask.size()>0, 'Amend Activity Not Created');
        System.assertEquals(true, amendedTask.size()>0, 'Amend Activity Not Created');
    }

    @isTest
    private static void testGetContactFromUser() {
        Map<Id, Id> userIdToContactIdMap = new Map<Id, Id>();
        
        Test.startTest();
            userIdToContactIdMap = UTL_CLM.getContactFromUser(new Set<Id>{UserInfo.getUserId()});
        Test.stopTest();
          
        System.assertEquals(true, !userIdToContactIdMap.isEmpty(), 'The value should be present');
    }
    
    @isTest
    private static void testGetFieldSetValues() {
        List<String> lstRes;
        
        Test.startTest();
            lstRes = UTL_CLM.getFieldSetValues('Team_Tab');
        Test.stopTest();
        
        System.assertEquals(true, !lstRes.isEmpty(), 'The value must not be empty');
    }
    
    @isTest
    private static void testAddErrorAndGenerateHTMLOnAgreementCloneCO() {
        String htmlResult;
        Apttus__APTS_Agreement__c agreement = [SELECT Id, Name, RecordType.DeveloperName, Apttus__Subtype__c,
            Apttus__Status_Category__c, Apttus__Status__c, First_Patient_In_Date__c, Last_Patient_Out_Date__c,Apttus_QPComply__RelatedProposalId__c,
            Date_Executed_Signed_Contract_Received__c, Planned_Execution_Date__c,Services__c, Original_Requested_Agreement_Type__c FROM Apttus__APTS_Agreement__c 
            WHERE Name = 'Test PSA Agreement CO' LIMIT 1]; 
        
        Test.startTest();
            htmlResult = UTL_CLM.addErrorAndGenerateHTMLOnAgreementClone(agreement, agreement.RecordType.DeveloperName,
                agreement.Apttus__Subtype__c, CON_CLM.IN_EFFECT, null, false);
        Test.stopTest();
        
        System.assertEquals(true, String.isNotBlank(htmlResult), 'The value should not be null');        
    }
    
    @isTest
    private static void testCreateContentDocument1() {
        IQVIA_Agreement__c agreementUSBU = [SELECT Id, Name FROM IQVIA_Agreement__c WHERE Name = 'Test USBU' LIMIT 1];
        AgreementWrapper agrWrapper = new AgreementWrapper();
        agrWrapper.iqviaAgreement = agreementUSBU;
        agrWrapper.contentVersionIds = new List<Id>{TST_CLM_TestDataFactory.createContentVersion(true).Id};
        agrWrapper.docType = 'Test Document';
        
        Test.startTest();
            List<ContentVersion> contDocList = UTL_CLM.createContentDocument(agrWrapper);
        Test.stopTest();
        
        List<ContentDocumentLink> cdl = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: agreementUSBU.Id AND ContentDocumentId =: contDocList[0].ContentDocumentId LIMIT 1];
        System.assertEquals(cdl[0].ContentDocumentId, contDocList[0].ContentDocumentId, 'Content version should get created');        
    }
    
    @isTest
    private static void testUploadFiles() {
        IQVIA_Agreement__c agreement = [SELECT Id FROM IQVIA_Agreement__c WHERE Name = 'Test USBU' LIMIT 1];
        ContentVersion cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Title = 'Test Content Version' LIMIT 1];
        FileWrapper fileWrap = new FileWrapper();
        fileWrap.title = 'Title';
        fileWrap.id = cv.ContentDocumentId;
        fileWrap.conVerId = cv.Id;
        
        Test.startTest();
            UTL_CLM.uploadFiles(new List<String>{JSON.serialize(new List<FileWrapper>{fileWrap}) + '~descr'}, agreement.Id);
        Test.stopTest();
        
        List<ContentDocumentLink> cdl = [SELECT Id, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: agreement.Id LIMIT 1];
        System.assertEquals(cdl.isEmpty(), false, 'The content document link should be created');
    }
    
    @isTest
    private static void testAssignOwnerBasedOnAgreementTeam() {
        Map<Id, String> updatedAgrToOwnerMap = new Map<Id, String>();
        Map<Id, String> agreementToOwnerMap = new Map<Id, String>();
        Map<Id, IQVIA_Agreement__c> idToAgreementMap = new Map<Id, IQVIA_Agreement__c>([SELECT Id, Name, OwnerId FROM IQVIA_Agreement__c]);
        if(!idToAgreementMap.isEmpty()){
            for(IQVIA_Agreement__c iqagr: idToAgreementMap.values()){
                agreementToOwnerMap.put(iqagr.Id, iqagr.OwnerId);
            }
        }

        Test.startTest();
            updatedAgrToOwnerMap = UTL_CLM.assignOwnerBasedOnAgreementTeam(agreementToOwnerMap.KeySet());
        Test.stopTest();
        
        if(!updatedAgrToOwnerMap.isEmpty()){
            for(Id agrId: updatedAgrToOwnerMap.KeySet()){
                if(idToAgreementMap.get(agrId).Name == 'Test USBU 3'){
                    System.assertEquals(agreementToOwnerMap.get(agrId), updatedAgrToOwnerMap.get(agrId), 'Owner updated when expected');
                } else {
                    System.assertNotEquals(agreementToOwnerMap.get(agrId), updatedAgrToOwnerMap.get(agrId), 'Owner not updated when expected');
                }
            }
        }
    }

    @isTest
    private static void testAmendIQVIAAgreement() {
        IQVIA_Agreement__c agr = [SELECT Id, Name, Subtype__c, Version_Number__c, Legal_Entity_1__c, Primary_Business_Line1__c, OwnerId, Requestor__c, Perpetual__c, Contract_Start_Date__c, Contract_End_Date__c, Related_Opportunity__c, Status__c FROM IQVIA_Agreement__c WHERE Name = 'Test USBU' LIMIT 1];
        AgreementWrapper agrWrap = new AgreementWrapper();
        agrWrap.iqviaAgreement = agr;
        agrWrap.action = 'IQVIA_AMEND_BY_FLOW';
        
        Test.startTest();
            UTL_CLM.amendIQVIAAgreement(agrWrap);
        Test.stopTest();
        
        List<IQVIA_Agreement__c> agrList = [SELECT Id FROM IQVIA_Agreement__c WHERE Agreement_Cloned_From__c=:agr.Id];
        System.assertEquals(false, agrList.isEmpty(), 'The cloned agreement should be created');
    }

    @isTest
    private static void testCreateActivityOnIQAmend() {   
        Test.startTest();
            IQVIA_Agreement__c agr = [SELECT Id, FF_Agreement_Number__c, Version_Number__c, Agreement_Cloned_From__c FROM IQVIA_Agreement__c WHERE Name = 'Test USBU' LIMIT 1];
            UTL_CLM.createActivityOnIQAmend(new List<IQVIA_Agreement__c>{agr});
        Test.stopTest();
        
        Integer count = [SELECT count() FROM Task WHERE Subject Like '%Amended From agreement%' OR Subject Like '%Amended Agreement%'];
        System.assertEquals(2, count, 'Tasks must be created');
    }

    @isTest
    private static void testGenerateDocument() {
        Apttus__APTS_Agreement__c agreement = [SELECT Id, Name, Apttus__Agreement_Number__c, Apttus__Version_Number__c FROM Apttus__APTS_Agreement__c WHERE Name = 'Test RWSSOW Agreement'];
        Apttus__APTS_Template__c templateRec = [SELECT Id, Name FROM Apttus__APTS_Template__c WHERE Name LIKE 'SCC Remediation'];
        
        Test.startTest();
        	String docVersionId = UTL_CLM.generateDocument(agreement.Id, templateRec.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, docVersionId, 'doc version not returned when expected');
    }
    
    @isTest
    private static void testCreateDocumentVersion() {
        Apttus__APTS_Agreement__c agreement = [SELECT Id, Name, Apttus__Agreement_Number__c, Apttus__Version_Number__c FROM Apttus__APTS_Agreement__c WHERE Name = 'Test RWSSOW Agreement'];
        Apttus__APTS_Template__c templateRec = [SELECT Id, Name FROM Apttus__APTS_Template__c WHERE Name LIKE 'SCC Remediation'];
        
        Test.startTest();
        	String docVersionId = UTL_CLM.createDocumentVersion(agreement.Id, templateRec.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, docVersionId, 'doc version not returned when expected');
    }

    @isTest
    private static void testGetAgreementMapFromCD() {
        IQVIA_Agreement__c agreement = [SELECT Id, Name  FROM IQVIA_Agreement__c WHERE Name = 'Test USBU'];
        Id cdId = [SELECT ContentDocumentId From ContentVersion WHERE Title = 'Test Content Version'].get(0).ContentDocumentId;
        agreement.Status_Category__c = 'In Effect';
        agreement.Status__c = 'Activated';
        update agreement;
        
        Test.startTest();
            Map<Id,IQVIA_Agreement__c> mapofIQAGR = UTL_CLM.getAgreementMapFromCD(new Set<Id>{cdId}, new Map<Id, Id>());
        Test.stopTest();
        
        System.assertNotEquals(null, mapofIQAGR, 'agreement map not returned when expected');
    }

    @isTest
    private static void testExcludeFieldsFromCloningFromAGRLifeCycle() {
        Apttus__APTS_Agreement__c agreement = [SELECT Apttus__Perpetual__c, Apttus__Activated_Date__c, RecordTypeId FROM Apttus__APTS_Agreement__c 
            WHERE Name = 'Test PSA Agreement GSA' LIMIT 1];  
                  
        Test.startTest();
            UTL_CLM.excludeFieldsFromCloningWhileAmendingAgreement(CON_CLM.AGREEMENT_OBJECT_API_NAME, agreement);
        Test.stopTest();
        
        System.assertEquals(false, agreement.Apttus__Perpetual__c, 'The perpetual field should have false value');
        System.assertEquals(null, agreement.Apttus__Activated_Date__c, 'The activated date field should have null value');
    }
    
    @isTest
    private static void testGetServicesFromOpportunity() {
        Opportunity opportunity = [SELECT Id FROM Opportunity LIMIT 1];  

        Test.startTest();
            String services = UTL_CLM.getServicesFromOpportunity(opportunity.Id);
        Test.stopTest();

        System.assertNotEquals('', services, 'Services should not be null');
    }

    @isTest
    public static void testUpdatePFM() {
        Apttus__APTS_Agreement__c agr = [Select Id, Legal_Entity_1__c, Therapy_Area__c, Apttus__Account__c, Parent_Account__c, IQVIA_Project_Finance_Manager__c 
        From Apttus__APTS_Agreement__c Where Name = 'Test RWLP Agreement' Limit 1];
        
        Test.startTest();
            String pfm = UTL_CLM.getDefaultPFM(agr.Legal_Entity_1__c, agr.Therapy_Area__c, agr.Apttus__Account__c, agr.Parent_Account__c);
        Test.stopTest();
        
        System.assertEquals(true, pfm != null, 'PFM Should not be null');
    }
    
    @isTest
    private static void testCloneAgreementTeamOnAmendment() {
        Apttus__APTS_Agreement__c initialAgr = [SELECT Id FROM Apttus__APTS_Agreement__c WHERE Name = 'Test AMA' LIMIT 1];
        Apttus__APTS_Agreement__c finalAgr = [SELECT Id FROM Apttus__APTS_Agreement__c WHERE  Name = 'Test RWLP Agreement' LIMIT 1];
        
        Test.startTest();
            UTL_CLM.cloneAgreementTeamOnAmendment(initialAgr.Id, finalAgr.Id);
        Test.stopTest();
        
        List<Agreement_Contacts__c> lstAgrCon = [SELECT Id FROM Agreement_Contacts__c WHERE Agreement__c=: finalAgr.Id];
        Assert.isTrue(!lstAgrCon.isEmpty(), 'Agreement team should be cloned.');
    }
    
    @isTest
    private static void testCreateAgreementRepositoryForOpportunity() {
        Opportunity selectedOpp = [SELECT Id, AR_Comments__c, AccountId FROM Opportunity LIMIT 1];
        
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Test Content';      
        contentVersion.PathOnClient = 'Test Content.pdf';
        contentVersion.VersionData = Blob.valueOf('Test Content'); 
        insert contentVersion;
        
        String jsonContentVersion = '{"FileExtension":"Opportunity","Title":"Test Content","Id":"' + 
            contentVersion.Id +'","Description":"UploadedFile","FileType":"ContentVersion"}';
        ContentVersion contentVersion1 = (ContentVersion)JSON.deserialize(jsonContentVersion, ContentVersion.class);
        AgreementWrapper agreementWrapper = new AgreementWrapper();
        agreementWrapper.contentVersion = contentVersion1;
        agreementWrapper.Opportunity = selectedOpp;
            
        Test.startTest();
            Id agreementRepositoryId = UTL_CLM.createAgreementRepository(agreementWrapper);
        Test.stopTest();
        
        Opportunity updatedOpp = [SELECT Id, AR_Comments__c FROM Opportunity WHERE Id = :selectedOpp.Id];
        System.assertNotEquals(null, agreementRepositoryId, 'agreementRepositoryId should not be null');
    }

    @isTest
    private static void testCreateAgreementRepositoryForBNF() {
        Opportunity selectedOpp = [SELECT Id, AccountId FROM Opportunity LIMIT 1];
       
        BNF2__c TestBnf = new BNF2__c(Opportunity__c = selectedOpp.Id);
        insert TestBnf;
        
        Attachment attachment = TST_CLM_TestDataFactory.createAttachment(TestBnf.Id, 'Test Content.pdf', false);
        attachment.OwnerId = UserInfo.getUserId();
        attachment.body= Blob.valueOf('Test Body');
        insert attachment;
        
        String jsonContentVersion = '{"FileExtension":"BNF","Title":"Test Content","Id":"' + 
            attachment.Id +'","Description":"BNF","FileType":"Attachment"}';
        ContentVersion contentVersion1 = (ContentVersion)JSON.deserialize(jsonContentVersion, ContentVersion.class);
        AgreementWrapper agreementWrapper = new AgreementWrapper();
        agreementWrapper.contentVersion = contentVersion1;
        agreementWrapper.BNF = TestBnf;
        agreementWrapper.Opportunity = selectedOpp;
            
        Test.startTest();
            Id agreementRepositoryId = UTL_CLM.createAgreementRepository(agreementWrapper);
        Test.stopTest();
        
        BNF2__c updatedBNF = [SELECT Id, AR_Comments__c FROM BNF2__c WHERE Id = :TestBnf.Id];
        System.assertNotEquals(null, agreementRepositoryId, 'agreementRepositoryId should not be null');
    }

    @isTest
    private static void testIsNonInflightAgreement() {
        Apttus__APTS_Agreement__c agreement = [SELECT Apttus__Perpetual__c, Apttus__Activated_Date__c, RecordTypeId,IQVIA_Quote__c FROM Apttus__APTS_Agreement__c 
            WHERE Name = 'Test PSA Agreement GSA' LIMIT 1]; 
        agreement.Apttus__Status_Category__c = 'In Effect';
        agreement.Apttus__Status__c = 'Activated';
        update agreement;
       
        Test.startTest();
            AgreementWrapper.CPQCLMWrapper wrapper = UTL_CLM.isNonInflightAgreement(agreement.IQVIA_Quote__c);
        Test.stopTest();
        
        System.assertEquals(true, wrapper.hasAGRAccess, 'hasAGRAccess is false when not expected');
        System.assertEquals(true, wrapper.hasRelatedAgreement, 'hasRelatedAgreement is false when not expected');
        System.assertEquals(true, wrapper.isNonInflightAgreement, 'isNonInflightAgreement is false when not expected');
    }
    
    @isTest
    private static void testValidateAgreement() {
        Apttus__APTS_Agreement__c agreement = [SELECT Apttus__Perpetual__c, Apttus__Activated_Date__c, RecordTypeId,Apttus__Related_Opportunity__c FROM Apttus__APTS_Agreement__c 
            WHERE Name = 'Test PSA Agreement GSA' LIMIT 1]; 
        agreement.Apttus__Status_Category__c = 'In Effect';
        agreement.Apttus__Status__c = 'Activated';
        update agreement;
       
        Test.startTest();
            AgreementWrapper.CPQCLMWrapper wrapper = UTL_CLM.validateAgreement(new Set<Id> {agreement.Apttus__Related_Opportunity__c});
        Test.stopTest();
        
        System.assertEquals(true, wrapper.activatedPSAFound, 'activatedPSAFound is false when not expected');
        System.assertEquals(false, wrapper.oppToInFlightAgrMap.isEmpty(), 'hasRelatedAgreement is false when not expected');
    }

    @isTest
    private static void testGetRelatedAGRs() {
        
        Apttus__APTS_Agreement__c agreement = [SELECT Apttus__Perpetual__c, Apttus__Activated_Date__c, RecordTypeId,Apttus__Related_Opportunity__c, IQVIA_Quote__c FROM Apttus__APTS_Agreement__c 
            WHERE Name = 'Test PSA Agreement GSA' LIMIT 1]; 
        
        Test.startTest();
            Map<Id, Apttus__APTS_Agreement__c> mapAGR = UTL_CLM.getRelatedAGRs(new Set<String> {'Id', 'Name', 'IQVIA_Quote__c'}, 'IQVIA_Quote__c IN: agreementIds', new Set<Id> {agreement.IQVIA_Quote__c});
        Test.stopTest();
        
        System.assertEquals(false, mapAGR.isEmpty(), 'Map is empty when expected');
    }

    @isTest
    private static void testGetRelatedAGRFromProposal() {
        Apttus__APTS_Agreement__c agreement = [SELECT Apttus__Perpetual__c, Apttus__Activated_Date__c, RecordTypeId,Apttus__Related_Opportunity__c, IQVIA_Quote__c FROM Apttus__APTS_Agreement__c 
            WHERE Name = 'Test PSA Agreement GSA' LIMIT 1]; 
        
        Test.startTest();
            AgreementWrapper.CPQCLMWrapper wrapper = UTL_CLM.getRelatedAGRFromProposal(new Set<String> {'Id', 'Name', 'IQVIA_Quote__c'}, 'IQVIA_Quote__c IN: agreementIds', new Set<Id> {agreement.IQVIA_Quote__c});
        Test.stopTest();

        System.assertEquals(true, wrapper.hasAGRAccess, 'Boolean is false when not expected');
        System.assertEquals(false, wrapper.mapOfPropIdAGR.isEmpty(), 'Map is empty when not expected');
    }
}