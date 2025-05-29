/**
* This test class is used to test all methods in opportunity trigger helper.
* version : 1.0
*/
@IsTest
private class TST_DAO_APTS_Agreement {
    
    /**
    * This method is used to setup data for all methods.
    */
    @TestSetup
    static void dataSetup() 
	{
        Account acc = UTL_OWF_TestData.createAccount();
        insert acc;
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        Contact cont = UTL_OWF_TestData.createContact(acc.Id); 
        cont.pse__Is_Resource__c = true;
        cont.pse__Is_Resource_Active__c = true;
        cont.pse__Group__c = grp.Id;
        insert cont;
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        pse__Permission_Control__c permissionControlGroup1 = UTL_OWF_TestData.createPermissionControl(cont, null, null, null);
        insert permissionControlGroup1;

        List<User> salesUserList = UTL_TestData.createUser('Sales User',1);
        salesUserList.get(0).LastName = 'Test Sales User';
        insert salesUserList;
        
        Account account = new Account(Name = 'IMS Health Global',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert account;
        
        Contact contact = new Contact(FirstName='test', Email='test@example.com', LastName ='lastname');
        contact.Account = account;
        contact.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('IQVIA_User_Contact').getRecordTypeId();
        contact.Inactive__c = false;
        contact.EmployeeNumber__c = '123456789';
        insert contact; 

        CLM_Configuration__c clmConfiguration = TST_CLM_TestDataFactory.createClmConfigurationSetting(false);
        clmConfiguration.RecordTypeForStatusAutomation__c = 'PSA;MSA;Preliminary_Agreement';
        clmConfiguration.GBO_Team_Email_Address__c = 'clmintegration@iqvia.com';
        insert clmConfiguration; 

    }

    @isTest
    private static void testCLMAgreement() {
        

        Account account = new Account(Name = 'IMS Health Global',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert account;
        
        Contact contact = new Contact(FirstName='test', Email='test@example.com', LastName ='lastname');
        contact.Account = account;
        insert contact;

        List<Apttus__APTS_Agreement__c> lstAgreement = new List<Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        agreement.Name = 'Test Agreement';
        agreement.Apttus__Primary_Contact__c = contact.Id;
        agreement.Apttus__Account__c = account.Id;
        agreement.Services__c = 'Data Management;IQVIA Technology Services';
        lstAgreement.add(agreement);

        Apttus__APTS_Agreement__c prelimagreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PRELIMINARY_RECORDTYPEID, false);
        prelimagreement.Name = 'Test Prelim Agreement';
        lstAgreement.add(prelimagreement);
        
        Apttus__APTS_Agreement__c osaAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.OSA_RECORDTYPEID, false);
        osaAgreement.Name = 'Test OSA Agreement';
        osaAgreement.Apttus__Status__c = 'Other Party Review';
        osaAgreement.Confidence_In_Approval_Of_Budget_Draft__c = 'High';
        osaAgreement.Unsigned_Comments__c = 'test';
        lstAgreement.add(osaAgreement);
        

        insert lstAgreement;
    }

    @isTest
    private static void testPopulatePSAInitialDraftFields() {
        Apttus__APTS_Agreement__c psaAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        psaAgreement.Name = 'Test Initial Draft Agreement';
        psaAgreement.Confidence_In_Approval_Of_Budget_Draft__c = 'High';
        psaAgreement.High_Confidence_Budget_Link1__c = 'xyz.com';
        insert psaAgreement;

        psaAgreement.Apttus__Status__c = 'Other Party Review';
        
        Test.startTest();
            update psaAgreement;
        Test.stopTest();

        Apttus__APTS_Agreement__c result = [Select Id, Initial_Draft_At_High_Confidence_Date__c FROM Apttus__APTS_Agreement__c 
            WHERE Name = 'Test Initial Draft Agreement' LIMIT 1];
        System.assertEquals(Date.today(), result.Initial_Draft_At_High_Confidence_Date__c, 
            'Date must have populated with current date but it is not.');
    }
    
    @isTest
    private static void testUpdateTotalAgreementValueOnBeforeInsert() {
        List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c testAgreementPSA1 = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        testAgreementPSA1.Name = 'Test 4784 Agreement 1';
        testAgreementPSA1.Actual_Agreement_Value__c = 1;
        testAgreementPSA1.Project_Expenses__c = 2;
        agreementList.add(testAgreementPSA1);
        
        Apttus__APTS_Agreement__c testAgreementPSA2 = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        testAgreementPSA2.Name = 'Test 4784 Agreement 2';
        testAgreementPSA2.Project_Expenses__c = 2;
        agreementList.add(testAgreementPSA2);
        
        Apttus__APTS_Agreement__c testAgreementPSA3 = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        testAgreementPSA3.Name = 'Test 4784 Agreement 3';
        testAgreementPSA3.Actual_Agreement_Value__c = 1;
        agreementList.add(testAgreementPSA3);
        
        Apttus__APTS_Agreement__c testAgreementPSA4 = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        testAgreementPSA4.Name = 'Test 4784 Agreement 4';
        agreementList.add(testAgreementPSA4);

        Apttus__APTS_Agreement__c testAgreementPrel = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PRELIMINARY_RECORDTYPEID, false);
        testAgreementPrel.Name = 'Test Prel';
        agreementList.add(testAgreementPrel);

        Test.startTest();
        	insert agreementList;
        Test.stopTest();

        List<Apttus__APTS_Agreement__c> agreementListAfterInsert = [SELECT id, Name, RecordTypeId, Project_Expenses__c, 
            Actual_Agreement_Value__c, Apttus__Total_Contract_Value__c
            FROM Apttus__APTS_Agreement__c WHERE Name like 'Test 4784 Agreement%'];
        System.assertEquals(3, agreementListAfterInsert[0].Apttus__Total_Contract_Value__c, 
            'Total Agreement Value is not updated when both Actual Agreement Value and Project Expenses are populated');
        System.assertEquals(2, agreementListAfterInsert[1].Apttus__Total_Contract_Value__c, 
            'Total Agreement Value is not updated when Actual Agreement Value is null and Project Expenses is populated');
        System.assertEquals(1, agreementListAfterInsert[2].Apttus__Total_Contract_Value__c, 
            'Total Agreement Value is not updated when Actual Agreement Value is populated and Project Expenses is null');
        System.assertEquals(null, agreementListAfterInsert[3].Apttus__Total_Contract_Value__c, 
            'Total Agreement Value is not null when both Actual Agreement Value and Project Expenses are null');
    }
    
    @isTest
    private static void testUpdateTotalAgreementValueOnBeforeUpdate() {
        List<Apttus__APTS_Agreement__c> newAgreementList = new List<Apttus__APTS_Agreement__c>();
        List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c testAgreementPSA1 = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        testAgreementPSA1.Name = 'Test 4784 Agreement 1';
        testAgreementPSA1.Actual_Agreement_Value__c = 1;
        testAgreementPSA1.Project_Expenses__c = 2;
        agreementList.add(testAgreementPSA1);
        
        Apttus__APTS_Agreement__c testAgreementPSA2 = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        testAgreementPSA2.Name = 'Test 4784 Agreement 2';
        testAgreementPSA2.Project_Expenses__c = 2;
        agreementList.add(testAgreementPSA2);

        Apttus__APTS_Agreement__c testAgreementPrel = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PRELIMINARY_RECORDTYPEID, false);
        testAgreementPrel.Name = 'Test 4784 Prel';
        testAgreementPrel.Project_Expenses__c = 2;
        agreementList.add(testAgreementPrel);
        insert agreementList;
        
        agreementList[0].Actual_Agreement_Value__c = 4;
        agreementList[0].Project_Expenses__c = 5;
        agreementList[1].Actual_Agreement_Value__c = null;
        agreementList[1].Project_Expenses__c = null;
        agreementList[2].Project_Expenses__c = null;

        Test.startTest();
            update agreementList;
        Test.stopTest();

        Apttus__APTS_Agreement__c newAgreement1 = [SELECT id, Name, RecordTypeId, Project_Expenses__c, 
            Actual_Agreement_Value__c, Apttus__Total_Contract_Value__c
            FROM Apttus__APTS_Agreement__c WHERE Name = 'Test 4784 Agreement 1'];
        
        Apttus__APTS_Agreement__c newAgreement2 = [SELECT id, Name, RecordTypeId, Project_Expenses__c, 
            Actual_Agreement_Value__c, Apttus__Total_Contract_Value__c
            FROM Apttus__APTS_Agreement__c WHERE Name = 'Test 4784 Agreement 2'];
        System.assertEquals(9, newAgreement1.Apttus__Total_Contract_Value__c, 'Total Agreement Value is not updated.');
        System.assertEquals(null, newAgreement2.Apttus__Total_Contract_Value__c, 'Total Agreement Value should be null.');
    }
    
    @isTest
    private static void testUpdateOpportunityNumber() {
        Apttus__APTS_Agreement__c agreementPSA = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        agreementPSA.Name = 'Test PSA Agreement';
        insert agreementPSA;
        
        Account account = new Account(Name = 'IMS Health Global',CustomerSegment__c = 'GOVERNMENT',Sub_Industry__c = 'STATE');
        insert account;
        
        Opportunity opportunity = UTL_TestData.createOpportunity(account.Id);
        insert opportunity;
        
        agreementPSA.Apttus__Related_Opportunity__c = opportunity.Id;
        
        Test.startTest();
            update agreementPSA;
        Test.stopTest();
        
        Apttus__APTS_Agreement__c agreement = [SELECT Id,Opportunity_Number__c,Apttus__Related_Opportunity__r.Opportunity_Number__c FROM Apttus__APTS_Agreement__c WHERE Id =: agreementPSA.Id LIMIT 1];
        System.assertEquals(agreement.Apttus__Related_Opportunity__r.Opportunity_Number__c, agreement.Opportunity_Number__c , 'Agreement Opportunity Number not matching with opportunity record');
    }

    @isTest
    private static void testUpdateAgreementforIsStudyAwardedOnBeforeInsert() {
        Opportunity newOpportunity = TST_CLM_TestDataFactory.createOpportunity(false);
        newOpportunity.stageName = '5. Finalizing Deal';
        insert newOpportunity;
        List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c testAgreementPre1 = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PRELIMINARY_RECORDTYPEID, false);
        testAgreementPre1.Name = 'Test Preliminary Agreement';
        testAgreementPre1.Apttus__Related_Opportunity__c = newOpportunity.Id;
        testAgreementPre1.Is_Study_Awarded__c = 'No';
        agreementList.add(testAgreementPre1);

        Test.startTest();
            insert agreementList;
        Test.stopTest();

        List <Apttus__APTS_Agreement__c> ListAgreementAfterInsert = [SELECT Id, Name, Apttus__Related_Opportunity__c, Is_Study_Awarded__c 
            FROM Apttus__APTS_Agreement__c WHERE RecordTypeId =: CON_CLM.PRELIMINARY_RECORDTYPEID AND
            Name =: 'Test Preliminary Agreement' LIMIT 1];

        System.assertEquals('Yes', ListAgreementAfterInsert[0].Is_Study_Awarded__c, 'Returned study awarded is not what is expected.');
    }

    @isTest
    private static void testUpdateAgreementforIsStudyAwardedOnBeforeUpdate() {
        Opportunity newOpportunity = TST_CLM_TestDataFactory.createOpportunity(false);
        newOpportunity.stageName = '4. Delivering Proposal';
        insert newOpportunity;
        List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c testAgreementPre1 = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PRELIMINARY_RECORDTYPEID, false);
        testAgreementPre1.Name = 'Test Update Preliminary Agreement';
        testAgreementPre1.Apttus__Related_Opportunity__c = newOpportunity.Id;
        testAgreementPre1.Is_Study_Awarded__c = 'No';
        agreementList.add(testAgreementPre1);
        insert agreementList;
        agreementList[0].Is_Study_Awarded__c = 'Yes';

        Test.startTest();
            update agreementList;
        Test.stopTest();
        
        List <Apttus__APTS_Agreement__c> ListAgreementAfterUpdate = [SELECT Id, Name, Apttus__Related_Opportunity__c, Is_Study_Awarded__c 
            FROM Apttus__APTS_Agreement__c WHERE RecordTypeId =: CON_CLM.PRELIMINARY_RECORDTYPEID AND
            Name =: 'Test Update Preliminary Agreement' LIMIT 1];

        System.assertEquals('No', ListAgreementAfterUpdate[0].Is_Study_Awarded__c, 'Returned study awarded is not what is expected.');
    }
    
    @isTest
    private static void testUpdateRelatedAgreementOnQuoteShouldUpdateCOQuote() {
        Opportunity newOpportunity = TST_CLM_TestDataFactory.createOpportunity(false);
        newOpportunity.stageName = '5. Finalizing Deal';
        insert newOpportunity;
        
        Apttus_Proposal__Proposal__c budget = TST_CLM_TestDataFactory.createProposalQuote(false);
        budget.RecordTypeId = CON_CLM.QUOTE_RDS_BUDGET_RECORDTYPE;
        budget.Apttus_Proposal__Opportunity__c = newOpportunity.Id;
        budget.Apttus_Proposal__Primary__c = true;
        budget.Apttus_Proposal__Proposal_Category__c = CON_CLM.PROPOSAL_CHANGE_ORDER;
        budget.Scenario_Number__c = 123.0;
        budget.Budget_Iteration__c = 1;
        insert budget;
        
        budget.Apttus_Proposal__Approval_Stage__c = CON_CLM.PROPOSAL_APPROVAL_STAGE_ACCEPTED;
        update budget;
        
        Apttus__APTS_Agreement__c testPSAAGRWithOpp = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        testPSAAGRWithOpp.Name = 'Test PSA AGR With Oppr';
        testPSAAGRWithOpp.Actual_Agreement_Value__c = 1;
        testPSAAGRWithOpp.Project_Expenses__c = 2;
        testPSAAGRWithOpp.Apttus__Related_Opportunity__c = newOpportunity.Id;
        testPSAAGRWithOpp.Apttus_QPComply__RelatedProposalId__c = budget.Id; 
        testPSAAGRWithOpp.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_CHANGEORDER;
        
        Test.startTest();
            insert testPSAAGRWithOpp;
        Test.stopTest();

        Apttus_Proposal__Proposal__c proposal = [SELECT Id, Apttus_QPComply__MasterAgreementId__c 
            FROM Apttus_Proposal__Proposal__c 
        	WHERE Apttus_Proposal__Opportunity__c =: testPSAAGRWithOpp.Apttus__Related_Opportunity__c
            AND Apttus_Proposal__Primary__c = true];
        System.assertEquals(proposal.Apttus_QPComply__MasterAgreementId__c, testPSAAGRWithOpp.Id ,
            'Agreement Id not updated on Proposal when expected');
    }
    
    @isTest
    private static void testValidateProvisionTabOnAfterUpdate() {
        List<Apttus__APTS_Agreement__c> agreementList = new List<Apttus__APTS_Agreement__c>();
        List<Apttus__APTS_Agreement__c> agreementUpdatedList = new List<Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c testAgreementMSA = TST_CLM_TestDataFactory.createAgreement(CON_CLM.MSA_RECORDTYPEID, false);
        testAgreementMSA.Name = 'Test MSA Agreement';
        testAgreementMSA.Apttus__Contract_Start_Date__c = null;
        agreementList.add(testAgreementMSA);
        
        Apttus__APTS_Agreement__c testAgreementPSA = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        testAgreementPSA.Name = 'Test PSA Agreement';
        testAgreementPSA.Apttus__Contract_Start_Date__c = null;
        agreementList.add(testAgreementPSA);
        insert agreementList;

        /*
        Agreement_Extension__c agreementExt = TST_CLM_TestDataFactory.createAgreementExtension(testAgreementPSA.Id,false);
        agreementExt.Late_Payment_Clause__c = 'Within fallbacks';
        insert agreementExt;*/
        
        
        testAgreementMSA.Apttus__Status_Category__c = 'In Signatures';
        testAgreementPSA.Apttus__Status_Category__c = 'In Signatures';
        testAgreementMSA.Apttus__Status__c = CON_CLM.READY_FOR_SIGNATURES;
        testAgreementPSA.Apttus__Status__c = CON_CLM.READY_FOR_SIGNATURES;
        agreementUpdatedList.add(testAgreementMSA);
        agreementUpdatedList.add(testAgreementPSA);
        
        Test.startTest();
            try {
                update agreementUpdatedList; 
            } catch(Exception e) {
                Boolean expectedExceptionThrown =  e.getMessage().contains(
                    'Complete this field') 
                    ? true : false;
                System.assertEquals(expectedExceptionThrown, true, 'Provision tab Validation error message is not raised');
            }
        Test.stopTest();
        
        List<Apttus__APTS_Agreement__c> agreementList2 = [SELECT Id, Name, Apttus__Status__c FROM Apttus__APTS_Agreement__c
            WHERE Name IN ('Test MSA Agreement', 'Test PSA Agreement')];
        System.assertNotEquals(CON_CLM.READY_FOR_SIGNATURES, agreementList2[0].Apttus__Status__c, 'Agreement Status should not changed.');
        System.assertNotEquals(CON_CLM.READY_FOR_SIGNATURES, agreementList2[1].Apttus__Status__c, 'Agreement Status should not changed.');
    }

    @isTest
    private static void testSetAutoRenewFieldOnBeforeInsert() {
        Apttus__APTS_Agreement__c testAgreementMSA = TST_CLM_TestDataFactory.createAgreement(CON_CLM.MSA_RECORDTYPEID, false);

        Test.startTest();
        	insert testAgreementMSA;
        Test.stopTest();
        
        Apttus__APTS_Agreement__c resultMSA = [SELECT Id, Apttus__Auto_Renewal__c FROM Apttus__APTS_Agreement__c];
        
        System.assertEquals(true, resultMSA.Apttus__Auto_Renewal__c, 'Auto Renew is not updated.');
    }
    
    @isTest
    private static void testValidatePAAgreementBeforeStatusCategoryChanged() {
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PRELIMINARY_RECORDTYPEID, false);
        agreement.Name = 'Test Preliminary Agreement';
        agreement.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_ATP;
        agreement.Apttus__Contract_Start_Date__c = null;
        insert agreement;
        agreement.Apttus__Status_Category__c = CON_CLM.IN_AUTHORING;
        agreement.Apttus__Status__c = CON_CLM.AUTHOR_CONTRACT;

        Test.startTest();
            try {
                update agreement;
            } catch(Exception e) {
            }
        Test.stopTest();
        
        Apttus__APTS_Agreement__c newAgreement = [SELECT Id, Name, Apttus__Status_Category__c 
            FROM Apttus__APTS_Agreement__c WHERE Name =: 'Test Preliminary Agreement' LIMIT 1][0];
        System.assertNotEquals(CON_CLM.IN_AUTHORING, newAgreement.Apttus__Status_Category__c, 
            'Returned status category should not updated.');
    }
    
    @isTest
    private static void testValidatePSAAgreementBeforeStatusCategoryChanged() {
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        agreement.Name = 'Test PSA Agreement';
        agreement.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_WO;
        agreement.Apttus__Contract_Start_Date__c = null;
        insert agreement;
        agreement.Apttus__Status_Category__c = CON_CLM.IN_SIGNATURES;
        agreement.Apttus__Status__c = CON_CLM.INTERNAL_SIGNATURES;

        Test.startTest();
            try {
                update agreement;
            } catch(Exception e) {
            }
        Test.stopTest();
        
        Apttus__APTS_Agreement__c newAgreement = [SELECT Id, Name, Apttus__Status_Category__c 
            FROM Apttus__APTS_Agreement__c WHERE Name =: 'Test PSA Agreement' LIMIT 1][0];
        System.assertNotEquals(CON_CLM.IN_SIGNATURES, newAgreement.Apttus__Status_Category__c, 
            'Returned status category should not updated.');
    }
    
    @isTest
    private static void testUpdateRelatedQuoteOnAgreementCancellation() {
        Set<Id> proposalIds = new Set<Id>();
        Opportunity newOpportunity = TST_CLM_TestDataFactory.createOpportunity(false);
        newOpportunity.stageName = '5. Finalizing Deal';
        insert newOpportunity;
        
        Apttus_Proposal__Proposal__c budget = TST_CLM_TestDataFactory.createProposalQuote(false);
        budget.RecordTypeId = CON_CLM.QUOTE_RDS_BUDGET_RECORDTYPE;
        budget.Apttus_Proposal__Opportunity__c = newOpportunity.Id;
        budget.Apttus_Proposal__Primary__c = true;
        budget.Apttus_Proposal__Proposal_Category__c = CON_CLM.PROPOSAL_CHANGE_ORDER;
        budget.Scenario_Number__c = 123.0;
        budget.Budget_Iteration__c = 1;
        budget.Apttus_QPConfig__ConfigurationFinalizedDate__c = Date.today();
        insert budget;
        
        budget.Apttus_Proposal__Approval_Stage__c = CON_CLM.PROPOSAL_APPROVAL_STAGE_PRESENTED;
        update budget;
        
        Apttus__APTS_Agreement__c testPSAAGRWithOpp = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        testPSAAGRWithOpp.Name = 'Test PSA AGR With Oppr';
        testPSAAGRWithOpp.Apttus__Related_Opportunity__c = newOpportunity.Id;
        testPSAAGRWithOpp.Apttus_QPComply__RelatedProposalId__c = budget.Id; 
        testPSAAGRWithOpp.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_CHANGEORDER;
        insert testPSAAGRWithOpp;
        
        testPSAAGRWithOpp.Apttus__Contract_End_Date__c = Date.today();
        testPSAAGRWithOpp.Apttus__Status_Category__c = CON_CLM.CANCELLED;
        testPSAAGRWithOpp.Apttus__Status__c = CON_CLM.CANCELLED_REQUEST;
        
        proposalIds.add(testPSAAGRWithOpp.Apttus_QPComply__RelatedProposalId__c);
        
        Test.startTest();
        try{
        update testPSAAGRWithOpp;
        }catch(Exception e){}
        Test.stopTest();
        
        Apttus_Proposal__Proposal__c proposal = [SELECT Id, Apttus_Proposal__Approval_Stage__c 
            FROM Apttus_Proposal__Proposal__c 
            WHERE Apttus_Proposal__Opportunity__c =: testPSAAGRWithOpp.Apttus__Related_Opportunity__c];
       
    }
    @isTest
    private static void testValidateSignedDateBeforeFullySigned() {
        
        
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        agreement.Name = 'Test PSA GSA Agreement';
        agreement.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_GSA;
        insert agreement;
        agreement.Apttus__Status_Category__c = CON_CLM.IN_SIGNATURES;
        agreement.Apttus__Status__c = CON_CLM.FULLY_SIGNED;

        Test.startTest();
            try {
                update agreement;
            } catch(Exception e) {
            }
        Test.stopTest();
        
        Apttus__APTS_Agreement__c newAgreement = [SELECT Id, Name, Apttus__Status__c 
            FROM Apttus__APTS_Agreement__c WHERE Name =: 'Test PSA GSA Agreement' LIMIT 1][0];
        System.assertNotEquals(CON_CLM.FULLY_SIGNED, newAgreement.Apttus__Status__c, 
            'Returned status should not updated.');
    }
    
    /*@isTest
    private static void testUpdateRelatedQuoteOnAgreementActivation() {
        Opportunity newOpportunity = TST_CLM_TestDataFactory.createOpportunity(false);
        newOpportunity.stageName = '5. Finalizing Deal';
        insert newOpportunity;
        
        Apttus_Proposal__Proposal__c budget = TST_CLM_TestDataFactory.createProposalQuote(false);
        budget.RecordTypeId = CON_CLM.QUOTE_RDS_BUDGET_RECORDTYPE;
        budget.Apttus_Proposal__Opportunity__c = newOpportunity.Id;
        budget.Apttus_Proposal__Primary__c = true;
        budget.Apttus_Proposal__Proposal_Category__c = CON_CLM.PROPOSAL_CHANGE_ORDER;
        budget.Scenario_Number__c = 123.0;
        budget.Budget_Iteration__c = 1;
        budget.Apttus_QPConfig__ConfigurationFinalizedDate__c = Date.today();
        insert budget;
        
        budget.Apttus_Proposal__Approval_Stage__c = CON_CLM.PROPOSAL_APPROVAL_STAGE_PRESENTED;
        update budget;
        
        Apttus__APTS_Agreement__c testPSAAGRWithOpp = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        testPSAAGRWithOpp.Name = 'Test PSA AGR With Oppr';
        testPSAAGRWithOpp.Apttus__Related_Opportunity__c = newOpportunity.Id;
        testPSAAGRWithOpp.Apttus_QPComply__RelatedProposalId__c = budget.Id; 
        testPSAAGRWithOpp.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_CHANGEORDER;
        insert testPSAAGRWithOpp;
        
        testPSAAGRWithOpp.Apttus__Contract_End_Date__c = Date.today();
        testPSAAGRWithOpp.Apttus__Status_Category__c = CON_CLM.IN_EFFECT;
        testPSAAGRWithOpp.Apttus__Status__c = CON_CLM.ACTIVATED;
        
        
        Test.startTest();
            update testPSAAGRWithOpp;
        Test.stopTest();

        Apttus_Proposal__Proposal__c proposal = [SELECT Id, Executed_Date__c, Apttus_Proposal__Approval_Stage__c 
            FROM Apttus_Proposal__Proposal__c 
        	WHERE Apttus_Proposal__Opportunity__c =: testPSAAGRWithOpp.Apttus__Related_Opportunity__c
            AND Apttus_Proposal__Primary__c = true];
        System.assertEquals(testPSAAGRWithOpp.Apttus__Other_Party_Signed_Date__c, proposal.Executed_Date__c,
            'Executed date is not updated on Proposal when expected');
        System.assertEquals(CON_CLM.PROPOSAL_APPROVAL_STAGE_ACCEPTED, proposal.Apttus_Proposal__Approval_Stage__c,
            'Proposal Stage should be updated to Accepted');
    }*/

    @isTest
    private static void testPreventUserToUpdateCurrencyOnAgreement() {
        Opportunity newOpportunity = TST_CLM_TestDataFactory.createOpportunity(false);
        newOpportunity.stageName = '5. Finalizing Deal';
        insert newOpportunity;
        
        Apttus_Proposal__Proposal__c proposal = TST_CLM_TestDataFactory.createProposalQuote(false);
        proposal.RecordTypeId = CON_CLM.QUOTE_RDS_BUDGET_RECORDTYPE;
        proposal.Apttus_Proposal__Proposal_Category__c = CON_CLM.PROPOSAL_CHANGE_ORDER;
        proposal.Apttus_Proposal__Opportunity__c = newOpportunity.Id;
        insert proposal;

        Apttus__APTS_Agreement__c testPSAAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        testPSAAgreement.Name = 'Test PSA AGR';
        testPSAAgreement.Apttus_QPComply__RelatedProposalId__c = proposal.Id; 
        testPSAAgreement.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_CHANGEORDER;
        insert testPSAAgreement;

        testPSAAgreement.CurrencyIsoCode = 'THB';

        Test.startTest();
        try {
            update testPSAAgreement;
        } catch(Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains(
                'Agreement currency cannot be updated when Related Quote is present.') 
                ? true : false;
            System.assertEquals(expectedExceptionThrown, true,
                'Currency validation did not raised');
        }
        Test.stopTest();
    }
    
    @isTest
    private static void testUpdateRelatedQuoteStageOnAgrActivation() {
        Opportunity newOpportunity = TST_CLM_TestDataFactory.createOpportunity(false);
        newOpportunity.stageName = '5. Finalizing Deal';
        insert newOpportunity;
        
        Apttus_Proposal__Proposal__c budget = TST_CLM_TestDataFactory.createProposalQuote(false);
        budget.RecordTypeId = CON_CLM.QUOTE_RDS_BUDGET_RECORDTYPE;
        budget.Apttus_Proposal__Opportunity__c = newOpportunity.Id;
        budget.Apttus_Proposal__Primary__c = true;
        budget.Apttus_Proposal__Proposal_Category__c = CON_CLM.PROPOSAL_CHANGE_ORDER;
        budget.Scenario_Number__c = 123.0;
        budget.Budget_Iteration__c = 1;
        budget.Apttus_QPConfig__ConfigurationFinalizedDate__c = Date.today();
        insert budget;
        
        Apttus__APTS_Agreement__c testPSAAGRWithOpp = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        testPSAAGRWithOpp.Name = 'Test PSA AGR With Oppr';
        testPSAAGRWithOpp.Apttus__Related_Opportunity__c = newOpportunity.Id;
        testPSAAGRWithOpp.Apttus_QPComply__RelatedProposalId__c = budget.Id; 
        testPSAAGRWithOpp.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_CHANGEORDER;
        insert testPSAAGRWithOpp;
        
        testPSAAGRWithOpp.Apttus__Contract_End_Date__c = Date.today();
        testPSAAGRWithOpp.Apttus__Status_Category__c = CON_CLM.IN_EFFECT;
        testPSAAGRWithOpp.Apttus__Status__c = CON_CLM.ACTIVATED;
        
        Test.startTest();
            update testPSAAGRWithOpp;
        Test.stopTest();

        Apttus_Proposal__Proposal__c proposal = [SELECT Id, Apttus_Proposal__Approval_Stage__c 
            FROM Apttus_Proposal__Proposal__c 
        	WHERE Apttus_Proposal__Opportunity__c =: testPSAAGRWithOpp.Apttus__Related_Opportunity__c];
        System.assertEquals(CON_CLM.PROPOSAL_APPROVAL_STAGE_ACCEPTED, proposal.Apttus_Proposal__Approval_Stage__c,
            'Proposal Stage should be updated to Accepted');
    }


    @isTest
    private static void testFlow_AgreementHandler() {

        List<Apttus__APTS_Agreement__c> lstAgreement = new List<Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        agreement.Name = 'Test PSA';
        lstAgreement.add(agreement);

        Apttus__APTS_Agreement__c prelimagreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PRELIMINARY_RECORDTYPEID, false);
        prelimagreement.Name = 'Test MSA';
        lstAgreement.add(prelimagreement);

        Apttus__APTS_Agreement__c msaAGR = TST_CLM_TestDataFactory.createAgreement(CON_CLM.MSA_RECORDTYPEID, false);
        msaAGR.Name = 'Test MSA';
        lstAgreement.add(msaAGR);
        
        Apttus__APTS_Agreement__c osaAgreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.OSA_RECORDTYPEID, false);
        osaAgreement.Name = 'Test OSA';
        lstAgreement.add(osaAgreement);
        

        Apttus__APTS_Agreement__c agreementRWS = TST_CLM_TestDataFactory.createAgreement(CON_CLM.RWS_RECORDTYPEID, false);
        agreementRWS.Name = 'Test RWSSOW';
        lstAgreement.add(agreementRWS);

        Apttus__APTS_Agreement__c agreementRWLP = TST_CLM_TestDataFactory.createAgreement(CON_CLM.RWLP_RECORDTYPEID, false);
        agreementRWLP.Name = 'Test RWLP';
        lstAgreement.add(agreementRWLP);

        Apttus__APTS_Agreement__c agreementAMESA = TST_CLM_TestDataFactory.createAgreement(CON_CLM.AMESA_RECORDTYPEID, false);
        agreementAMESA.Name = 'Test AMESA';
        agreementAMESA.Apttus__Account__c = TST_CLM_TestDataFactory.createAccount('TEST AMESA ACCOUNT', true).Id;
        lstAgreement.add(agreementAMESA);
        
        Apttus__APTS_Agreement__c agreementEMEA = TST_CLM_TestDataFactory.createAgreement(CON_CLM.EMEA_RECORDTYPEID, false);
        agreementEMEA.Name = 'Test EMEA';
        lstAgreement.add(agreementEMEA);
        
        Apttus__APTS_Agreement__c agreementCommercial = TST_CLM_TestDataFactory.createAgreement(CON_CLM.COMMERCIAL_RECORDTYPEID, false);
        agreementCommercial.Name = 'Test Commercial';
        lstAgreement.add(agreementCommercial);

        Contact contact = [SELECT Id FROM Contact WHERE EmployeeNumber__c = '123456789'];

        Test.startTest();
            insert lstAgreement;

            for(Apttus__APTS_Agreement__c agr: lstAgreement) {
                If(agr.Record_Type_Developer_Name__c != 'AMESA') {
                    agr.IQVIA_Contract_Manager__c = contact.Id;
                }else{
                    agr.Apttus__Account__c = TST_CLM_TestDataFactory.createAccount('TEST AMESA ACCOUNT1', true).Id;
                }
                
            }
            update lstAgreement;
        Test.stopTest();
    }

    @isTest
    private static void testFlow_RWSCloneLineItems() {

        Account account = UTL_TestData.createAccount();
        insert account;

        Opportunity newOpportunity = TST_CLM_TestDataFactory.createOpportunity(false);
        newOpportunity.stageName = '1. Identifying Opportunity';
        newOpportunity.AccountId = account.Id;
        insert newOpportunity;

        Product2 product2 = UTL_TestData.createProduct();
        insert product2;
        PricebookEntry pbe = UTL_TestData.createPricebookEntry(product2.Id);
        insert pbe;
        OpportunityLineItem oli = UTL_TestData.createOpportunityLineItem(newOpportunity.Id, pbe.Id);
        insert oli;
        
        List<Apttus__APTS_Agreement__c> lstAgreement = new List<Apttus__APTS_Agreement__c>();
        Apttus__APTS_Agreement__c agreementRWS = TST_CLM_TestDataFactory.createAgreement(CON_CLM.RWS_RECORDTYPEID, false);
        agreementRWS.Name = 'Test RWSSOW';
        agreementRWS.Apttus__Related_Opportunity__c = newOpportunity.Id;
        insert agreementRWS;
    
        Apttus__AgreementLineItem__c ali = UTL_TestData.createAgreementLineItem(agreementRWS.Id,product2.Id);
        Apttus__APTS_Agreement__c agreementRWSAmend = TST_CLM_TestDataFactory.createAgreement(CON_CLM.RWS_RECORDTYPEID, false);
        agreementRWSAmend.Name = 'Test RWSSOW';
        agreementRWSAmend.Agreement_Cloned_From__c = agreementRWS.Id;
        agreementRWSAmend.Apttus__Version_Number__c = 1;

        Test.startTest();
            insert agreementRWSAmend;
        Test.stopTest();

        List<Apttus__AgreementLineItem__c> alis = [SELECT Id FROM Apttus__AgreementLineItem__c WHERE Apttus__AgreementId__c =: agreementRWSAmend.Id];
        System.assertEquals(false, alis.isEmpty(), 'Agreement Line Item not created when expected');
    }

     @isTest
    private static void testCLMSubflowRescueNotification() {
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PRELIMINARY_RECORDTYPEID, false);
        agreement.Name = 'Test PA Agreement';
        agreement.Apttus__Status_Category__c = CON_CLM.REQUEST;
        agreement.Apttus__Status__c = CON_CLM.REQUEST;
        insert agreement;
        
        Test.startTest();
            agreement.Site_Activation_Requested__c = 'Yes';
            update agreement;
        Test.stopTest();
        
        Apttus__APTS_Agreement__c agr = [SELECT Id, Site_Activation_Requested__c FROM Apttus__APTS_Agreement__c WHERE Name = 'Test PA Agreement' LIMIT 1];
        System.assertEquals('Yes', agr.Site_Activation_Requested__c, 'The value should be Yes');
    }
    
    @isTest
    private static void testCLMSubflowIQVIAContractManagerUpdateNotification() {
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        agreement.Name = 'Test_PSA';
        agreement.Apttus__Status_Category__c = CON_CLM.REQUEST;
        agreement.Apttus__Status__c = CON_CLM.REQUEST;
        insert agreement;

        Contact contact = [SELECT Id FROM Contact WHERE EmployeeNumber__c = '123456789'];
        
        Test.startTest();
            agreement.IQVIA_Contract_Manager__c = contact.Id;
            update agreement;
        Test.stopTest();
        
        Apttus__APTS_Agreement__c agr = [SELECT Id, IQVIA_Contract_Manager__c FROM Apttus__APTS_Agreement__c WHERE Name = 'Test_PSA' LIMIT 1];
        System.assertNotEquals(null, agr.IQVIA_Contract_Manager__c, 'The value should not be null');
    }
     
    @isTest
    private static void testCLMSubflowSendMailForAnticipatedDate30() {
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        agreement.Name = 'Test_PSA_1';
        agreement.Apttus__Status_Category__c = CON_CLM.REQUEST;
        agreement.Apttus__Status__c = CON_CLM.REQUEST;
        agreement.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_GSA;
        insert agreement;
        
        Test.startTest();
            agreement.Anticipated_Date_For_1st_SIV__c = System.TODAY() + 5;
            update agreement;
        Test.stopTest();
        
        Apttus__APTS_Agreement__c agr = [SELECT Id, Anticipated_Date_For_1st_SIV__c FROM Apttus__APTS_Agreement__c WHERE Name = 'Test_PSA_1' LIMIT 1];
        System.assertNotEquals(null, agr.Anticipated_Date_For_1st_SIV__c, 'The date should be filled');
    }    
    
    @isTest
    private static void testCLMSubflowSendMailForAnticipatedDate45() {
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        agreement.Name = 'Test_PSA_1';
        agreement.Apttus__Status_Category__c = CON_CLM.REQUEST;
        agreement.Apttus__Status__c = CON_CLM.REQUEST;
        agreement.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_GSA;
        insert agreement;
        
        Test.startTest();
            agreement.Anticipated_Date_For_1st_SIV__c = System.TODAY() + 40;
            update agreement;
        Test.stopTest();
        
        Apttus__APTS_Agreement__c agr = [SELECT Id, Anticipated_Date_For_1st_SIV__c FROM Apttus__APTS_Agreement__c WHERE Name = 'Test_PSA_1' LIMIT 1];
        System.assertNotEquals(null, agr.Anticipated_Date_For_1st_SIV__c, 'The date should be filled');
    }  

    @isTest
    private static void testCLMSubflowOwnerChange() {
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.OSA_RECORDTYPEID, false);
        agreement.Name = 'Test_OSA';
        insert agreement;
        User salesUser = [SELECT Id FROM User WHERE LastName = 'Test Sales User' LIMIT 1];
        
        List<User> adminUserList = UTL_TestData.createUser('System Administrator', 1);
        System.runAs (adminUserList[0]) {
            insert UTL_TestData.createPermissionSetAssignmentRecord('Apttus_CLM_Base_Permission_Set', salesUser.Id);
        }

        Test.startTest();
            agreement.OwnerId = salesUser.Id;
            update agreement;
        Test.stopTest();
        
        System.assertNotEquals(null, agreement.OwnerId, 'The value should not be null');
    }

    @isTest
	private static void testCLMSubflowRDSNotificationForCAStatusUpdate() {
	    Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        agreement.Name = 'Test PSA AGR';
		agreement.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_CHANGEORDER;
        agreement.Apttus__Status__c = 'Request';
        agreement.Apttus__Status_Category__c = 'Request';
        insert agreement;

        Apttus__APTS_Related_Agreement__c relatedAgreement = new Apttus__APTS_Related_Agreement__c();
        relatedAgreement.Name = 'Current Agreement';
        relatedAgreement.Apttus__Relationship_From_Type__c = 'Is Full Service Master Of';
        relatedAgreement.Apttus__APTS_Contract_From__c = agreement.Id;
        relatedAgreement.Apttus__Relationship_To_Type__c = 'Is Full Service Child Of';
        relatedAgreement.Apttus__APTS_Contract_To__c = agreement.Id;
        insert relatedAgreement;

        agreement.Apttus__Contract_End_Date__c = Date.today();
        agreement.Apttus__Status_Category__c = CON_CLM.IN_EFFECT;
        agreement.Apttus__Status__c = CON_CLM.ACTIVATED;
		
        Test.startTest();
            update agreement;
        Test.stopTest();
		
		Apttus__APTS_Agreement__c agr = [SELECT Id, Apttus__Status__c FROM Apttus__APTS_Agreement__c WHERE Name = 'Test PSA AGR' LIMIT 1];
		System.assertEquals('Activated', agr.Apttus__Status__c);

        EmailMessage e=[SELECT Id, ActivityId FROM EmailMessage where RelatedToId =: agr.Id LIMIT 1];
        System.assertNotEquals(null, e.ActivityId);
	}

    @isTest
	private static void testCLMSubflowRDSNotificationForRegulatoryLOB() { 
        Opportunity newOpportunity = TST_CLM_TestDataFactory.createOpportunity(false);
        newOpportunity.Name = 'Test Opp';
        newOpportunity.stageName = '1. Identifying Opportunity';
        insert newOpportunity;
        newOpportunity.Line_of_Business__c='Regulatory & Drug Development Solutions';
        update newOpportunity;
        
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        agreement.Name = 'Test_PSA';
        agreement.Apttus__Status_Category__c = CON_CLM.REQUEST;
        agreement.Apttus__Status__c = CON_CLM.REQUEST;
        agreement.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_GSA;
        agreement.Apttus__Related_Opportunity__c = newOpportunity.Id;
        
        Test.startTest();      
		    insert agreement;
        Test.stopTest();
        
        Apttus__APTS_Agreement__c agr = [SELECT Id, Line_of_Business__c FROM Apttus__APTS_Agreement__c WHERE Name = 'Test_PSA' LIMIT 1];
        System.assertEquals('Regulatory & Drug Development Solutions', agr.Line_of_Business__c);
    } 

	@isTest
    private static void testCLMSubflowRWSSOWNotificationforSubmittedToClinical() {

        User salesUser = [SELECT Id FROM User WHERE LastName = 'Test Sales User' LIMIT 1];
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.RWS_RECORDTYPEID, false);
        agreement.Name = 'Test RWS AGR';
        agreement.Apttus__Status_Category__c = CON_CLM.REQUEST;
        agreement.Apttus__Status__c = CON_CLM.REQUEST;
        agreement.First_Patient_In_Date__c = system.today();
        agreement.OwnerId = salesUser.Id;
        insert agreement;
        
        Apttus__APTS_Related_Agreement__c relatedAgreement = new Apttus__APTS_Related_Agreement__c();
        relatedAgreement.Name = 'Current Agreement';
        relatedAgreement.Apttus__Relationship_From_Type__c = 'Is Full Service Master Of';
        relatedAgreement.Apttus__APTS_Contract_From__c = agreement.Id;
        relatedAgreement.Apttus__Relationship_To_Type__c = 'Is Full Service Child Of';
        relatedAgreement.Apttus__APTS_Contract_To__c = agreement.Id;
        insert relatedAgreement;

        Contact contact=[SELECT Id FROM Contact WHERE FirstName='test'];
        Agreement_Contacts__c agreementContact = TST_CLM_TestDataFactory.createAgreementContacts(agreement.Id, false);
        agreementContact.Agreement__c = agreement.Id;
        agreementContact.Contact__c = contact.Id;
        agreementContact.Type__c = 'IQVIA User Contact';
        agreementContact.Role__c = 'BD Representative';
        insert agreementContact;
        
        Apttus__APTS_Agreement__c agr = [SELECT Id, Apttus__Status__c, Apttus__Agreement_Number__c FROM Apttus__APTS_Agreement__c WHERE Name = 'Test RWS AGR' LIMIT 1];
        Apttus__APTS_Related_Agreement__c rel = [SELECT Id, Apttus__APTS_Contract_From__c, Apttus__APTS_Contract_From__r.Owner.Email FROM Apttus__APTS_Related_Agreement__c WHERE Apttus__Relationship_From_Type__c = 'Is Full Service Master Of' AND Apttus__Relationship_To_Type__c = 'Is Full Service Child Of' AND Apttus__APTS_Contract_To__c =: agreement.Id AND Apttus__APTS_Contract_From__c != null];

        agreement.Apttus__Status_Category__c = CON_CLM.IN_AUTHORING;
        agreement.Apttus__Status__c = CON_CLM.SUBMITTED_TO_CLINICAL;
        
        Test.startTest();
            update agreement;
        Test.stopTest();
        
        EmailMessage e = [SELECT Id, FromAddress, Subject, ToAddress  FROM EmailMessage where Subject LIKE '%Follows eCOA%' LIMIT 1];
        String sub = 'Follows eCOA Scope of Work for   '+ agr.Apttus__Agreement_Number__c;
        System.assertEquals(sub, e.Subject, 'Email subject is incorrect');
        
    }

    @isTest
    private static void testCLMSubflowNotificationOnIsStudyAwardedUpdated() { 
        List<Opportunity> lstOpportunities = new List<Opportunity>();
        Opportunity newOpportunity = TST_CLM_TestDataFactory.createOpportunity(false);
        newOpportunity.Name = 'Test Opp';
        newOpportunity.stageName = '1. Identifying Opportunity';
        lstOpportunities.add(newOpportunity);
        
        Opportunity newOpportunity1 = TST_CLM_TestDataFactory.createOpportunity(false);
        newOpportunity1.Name = 'Test Opp 1';
        newOpportunity1.stageName = '5. Finalizing Deal';
        newOpportunity1.Potential_Regions__c = 'Asia Pacific';
        newOpportunity1.QI_Invited_to_Present__c = 'Yes';
        newOpportunity1.Bid_Defense_Date__c = System.today();
        newOpportunity1.Presentation_Date_Status__c = 'Estimated';
        newOpportunity1.Presentation_Country__c = 'Venezuela';
        lstOpportunities.add(newOpportunity1);
        insert lstOpportunities;
        
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PRELIMINARY_RECORDTYPEID, false);
        agreement.Name = 'Test_PA';
        agreement.Apttus__Status_Category__c = CON_CLM.REQUEST;
        agreement.Apttus__Status__c = CON_CLM.REQUEST;
        agreement.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_ATP;
        agreement.Apttus__Related_Opportunity__c = newOpportunity.Id;
        agreement.Is_Study_Awarded__c = 'No';
        insert agreement;

        agreement.Apttus__Related_Opportunity__c = newOpportunity1.Id;
        agreement.Is_Study_Awarded__c = 'Yes';
        Test.startTest();
            update agreement;
        Test.stopTest();
        
        Apttus__APTS_Agreement__c agr = [SELECT Id, Is_Study_Awarded__c FROM Apttus__APTS_Agreement__c WHERE Name = 'Test_PA' LIMIT 1];
        System.assertEquals('Yes', agr.Is_Study_Awarded__c, 'Returned study awarded is not what is expected.');
    }

    @isTest
    private static void testCLMSubflowCDContractAgreementActivationNotification() { 
        
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.OSA_RECORDTYPEID, false);
        agreement.Name = 'Test_OSA';
        agreement.Apttus__Status_Category__c = CON_CLM.REQUEST;
        agreement.Apttus__Status__c = CON_CLM.REQUEST;
        agreement.Services__c = 'CSS-CD Contract';
        insert agreement;

        Test.startTest();      
            agreement.Apttus__Status_Category__c = CON_CLM.IN_EFFECT;
            agreement.Apttus__Status__c = CON_CLM.ACTIVATED;
            agreement.Apttus__Contract_End_Date__c = System.today();
            update agreement;
        Test.stopTest();
        
        Apttus__APTS_Agreement__c agr = [SELECT Id, Apttus__Status_Category__c, Apttus__Status__c FROM Apttus__APTS_Agreement__c WHERE Name = 'Test_OSA' LIMIT 1];
        System.assertEquals(CON_CLM.IN_EFFECT, agr.Apttus__Status_Category__c, 'Agreement Not In Effect Status Category.');
        System.assertEquals(CON_CLM.ACTIVATED, agr.Apttus__Status__c, 'Agreement Not Activated.');
    }

    @isTest
    private static void testCLMSubflowNotificationOnAdditionOfThirdPartyVendorAsService() { 
        
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        agreement.Name = 'Test_PSA';
        agreement.Services__c = '';
        insert agreement;

        Test.startTest();      
            agreement.Services__c = 'Third Party Vendors';
            update agreement;
        Test.stopTest();
        
        Apttus__APTS_Agreement__c agr = [SELECT Id, Services__c FROM Apttus__APTS_Agreement__c WHERE Name = 'Test_PSA' LIMIT 1];
        System.assertEquals('Third Party Vendors', agr.Services__c, 'Services Doesn\'t Include Third Party Vendors.');
    }

    @isTest
    private static void testCLMSubflowAgreementApprovedNotification() {
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.OSA_RECORDTYPEID, false);
        agreement.Name = 'Test OSA Agreement';
        agreement.Apttus__Status__c = CON_CLM.REQUEST;
        agreement.Apttus__Status_Category__c = CON_CLM.REQUEST;
        agreement.Confidence_In_Approval_Of_Budget_Draft__c = 'High';
        agreement.Unsigned_Comments__c = 'test';
        agreement.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_LRA;
        agreement.Contracting_Country__c = 'AD';
        insert agreement;
        
        
        agreement.Apttus__Status_Category__c = CON_CLM.IN_AUTHORING;
        agreement.Apttus__Status__c = CON_CLM.AUTHOR_CONTRACT;
        update agreement;
        
        
        Test.startTest();
            agreement.Apttus__Status_Category__c = CON_CLM.IN_APPROVAL;
            agreement.Apttus__Status__c = CON_CLM.APPROVED;
        	update agreement;
        Test.stopTest();
        
        Apttus__APTS_Agreement__c agr = [SELECT Id, Apttus__Status__c, Apttus__Agreement_Number__c FROM Apttus__APTS_Agreement__c WHERE Name = 'Test OSA Agreement' LIMIT 1];
        System.assertEquals(CON_CLM.APPROVED, agr.Apttus__Status__c, 'Status Should be Approved');
    }
    
    @isTest
    private static void testCLMSubflowAgreementCancellationNotification() {
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        agreement.Name = 'Test PSA AGR';
		agreement.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_GSA;
        agreement.Apttus__Status__c = CON_CLM.REQUEST;
        agreement.Apttus__Status_Category__c = CON_CLM.REQUEST;
        insert agreement;                
        
        agreement.Apttus__Status_Category__c = CON_CLM.CANCELLED;
        agreement.Apttus__Status__c = CON_CLM.CANCELLED_REQUEST;
        
        Test.startTest();
        	update agreement;
        Test.stopTest();
        
        Apttus__APTS_Agreement__c agr = [SELECT Id, Apttus__Status__c, Apttus__Agreement_Number__c FROM Apttus__APTS_Agreement__c WHERE Name = 'Test PSA AGR' LIMIT 1];
        System.assertEquals(CON_CLM.CANCELLED_REQUEST, agr.Apttus__Status__c, 'Status Should be Cancelled Request');
    }
    
    @isTest
    private static void testCLMSubflowAgreementExpiredNotification() {
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        agreement.Name = 'Test PSA AGR';
		agreement.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_GSA;
        agreement.Apttus__Status__c = CON_CLM.REQUEST;
        agreement.Apttus__Status_Category__c = CON_CLM.REQUEST;
        insert agreement;
        
        agreement.Apttus__Status_Category__c = CON_CLM.EXPIRED;
        agreement.Apttus__Status__c = CON_CLM.EXPIRED;
        
        Test.startTest();
        	update agreement;
        Test.stopTest();
        
        Apttus__APTS_Agreement__c agr = [SELECT Id, Apttus__Status__c, Apttus__Agreement_Number__c FROM Apttus__APTS_Agreement__c WHERE Name = 'Test PSA AGR' LIMIT 1];
        System.assertEquals(CON_CLM.EXPIRED, agr.Apttus__Status__c, 'Status Should be Expired');
    }
    
    @isTest
    private static void testCLMSubflowAgreementRejectedNotification() {
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.OSA_RECORDTYPEID, false);
        agreement.Name = 'Test OSA Agreement';
        agreement.Apttus__Status__c = CON_CLM.REQUEST;
        agreement.Apttus__Status_Category__c = CON_CLM.REQUEST;
        agreement.Confidence_In_Approval_Of_Budget_Draft__c = 'High';
        agreement.Unsigned_Comments__c = 'test';
        agreement.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_LRA;
        agreement.Contracting_Country__c = 'AD';
        insert agreement;
        
        agreement.Apttus__Status_Category__c = CON_CLM.IN_AUTHORING;
        agreement.Apttus__Status__c = CON_CLM.AUTHOR_CONTRACT;
        update agreement;
        
        
        Test.startTest();
            agreement.Apttus__Status_Category__c = CON_CLM.IN_APPROVAL;
            agreement.Apttus__Status__c = CON_CLM.REJECTED;
        	update agreement;
        Test.stopTest();
        
        Apttus__APTS_Agreement__c agr = [SELECT Id, Apttus__Status__c, Apttus__Agreement_Number__c FROM Apttus__APTS_Agreement__c WHERE Name = 'Test OSA Agreement' LIMIT 1];
        System.assertEquals(CON_CLM.REJECTED, agr.Apttus__Status__c, 'Status Should be Rejected');
    }
    
    @isTest
    private static void testCLMSubflowContractActivationNotice() {
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        agreement.Name = 'Test PSA AGR';
		agreement.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_GSA;
        agreement.Apttus__Status__c = CON_CLM.REQUEST;
        agreement.Apttus__Status_Category__c = CON_CLM.REQUEST;
        insert agreement;        
        
        agreement.Apttus__Contract_End_Date__c = Date.today();
        agreement.Apttus__Status_Category__c = CON_CLM.IN_EFFECT;
        agreement.Apttus__Status__c = CON_CLM.ACTIVATED;
        
        Test.startTest();
        	update agreement;
        Test.stopTest();
        
        Apttus__APTS_Agreement__c agr = [SELECT Id, Apttus__Status__c, Apttus__Agreement_Number__c FROM Apttus__APTS_Agreement__c WHERE Name = 'Test PSA AGR' LIMIT 1];
        System.assertEquals(CON_CLM.ACTIVATED, agr.Apttus__Status__c, 'Status Should be Terminated');
    }
    
    @isTest
    private static void testCLMSubflowContractTerminationNotice() {
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        agreement.Name = 'Test PSA AGR';
		agreement.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_GSA;
        agreement.Apttus__Status__c = CON_CLM.REQUEST;
        agreement.Apttus__Status_Category__c = CON_CLM.REQUEST;
        insert agreement;
        
        agreement.Apttus__Status_Category__c = CON_CLM.TERMINATED;
        agreement.Apttus__Status__c = CON_CLM.TERMINATED;
        
        Test.startTest();
        	update agreement;
        Test.stopTest();
        
        Apttus__APTS_Agreement__c agr = [SELECT Id, Apttus__Status__c, Apttus__Agreement_Number__c FROM Apttus__APTS_Agreement__c WHERE Name = 'Test PSA AGR' LIMIT 1];
        System.assertEquals(CON_CLM.TERMINATED, agr.Apttus__Status__c, 'Status Should be Terminated');
    }
    
    @isTest
    private static void testCLMSubflowAgreementCreationNotification() {
        Opportunity newOpportunity = TST_CLM_TestDataFactory.createOpportunity(false);
        newOpportunity.Name = 'Test Opp';
        newOpportunity.stageName = '1. Identifying Opportunity';
        insert newOpportunity;
        
        Organization_Default__c organizationDefault = new Organization_Default__c();
        organizationDefault.UserID__c = UserInfo.getUserId();
        organizationDefault.Username__c = 'Test User';
        insert organizationDefault;
        
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.PSA_RECORDTYPEID, false);
        agreement.Name = 'Test PSA AGR';
		agreement.Apttus__Subtype__c = CON_CLM.REQUESTED_AGREEMENT_TYPE_GSA;
        agreement.Apttus__Status__c = CON_CLM.REQUEST;
        agreement.Apttus__Status_Category__c = CON_CLM.REQUEST;
        agreement.Apttus__Related_Opportunity__c = newOpportunity.Id;
        
        Test.startTest();
        	insert agreement;
        Test.stopTest();
        
        Apttus__APTS_Agreement__c agr = [SELECT Id, Apttus__Status__c, Apttus__Agreement_Number__c, Apttus__Related_Opportunity__c FROM Apttus__APTS_Agreement__c WHERE Name = 'Test PSA AGR' LIMIT 1];
        System.assertNotEquals(null, agr.Apttus__Related_Opportunity__c, 'Opportunity Should not be blank');
    }

    @isTest
    private static void testCLMSubflowAgreementStatusUpdateNotification() {
        Opportunity newOpportunity = TST_CLM_TestDataFactory.createOpportunity(false);
        newOpportunity.Name = 'Test Opp';
        newOpportunity.stageName = '1. Identifying Opportunity';
        insert newOpportunity;
        
        Contact cont = [SELECT Id FROM Contact WHERE LastName = 'lastname' LIMIT 1];
        
        Apttus__APTS_Agreement__c agreement = TST_CLM_TestDataFactory.createAgreement(CON_CLM.RWLP_RECORDTYPEID, false);
        agreement.Name = 'Test RWLP';
        agreement.Apttus__Status_Category__c = CON_CLM.REQUEST;
        agreement.Apttus__Status__c = CON_CLM.REQUEST;
        agreement.Apttus__Related_Opportunity__c = newOpportunity.Id;
        agreement.Services__c = 'RBU IMC';
		agreement.IQVIA_Project_Manager_Con__c = cont.Id;
        insert agreement;
        
        agreement.Apttus__Status_Category__c = CON_CLM.IN_AUTHORING;
        agreement.Apttus__Status__c = CON_CLM.STATUS_OTHER_PARTY_REVIEW;
        
        Test.startTest();
        	update agreement;
        Test.stopTest();
        
        Apttus__APTS_Agreement__c agr = [SELECT Id, Apttus__Status__c, Apttus__Agreement_Number__c, Apttus__Related_Opportunity__c FROM Apttus__APTS_Agreement__c WHERE Name = 'Test RWLP' LIMIT 1];
        System.assertEquals(CON_CLM.STATUS_OTHER_PARTY_REVIEW, agr.Apttus__Status__c, 'Status Should be Other Party Review');
    }
}