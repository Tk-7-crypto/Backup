@isTest
public class TST_DAOH_CLM_APTS_Agreement {

    @TestSetup
    static void dataSetup() {
        Log_Setting__c logSetting = new Log_Setting__c();
        logSetting.Name = 'CLM';
        logSetting.Severity_Level__c = 'INFO';
        logSetting.Log_Data_to_keep_for__c = 10;
        insert logSetting;

        Account account = UTL_TestData.createAccount();
        insert account;
        
        Contract contract = new Contract();
        contract.Name = 'Test Contract';
        contract.AccountId = account.Id;
        insert contract; 

        String file1 = 'Test Content'; 
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.ContentLocation = 'S';
        contentVersion.PathOnClient = 'ionicLogo.png';
        contentVersion.Title = 'Test Title';
        contentVersion.VersionData = EncodingUtil.base64Decode(file1);
        insert contentVersion;
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:contentVersion.Id].ContentDocumentId;
        
        ContentDocumentLink contentLink=new ContentDocumentLink();
        contentLink.LinkedEntityId = contract.Id; 
        contentLink.ContentDocumentId = conDoc;
        contentLink.Visibility = 'AllUsers';
        contentLink.ShareType = 'V';
        insert contentLink;

        CLM_Configuration__c clmConfiguration = TST_CLM_TestDataFactory.createClmConfigurationSetting(false);
        clmConfiguration.RecordTypeForStatusAutomation__c = 'PSA;MSA';
        clmConfiguration.User_Names_For_Notification__c = 'Oana Borse;';
        clmConfiguration.Triage_Team_Email__c = 'abc@example.com';
        insert clmConfiguration; 
        
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity newOpportunity = TST_CLM_TestDataFactory.createOpportunity(false);
        newOpportunity.stageName = '1. Identifying Opportunity';
        oppList.add(newOpportunity);
        Opportunity newOpportunity2 = TST_CLM_TestDataFactory.createOpportunity(false);
        newOpportunity2.stageName = '1. Identifying Opportunity';
        oppList.add(newOpportunity2);
        Opportunity newOpportunity3 = TST_CLM_TestDataFactory.createOpportunity(false);
        newOpportunity3.stageName = '5. Finalizing Deal Stage Entry';
        oppList.add(newOpportunity3);
        insert oppList;
        
        List<Apttus_Proposal__Proposal__c> proposalList = new List<Apttus_Proposal__Proposal__c>();
        Apttus_Proposal__Proposal__c budget = TST_CLM_TestDataFactory.createProposalQuote(false);
        budget.RecordTypeId = CON_CLM.QUOTE_RDS_BUDGET_RECORDTYPE;
        budget.Apttus_Proposal__Opportunity__c = newOpportunity.Id;
        budget.Apttus_Proposal__Primary__c = true;
        budget.Budget_Template_Name__c = 'budget1';          
        budget.Apttus_Proposal__Proposal_Category__c = CON_CLM.PROPOSAL_INITIAL;
        budget.Scenario_Number__c = 123.0;
        budget.Budget_Iteration__c = 1;
        budget.Select_Pricing_Tool__c = 'CPQ_UPT';
        budget.Apttus_QPConfig__ConfigurationFinalizedDate__c = Date.today();
        proposalList.add(budget);
        Apttus_Proposal__Proposal__c budget2 = TST_CLM_TestDataFactory.createProposalQuote(false);
        budget2.RecordTypeId = CON_CLM.QUOTE_RDS_BUDGET_RECORDTYPE;
        budget2.Apttus_Proposal__Opportunity__c = newOpportunity2.Id;
        budget2.Apttus_Proposal__Primary__c = true;
        budget2.Apttus_Proposal__Proposal_Category__c = CON_CLM.PROPOSAL_CHANGE_ORDER;
        budget2.Scenario_Number__c = 123.0;
        budget2.Budget_Iteration__c = 1;
        budget2.Select_Pricing_Tool__c = 'CPQ_UPT';
        proposalList.add(budget2);
        Apttus_Proposal__Proposal__c budget3 = TST_CLM_TestDataFactory.createProposalQuote(false);
        budget3.RecordTypeId = CON_CLM.QUOTE_RDS_BUDGET_RECORDTYPE;
        budget3.Apttus_Proposal__Opportunity__c = newOpportunity3.Id;
        budget3.Apttus_Proposal__Primary__c = true;
        budget3.Apttus_Proposal__Proposal_Category__c = CON_CLM.PROPOSAL_PRELIMINARY;
        budget3.Scenario_Number__c = 123.0;
        budget3.Budget_Iteration__c = 1;
        budget3.Select_Pricing_Tool__c = 'CPQ_UPT';
        budget3.Apttus_QPConfig__ConfigurationFinalizedDate__c = Date.today();
        proposalList.add(budget3);
        Apttus_Proposal__Proposal__c budget4 = TST_CLM_TestDataFactory.createProposalQuote(false);
        budget4.RecordTypeId = CON_CLM.QUOTE_RDS_NON_SF_RECORDTYPE;
        budget4.Apttus_Proposal__Opportunity__c = newOpportunity3.Id;
        budget4.Apttus_Proposal__Primary__c = true;
        budget4.Apttus_Proposal__Proposal_Category__c = CON_CLM.PROPOSAL_PROJECT_SPECIFIC;
        budget4.Scenario_Number__c = 123.0;
        budget4.Budget_Iteration__c = 1;
        budget4.Select_Pricing_Tool__c = 'Non SF Unit Pricing Tool';
        budget4.Apttus_QPConfig__ConfigurationFinalizedDate__c = Date.today();    
        proposalList.add(budget4);    
        Apttus_Proposal__Proposal__c budget5 = TST_CLM_TestDataFactory.createProposalQuote(false);
        budget5.RecordTypeId = CON_CLM.QUOTE_RDS_BUDGET_RECORDTYPE;
        budget5.Apttus_Proposal__Opportunity__c = newOpportunity3.Id;
        budget5.Apttus_Proposal__Primary__c = true;
        budget5.Apttus_Proposal__Proposal_Category__c = CON_CLM.PROPOSAL_PRELIMINARY;
        budget5.Scenario_Number__c = 123.0;
        budget5.Budget_Iteration__c = 1;
        budget5.Select_Pricing_Tool__c = 'CPQ_UPT';
        proposalList.add(budget5);            
        insert proposalList;
        
        List<User> salesUserList = UTL_TestData.createUser('Sales User',2);
        salesUserList.get(0).LastName = 'Test Sales User';
        salesUserList.get(1).LastName = 'Oana Borse';
        User salesUser = salesUserList.get(0);
        insert salesUserList;

        IQVIA_Agreement__c IQAgr = TST_CLM_TestDataFactory.createIQAgreement(CON_CLM.USBU_IQVIA_RECORDTYPEID, false);
        IQAgr.Name = 'Test IQVIA Agreement';
        insert IQAgr;
        
        List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(null, false);
        agreement.Name = 'Test Agreement';
        agreementList.add(agreement);

        Apttus__APTS_Agreement__c agreementAMESA = TST_CLM_TestDataFactory.createAgreement(CON_CLM.AMESA_RECORDTYPEID, false);
        agreementAMESA.Name = 'Test AMESA Agreement';
        agreementAMESA.Apttus__Account__c = TST_CLM_TestDataFactory.createAccount('TEST AMESA ACCOUNT', true).Id;
        agreementList.add(agreementAMESA);

        Apttus__APTS_Agreement__c agreementOutPutFormat = TST_CLM_TestDataFactory.createAgreement(null, false);
        agreementOutPutFormat.Name = 'Test Agreement Output Format';
        agreementOutPutFormat.Apttus__AllowableOutputFormats__c = 'PDF;DOCX';
        agreementList.add(agreementOutPutFormat);
        
        Apttus__APTS_Agreement__c oldAgreementOutPutFormat = TST_CLM_TestDataFactory.createAgreement(null, false);
        oldAgreementOutPutFormat.Name = 'Test Agreement Output Format 2';
        oldAgreementOutPutFormat.Apttus__AllowableOutputFormats__c = 'DOCX';
        agreementList.add(oldAgreementOutPutFormat);
        
        Apttus__APTS_Agreement__c oldAgreement = TST_CLM_TestDataFactory.createAgreement(null, false);
        oldAgreement.Name = 'Test Agreement - Rapid SOW';
        oldAgreement.Apttus__Status_Category__c = 'In Authoring';
        oldAgreement.Apttus__Status__c = 'Language Approved';
        agreementList.add(oldAgreement);
        
        Apttus__APTS_Agreement__c oldAgreement1 = TST_CLM_TestDataFactory.createAgreement(null, false);
        oldAgreement1.Name = 'Old Agreement PSA';
        oldAgreement1.Apttus__Status_Category__c = 'Request';
        oldAgreement1.Apttus__Status__c = 'Request';
        oldAgreement1.RecordTypeId = CON_CLM.PSA_RECORDTYPEID;
        oldAgreement1.Late_Payment_Clause__c = 'Within fallbacks';
        oldAgreement1.Confidence_In_Approval_Of_Budget_Draft__c = 'High';
        oldAgreement1.High_Confidence_Budget_Link1__c = 'xyz.com';
        oldAgreement1.Select_Pricing_Tool__c = 'CPQ_UPT';
        oldAgreement1.Contracts_Component__c = 'Single service/Fees <$1M/No TPV';
        oldAgreement1.Project_Leader_Region__c = 'Asia Pacific';
        agreementList.add(oldAgreement1);
        
        Apttus__APTS_Agreement__c oldAgreement2 = TST_CLM_TestDataFactory.createAgreement(null, false);
        oldAgreement2.Name = 'Old Agreement PA';
        oldAgreement2.Apttus__Status_Category__c = 'Request';
        oldAgreement2.Apttus__Status__c = 'Request';
        oldAgreement2.RecordTypeId = CON_CLM.PRELIMINARY_RECORDTYPEID;
        agreementList.add(oldAgreement2);
        
        Apttus__APTS_Agreement__c agreementServiceFormat = TST_CLM_TestDataFactory.createAgreement(null, false);
        agreementServiceFormat.Name = 'Test Agreement Services Formatted';
        agreementServiceFormat.Services__c = 'Clinical Trial Services;Data Management;IQVIA Technology Services';
        agreementList.add(agreementServiceFormat);
        
        Apttus__APTS_Agreement__c psaAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        psaAgreement.Name = 'Test Initial Draft Agreement';
        psaAgreement.Apttus__Status__c = 'Other Party Review';
        psaAgreement.Confidence_In_Approval_Of_Budget_Draft__c = 'High';
        psaAgreement.High_Confidence_Budget_Link1__c = 'xyz.com';
        psaAgreement.Actual_Agreement_Value__c = 500;
        psaAgreement.Project_Expenses__c = 300;
        psaAgreement.Concessions_Discussion__c = 'Yes';
        psaAgreement.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_CHANGEORDER;
        agreementList.add(psaAgreement);

        Apttus__APTS_Agreement__c parentAgreementPSA = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, true);
        parentAgreementPSA.Name = 'Test Parent Agreement';
        parentAgreementPSA.Apttus__Workflow_Trigger_Created_From_Clone__c = false;
        parentAgreementPSA.Apttus_QPComply__RelatedProposalId__c = budget.Id;
        parentAgreementPSA.Apttus__Agreement_Number__c = '12345';
        parentAgreementPSA.Agreement_Cloned_From__c = null;
        agreementList.add(parentAgreementPSA);

        Apttus__APTS_Agreement__c childAgreementPSA1 = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        childAgreementPSA1.Name = 'Test Child Agreement1';
        childAgreementPSA1.Apttus_QPComply__RelatedProposalId__c = budget4.Id;
        childAgreementPSA1.Agreement_Cloned_From__c = parentAgreementPSA.Id;     
        childAgreementPSA1.Apttus__Agreement_Number__c = parentAgreementPSA.Apttus__Agreement_Number__c;
        childAgreementPSA1.Apttus__Workflow_Trigger_Created_From_Clone__c = false;
        agreementList.add(childAgreementPSA1);
        
        Apttus__APTS_Agreement__c childAgreementPSA2 = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        childAgreementPSA2.Name = 'Test Child Agreement2';
        childAgreementPSA2.Apttus_QPComply__RelatedProposalId__c = budget2.Id;
        childAgreementPSA2.Apttus__Agreement_Number__c = parentAgreementPSA.Apttus__Agreement_Number__c;        
        childAgreementPSA2.Agreement_Cloned_From__c = parentAgreementPSA.Id;
        agreementList.add(childAgreementPSA2);
        
        Apttus__APTS_Agreement__c testAgreementPSA1 = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        testAgreementPSA1.Name = 'Test 4784 Agreement 1';
        testAgreementPSA1.Actual_Agreement_Value__c = 1; 
        testAgreementPSA1.Project_Expenses__c = 2;
        testAgreementPSA1.Is_Study_Awarded__c = 'No';
        testAgreementPSA1.OwnerId = salesUser.Id;
        testAgreementPSA1.Apttus__Status__c = 'Assigned';
        testAgreementPSA1.Apttus__Status_Category__c =  CON_CLM.REQUEST;
        testAgreementPSA1.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_GSA;
        testAgreementPSA1.Apttus__Workflow_Trigger_Viewed_Final__c = false;
        agreementList.add(testAgreementPSA1);
        
        Apttus__APTS_Agreement__c testAgreementPSA2 = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        testAgreementPSA2.Name = 'Test 4784 Agreement 2';
        testAgreementPSA2.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_GSA;
        testAgreementPSA2.Project_Expenses__c = 2;
        agreementList.add(testAgreementPSA2);
        
        Apttus__APTS_Agreement__c testAgreementPSA3 = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        testAgreementPSA3.Name = 'Test 4784 Agreement 3';
        testAgreementPSA3.Apttus__Status__c = CON_CLM.REQUEST;
        testAgreementPSA3.Apttus__Status_Category__c = CON_CLM.REQUEST;        
        testAgreementPSA3.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_CHANGEORDER;        
        testAgreementPSA3.Actual_Agreement_Value__c = 1;
        agreementList.add(testAgreementPSA3);
        
        Apttus__APTS_Agreement__c testAgreementPre1 = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PRELIMINARY_RECORDTYPEID, false);
        testAgreementPre1.Name = 'Test Preliminary Agreement';
        testAgreementPre1.Apttus__Related_Opportunity__c = newOpportunity.Id;
        testAgreementPre1.Select_Pricing_Tool__c = 'CPQ_UPT';
        testAgreementPre1.Apttus_QPComply__RelatedProposalId__c = budget.Id;
        testAgreementPre1.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_ATP;
        testAgreementPre1.Payment_Term__c = 'sixty (60)';
        testAgreementPre1.Apttus__Workflow_Trigger_Viewed_Final__c = false;
        agreementList.add(testAgreementPre1);
        
        Apttus__APTS_Agreement__c testAgreementPre2 = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PRELIMINARY_RECORDTYPEID, false);
        testAgreementPre2.Name = 'Test Preliminary Agreement2';
        testAgreementPre2.Apttus__Related_Opportunity__c = newOpportunity3.Id;
        testAgreementPre2.Select_Pricing_Tool__c = 'CPQ_UPT';
        testAgreementPre2.Apttus_QPComply__RelatedProposalId__c = budget4.Id;
        testAgreementPre2.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_ATP;
        testAgreementPre2.Payment_Term__c = 'sixty (60)';
        agreementList.add(testAgreementPre2);

        Apttus__APTS_Agreement__c testAgreementPSA4 = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        testAgreementPSA4.Name = 'Test 4784 Agreement 4';
        testAgreementPSA4.Apttus_QPComply__RelatedProposalId__c = budget5.Id;
        agreementList.add(testAgreementPSA4);
        
        Apttus__APTS_Agreement__c testAgreementMSA = TST_CLM_TestDataFactory.createAgreement(CON_CLM.MSA_RECORDTYPEID, false);
        testAgreementMSA.Name = 'Test 5597 MSA Agreement';
        testAgreementMSA.Apttus__Status__c=CON_CLM.REQUEST;
        testAgreementMSA.Late_Payment_Clause__c = CON_CLM.WITHIN_FALLBACKS;
        agreementList.add(testAgreementMSA);

        Apttus__APTS_Agreement__c testAgreementMSAPaymentTerm = TST_CLM_TestDataFactory.createAgreement(CON_CLM.MSA_RECORDTYPEID, false);
        testAgreementMSAPaymentTerm.Name = 'Test MSA Agreement Payment Term';
        testAgreementMSAPaymentTerm.Payment_Term__c = 'thirty (30)';
        agreementList.add(testAgreementMSAPaymentTerm);

        Apttus__APTS_Agreement__c testAgreementPSAPaymentTerm = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        testAgreementPSAPaymentTerm.Name = 'Test PSA Agreement Payment Term';
        testAgreementPSAPaymentTerm.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_WO;
        testAgreementPSAPaymentTerm.Payment_Term__c = 'sixty (60)';
        agreementList.add(testAgreementPSAPaymentTerm);

        Apttus__APTS_Agreement__c testPSAAGRWithOpp = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        testPSAAGRWithOpp.Name = 'Test PSA AGR With Oppr';
        testPSAAGRWithOpp.Actual_Agreement_Value__c = 1;
        testPSAAGRWithOpp.Project_Expenses__c = 2;
        testPSAAGRWithOpp.Apttus__Related_Opportunity__c = newOpportunity2.Id;
        testPSAAGRWithOpp.Apttus_QPComply__RelatedProposalId__c = budget2.Id; 
        agreementList.add(testPSAAGRWithOpp);

        Apttus__APTS_Agreement__c psaAgreementIniDraft = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        psaAgreementIniDraft.Name = 'Test Initial Draft Agreement';
        psaAgreementIniDraft.Apttus__Status__c = 'Other Party Review';
        psaAgreementIniDraft.Confidence_In_Approval_Of_Budget_Draft__c = 'High';
        psaAgreementIniDraft.High_Confidence_Budget_Link1__c = 'xyz.com';
        psaAgreementIniDraft.Actual_Agreement_Value__c = 500;
        psaAgreementIniDraft.Project_Expenses__c = 300;
        agreementList.add(psaAgreementIniDraft);
        
        Apttus__APTS_Agreement__c testAgreementPSA5 = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        testAgreementPSA5.Name = 'Test 10237 Agreement';
        testAgreementPSA5.Is_Study_Awarded__c = 'Yes';
        testAgreementPSA5.OwnerId = salesUser.Id;
        agreementList.add(testAgreementPSA5);

        Apttus__APTS_Agreement__c testAgreementAMA = TST_CLM_TestDataFactory.createAgreement(CON_CLM.AMA_RECORDTYPEID, false);
        testAgreementAMA.Name = 'AMA Agreement';
        agreementList.add(testAgreementAMA);

        Apttus__APTS_Agreement__c testAgreementAMAAmend = TST_CLM_TestDataFactory.createAgreement(CON_CLM.AMA_RECORDTYPEID, false);
        testAgreementAMAAmend.Name = 'AMA Agreement Amend';
        agreementList.add(testAgreementAMAAmend);
        
        Apttus__APTS_Agreement__c testAMAAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.AMA_RECORDTYPEID, false);
        testAMAAgreement.Name = 'Test AMA Agreement';
        agreementList.add(testAMAAgreement);

        Apttus__APTS_Agreement__c osaAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.OSA_RECORDTYPEID, false);
        osaAgreement.Name = 'Test OSA Agreement';
        agreementList.add(osaAgreement);

        Apttus__APTS_Agreement__c testRWSSowAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.RWS_RECORDTYPEID, false);
        testRWSSowAgreement.Name = 'Test RWS Agreement';
        agreementList.add(testRWSSowAgreement);

        Apttus__APTS_Agreement__c testRWLPAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.RWLP_RECORDTYPEID, false);
        testRWLPAgreement.Name = 'Test RWLP Agreement';
        testRWLPAgreement.Apttus__Related_Opportunity__c = newOpportunity.Id;
        agreementList.add(testRWLPAgreement);
        
        Apttus__APTS_Agreement__c testVendorAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.VENDOR_RECORDTYPEID, false);
        testVendorAgreement.Name = 'Test Vendor Agreement';
        testVendorAgreement.Apttus__Subtype__c = 'Work Order';
        testVendorAgreement.Apttus__Related_Opportunity__c = newOpportunity.Id;
        agreementList.add(testVendorAgreement);

        Apttus__APTS_Agreement__c testGenericAGR = TST_CLM_TestDataFactory.createAgreement(CON_CLM.GENERIC_RECORDTYPEID, false);
        testGenericAGR.Name = 'Test Generic Agreement';
        testGenericAGR.IQVIA_Agreement__c = IQAgr.Id;
        agreementList.add(testGenericAGR);
        
        Test.startTest();
            Trigger_Control_For_Migration__c tc = new Trigger_Control_For_Migration__c();
            tc.Disable_Agreement_Flows__c = true;
            tc.Disable_Bid_History_Trigger__c = true;
            tc.Disable_RR_Trigger__c = true;
            tc.Disable_Assignment_Trigger__c = true;
            tc.Disable_Project_Trigger__c = true;
            Bid_History__c bid = TST_CLM_TestDataFactory.createBidHistory(
            CON_CLM.CONTRACT_POST_AWARD_BID_HISTORY_RECORD_TYPE_ID, newOpportunity3.Id, true);
            insert tc;
            upsert agreementList;
            
            pse__Grp__c grp = [SELECT Id FROM pse__Grp__c LIMIT 1];
            List<Contact> lstOfContacts = new List<Contact>();  
            lstOfContacts.add(new Contact(AccountId = account.Id, FirstName = 'Test', LastName = 'Internal', 
                RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('IQVIA User Contact').getRecordTypeId(),
                EmployeeNumber__c = '1234567', Sub_Group__c ='GBO-Lead PD', pse__Is_Resource__c = true, pse__Is_Resource_Active__c = true,
                pse__Group__c = grp.Id, pse__Salesforce_User__c = UserInfo.getUserId(), Available_for_Triage_Flag__c = true));
            lstOfContacts.add(new Contact(AccountId = account.Id, FirstName = 'Test', LastName = 'External', 
                RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Contact').getRecordTypeId()));
            insert lstOfContacts;
            
            pse__Proj__c project = new pse__Proj__c();
            project.name = 'Bid Project';
            project.pse__Start_Date__c = system.today().addDays(-30);
            project.pse__End_Date__c = system.today().addDays(10); 
            project.pse__Group__c = grp.Id;
            project.RecordTypeId = Schema.SObjectType.pse__Proj__c.getRecordTypeInfosByDeveloperName().get('RDS_Service_Line').getRecordTypeId();
            project.Bid_History__c = bid.Id;
            project.pse__Account__c = account.Id;
            insert project;
            
            pse__Resource_Request__c resourceRequest = UTL_OWF_TestData.createResourceRequestForBidHistory(bid.Id, newOpportunity3.Id, project.Id);
            resourceRequest.pse__Group__c = grp.Id;
            resourceRequest.pse__Status__c = CON_OWF.OWF_STATUS_ASSIGNED;
            resourceRequest.pse__Start_Date__c = System.today() + 10;
            resourceRequest.SubGroup__c = 'GBO-Lead PD';
            insert resourceRequest;   
            
            pse__Assignment__c assignment = new pse__Assignment__c(Name = 'Test OWF Assignment', Bid_History__c = bid.Id, pse__Project__c = project.Id,
                pse__Resource__c = lstOfContacts[0].Id, pse__Resource_Request__c = resourceRequest.id,  
                pse__Status__c = 'Accepted', pse__Bill_Rate__c = 0 ,
                RecordTypeId = Schema.SObjectType.pse__Assignment__c.getRecordTypeInfosByName().get('OWF Assignment').getRecordTypeId());   
            insert assignment;
            
            resourceRequest.pse__Assignment__c = assignment.Id;
            update resourceRequest;
        Test.stopTest();

        CLM_Field_Mappings__c agrQuoteCustomSetting = TST_CLM_TestDataFactory.createClmAgreementQuoteFieldMappingSetting(true);
        Apttus__DocumentVersion__c documentVersion = new Apttus__DocumentVersion__c();
        documentVersion.Apttus__IsTransient__c = false;
        documentVersion.Apttus__Title__c = 'test document';
        documentVersion.Apttus__LatestVersion__c = '1.0.0';
        documentVersion.Apttus__AgreementId__c = testRWLPAgreement.Id;
        insert documentVersion;

        Apttus__DocumentVersionDetail__c documentVersionDetail = new Apttus__DocumentVersionDetail__c();
        documentVersionDetail.Apttus__DocumentVersionId__c = documentVersion.Id;
        documentVersionDetail.Apttus__IsTransient__c = false;
        documentVersionDetail.Apttus__Title__c = 'test document';
        documentVersionDetail.Apttus__VersionMajor__c = 1;
        documentVersionDetail.Apttus__VersionMinor__c = 0;
        documentVersionDetail.Apttus__VersionRevision__c = 0;
        insert documentVersionDetail;

        ContentDocumentLink cdl = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId =: contract.Id Limit 1];
        ContentDocumentLink cdlForDVD = cdl.clone(false, true, false, false);
        cdlForDVD.LinkedEntityId = documentVersionDetail.Id;
        insert cdlForDVD;

        documentVersion.Apttus__LatestVersionId__c = documentVersionDetail.Id;
        update documentVersion; 
    }

    @isTest
    private static void testUpdateGenerateStatuses() {
        Apttus__APTS_Agreement__c oldAgreement = [SELECT Id, Name, Apttus__Status_Category__c, Apttus__Status__c, RecordTypeId, Apttus__Workflow_Trigger_Viewed_Final__c
            FROM Apttus__APTS_Agreement__c WHERE Name = 'Test 4784 Agreement 1'];

        Apttus__APTS_Agreement__c newAgreement = oldAgreement.clone(true, false, false, false);
        newAgreement.Apttus__Status_Category__c = 'In Signatures';
        newAgreement.Apttus__Status__c = 'Ready for Signatures';
        newAgreement.Apttus__Workflow_Trigger_Viewed_Final__c = true;
        Map<Id, Apttus__APTS_Agreement__c> oldMap = new Map<Id, Apttus__APTS_Agreement__c>();
        oldMap.put(oldAgreement.Id, oldAgreement);

        Test.startTest();
            DAOH_CLM_APTS_Agreement.updateGenerateStatuses(new List<Apttus__APTS_Agreement__c>{newAgreement}, oldMap);
        Test.stopTest();
        
        System.assertEquals('In Authoring', newAgreement.Apttus__Status_Category__c, 'Returned status category is not what is expected.');
        System.assertEquals('Author Contract', newAgreement.Apttus__Status__c, 'Returned status is not what is expected.');
    }

    @isTest
    private static void testUpdateTermYearsOnBeforeInsert() {
        List<Apttus__APTS_Agreement__c> newAgreementList = [SELECT id, Name, RecordType.Name, RecordTypeId,
            O_Term_Years__c, Apttus__Term_Months__c FROM Apttus__APTS_Agreement__c LIMIT 1];
        if(newAgreementList != null && newAgreementList.size() > 0) {
            newAgreementList[0].Apttus__Term_Months__c = 36;
        }

        Test.startTest();
            DAOH_CLM_APTS_Agreement.updateTermYears(newAgreementList, null);
        Test.stopTest();
 
        System.assertEquals('three (3)', newAgreementList[0].O_Term_Years__c, 'Term Year is not updated.');
    }

    @isTest
    private static void testUpdateTermYearsOnBeforeUpdate() {
        List<Apttus__APTS_Agreement__c> newAgreementList = new List<Apttus__APTS_Agreement__c>();  

        Apttus__APTS_Agreement__c oldAgreement = [SELECT id, Name, RecordType.Name, RecordTypeId,
            O_Term_Years__c, Apttus__Term_Months__c FROM Apttus__APTS_Agreement__c LIMIT 1];

        Apttus__APTS_Agreement__c oldAgreementClone = oldAgreement.clone(true, false, false, false);
        Map<Id, Apttus__APTS_Agreement__c> oldMap = new Map<Id, Apttus__APTS_Agreement__c>();
        oldAgreement.Apttus__Term_Months__c = 60;
        oldAgreementClone.Apttus__Term_Months__c = 36;
        oldMap.put(oldAgreement.Id, oldAgreementClone);
        newAgreementList.add(oldAgreement);

        Test.startTest();
            DAOH_CLM_APTS_Agreement.updateTermYears(newAgreementList, oldMap);
        Test.stopTest();

        System.assertEquals('five (5)', newAgreementList[0].O_Term_Years__c, 'Term Year is not updated.');
    }

    @isTest
    private static void testUpdateRenewalNoticeDaysOnBeforeInsert() {
        List<Apttus__APTS_Agreement__c> newAgreementList = [SELECT id, Name, RecordType.Name, RecordTypeId,
            Apttus__Renewal_Notice_Days__c, Renewal_Notification_Days__c FROM Apttus__APTS_Agreement__c LIMIT 1];

        Test.startTest();
            DAOH_CLM_APTS_Agreement.updateRenewalNoticeDays(newAgreementList, null);
        Test.stopTest();

        System.assertNotEquals(0, newAgreementList[0].Apttus__Renewal_Notice_Days__c, 'Renewal Notice Days is not updated.');
    }

    @isTest
    private static void testSetAutoRenewFieldOnBeforeInsert(){
        List<Apttus__APTS_Agreement__c> agreementList = [SELECT Id, Name, Apttus__Auto_Renewal__c FROM Apttus__APTS_Agreement__c WHERE Name = 'Test 5597 MSA Agreement' LIMIT 1];
        
        Test.startTest();
        	DAOH_CLM_APTS_Agreement.setAutoRenewField(agreementList, null);
        Test.stopTest();
        
        System.assertEquals(true, agreementList[0].Apttus__Auto_Renewal__c, 'Auto Renew is not updated.');
    }

    @isTest
    private static void testUpdateRenewalNoticeDaysOnBeforeUpdate() {
        List<Apttus__APTS_Agreement__c> newAgreementList = new List<Apttus__APTS_Agreement__c>();  

        Apttus__APTS_Agreement__c oldAgreement = [SELECT id, Name, RecordType.Name, RecordTypeId,
            Apttus__Renewal_Notice_Days__c, Renewal_Notification_Days__c FROM Apttus__APTS_Agreement__c LIMIT 1];

        Apttus__APTS_Agreement__c oldAgreementClone = oldAgreement.clone(true, false, false, false);
        Map<Id, Apttus__APTS_Agreement__c> oldMap = new Map<Id, Apttus__APTS_Agreement__c>();
        oldAgreement.Renewal_Notification_Days__c = 'ninety (90)';
        oldMap.put(oldAgreement.Id, oldAgreementClone);
        newAgreementList.add(oldAgreement);

        Test.startTest();
            DAOH_CLM_APTS_Agreement.updateRenewalNoticeDays(newAgreementList, oldMap);
        Test.stopTest();

        System.assertNotEquals(0, newAgreementList[0].Apttus__Renewal_Notice_Days__c, 'Renewal Notice Days is not updated.');
    }

    @isTest
    private static void testConvertNumberToWords() {
        Integer yearNumber = 3;
        String numberWords = '';

        Test.startTest();
            numberWords = DAOH_CLM_APTS_Agreement.convertNumberToWords(yearNumber);
        Test.stopTest();

        System.assertEquals('three', numberWords, 'The number has been not converted into words.');
    }

    @isTest
    private static void testPopulatePSAInitialDraftFields() {
        Apttus__APTS_Agreement__c psaAgreement = [SELECT Id, Name, Confidence_In_Approval_Of_Budget_Draft__c, Actual_Agreement_Value__c, 
            Project_Expenses__c , Apttus__Status__c, Initial_Draft_At_High_Confidence_Date__c, Initial_Draft_At_High_Confidence_Value__c ,
            Initial_Draft_At_High_Confidence_Expense__c
            FROM Apttus__APTS_Agreement__c WHERE Name = 'Test Initial Draft Agreement' LIMIT 1];
        psaAgreement.Apttus__Status__c = 'Other Party Review';

        Test.startTest();
            DAOH_CLM_APTS_Agreement.populatePSAInitialDraftFields(new List<Apttus__APTS_Agreement__c>{psaAgreement}, null);
        Test.stopTest();

        System.assertEquals(Date.today(), psaAgreement.Initial_Draft_At_High_Confidence_Date__c, 
            'Date must have populated with current date but it is not.');
        System.assertEquals(500, psaAgreement.Initial_Draft_At_High_Confidence_Value__c, 
            'Initial Draft At High Confidence Value must be 500 but it is not.');
        System.assertEquals(300, psaAgreement.Initial_Draft_At_High_Confidence_Expense__c, 
            'Initial Draft At High Confidence Expense must be 300 but it is not.');
    }
    
    @isTest
    private static void testPopulateConcessionFields() {
        Apttus__APTS_Agreement__c psaAgreement = [SELECT Id, Name, Apttus__Subtype__c, Concessions_Discussion__c, Concession_Amount__c, 
            Project_Expenses__c, Apttus__Status__c, Concession_Reason_Category__c
            FROM Apttus__APTS_Agreement__c WHERE Name = 'Test Initial Draft Agreement' LIMIT 1];

        Apttus__APTS_Agreement__c newPsaAgreement = psaAgreement.clone(true, false, false, false);
        newPsaAgreement.Concessions_Discussion__c = 'No';

        Map<Id, Apttus__APTS_Agreement__c> oldMap = new Map<Id, Apttus__APTS_Agreement__c>();
        oldMap.put(psaAgreement.Id, psaAgreement);
        
        Test.startTest();
        	DAOH_CLM_APTS_Agreement.populateConcessionFields(new List<Apttus__APTS_Agreement__c>{newPsaAgreement}, oldMap);
        Test.stopTest();

        System.assertEquals(0, newPsaAgreement.Concession_Amount__c,
            'Concession Amount should be 0.00');
        System.assertEquals('N/A', newPsaAgreement.Concession_Reason_Category__c, 
            'Concession Reason should be N/A');
    }
    @isTest
    private static void testUpdateTotalAgreementValueOnBeforeInsert() {
        List<Apttus__APTS_Agreement__c> newAgreementList = [SELECT id, Name, RecordTypeId, Project_Expenses__c, 
            Actual_Agreement_Value__c, Apttus__Total_Contract_Value__c
            FROM Apttus__APTS_Agreement__c WHERE Name like 'Test 4784 Agreement%'];

        Test.startTest();
            DAOH_CLM_APTS_Agreement.updateTotalAgreementValue(newAgreementList, null);
        Test.stopTest();

        System.assertEquals(3, newAgreementList[0].Apttus__Total_Contract_Value__c, 
            'Total Agreement Value is not updated when both Actual Agreement Value and Project Expenses are populated');
        System.assertEquals(2, newAgreementList[1].Apttus__Total_Contract_Value__c, 
            'Total Agreement Value is not updated when Actual Agreement Value is null and Project Expenses is populated');
        System.assertEquals(1, newAgreementList[2].Apttus__Total_Contract_Value__c, 
            'Total Agreement Value is not updated when Actual Agreement Value is populated and Project Expenses is null');
        System.assertEquals(null, newAgreementList[3].Apttus__Total_Contract_Value__c, 
            'Total Agreement Value is not null when both Actual Agreement Value and Project Expenses are null');
    }
    
    @isTest
    private static void testUpdateTotalAgreementValueOnBeforeUpdate() {
        List<Apttus__APTS_Agreement__c> newAgreementList = new List<Apttus__APTS_Agreement__c>();  

        Apttus__APTS_Agreement__c oldAgreement1 = [SELECT id, Name, RecordTypeId, Project_Expenses__c, 
            Actual_Agreement_Value__c, Apttus__Total_Contract_Value__c
            FROM Apttus__APTS_Agreement__c WHERE Name = 'Test 4784 Agreement 1'];
        
        Apttus__APTS_Agreement__c oldAgreement2 = [SELECT id, Name, RecordTypeId, Project_Expenses__c, 
            Actual_Agreement_Value__c, Apttus__Total_Contract_Value__c
            FROM Apttus__APTS_Agreement__c WHERE Name = 'Test 4784 Agreement 2'];

        Apttus__APTS_Agreement__c oldAgreementClone1 = oldAgreement1.clone(true, false, false, false);
        Map<Id, Apttus__APTS_Agreement__c> oldMap = new Map<Id, Apttus__APTS_Agreement__c>();
        oldAgreement1.Actual_Agreement_Value__c = 4;
        oldAgreement1.Project_Expenses__c = 5;
        oldMap.put(oldAgreement1.Id, oldAgreementClone1);
        newAgreementList.add(oldAgreement1);
        
        Apttus__APTS_Agreement__c oldAgreementClone2 = oldAgreement2.clone(true, false, false, false);
        oldAgreement2.Actual_Agreement_Value__c = null;
        oldAgreement2.Project_Expenses__c = null;
        oldMap.put(oldAgreement2.Id, oldAgreementClone2);
        newAgreementList.add(oldAgreement2);

        Test.startTest();
            DAOH_CLM_APTS_Agreement.updateTotalAgreementValue(newAgreementList, oldMap);
        Test.stopTest();

        System.assertEquals(9, newAgreementList[0].Apttus__Total_Contract_Value__c, 'Total Agreement Value is not updated.');
        System.assertEquals(null, newAgreementList[1].Apttus__Total_Contract_Value__c, 'Total Agreement Value should be null.');
    }
    
    @isTest
    private static void testUpdateAGRFromOpportunity() {
        Id oppId = null;
        Apttus__APTS_Agreement__c oldAgreement = [SELECT Id, Apttus__Related_Opportunity__c
            FROM Apttus__APTS_Agreement__c WHERE Name = 'Test Parent Agreement' LIMIT 1];
        oppId = oldAgreement.Apttus__Related_Opportunity__c;
        oldAgreement.Apttus__Related_Opportunity__c = null;

        Apttus__APTS_Agreement__c newAgreement = oldAgreement.clone(true, false, false, false);
        newAgreement.Apttus__Related_Opportunity__c = oppId;
        Map<Id, Apttus__APTS_Agreement__c> oldMap = new Map<Id, Apttus__APTS_Agreement__c>();
        oldMap.put(oldAgreement.Id, oldAgreement);

        Test.startTest();
            DAOH_CLM_APTS_Agreement.updateAGRFromOpportunity(new List<Apttus__APTS_Agreement__c>{newAgreement}, oldMap);
        Test.stopTest();

        Apttus__APTS_Agreement__c agreement = [SELECT Id,Opportunity_Number__c,Apttus__Related_Opportunity__r.Opportunity_Number__c,
            Project_Number__c, Apttus__Related_Opportunity__r.Legacy_Quintiles_Opportunity_Number__c, Apttus__Related_Opportunity__r.Proposal_Sent_Date__c,
            Rel_Opp_Global_Project_Unit__c, Apttus__Related_Opportunity__r.Global_project_unit__c, Protocol_Number__c,Proposal_Date__c   FROM Apttus__APTS_Agreement__c 
            WHERE Id =: newAgreement.Id LIMIT 1];
        System.assertEquals(agreement.Apttus__Related_Opportunity__r.Opportunity_Number__c, agreement.Opportunity_Number__c, 'Opportunity Number on agreement not matches with Opportunity when expected');
        System.assertEquals(agreement.Apttus__Related_Opportunity__r.Legacy_Quintiles_Opportunity_Number__c, agreement.Project_Number__c, 'Project Number on agreement does not matches with Legacy Quintiles Opportunity Number when expected');
        System.assertEquals(agreement.Apttus__Related_Opportunity__r.Global_project_unit__c, agreement.Rel_Opp_Global_Project_Unit__c, 'Global Project Unit on agreement does not matches with Global Project Unit of Opportunity when expected');
        System.assertEquals(agreement.Apttus__Related_Opportunity__r.Protocol_Number__c, agreement.Protocol_Number__c, 'Protocol Number on agreement does not matches with Protocol Number of Opportunity when expected');
        System.assertEquals(agreement.Apttus__Related_Opportunity__r.Proposal_Sent_Date__c, agreement.Proposal_Date__c, 'Proposal Date on agreement does not matches with Proposal Sent Date of Opportunity when expected');
    }

    @isTest
    private static void testUpdateStatusChangeDateOnAgreement() {
        Apttus__APTS_Agreement__c oldAgreement = [SELECT Id, RecordTypeId, Apttus__Status__c
            FROM Apttus__APTS_Agreement__c WHERE Name = 'Test 4784 Agreement 4' LIMIT 1];
        Map<Id, Apttus__APTS_Agreement__c> oldMap = new Map<Id, Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c newAgreement = oldAgreement.clone(true, false, false, false);
        oldMap.put(oldAgreement.Id, oldAgreement);
        newAgreement.Apttus__Status__c = CON_CLM.IN_EFFECT;
        
        Test.startTest();
            DAOH_CLM_APTS_Agreement.updateStatusChangeDateOnAgreement(new List<Apttus__APTS_Agreement__c>{newAgreement}, oldMap);
        Test.stopTest();
        
        System.assertEquals(System.today(), newAgreement.Status_Change_Date__c, 'Returned value is not expected.');
    }
    
    @isTest
    private static void testUpdateGenerateStatusesForPreliminary() {
        Apttus__APTS_Agreement__c oldAgreement = [SELECT Id, Name, Apttus__Status_Category__c, Apttus__Status__c, RecordTypeId, Apttus__Workflow_Trigger_Viewed_Final__c
            FROM Apttus__APTS_Agreement__c WHERE RecordTypeId =: CON_CLM.PRELIMINARY_RECORDTYPEID AND
            Name =: 'Test Preliminary Agreement' LIMIT 1];

        Apttus__APTS_Agreement__c newAgreement = oldAgreement.clone(true, false, false, false);
        newAgreement.Apttus__Status_Category__c = 'In Signatures';
        newAgreement.Apttus__Status__c = 'Ready for Signatures';
        newAgreement.Apttus__Workflow_Trigger_Viewed_Final__c = true;
        Map<Id, Apttus__APTS_Agreement__c> oldMap = new Map<Id, Apttus__APTS_Agreement__c>();
        oldMap.put(oldAgreement.Id, oldAgreement);

        Test.startTest();
            DAOH_CLM_APTS_Agreement.updateGenerateStatuses(new List<Apttus__APTS_Agreement__c>{newAgreement}, oldMap);
        Test.stopTest();
        
        System.assertEquals('In Authoring', newAgreement.Apttus__Status_Category__c, 'Returned status category is not what is expected.');
        System.assertEquals('Author Contract', newAgreement.Apttus__Status__c, 'Returned status is not what is expected.');
    }

    @isTest
    private static void testUpdateAgreementforIsStudyAwarded() {
        List <Apttus__APTS_Agreement__c> agreementList = [SELECT Id, Name, Apttus__Related_Opportunity__c, Is_Study_Awarded__c 
            FROM Apttus__APTS_Agreement__c WHERE RecordTypeId =: CON_CLM.PRELIMINARY_RECORDTYPEID AND
            Name =: 'Test Preliminary Agreement' LIMIT 1];
        
        Test.startTest();
            DAOH_CLM_APTS_Agreement.updateAgreementforIsStudyAwarded(agreementList, null);
        Test.stopTest();
        
        System.assertEquals('No', agreementList[0].Is_Study_Awarded__c, 'Returned study awarded is not what is expected.');
    }
    
    @isTest
    private static void testSetProvisionsTabForPSA() {
        Apttus__APTS_Agreement__c msaAgreement = [SELECT Id, Name FROM Apttus__APTS_Agreement__c 
            WHERE Name='Test 5597 MSA Agreement'];
        Apttus__APTS_Agreement__c testAgreementPSA = [SELECT Id, Name, Agreement_Cloned_From__c FROM Apttus__APTS_Agreement__c 
            WHERE Name='Test 4784 Agreement 2'][0];
        testAgreementPSA.Related_Master_Agreement__c = msaAgreement.Id ;
        
        Test.startTest(); 
            DAOH_CLM_APTS_Agreement.setProvisionsTabForPSA(new List<Apttus__APTS_Agreement__c>{testAgreementPSA}, null);
        Test.stopTest();
        
        System.assertEquals(CON_CLM.WITHIN_FALLBACKS, testAgreementPSA.Late_Payment_Clause__c, 
            'Late Payment Clause value should be Within fallbacks.');
    }
    
    @isTest
    private static void testSetProvisionTabToDefault() {
        Apttus__APTS_Agreement__c agreement = [SELECT Id, Late_Payment_Clause__c FROM Apttus__APTS_Agreement__c 
            WHERE Late_Payment_Clause__c = 'Within fallbacks' LIMIT 1];
        
        Test.startTest();
            agreement = DAOH_CLM_APTS_Agreement.setProvisionTabToDefault(agreement);
        Test.stopTest();
        
        System.assertEquals('No Change', agreement.Late_Payment_Clause__c, 'Late_Payment_Clause__c field should be No Change');
    }
    
    @isTest
    private static void testCopyAgreementFields() {
        Apttus__APTS_Agreement__c agreement = [SELECT Id, Late_Payment_Clause__c, Penalty__c FROM Apttus__APTS_Agreement__c 
            WHERE Late_Payment_Clause__c = 'Within fallbacks' LIMIT 1];
        Apttus__APTS_Agreement__c newAgreement = agreement.clone(true, false, false, false);
        newAgreement.Late_Payment_Clause__c = 'No change';
        
        Test.startTest();
            newAgreement = DAOH_CLM_APTS_Agreement.copyAgreementFields(newAgreement, agreement,
                new Set<String>{'Late_Payment_Clause__c'});
        Test.stopTest();
        
        System.assertEquals('Within fallbacks', newAgreement.Late_Payment_Clause__c,
            'Late_Payment_Clause__c field is not copied');
    }
    
    @isTest
    private static void testUpdateRelatedAgreementOnQuoteShouldUpdateCOQuote() {
        List<Apttus__APTS_Agreement__c> newAgreementList = new List<Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c newAgreement = [SELECT Id, Name, Apttus__Related_Opportunity__c, Apttus__Subtype__c, Apttus_QPComply__RelatedProposalId__c
            FROM Apttus__APTS_Agreement__c WHERE Name = 'Test PSA AGR With Oppr'];
        
        Apttus_Proposal__Proposal__c proposal = [SELECT Id, Apttus_QPComply__MasterAgreementId__c 
            FROM Apttus_Proposal__Proposal__c 
        	WHERE Apttus_Proposal__Opportunity__c =: newAgreement.Apttus__Related_Opportunity__c
            AND Apttus_Proposal__Primary__c = true];
        
        newAgreement.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_CHANGEORDER;
        newAgreementList.add(newAgreement);

        Test.startTest();
            DAOH_CLM_APTS_Agreement.updateRelatedAgreementOnQuote(newAgreementList, null);
        Test.stopTest();
		
        Apttus_Proposal__Proposal__c updatedProposal = [SELECT Id, Apttus_QPComply__MasterAgreementId__c 
            FROM Apttus_Proposal__Proposal__c 
        	WHERE Apttus_Proposal__Opportunity__c =: newAgreement.Apttus__Related_Opportunity__c
            AND Apttus_Proposal__Primary__c = true];
        System.assertEquals(updatedProposal.Apttus_QPComply__MasterAgreementId__c, newAgreement.Id ,
            'Agreement Id not updated on Proposal when expected');
    }
    
    @isTest
    private static void testValidateAgreementBeforeStatusCategoryChangedForPSA() {
        Map<Id, Apttus__APTS_Agreement__c> oldMapPSA = new Map<Id, Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c oldAgreementPSAWithAgrExt = [SELECT Id, Apttus__Status__c, RecordTypeId, Apttus__Subtype__c, Local_Representative__c, 
            EU_Legal_Representative__c, Late_Payment_Clause__c, Upfront_Payment_Provision__c, Early_Termination_Payment__c, 
            Currency_Exchange_Provision__c, Consequential_Damages_Disclaimer__c, Comprehensive_Indemnification_Provision__c,
            IQVIA_Confidentiality_And_IP_Provisions__c,  Force_Majeure_Provision__c, Investigator_Relationship_Provision__c,
            Cap_On_Damages__c, Termination_Provision__c, Change_Order_Language__c, Electronic_Records_And_Signatures_Prov__c,
            Confidential_And_Proprietary_Info_Id__c, Discounts_Risk_Premium_Volume_Rebate__c, Penalty__c, Non_Solicitation__c,
            Outcomes_Based_Gain_Risk_PFS__c, Rest_Work_For_Sponsor_Competitors__c, Data_Processing_Agreement_Exhibit_B__c,
            EU_Standard_Contractual_Clauses__c, Governing_Clause__c, Responsibility_Third_Party_Vendors__c, Fixed_Pricing__c,
            Data_Privacy_Addendum_Included__c, Other_Issues__c, Ok_To_Use_IQVIA_Affiliates__c, Ok_To_Use_Client_Affiliates__c,
            Non_Standard_Work_Order_Template_Reqd__c, Does_MSA_Include_3rd_Party_Flow_Downs__c,
            Apttus__Status_Category__c,Is_This_A_Rescue_Study__c,Prob_to_Execute_in_the_Qtr_Mgrs_Only__c,Planned_Execution_Date__c,
            IQVIA_Project_Manager_Con__c,IQVIA_Project_Finance_Manager__c, Original_Requested_Agreement_Type__c FROM Apttus__APTS_Agreement__c
            WHERE Name = 'Test 4784 Agreement 1' LIMIT 1];
        
        Apttus__APTS_Agreement__c newAgreementPSAWithAgrExt = oldAgreementPSAWithAgrExt.clone(true, false, false, false);
        newAgreementPSAWithAgrExt.Apttus__Status__c = CON_CLM.READY_FOR_SIGNATURES;
        newAgreementPSAWithAgrExt.EU_Legal_Representative__c = 'Yes';
        oldMapPSA.put(oldAgreementPSAWithAgrExt.Id, oldAgreementPSAWithAgrExt);        

        Test.startTest();
            DAOH_CLM_APTS_Agreement.validateAgreementBeforeStatusCategoryChanged(new List<Apttus__APTS_Agreement__c>{newAgreementPSAWithAgrExt}, oldMapPSA);
        Test.stopTest();
        
        System.assertEquals(true, ApexPages.getMessages().size() > 0, 'error message should be raised.');
    }

    @isTest
    private static void testValidateAgreementBeforeStatusCategoryChangedWithEU() {
        Map<Id, Apttus__APTS_Agreement__c> oldMapPSA = new Map<Id, Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c oldAgreementPSAWithoutAgrExt = [SELECT Id, Apttus__Status__c, RecordTypeId,
            Apttus__Subtype__c, Local_Representative__c, EU_Legal_Representative__c, Late_Payment_Clause__c, 
            Upfront_Payment_Provision__c, Early_Termination_Payment__c, Currency_Exchange_Provision__c, 
            Consequential_Damages_Disclaimer__c, Comprehensive_Indemnification_Provision__c, 
            IQVIA_Confidentiality_And_IP_Provisions__c,  Force_Majeure_Provision__c, Investigator_Relationship_Provision__c, 
            Cap_On_Damages__c, Termination_Provision__c, Change_Order_Language__c, Electronic_Records_And_Signatures_Prov__c, 
            Confidential_And_Proprietary_Info_Id__c, Discounts_Risk_Premium_Volume_Rebate__c, Penalty__c,
            Non_Solicitation__c, Outcomes_Based_Gain_Risk_PFS__c, Rest_Work_For_Sponsor_Competitors__c,
            Data_Processing_Agreement_Exhibit_B__c, EU_Standard_Contractual_Clauses__c, Governing_Clause__c, 
            Responsibility_Third_Party_Vendors__c, Fixed_Pricing__c, Data_Privacy_Addendum_Included__c, Other_Issues__c,
            Ok_To_Use_IQVIA_Affiliates__c, Ok_To_Use_Client_Affiliates__c, Non_Standard_Work_Order_Template_Reqd__c,
            Does_MSA_Include_3rd_Party_Flow_Downs__c,Apttus__Status_Category__c,Is_This_A_Rescue_Study__c,Prob_to_Execute_in_the_Qtr_Mgrs_Only__c,Planned_Execution_Date__c,
            IQVIA_Project_Manager_Con__c,IQVIA_Project_Finance_Manager__c, Original_Requested_Agreement_Type__c 
            FROM Apttus__APTS_Agreement__c WHERE Name = 'Test 4784 Agreement 2' LIMIT 1];
        
        Apttus__APTS_Agreement__c newAgreementPSAWithoutAgrExt = oldAgreementPSAWithoutAgrExt.clone(true, false, false, false);
        newAgreementPSAWithoutAgrExt.Apttus__Status__c = CON_CLM.READY_FOR_SIGNATURES;
        newAgreementPSAWithoutAgrExt.EU_Legal_Representative__c = 'Yes';
        oldMapPSA.put(oldAgreementPSAWithoutAgrExt.Id, oldAgreementPSAWithoutAgrExt);
        
        Test.startTest();
            DAOH_CLM_APTS_Agreement.validateAgreementBeforeStatusCategoryChanged(new List<Apttus__APTS_Agreement__c>{newAgreementPSAWithoutAgrExt}, oldMapPSA);
        Test.stopTest();
        
        System.assertEquals(true, ApexPages.getMessages().size() > 0, 'error message should be raised.');
    }

    @isTest
    private static void testValidateAgreementBeforeStatusCategoryChangedWithEULocalRep() {
        Map<Id, Apttus__APTS_Agreement__c> oldMapPSA = new Map<Id, Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c oldAgreementPSAWithAgrExtWithField = [SELECT Id, Apttus__Status__c, RecordTypeId, 
            Apttus__Subtype__c, Local_Representative__c, EU_Legal_Representative__c, Late_Payment_Clause__c, 
            Upfront_Payment_Provision__c, Early_Termination_Payment__c, Currency_Exchange_Provision__c, 
            Consequential_Damages_Disclaimer__c, Comprehensive_Indemnification_Provision__c, 
            IQVIA_Confidentiality_And_IP_Provisions__c,  Force_Majeure_Provision__c, Investigator_Relationship_Provision__c,
            Cap_On_Damages__c, Termination_Provision__c, Change_Order_Language__c, Electronic_Records_And_Signatures_Prov__c,
            Confidential_And_Proprietary_Info_Id__c, Discounts_Risk_Premium_Volume_Rebate__c, Penalty__c, Non_Solicitation__c,
            Outcomes_Based_Gain_Risk_PFS__c, Rest_Work_For_Sponsor_Competitors__c, Data_Processing_Agreement_Exhibit_B__c,
            EU_Standard_Contractual_Clauses__c, Governing_Clause__c, Responsibility_Third_Party_Vendors__c, Fixed_Pricing__c, 
            Data_Privacy_Addendum_Included__c, Other_Issues__c, Ok_To_Use_IQVIA_Affiliates__c, Ok_To_Use_Client_Affiliates__c,
            Non_Standard_Work_Order_Template_Reqd__c, Does_MSA_Include_3rd_Party_Flow_Downs__c,
            Apttus__Status_Category__c,Is_This_A_Rescue_Study__c,Prob_to_Execute_in_the_Qtr_Mgrs_Only__c,Planned_Execution_Date__c,
            IQVIA_Project_Manager_Con__c,IQVIA_Project_Finance_Manager__c,Apttus__Contract_Start_Date__c, Original_Requested_Agreement_Type__c FROM Apttus__APTS_Agreement__c
            WHERE Name = 'Test 4784 Agreement 1' LIMIT 1];
        
        Apttus__APTS_Agreement__c newAgreementPSAWithAgrExtWithField = oldAgreementPSAWithAgrExtWithField.clone(true, false, false, false);
        newAgreementPSAWithAgrExtWithField.Apttus__Status_Category__c = 'In Signatures';
        newAgreementPSAWithAgrExtWithField.Apttus__Status__c = CON_CLM.READY_FOR_SIGNATURES;
        newAgreementPSAWithAgrExtWithField.EU_Legal_Representative__c = 'Yes';
        newAgreementPSAWithAgrExtWithField.Local_Representative__c = 'No';  
        newAgreementPSAWithAgrExtWithField.Apttus__Contract_Start_Date__c = null;      
        oldMapPSA.put(oldAgreementPSAWithAgrExtWithField.Id, oldAgreementPSAWithAgrExtWithField);
        
        Test.startTest();
            DAOH_CLM_APTS_Agreement.validateAgreementBeforeStatusCategoryChanged(new List<Apttus__APTS_Agreement__c>{newAgreementPSAWithAgrExtWithField}, oldMapPSA);
        Test.stopTest();
        
        System.assertEquals(true, ApexPages.getMessages().size() > 0, 'error message should be raised.');
    }
    
    @isTest
    private static void testValidateAgreementBeforeStatusCategoryChangedForMSA() {
        Map<Id, Apttus__APTS_Agreement__c> oldMapMSA = new Map<Id, Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c oldAgreementMSAWithAgrExt = [SELECT Id, Name, Apttus__Status__c, Late_Payment_Clause__c,
            Upfront_Payment_Provision__c, Early_Termination_Payment__c, Currency_Exchange_Provision__c,
            Consequential_Damages_Disclaimer__c, Comprehensive_Indemnification_Provision__c, 
            IQVIA_Confidentiality_And_IP_Provisions__c,  Force_Majeure_Provision__c, Investigator_Relationship_Provision__c,
            Cap_On_Damages__c, Termination_Provision__c, Change_Order_Language__c, Electronic_Records_And_Signatures_Prov__c,
            Confidential_And_Proprietary_Info_Id__c, Discounts_Risk_Premium_Volume_Rebate__c, Penalty__c, Non_Solicitation__c,
            Outcomes_Based_Gain_Risk_PFS__c, Rest_Work_For_Sponsor_Competitors__c, Data_Processing_Agreement_Exhibit_B__c,
            EU_Standard_Contractual_Clauses__c, Governing_Clause__c, Responsibility_Third_Party_Vendors__c, Fixed_Pricing__c,
            Data_Privacy_Addendum_Included__c, Other_Issues__c, Ok_To_Use_IQVIA_Affiliates__c, Ok_To_Use_Client_Affiliates__c,
            Non_Standard_Work_Order_Template_Reqd__c, Does_MSA_Include_3rd_Party_Flow_Downs__c,Apttus__Subtype__c,RecordTypeId,
            Apttus__Status_Category__c, Original_Requested_Agreement_Type__c FROM Apttus__APTS_Agreement__c
            WHERE Name IN ('Test 5597 MSA Agreement')][0];
        
        Apttus__APTS_Agreement__c newAgreementMSAWithAgrExt = oldAgreementMSAWithAgrExt.clone(true, false, false, false);
        newAgreementMSAWithAgrExt.Apttus__Contract_Start_Date__c = null;
        newAgreementMSAWithAgrExt.Apttus__Status_Category__c = 'In Signatures';
        newAgreementMSAWithAgrExt.Apttus__Status__c = CON_CLM.READY_FOR_SIGNATURES;
        oldMapMSA.put(oldAgreementMSAWithAgrExt.Id, oldAgreementMSAWithAgrExt);
                
        Test.startTest();
            DAOH_CLM_APTS_Agreement.validateAgreementBeforeStatusCategoryChanged(new List<Apttus__APTS_Agreement__c>{newAgreementMSAWithAgrExt}, oldMapMSA);
        Test.stopTest();
              
        System.assertEquals(true, ApexPages.getMessages().size() > 0, 'error message should be raised.');
    }
    
    @isTest
    private static void testUpdateAgreementFromQuote() {
        List <Apttus__APTS_Agreement__c> agreementList = new List <Apttus__APTS_Agreement__c>();
        Apttus_Proposal__Proposal__c proposal = [SELECT Id, Select_Pricing_Tool__c FROM Apttus_Proposal__Proposal__c LIMIT 1];  
        
        Apttus__APTS_Agreement__c agreementQuote = [SELECT Id, Name, Select_Pricing_Tool__c, Apttus_QPComply__RelatedProposalId__c 
            FROM Apttus__APTS_Agreement__c WHERE RecordTypeId =: CON_CLM.PRELIMINARY_RECORDTYPEID AND
            Name =: 'Test Preliminary Agreement' LIMIT 1];
        agreementList.add(agreementQuote);

        Test.startTest();
            DAOH_CLM_APTS_Agreement.updateAgreementFromQuote(agreementList, null, CON_CLM.PA_RECORD_TYPE_NAME);
        Test.stopTest();
        
        Apttus__APTS_Agreement__c agreement = [SELECT Id, Select_Pricing_Tool__c  FROM Apttus__APTS_Agreement__c 
            WHERE Id =: agreementList[0].Id];
        
        System.assertEquals(agreement.Select_Pricing_Tool__c, proposal.Select_Pricing_Tool__c,
            'Field is not updated.');
    }
    
    @isTest
    private static void testValidatePAAgreementBeforeStatusCategoryChanged() {
        Apttus__APTS_Agreement__c oldAgreement = [SELECT Id, Name, Apttus__Status_Category__c, Apttus__Status__c,
            Apttus__Subtype__c, RecordTypeId, Is_This_A_Rescue_Study__c, Prob_to_Execute_in_the_Qtr_Mgrs_Only__c, 
            Planned_Execution_Date__c, IQVIA_Project_Manager_Con__c, IQVIA_Project_Finance_Manager__c, 
            Prob_to_move_to_High_Confidence_in_Qtr__c,Apttus__Contract_Start_Date__c, Original_Requested_Agreement_Type__c 
            FROM Apttus__APTS_Agreement__c 
            WHERE RecordTypeId =: CON_CLM.PRELIMINARY_RECORDTYPEID AND Name =: 'Test Preliminary Agreement' LIMIT 1];

        Apttus__APTS_Agreement__c newAgreement = oldAgreement.clone(true, false, false, false);
        newAgreement.Apttus__Contract_Start_Date__c = null;
        newAgreement.Apttus__Status_Category__c = CON_CLM.IN_AUTHORING;
        newAgreement.Apttus__Status__c = CON_CLM.AUTHOR_CONTRACT;
        Map<Id, Apttus__APTS_Agreement__c> oldMap = new Map<Id, Apttus__APTS_Agreement__c>();
        oldMap.put(oldAgreement.Id, oldAgreement);

        Test.startTest();
            DAOH_CLM_APTS_Agreement.validateAgreementBeforeStatusCategoryChanged
                (new List<Apttus__APTS_Agreement__c>{newAgreement}, oldMap);
        Test.stopTest();
        
        System.assertEquals(true, ApexPages.getMessages().size() > 0, 
            'The value should be true and error message should be shown.');
    }
 
    @isTest
    private static void testValidatePSAAgreementBeforeStatusCategoryChanged() {
        Apttus__APTS_Agreement__c oldAgreementGSA = [SELECT Id, Name, Apttus__Status_Category__c, Apttus__Status__c,
            Apttus__Subtype__c, RecordTypeId, Apttus__Contract_Start_Date__c, Is_This_A_Rescue_Study__c, Prob_to_Execute_in_the_Qtr_Mgrs_Only__c, Original_Requested_Agreement_Type__c,
            Planned_Execution_Date__c, IQVIA_Project_Manager_Con__c, IQVIA_Project_Finance_Manager__c, Prob_to_move_to_High_Confidence_in_Qtr__c FROM Apttus__APTS_Agreement__c 
            WHERE RecordTypeId =: CON_CLM.PSA_RECORDTYPEID AND Name =: 'Test 4784 Agreement 1' LIMIT 1];
        
        Apttus__APTS_Agreement__c newAgreementGSA = oldAgreementGSA.clone(true, false, false, false);
        newAgreementGSA.Apttus__Status_Category__c = CON_CLM.IN_SIGNATURES;
        newAgreementGSA.Apttus__Status__c = CON_CLM.INTERNAL_SIGNATURES;
        newAgreementGSA.Apttus__Contract_Start_Date__c = null;
       
        Map<Id, Apttus__APTS_Agreement__c> oldMap = new Map<Id, Apttus__APTS_Agreement__c>();
        oldMap.put(oldAgreementGSA.Id, oldAgreementGSA);

        Test.startTest();
            DAOH_CLM_APTS_Agreement.validateAgreementBeforeStatusCategoryChanged
                (new List<Apttus__APTS_Agreement__c>{newAgreementGSA}, oldMap);
        Test.stopTest();
        
        System.assertEquals(true, ApexPages.getMessages().size() > 0, 
            'The value should be true and error message should be shown.');
    }
    
    @isTest
    private static void testValidateReviewCycleBeforeStatusCategoryChanged() {
        Apttus__APTS_Agreement__c agreement = [SELECT Id, Name, Apttus__Status_Category__c, Apttus__Status__c FROM Apttus__APTS_Agreement__c WHERE Name = 'Test RWLP Agreement' LIMIT 1];

        Apttus__DocumentVersion__c dV = [SELECT Id, Apttus__LatestReviewCycleStatus__c, Apttus__AgreementId__c, Apttus__AgreementId__r.Name FROM Apttus__DocumentVersion__c 
                                        WHERE Apttus__AgreementId__r.Name = 'Test RWLP Agreement'];
        
        dV.Apttus__LatestReviewCycleStatus__c = 'In Progress';
        update dV;
        Apttus__APTS_Agreement__c newAgreement  = agreement.clone(true, false, false, false);
        newAgreement.Apttus__Status_Category__c = CON_CLM.IN_SIGNATURES;
        newAgreement.Apttus__Status__c = CON_CLM.INTERNAL_SIGNATURES;
        Map<Id, Apttus__APTS_Agreement__c> oldMap = new Map<Id, Apttus__APTS_Agreement__c>();
        oldMap.put(agreement.Id, agreement);
        
        Test.startTest();
            DAOH_CLM_APTS_Agreement.validateReviewCycleBeforeStatusCategoryChanged(new List<Apttus__APTS_Agreement__c>{newAgreement}, oldMap);
        Test.stopTest();
        
        System.assertEquals(true, ApexPages.getMessages().size() > 0, 
            'The value should be true and error message should be shown.');
    }

    @isTest
    private static void testAllowCOAmendmentSubTypeOnlyOnBeforeInsert() {
        Apttus__APTS_Agreement__c originalAgrPSA = [SELECT Id FROM Apttus__APTS_Agreement__c WHERE Name = 'Old Agreement PSA'];
        Apttus__APTS_Agreement__c originalAgrMSA = [SELECT Id FROM Apttus__APTS_Agreement__c WHERE Name = 'Test 5597 MSA Agreement'];
        
        Test.startTest();
            Apttus__APTS_Agreement__c amendedAgrPSA = [SELECT Id, Name, Apttus__Version_Number__c, Agreement_Cloned_From__c, Apttus__Subtype__c, RecordTypeId 
                FROM Apttus__APTS_Agreement__c WHERE Name = 'Test 4784 Agreement 4'];
            amendedAgrPSA.Apttus__Version_Number__c = 1;
            amendedAgrPSA.Agreement_Cloned_From__c = originalAgrPSA.Id;   
            amendedAgrPSA.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_GSA;

            Apttus__APTS_Agreement__c amendedAgrMSA = [SELECT Id, Name, Apttus__Version_Number__c, Agreement_Cloned_From__c, Apttus__Subtype__c, RecordTypeId, Original_Agreement__c
                FROM Apttus__APTS_Agreement__c WHERE Name = 'Test MSA Agreement Payment Term'];
            amendedAgrMSA.Apttus__Version_Number__c = 1;
            amendedAgrMSA.Agreement_Cloned_From__c = originalAgrMSA.Id;
            amendedAgrMSA.Apttus__Subtype__c = 'Other Master Agreement';
            DAOH_CLM_APTS_Agreement.allowCOAmendmentSubTypeOnly(new List<Apttus__APTS_Agreement__c>{amendedAgrPSA, amendedAgrMSA}, null);
        Test.stopTest();
        
        System.assertEquals(null, amendedAgrPSA.Apttus__Subtype__c, 'The subtype should be set to null while amendment during insert for PSA');
        System.assertEquals(null, amendedAgrMSA.Apttus__Subtype__c, 'The subtype should be set to null while amendment during insert for MSA');
    }
    
    @isTest
    private static void testAllowCOAmendmentSubTypeOnlyOnBeforeUpdate() {
        Apttus__APTS_Agreement__c oldAgreementPSA = [SELECT Id, Name, Apttus__Version_Number__c, Agreement_Cloned_From__c, RecordTypeId,
            Apttus__Subtype__c FROM Apttus__APTS_Agreement__c WHERE Name = 'Test 4784 Agreement 2' LIMIT 1];    
        oldAgreementPSA.Apttus__Subtype__c = null;
        Apttus__APTS_Agreement__c amendedAgreementPSA = oldAgreementPSA.clone(true, false, false, false);
        amendedAgreementPSA.Apttus__Version_Number__c = 1;
        amendedAgreementPSA.Agreement_Cloned_From__c = oldAgreementPSA.Id;
        amendedAgreementPSA.Apttus__Subtype__c = 'Work Order';
        
        Apttus__APTS_Agreement__c oldAgreementMSA = [SELECT Id, Name, Apttus__Version_Number__c, Agreement_Cloned_From__c, RecordTypeId,   
            Apttus__Subtype__c, Original_Agreement__c FROM Apttus__APTS_Agreement__c WHERE Name = 'Test 5597 MSA Agreement'];
        oldAgreementMSA.Apttus__Subtype__c = null;
        Apttus__APTS_Agreement__c amendedAgreementMSA = oldAgreementMSA.clone(true, false, false, false); 
        amendedAgreementMSA.Apttus__Version_Number__c = 1;
        amendedAgreementMSA.Agreement_Cloned_From__c = oldAgreementMSA.Id;
        amendedAgreementMSA.Apttus__Subtype__c = 'Other Master Agreement';
        
        Map<Id, Apttus__APTS_Agreement__c> oldMap = new Map<Id, Apttus__APTS_Agreement__c>();  
        oldMap.put(oldAgreementPSA.Id, oldAgreementPSA);
        oldMap.put(oldAgreementMSA.Id, oldAgreementMSA);
        
        Test.startTest();
            DAOH_CLM_APTS_Agreement.allowCOAmendmentSubTypeOnly(new List<Apttus__APTS_Agreement__c>{amendedAgreementMSA, amendedAgreementPSA}, oldMap);
        Test.stopTest();
        
        System.assertEquals(true, ApexPages.getMessages()[1].getDetail().contains(System.Label.CLM_CL00017_PSA_SUBTYPE_AMEND_ERROR), 
            'The value should be true and error message should be shown.');   
        System.assertEquals(true, ApexPages.getMessages()[0].getDetail().contains(System.Label.CLM_CL00017_PA_MSA_SUBTYPE_AMEND_ERROR),
            'The value should be true and error message should be shown.');        
    }

    @isTest
    private static void testAllowCOAmendmentSubTypeOnlyRWLP() {
        Apttus__APTS_Agreement__c oldAgreement = [SELECT id, OwnerId, Apttus__Status__c,
            Apttus__Status_Category__c,Apttus__Related_Opportunity__c,Apttus__Subtype__c,RecordTypeId FROM Apttus__APTS_Agreement__c WHERE Name = 'Test RWLP Agreement' LIMIT 1];
        oldAgreement.Apttus__Subtype__c = null;

        Apttus__APTS_Agreement__c amendedAgreement = oldAgreement.clone(true, false, false, false);
        amendedAgreement.Apttus__Version_Number__c = 1;
        amendedAgreement.Agreement_Cloned_From__c = oldAgreement.Id;
        amendedAgreement.Apttus__Subtype__c = 'Work Order';

        Map<Id, Apttus__APTS_Agreement__c> oldMap = new Map<Id, Apttus__APTS_Agreement__c>();
        oldMap.put(oldAgreement.Id, oldAgreement);

        Test.startTest();
            DAOH_CLM_APTS_Agreement.allowCOAmendmentSubTypeOnly(new List<Apttus__APTS_Agreement__c>{amendedAgreement}, oldMap);
        Test.stopTest();

        System.assertEquals(true, ApexPages.getMessages()[0].getDetail().contains(System.Label.CLM_CL00017_RWLP_SUBTYPE_CO_AMEND_ERROR), 
            'The value should be true and error message should be shown.');        
    }

    @isTest
    private static void testAllowCOAmendmentSubTypeOnlyVendorAGR() {
        Apttus__APTS_Agreement__c oldAgreement = [SELECT id, OwnerId, Apttus__Status__c,
            Apttus__Status_Category__c,Apttus__Related_Opportunity__c,Apttus__Subtype__c,RecordTypeId FROM Apttus__APTS_Agreement__c WHERE Name = 'Test Vendor Agreement' LIMIT 1];
        oldAgreement.Apttus__Subtype__c = null;

        Apttus__APTS_Agreement__c amendedAgreement = oldAgreement.clone(true, false, false, false);
        amendedAgreement.Apttus__Version_Number__c = 1;
        amendedAgreement.Agreement_Cloned_From__c = oldAgreement.Id;
        amendedAgreement.Apttus__Subtype__c = 'Work Order';

        Map<Id, Apttus__APTS_Agreement__c> oldMap = new Map<Id, Apttus__APTS_Agreement__c>();
        oldMap.put(oldAgreement.Id, oldAgreement);

        Test.startTest();
            DAOH_CLM_APTS_Agreement.allowCOAmendmentSubTypeOnly(new List<Apttus__APTS_Agreement__c>{amendedAgreement}, oldMap);
        Test.stopTest();

        System.assertEquals(true, ApexPages.getMessages()[0].getDetail().contains(System.Label.CLM_CL00017_VA_CO_AMEND_TERMINATION_LETTER_ERROR), 
            'The value should be true and error message should be shown.');        
    }

    @isTest
    private static void testUpdatePaymentTerm() {
        Apttus__APTS_Agreement__c oldMSAAgreement = [SELECT Id, Name, RecordTypeId, Apttus__Subtype__c, Related_Master_Agreement__c, Payment_Term__c
            FROM Apttus__APTS_Agreement__c WHERE Name =: 'Test MSA Agreement Payment Term' LIMIT 1];

        Apttus__APTS_Agreement__c testAgreementPSA = [SELECT Id, Name, RecordTypeId, Apttus__Subtype__c, Related_Master_Agreement__c, Payment_Term__c 
            FROM Apttus__APTS_Agreement__c WHERE Name=: 'Test PSA Agreement Payment Term' LIMIT 1];
        testAgreementPSA.Related_Master_Agreement__c = oldMSAAgreement.Id ;

        Test.startTest();
            DAOH_CLM_APTS_Agreement.updatePaymentTerm(new List<Apttus__APTS_Agreement__c>{testAgreementPSA}, null);
        Test.stopTest();
        
        System.assertEquals(oldMSAAgreement.Payment_Term__c, testAgreementPSA.Payment_Term__c, 'Payment Term is not what is expected.');
    }

    @isTest
    private static void testUpdatePaymentTermForPA() {
        Apttus__APTS_Agreement__c oldMSAAgreement = [SELECT Id, Name, RecordTypeId, Apttus__Subtype__c, Related_Master_Agreement__c, Payment_Term__c
            FROM Apttus__APTS_Agreement__c WHERE Name =: 'Test MSA Agreement Payment Term' LIMIT 1];

        Apttus__APTS_Agreement__c testAgreementPA = [SELECT Id, Name, RecordTypeId, Apttus__Subtype__c, Related_Master_Agreement__c, Payment_Term__c 
            FROM Apttus__APTS_Agreement__c WHERE Name=: 'Test Preliminary Agreement' LIMIT 1];
        testAgreementPA.Related_Master_Agreement__c = oldMSAAgreement.Id ;

        Test.startTest();
            DAOH_CLM_APTS_Agreement.updatePaymentTerm(new List<Apttus__APTS_Agreement__c>{testAgreementPA}, null);
        Test.stopTest();
        
        System.assertEquals(oldMSAAgreement.Payment_Term__c, testAgreementPA.Payment_Term__c, 'Payment Term is not what is expected.');
    }
    
    @isTest
    private static void testValidateSignedDateBeforeFullySigned() {
        Apttus__APTS_Agreement__c oldAgreementGSA = [SELECT Id, Name, Apttus__Status__c,
            Apttus__Other_Party_Signed_Date__c, Apttus__Company_Signed_Date__c, Execution_Order__c FROM Apttus__APTS_Agreement__c 
            WHERE RecordTypeId =: CON_CLM.PSA_RECORDTYPEID AND Name =: 'Test 4784 Agreement 1' LIMIT 1];
        
        Apttus__APTS_Agreement__c newAgreementGSA = oldAgreementGSA.clone(true, false, false, false);
        newAgreementGSA.Apttus__Status_Category__c = CON_CLM.IN_SIGNATURES;
        newAgreementGSA.Apttus__Status__c = CON_CLM.FULLY_SIGNED;
     
        Map<Id, Apttus__APTS_Agreement__c> oldMap = new Map<Id, Apttus__APTS_Agreement__c>();
        oldMap.put(oldAgreementGSA.Id, oldAgreementGSA);

        Test.startTest();
            DAOH_CLM_APTS_Agreement.validateSignedDateBeforeFullySigned
                (new List<Apttus__APTS_Agreement__c>{newAgreementGSA}, oldMap);
        Test.stopTest();
        
        System.assertEquals(true, ApexPages.getMessages().size() > 0, 
            'The value should be true and error message should be shown.');
    }

    @isTest
    private static void testPreventUserFromCreatingCOFromOppShouldReturnErrorMsg() {
        Apttus__APTS_Agreement__c agreement = [SELECT Id, Special_Terms_Included__c, Apttus__Subtype__c,
            Agreement_Cloned_From__c,RecordTypeId FROM Apttus__APTS_Agreement__c WHERE Name =: 'Test 4784 Agreement 2' LIMIT 1];
        agreement.Special_Terms_Included__c = CON_CLM.RESTRICT_CO_AGREEMENT;
        agreement.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_CHANGEORDER;
        agreement.Agreement_Cloned_From__c = null;

        Test.startTest();
            DAOH_CLM_APTS_Agreement.preventUserFromCreatingCOFromOpp(new List<Apttus__APTS_Agreement__c>{agreement});
        Test.stopTest();

        System.assertEquals(true, ApexPages.getMessages()[0].getDetail().contains(System.Label.CLM_CL00014_ERROR_MESSAGE_FOR_CO_FROM_OPP),
            'There must be validation message to stop creating change order from opp but it is not.');
    }
    
    /*@isTest
    private static void testUpdateRelatedQuoteOnAgreementActivation() {
        Apttus__APTS_Agreement__c oldAgreementATP = [SELECT Id, Name, Apttus__Status__c, Apttus_QPComply__RelatedProposalId__c,
            Apttus__Contract_End_Date__c, Apttus__Status_Category__c FROM Apttus__APTS_Agreement__c 
            WHERE RecordTypeId =: CON_CLM.PRELIMINARY_RECORDTYPEID AND Name =: 'Test Preliminary Agreement' LIMIT 1];
        
        Apttus_Proposal__Proposal__c proposal = [SELECT Id, Executed_Date__c, Apttus_Proposal__Approval_Stage__c 
            FROM Apttus_Proposal__Proposal__c 
        	WHERE Id = :oldAgreementATP.Apttus_QPComply__RelatedProposalId__c
            AND Apttus_Proposal__Primary__c = true];
        proposal.Apttus_Proposal__Approval_Stage__c = CON_CLM.PROPOSAL_APPROVAL_STAGE_PRESENTED;
        update proposal;
        
        Apttus__APTS_Agreement__c newAgreementATP = oldAgreementATP.clone(true, false, false, false);
        newAgreementATP.Apttus__Contract_End_Date__c = Date.today();
        newAgreementATP.Apttus__Other_Party_Signed_Date__c = Date.today();
        newAgreementATP.Apttus__Status_Category__c = CON_CLM.IN_EFFECT;
        newAgreementATP.Apttus__Status__c = CON_CLM.ACTIVATED;
     
        Map<Id, Apttus__APTS_Agreement__c> oldMap = new Map<Id, Apttus__APTS_Agreement__c>();
        oldMap.put(oldAgreementATP.Id, oldAgreementATP);

        Test.startTest();
            DAOH_CLM_APTS_Agreement.updateRelatedQuoteOnAgreementActivation
                (new List<Apttus__APTS_Agreement__c>{newAgreementATP}, oldMap);
        Test.stopTest();
        
        Apttus_Proposal__Proposal__c updatedProposal = [SELECT Id, Executed_Date__c, Apttus_Proposal__Approval_Stage__c 
            FROM Apttus_Proposal__Proposal__c 
        	WHERE Id = :oldAgreementATP.Apttus_QPComply__RelatedProposalId__c
            AND Apttus_Proposal__Primary__c = true];
        System.assertEquals(newAgreementATP.Apttus__Other_Party_Signed_Date__c, updatedProposal.Executed_Date__c,
            'Executed date is not updated on Proposal when expected');
        System.assertEquals(CON_CLM.PROPOSAL_APPROVAL_STAGE_ACCEPTED, updatedProposal.Apttus_Proposal__Approval_Stage__c,
            'Proposal Stage should be updated to Accepted');
    } */

    @isTest
    private static void testSetPickListLabelToField() {
        Apttus__APTS_Agreement__c agreementAMESA = [SELECT Id, Apttus__Account__c, Account_Country_Label__c 
            FROM Apttus__APTS_Agreement__c WHERE Name = 'Test AMESA Agreement'];
        Apttus__APTS_Agreement__c oldAgreement = agreementAMESA.clone(true, false, false, false);
        oldAgreement.Apttus__Account__c = null;

        Map<Id, Apttus__APTS_Agreement__c> oldMap = new Map<Id, Apttus__APTS_Agreement__c>();
        oldMap.put(oldAgreement.Id, oldAgreement);

        Test.startTest();
            DAOH_CLM_APTS_Agreement.setPickListLabelToField(new List<Apttus__APTS_Agreement__c>{agreementAMESA}, 
                oldMap, CON_CLM.FROM_ACCOUNT_COUNTRY_FIELD_API_NAME, CON_CLM.TO_ACCOUNT_COUNTRY_FIELD_API_NAME);
        Test.stopTest();

        System.assertEquals('India', agreementAMESA.Account_Country_Label__c, 
            'Account Country Label must have full label from account country.');
    }

    @isTest
    private static void testUpdateAnalystStartDateOnAgrExt() {
        Apttus__APTS_Agreement__c oldAgreement = [SELECT Id, Apttus__Account__c, Account_Country_Label__c, Date_Tracking_Started__c 
            FROM Apttus__APTS_Agreement__c WHERE Name = 'Test 4784 Agreement 1'];
        Apttus__APTS_Agreement__c agreement = oldAgreement.clone(true, false, false, false);
        agreement.Date_Tracking_Started__c = Date.today().addDays(-1);
        Map<Id, Apttus__APTS_Agreement__c> oldMap = new Map<Id, Apttus__APTS_Agreement__c>();
        oldMap.put(oldAgreement.Id, oldAgreement);

        Test.startTest();
            DAOH_CLM_APTS_Agreement.updateAnalystStartDateOnAgr(new List<Apttus__APTS_Agreement__c>{agreement}, oldMap);
        Test.stopTest();

        System.assertEquals(agreement.Analyst_Start_Date__c, agreement.Date_Tracking_Started__c,  
            'Analyst Start Date is not equals to Date Tracking Started when expected');
    }

    @isTest
    private static void testPreventUserToUpdateCurrencyOnAgreement() {
        Apttus__APTS_Agreement__c agreement = [SELECT Id, Apttus__Account__c, Account_Country_Label__c, Date_Tracking_Started__c,  
            Apttus_QPComply__RelatedProposalId__c, CurrencyIsoCode FROM Apttus__APTS_Agreement__c WHERE Name = 'Test Preliminary Agreement'];
        Apttus__APTS_Agreement__c oldAgreement = agreement.clone(true, false, false, false);

        Map<Id, Apttus__APTS_Agreement__c> oldMap = new Map<Id, Apttus__APTS_Agreement__c>();
        oldMap.put(oldAgreement.Id, oldAgreement);

        agreement.CurrencyIsoCode = 'INR';

        Test.startTest();
            DAOH_CLM_APTS_Agreement.preventUserFromUpdatingCurrencyFromAgreement(new List<Apttus__APTS_Agreement__c>{agreement}, 
                oldMap);
        Test.stopTest();

        System.assertEquals(true, ApexPages.getMessages()[0].getDetail().contains(System.Label.CLM_CL00018_AGR_CURRENCY_UPDATE_ERROR),
            'There must be validation message to stop updating Currency on Agreement.');
    }
    
    @isTest
    private static void testPopulateProbToMoveToHighConfidenceInQtr() {
        Apttus__APTS_Agreement__c agreement = [SELECT Id, Confidence_In_Approval_Of_Budget_Draft__c, Prob_to_move_to_High_Confidence_in_Qtr__c 
            FROM Apttus__APTS_Agreement__c where Name = 'Old Agreement PSA'];
        Apttus__APTS_Agreement__c oldAgreement = agreement.clone(true, false, false, false);
        oldAgreement.Confidence_In_Approval_Of_Budget_Draft__c = null;
        
        Map<Id, Apttus__APTS_Agreement__c> oldMap = new Map<Id, Apttus__APTS_Agreement__c>();
        oldMap.put(oldAgreement.Id, oldAgreement);

        
        Test.startTest();
        	DAOH_CLM_APTS_Agreement.populateProbToMoveToHighConfidenceInQtr(new List<Apttus__APTS_Agreement__c>{agreement},oldMap);
        Test.stopTest();
        
        System.assertEquals(CON_CLM.LIKELY, agreement.Prob_to_move_to_High_Confidence_in_Qtr__c,
                           '% Prob to move to High Confidence in Qtr is not updated to Likely.');
    }
    
    @isTest
    private static void testUpdateUnsignedCommentsChangeDate() {
        Apttus__APTS_Agreement__c agreement = [SELECT Id, Unsigned_Comments__c  
            FROM Apttus__APTS_Agreement__c WHERE Name = 'Test 4784 Agreement 1'];
        Apttus__APTS_Agreement__c oldAgreement = agreement.clone(true, false, false, false);
        agreement.Unsigned_Comments__c = 'Test';
        
        Map<Id, Apttus__APTS_Agreement__c> oldMap = new Map<Id, Apttus__APTS_Agreement__c>();
        oldMap.put(oldAgreement.Id, oldAgreement);

        Test.startTest();
            DAOH_CLM_APTS_Agreement.updateUnsignedCommentsChangeDate(new List<Apttus__APTS_Agreement__c>{agreement}, oldMap);
        Test.stopTest();

        System.assertEquals(System.today(), agreement.Unsigned_Status_Change_Date__c,  
            'Date must be equal to today\'s date');
    }           
    @isTest
    private static void testUpdateRelatedQuoteOnAgreementCancellation() {
        Set<Id> proposalId = new Set<Id>();
        
        Apttus__APTS_Agreement__c oldAgreementATP = [SELECT Id, Name, Apttus__Status__c, Apttus_QPComply__RelatedProposalId__c,
            Apttus__Contract_End_Date__c, Apttus__Status_Category__c FROM Apttus__APTS_Agreement__c 
            WHERE RecordTypeId =: CON_CLM.PRELIMINARY_RECORDTYPEID AND Name =: 'Test Preliminary Agreement' LIMIT 1];
        
        Apttus_Proposal__Proposal__c proposal = [SELECT Id, Executed_Date__c, Apttus_Proposal__Approval_Stage__c 
            FROM Apttus_Proposal__Proposal__c 
        	WHERE Id = :oldAgreementATP.Apttus_QPComply__RelatedProposalId__c
            AND Apttus_Proposal__Primary__c = true];
        
        proposal.Apttus_Proposal__Approval_Stage__c = CON_CLM.PROPOSAL_APPROVAL_STAGE_PRESENTED;
        
        Apttus__APTS_Agreement__c newAgreementATP = oldAgreementATP.clone(true, false, false, false);
        newAgreementATP.Apttus__Contract_End_Date__c = Date.today();
        newAgreementATP.Apttus__Other_Party_Signed_Date__c = Date.today();
        newAgreementATP.Apttus__Status_Category__c = CON_CLM.CANCELLED;
        newAgreementATP.Apttus__Status__c = CON_CLM.CANCELLED;
     
        Map<Id, Apttus__APTS_Agreement__c> oldMap = new Map<Id, Apttus__APTS_Agreement__c>();
        oldMap.put(oldAgreementATP.Id, oldAgreementATP);
        
        proposalId.add(oldAgreementATP.Apttus_QPComply__RelatedProposalId__c);
        
        Test.startTest();
            update proposal;
            DAOH_CLM_APTS_Agreement.updateRelatedQuoteOnAgreementCancellation
                (new List<Apttus__APTS_Agreement__c>{newAgreementATP}, oldMap);
        Test.stopTest();
        
        Apttus_Proposal__Proposal__c updatedProposal = [SELECT Id, Apttus_Proposal__Approval_Stage__c 
            FROM Apttus_Proposal__Proposal__c 
            WHERE Id = :oldAgreementATP.Apttus_QPComply__RelatedProposalId__c LIMIT 1];
    }
    @isTest
    private static void testUpdateCompanySignedByAndDate() {
        
        List<Apttus__APTS_Agreement__c> newAgreementList = new List<Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c agreement = [Select Id, name, Apttus__Status_Category__c, Apttus__Company_Signed_Date__c, Apttus__Company_Signed_By__c from Apttus__APTS_Agreement__c where name = 'Test AMA Agreement'];
         
        agreement.Apttus__Status_Category__c = CON_CLM.IN_AUTHORING;
        newAgreementList.add(agreement);
        
        CLM_Configuration__c obj = CLM_Configuration__c.getOrgDefaults();
        Id contactId = obj.AMA_Contact_Id__c;

        Apttus__APTS_Agreement__c oldAgreement = agreement.clone(true, false, false, false);
        oldAgreement.Apttus__Status_Category__c = 'Request';
        
        Map<Id, Apttus__APTS_Agreement__c> oldMap = new Map<Id, Apttus__APTS_Agreement__c>();
        oldMap.put(oldAgreement.Id, oldAgreement);
        
        Test.startTest();
            DAOH_CLM_APTS_Agreement.updateCompanySignedByAndDate(newAgreementList, oldMap);
        Test.stopTest();
        
        System.assertEquals(System.today(), agreement.Apttus__Company_Signed_Date__c,
                           'Company signed date not updated to todays date');
        System.assertEquals(contactId, agreement.Apttus__Company_Signed_By__c,
                           'Company not signed by Deborah Huffnagle');
    }
    
    @isTest
    private static void testUpdateRelatedQuoteStageOnAgrActivation() {
        Apttus__APTS_Agreement__c oldAgreementATP = [SELECT Id, Name, Apttus__Status__c, Apttus_QPComply__RelatedProposalId__c,
            Apttus__Status_Category__c FROM Apttus__APTS_Agreement__c 
            WHERE Name =: 'Test Preliminary Agreement2' LIMIT 1];
        
        Apttus__APTS_Agreement__c newAgreementATP = oldAgreementATP.clone(true, false, false, false);
        newAgreementATP.Apttus__Contract_End_Date__c = Date.today();
        newAgreementATP.Apttus__Other_Party_Signed_Date__c = Date.today();
        newAgreementATP.Apttus__Status_Category__c = CON_CLM.IN_EFFECT;
        newAgreementATP.Apttus__Status__c = CON_CLM.ACTIVATED;
     
        Map<Id, Apttus__APTS_Agreement__c> oldMap = new Map<Id, Apttus__APTS_Agreement__c>();
        oldMap.put(oldAgreementATP.Id, oldAgreementATP);

        Apttus_Proposal__Proposal__c proposal = [SELECT Id, Apttus_QPComply__MasterAgreementId__c, Executed_Date__c 
            FROM Apttus_Proposal__Proposal__c WHERE Id = :oldAgreementATP.Apttus_QPComply__RelatedProposalId__c LIMIT 1];
        proposal.Apttus_QPComply__MasterAgreementId__c = newAgreementATP.Id;
        
        Test.startTest();
            update proposal;
        	DAOH_CLM_APTS_Agreement.updateRelatedQuoteStageOnAgrActivation(new List<Apttus__APTS_Agreement__c>{newAgreementATP}, oldMap);
        Test.stopTest();
        
        /*Apttus_Proposal__Proposal__c updatedProposal = [SELECT Id, Apttus_Proposal__Approval_Stage__c, Executed_Date__c 
            FROM Apttus_Proposal__Proposal__c WHERE Id = :oldAgreementATP.Apttus_QPComply__RelatedProposalId__c LIMIT 1];
        System.assertEquals(CON_CLM.PROPOSAL_APPROVAL_STAGE_ACCEPTED, updatedProposal.Apttus_Proposal__Approval_Stage__c,
            'Proposal Stage should be updated to Accepted');
        System.assertEquals(newAgreementATP.Apttus__Other_Party_Signed_Date__c, updatedProposal.Executed_Date__c, 
            'Executed Date should match Other Party Signed Date');*/
    }
    
    @isTest
    private static void testUpdateRelatedQuoteStageOnAgrActivationForValidation() {
        Apttus__APTS_Agreement__c oldAgreement = [SELECT Id, Apttus__Status__c, Apttus__Status_Category__c, Apttus_QPComply__RelatedProposalId__c, Apttus__Other_Party_Signed_Date__c 
            FROM Apttus__APTS_Agreement__c WHERE Name = 'Test 4784 Agreement 4' LIMIT 1];
        
        Apttus__APTS_Agreement__c newAgreement = oldAgreement.clone(true, false, false, false);
        newAgreement.Apttus__Status_Category__c = CON_CLM.IN_SIGNATURES;
        newAgreement.Apttus__Status__c = CON_CLM.FULLY_SIGNED;
        Map<Id, Apttus__APTS_Agreement__c> oldMap = new Map<Id, Apttus__APTS_Agreement__c>();
        oldMap.put(oldAgreement.Id, oldAgreement);
        
        Test.startTest();
            DAOH_CLM_APTS_Agreement.updateRelatedQuoteStageOnAgrActivation(new List<Apttus__APTS_Agreement__c>{newAgreement}, oldMap);
        Test.stopTest();
         
        System.assertEquals(true, ApexPages.getMessages()[0].getDetail().contains(CON_CLM.IN_SIGNATURE_QUOTE_ERROR), 
            'The expected error should be returned');
    }
    
    @isTest
    private static void testUpdateTermMonthValue() {
        Apttus__APTS_Agreement__c agreement = [SELECT Id, Name, Apttus__Contract_Start_Date__c, Apttus__Contract_End_Date__c
            FROM Apttus__APTS_Agreement__c WHERE Name = 'Test RWS Agreement' LIMIT 1];
        agreement.Apttus__Contract_Start_Date__c = Date.newInstance(2023, 01,01);
        agreement.Apttus__Contract_End_Date__c = Date.newInstance(2024, 01, 20);

        Test.startTest();
            DAOH_CLM_APTS_Agreement.updateTermMonthValue(new List<Apttus__APTS_Agreement__c> {agreement}, null);
        Test.stopTest();

        System.assertEquals(13, agreement.Apttus__Term_Months__c, 'term has incorrect value');        
    }

    @isTest
    private static void testGetQuoteErrorMessageBySequence() {
        
        Test.startTest();
            String result = DAOH_CLM_APTS_Agreement.getQuoteErrorMessageBySequence(new List<String>{'Sample Error'});
        Test.stopTest();
         
        System.assertEquals('1. Sample Error   - ', result, 'The error message should be same');
    }

    @isTest
    private static void testValidateSignerInfo() {
        Contact internalCon = [SELECT Id FROM Contact WHERE LastName = 'Internal' LIMIT 1];
        Contact externalCon = [SELECT Id FROM Contact WHERE LastName = 'External' LIMIT 1];
        
        Apttus__APTS_Agreement__c oldAgreement = [SELECT Id, Name,Apttus__Company_Signed_By__c, Apttus__Other_Party_Signed_By__c
                                                  FROM Apttus__APTS_Agreement__c 
                                                  WHERE Name = 'Test OSA Agreement' LIMIT 1];
        Apttus__APTS_Agreement__c newAgreement = oldAgreement.clone(true, false, false, false);
        newAgreement.Apttus__Company_Signed_By__c = externalCon.Id;
        newAgreement.Apttus__Other_Party_Signed_By__c = internalCon.Id;
        Map<Id, Apttus__APTS_Agreement__c> oldMap = new Map<Id, Apttus__APTS_Agreement__c>();
        oldMap.put(oldAgreement.Id, oldAgreement);
        Test.startTest();
            try{
                DAOH_CLM_APTS_Agreement.validateSignerInfo(new List<Apttus__APTS_Agreement__c>{newAgreement}, oldMap);
            } catch(Exception e) {
                System.assertEquals(true, e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION'));
            }
        Test.stopTest();
    }

    @isTest
    private static void testShareActivatedAGRDocOnOpp() {
        Apttus__APTS_Agreement__c oldAgreement = [SELECT id, OwnerId, Apttus__Status__c,
            Apttus__Status_Category__c,Apttus__Related_Opportunity__c FROM Apttus__APTS_Agreement__c WHERE Name = 'Test RWLP Agreement' LIMIT 1];

        Apttus__APTS_Agreement__c newAgreement = oldAgreement.clone(true, false, false, false);
        newAgreement.Apttus__Status_Category__c = 'In Effect';
        newAgreement.Apttus__Status__c = 'Activated';
        newAgreement.Apttus__Activated_Date__c = Date.today();

        Map<Id, Apttus__APTS_Agreement__c> oldMap = new Map<Id, Apttus__APTS_Agreement__c>();
        oldMap.put(oldAgreement.Id, oldAgreement);

        Test.startTest();
            DAOH_CLM_APTS_Agreement.shareActivatedAGRDocOnOpp(new List<Apttus__APTS_Agreement__c>{newAgreement}, oldMap);
        Test.stopTest();
        
        List<ContentDocumentLink> cdlsOpp = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId =: oldAgreement.Apttus__Related_Opportunity__c];
        System.assertNotEquals(0, cdlsOpp.size(), 'Activated document not shared with opportunity when expected');
        
    }

    @isTest
    private static void testCreateTasksOnAgreementsInAuthoring() {
        Map<Id, Apttus__APTS_Agreement__c> oldMap = new Map<Id, Apttus__APTS_Agreement__c>(); 
        Apttus__APTS_Agreement__c oldAgreement = [SELECT Id, Apttus__Status_Category__c, OwnerId, RecordTypeId FROM Apttus__APTS_Agreement__c 
            WHERE Name = 'Test 4784 Agreement 1' LIMIT 1];
        oldMap.put(oldAgreement.Id, oldAgreement);
        Apttus__APTS_Agreement__c newAgr = oldAgreement.clone(true, false, false, false);
        newAgr.Apttus__Status_Category__c = CON_CLM.IN_AUTHORING;
        
        Test.startTest();
            DAOH_CLM_APTS_Agreement.createTasksOnAgreementsInAuthoring(new List<Apttus__APTS_Agreement__c>{newAgr}, oldMap);
        Test.stopTest();
        
        Integer count = [SELECT Count() FROM Task WHERE Subject LIKE '%PL Review%' OR Subject LIKE '%PFM Review%' OR Subject LIKE '%QC Review%'];
        System.assertEquals(3, count, 'Tasks should be created');
    }    
    
    @isTest
    private static void testCreateTaskOnContractManagerUpdate()
    {
        Map<Id, Apttus__APTS_Agreement__c> oldMap = new Map<Id, Apttus__APTS_Agreement__c>();
        Contact contact = [SELECT Id FROM Contact WHERE EmployeeNumber__c = '1234567'];
        Apttus__APTS_Agreement__c oldAgreement = [SELECT Id, Name, IQVIA_Contract_Manager__c, OwnerId FROM Apttus__APTS_Agreement__c 
            WHERE Name = 'Test PSA AGR With Oppr' LIMIT 1 ];
        oldMap.put(oldAgreement.Id, oldAgreement);
        Apttus__APTS_Agreement__c newAgreement = oldAgreement.clone(true, false, false, false);
        newAgreement.IQVIA_Contract_Manager__c = contact.Id;
        
        Test.startTest();
            DAOH_CLM_APTS_Agreement.createTaskonContractManagerUpdate(new List<Apttus__APTS_Agreement__c>{newAgreement}, oldMap);
        Test.stopTest();
        
        Integer count = [SELECT Count() FROM Task WHERE Subject LIKE '%LCN Review%'];
        System.assertEquals(1, count, 'Tasks should be created');
    }

    @isTest
    private static void testPopulateAgreementStartDate()
    {
        Map<Id, Apttus__APTS_Agreement__c> oldMap = new Map<Id, Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c oldAgreement = [SELECT Id, Name, Apttus__Company_Signed_Date__c,Apttus__Contract_Start_Date__c, Apttus__Other_Party_Signed_Date__c, Apttus__Status__c
            FROM Apttus__APTS_Agreement__c 
            WHERE Name = 'Test PSA AGR With Oppr' LIMIT 1 ];
        oldMap.put(oldAgreement.Id, oldAgreement);
        Apttus__APTS_Agreement__c newAgreement = oldAgreement.clone(true, false, false, false);
        newAgreement.Apttus__Status__c = CON_CLM.FULLY_SIGNED;
        newAgreement.Apttus__Contract_Start_Date__c = null;
        newAgreement.Apttus__Other_Party_Signed_Date__c = Date.today();
        
        Test.startTest();
            DAOH_CLM_APTS_Agreement.populateAgreementStartDate(new List<Apttus__APTS_Agreement__c>{newAgreement}, oldMap);
        Test.stopTest();
        
        
        System.assertEquals(newAgreement.Apttus__Contract_Start_Date__c,newAgreement.Apttus__Other_Party_Signed_Date__c ,
            'Start date not populated correctly when expected');
    }
    
    @isTest
    private static void testPopulateDateFirstSentToCustomer()
    {
        Map<Id, Apttus__APTS_Agreement__c> oldMap = new Map<Id, Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c oldAgreement = [SELECT Id, Name, Apttus__Status__c, Date_first_sent_to_Customer__c 
            FROM Apttus__APTS_Agreement__c WHERE Name = 'Test PSA AGR With Oppr' LIMIT 1 ];
        oldMap.put(oldAgreement.Id, oldAgreement);
        Apttus__APTS_Agreement__c newAgreement = oldAgreement.clone(true, false, false, false);
        newAgreement.Apttus__Status_Category__c = CON_CLM.IN_BUDGETING;
        newAgreement.Apttus__Status__c = CON_CLM.BUDGET_EXTERNAL_REVIEW;
        
        Test.startTest();
            DAOH_CLM_APTS_Agreement.populateDateFirstSentToCustomer(new List<Apttus__APTS_Agreement__c>{newAgreement}, oldMap);
        Test.stopTest();
        
        System.assertEquals(newAgreement.Date_first_sent_to_Customer__c, System.Today(),
            'Date first sent to Customer not populated when expected');
    }
    
    @isTest 
    private static void testUpdateParallelChangeOrderAmendmentsForChild() {
        List<Apttus_Proposal__Proposal__c> budget1 = [SELECT Budget_Template_Name__c, Id, Apttus_QPComply__MasterAgreementId__c, Apttus_Proposal__Proposal_Name__c FROM Apttus_Proposal__Proposal__c ];
        Apttus_Proposal__Proposal__c budget = [SELECT Budget_Template_Name__c, Id, Apttus_QPComply__MasterAgreementId__c, Apttus_Proposal__Proposal_Name__c FROM Apttus_Proposal__Proposal__c WHERE Budget_Template_Name__c = 'budget1' LIMIT 1];
        Apttus__APTS_Agreement__c childAgr = [SELECT Id, Name, Apttus__Status_Category__c, Apttus__Status__c, Agreement_Cloned_From__c, Apttus_QPComply__RelatedProposalId__c, Apttus__Agreement_Number__c, 
            Special_Terms_Included__c FROM Apttus__APTS_Agreement__c WHERE Name = 'Test Child Agreement2' LIMIT 1];
        Map<Id, Apttus__APTS_Agreement__c> oldMap = new Map<Id, Apttus__APTS_Agreement__c>();
        oldMap.put(childAgr.Id, childAgr); 
        Apttus__APTS_Agreement__c parentAgr = [SELECT Id, Name, Apttus__Status_Category__c, Apttus__Status__c, Agreement_Cloned_From__c, Apttus_QPComply__RelatedProposalId__c, Apttus__Agreement_Number__c, 
            Special_Terms_Included__c FROM Apttus__APTS_Agreement__c WHERE Name = 'Test Parent Agreement' LIMIT 1];
        Apttus__APTS_Agreement__c newChildAgr = childAgr.clone(true, false, false, false);
        newChildAgr.Apttus__Status_Category__c = CON_CLM.IN_EFFECT;
        newChildAgr.Apttus__Status__c = CON_CLM.ACTIVATED;    
        newChildAgr.Special_Terms_Included__c = CON_CLM.PARALLEL_CO; 
        newChildAgr.Apttus_QPComply__RelatedProposalId__c = budget.Id;   
        Test.startTest();
            budget.Apttus_QPComply__MasterAgreementId__c = parentAgr.Id;
            update budget;  
            parentAgr.Apttus__Status_Category__c = CON_CLM.IN_EFFECT;
            parentAgr.Apttus__Status__c = CON_CLM.ACTIVATED;
            parentAgr.Apttus__Perpetual__c = true;
            update parentAgr;
            DAOH_CLM_APTS_Agreement.updateParallelChangeOrderAmendments(new List<Apttus__APTS_Agreement__c>{newChildAgr}, oldMap);        
        Test.stopTest();
        
        System.assertEquals('Being Amended', newChildAgr.Apttus__Status__c, 'Status field must be updated');
    }  
    
    @isTest
    private static void testUpdateSiblingAgrForParallelCO() { 
        Apttus__APTS_Agreement__c agreement = [SELECT Id, Name, Apttus__Status_Category__c, Apttus__Status__c, Special_Terms_Included__c FROM Apttus__APTS_Agreement__c WHERE Name = 'Test PSA Agreement Payment Term' LIMIT 1];
        
        Test.startTest();
            agreement.Apttus__Status_Category__c = CON_CLM.IN_EFFECT;
            agreement.Apttus__Status__c = CON_CLM.BEING_AMENDED;
            agreement.Apttus__Perpetual__c = true;
            update agreement; 
            DAOH_CLM_APTS_Agreement.updateSiblingAgrForParallelCO(new Set<Id>{agreement.Id}, false);
        Test.stopTest();
        
        Apttus__APTS_Agreement__c result = [SELECT Id, Apttus__Status_Category__c FROM Apttus__APTS_Agreement__c WHERE Name = 'Test PSA Agreement Payment Term' LIMIT 1];
        System.assertEquals('Amended', result.Apttus__Status_Category__c, 'The Status Category should match');
    }    
    
    @isTest
    private static void testSetNotifyCustomerIfMissingINVCont() {
        List<Apttus__APTS_Agreement__c> newAgreementList = new List<Apttus__APTS_Agreement__c>();
        Map<Id, Apttus__APTS_Agreement__c> oldMap = new Map<Id, Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c oldAgreement = [SELECT Id, Name, Does_MSA_Include_3rd_Party_Flow_Downs__c FROM Apttus__APTS_Agreement__c WHERE Name = 'Test 5597 MSA Agreement' LIMIT 1];
        
        Apttus__APTS_Agreement__c newAgreement = oldAgreement.clone(true, false, false, false);
        newAgreement.Does_MSA_Include_3rd_Party_Flow_Downs__c = 'No';
        newAgreementList.add(newAgreement);
        oldMap.put(oldAgreement.Id, oldAgreement);
        
        Test.startTest();
            DAOH_CLM_APTS_Agreement.setNotifyCustomerIfMissingINVCont(newAgreementList, oldMap);
        Test.stopTest();
        
        System.assertEquals('N/A', newAgreementList[0].Notify_Customer_if_FD_missing_in_V_Cont__c, 'Notify Customer if FD Missing in V Cont. is not updated.');
    }

    @isTest
    private static void testValidateHCBudgetLink() { 
        
        Apttus__APTS_Agreement__c testRWLPAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.RWLP_RECORDTYPEID, false);
        testRWLPAgreement.Name = 'Test RWLP Agreement';
        testRWLPAgreement.Apttus__Subtype__c = 'Work Order';
        testRWLPAgreement.Confidence_In_Approval_Of_Budget_Draft__c = 'High';

        Test.startTest();
            try {
                DAOH_CLM_APTS_Agreement.validateHCBudgetLink(new List<Apttus__APTS_Agreement__c>{testRWLPAgreement}, null);
            } catch(Exception e) {
                System.assertEquals(true, e.getMessage().contains(System.label.CLM_CL00025_HC_Budget_Link_Error));
            }
        Test.stopTest();

        System.assertEquals(true, ApexPages.getMessages().size() > 0, 
            'The value should be true and error message should be shown.');
        
    }

    @isTest
    private static void testUpdateIQAGRToInAuthoring() {
        Apttus__APTS_Agreement__c oldAgreement = [SELECT Id,IQVIA_Agreement__c, Name, Apttus__Status_Category__c, Apttus__Status__c, RecordTypeId, Apttus__Workflow_Trigger_Viewed_Final__c
            FROM Apttus__APTS_Agreement__c WHERE Name = 'Test Generic Agreement'];

        Apttus__APTS_Agreement__c newAgreement = oldAgreement.clone(true, false, false, false);
        newAgreement.Apttus__Workflow_Trigger_Viewed_Final__c = true;
        Map<Id, Apttus__APTS_Agreement__c> oldMap = new Map<Id, Apttus__APTS_Agreement__c>();
        oldMap.put(oldAgreement.Id, oldAgreement);

        Test.startTest();
            DAOH_CLM_APTS_Agreement.updateIQAGRToInAuthoring(new List<Apttus__APTS_Agreement__c>{newAgreement}, oldMap);
        Test.stopTest();
        
        IQVIA_Agreement__c iQAGR = [SELECT Id, Status_Category__c, Status__c FROM IQVIA_Agreement__c WHERE Id =: oldAgreement.IQVIA_Agreement__c];
        System.assertEquals('In Authoring', iQAGR.Status_Category__c, 'Returned status category is not what is expected.');
        System.assertEquals('Author Contract', iQAGR.Status__c, 'Returned status is not what is expected.');
    }

    @isTest
    private static void testValidateStatusChangeToIR() {
        Map<Id, Apttus__APTS_Agreement__c> oldMap = new Map<Id, Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c oldAgreement = [SELECT Id, Name, Apttus__Status__c, Date_first_sent_to_Customer__c 
            FROM Apttus__APTS_Agreement__c WHERE Name = 'Test PSA AGR With Oppr' LIMIT 1 ];
        oldAgreement.Apttus__Status_Category__c = CON_CLM.IN_AUTHORING;
        oldAgreement.Apttus__Status__c = CON_CLM.STATUS_OTHER_PARTY_REVIEW;

        oldMap.put(oldAgreement.Id, oldAgreement);
        Apttus__APTS_Agreement__c newAgreement = oldAgreement.clone(true, false, false, false);
        newAgreement.Apttus__Status_Category__c = CON_CLM.IN_AUTHORING;
        newAgreement.Apttus__Status__c = CON_CLM.INTERNAL_REVIEW;
        
        Test.startTest();
            try {
                DAOH_CLM_APTS_Agreement.validateStatusChangeToIR(new List<Apttus__APTS_Agreement__c>{newAgreement}, oldMap);
            } catch(Exception e) {
                System.assertEquals(true, e.getMessage().contains(System.Label.CLM_CL00027_Internal_Review_Error));
            }
        Test.stopTest();
    }
    
    @isTest
    private static void testUpdateBidonAgreementUpdate() {
        Map<Id, Apttus__APTS_Agreement__c> oldMap = new Map<Id, Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c oldAgreement = [SELECT Id, Bid_History__c, Apttus__Status_Category__c, Planned_Execution_Date__c 
            FROM Apttus__APTS_Agreement__c WHERE Name = 'Test Initial Draft Agreement' LIMIT 1 ];
        Bid_History__c bid = [SELECT Id FROM Bid_History__c LIMIT 1];
        oldMap.put(oldAgreement.Id, oldAgreement);
        Apttus__APTS_Agreement__c newAgreement = oldAgreement.clone(true, false, false, false);
        newAgreement.Planned_Execution_Date__c = System.today();
        newAgreement.Bid_History__c = bid.Id;
        
        Test.startTest();
            DAOH_CLM_APTS_Agreement.updateBidonAgreementUpdate(new List<Apttus__APTS_Agreement__c>{newAgreement}, oldMap);
        Test.stopTest();
        
        Bid_History__c bidFinal = [SELECT Id, Bid_Due_Date__c FROM Bid_History__c WHERE Id =: bid.Id LIMIT 1];
        System.assertEquals(newAgreement.Planned_Execution_Date__c, bidFinal.Bid_Due_Date__c, 'Bid Due Date should updated');
    }

    @isTest
    private static void testUpdateIQAGRRecordTypeName() {
        Apttus__APTS_Agreement__c agreement = [SELECT Id,IQVIA_Agreement__c, Name, Apttus__Status_Category__c, Apttus__Status__c, RecordTypeId, Apttus__Workflow_Trigger_Viewed_Final__c
            FROM Apttus__APTS_Agreement__c WHERE Name = 'Test Generic Agreement'];


        Test.startTest();
            DAOH_CLM_APTS_Agreement.updateIQAGRRecordTypeName(new List<Apttus__APTS_Agreement__c>{agreement});
        Test.stopTest();
        
       
        System.assertEquals('USBU', agreement.IQ_Agreement_Record_Type_Developer_Name__c, 'Returned value is not expected');
    }
    
    @isTest
    private static void testSetAnalystStartDateFromBidRR() {
        Apttus__APTS_Agreement__c agr = [SELECT Id, Bid_History__c, Analyst_Start_Date__c, Start_Draft_Budget__c FROM Apttus__APTS_Agreement__c WHERE Name = 'Test RWLP Agreement' LIMIT 1];
        Bid_History__c bid = [SELECT Id FROM Bid_History__c LIMIT 1];
        agr.Bid_History__c = bid.Id;
        
        Test.startTest();
            DAOH_CLM_APTS_Agreement.setAnalystStartDateFromBidRR(new List<Apttus__APTS_Agreement__c>{agr}, null);
        Test.stopTest();
        
        System.assertEquals(System.today() + 10, agr.Analyst_Start_Date__c, 'The analyst date must not be null.');
        System.assertEquals(System.today() + 10, agr.Start_Draft_Budget__c , 'The draft date must not be null.');
    }

    @isTest
    private static void testAllowCOAmendmentSubTypeOnlyMSA() {
        Apttus__APTS_Agreement__c oldAgreement = [SELECT id, OwnerId, Apttus__Status__c,
            Apttus__Status_Category__c,Apttus__Related_Opportunity__c,Apttus__Subtype__c,RecordTypeId, Original_Agreement__c FROM Apttus__APTS_Agreement__c WHERE Name = 'Test 5597 MSA Agreement' LIMIT 1];
        oldAgreement.Apttus__Subtype__c = 'Service Agreement';

        Apttus__APTS_Agreement__c amendedAgreement = oldAgreement.clone();
        amendedAgreement.Apttus__Version_Number__c = 1;
        amendedAgreement.Agreement_Cloned_From__c = oldAgreement.Id;
        amendedAgreement.Original_Agreement__c = oldAgreement.Id;
        insert amendedAgreement;
        
        Apttus__APTS_Agreement__c newAmendedAgreement = amendedAgreement.clone(true, false, false, false);
        newAmendedAgreement.Apttus__Subtype__c = 'Amendment';   
        
        Map<Id, Apttus__APTS_Agreement__c> oldMap = new Map<Id, Apttus__APTS_Agreement__c>();
        oldMap.put(amendedAgreement.Id, amendedAgreement);

        Test.startTest();
        	update oldAgreement;
            DAOH_CLM_APTS_Agreement.allowCOAmendmentSubTypeOnly(new List<Apttus__APTS_Agreement__c>{newAmendedAgreement}, oldMap);
        Test.stopTest();

        System.assertEquals(true, ApexPages.getMessages()[0].getDetail().contains(System.Label.CLM_CL00018_MSA_SERVICE_SUBTYPE_AMEND_ERROR), 
            'The value should be true and error message should be shown.');        
    }

    @isTest
    private static void testSetPerpetualOnFullySigned() {
        Apttus__APTS_Agreement__c oldAgreementGSA = [SELECT Id, Name, Apttus__Status__c,
            Apttus__Other_Party_Signed_Date__c, Apttus__Company_Signed_Date__c, Apttus__Perpetual__c FROM Apttus__APTS_Agreement__c 
            WHERE RecordTypeId =: CON_CLM.PSA_RECORDTYPEID AND Name =: 'Test 4784 Agreement 1' LIMIT 1];
        
        Apttus__APTS_Agreement__c newAgreementGSA = oldAgreementGSA.clone(true, false, false, false);
        newAgreementGSA.Apttus__Status_Category__c = CON_CLM.IN_SIGNATURES;
        newAgreementGSA.Apttus__Status__c = CON_CLM.FULLY_SIGNED;
     
        Map<Id, Apttus__APTS_Agreement__c> oldMap = new Map<Id, Apttus__APTS_Agreement__c>();
        oldMap.put(oldAgreementGSA.Id, oldAgreementGSA);
		
        Test.startTest();
            DAOH_CLM_APTS_Agreement.setPerpetualOnFullySigned
                (new List<Apttus__APTS_Agreement__c>{newAgreementGSA}, oldMap);
        Test.stopTest();
        
        System.assertEquals(newAgreementGSA.Apttus__Perpetual__c, true, 
            'Perpetual should be set to true.');
    }
}