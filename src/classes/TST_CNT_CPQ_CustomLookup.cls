@isTest
public class TST_CNT_CPQ_CustomLookup {
    @testSetup
    static void dataSetUp() {
        Account testAccount = UTL_TestData.createAccount();
        insert testAccount;
        
        Opportunity testOpportunity = UTL_OWF_TestData.createOpportunity(testAccount.Id);
        testOpportunity.Line_of_Business__c = CON_CPQ.SAMPLE_LINE_OF_BUSINESS;
        testOpportunity.Is_this_IQVIA_Biotech__c = CON_CPQ.YES_TITLE_CASE;
        testOpportunity.Legacy_Quintiles_Opportunity_Number__c = 'MVP123';
        insert testOpportunity;
        
        pse__Grp__c grp = UTL_OWF_TestData.createGroup();
        insert grp;
        pse__Permission_Control__c permissionControlGroup = UTL_OWF_TestData.createPermissionControl(null, null, grp, null);
        insert permissionControlGroup;
        
        RecordType recordType = [SELECT Id, Name, DeveloperName From RecordType WHERE Id = :CON_CRM.CONTRACT_RECORD_TYPE_CNF_GBO LIMIT 1];
        IQVIA_Legal_Entity__c iqviaLegalEntity = new IQVIA_Legal_Entity__c(Name = 'Test');
        insert iqviaLegalEntity;
        Contract cntrt = UTL_TestData.createContract(testOpportunity, recordType.DeveloperName);
        cntrt.Name = 'Test Contract1';
        cntrt.Project_Number__c = '12';
        cntrt.Parent_Contract_Number__c = 1234;
        cntrt.Ultimate_Parent_Contract_Number__c = 5678;
        cntrt.Legal_Entity_IQVIA__c = iqviaLegalEntity.Id;
        cntrt.Legal_Entity_Customer__c = 'test';
        insert cntrt;
        
        Contract cntrtRecord = [SELECT Id, ContractNumber FROM Contract LIMIT 1];
        Id recordTypeId = CPQ_Utility.proposalBudgetRecordTypeId;
        Apttus_Proposal__Proposal__c testProposal = UTL_TestData.createQuote();
        testProposal.Apttus_Proposal__Opportunity__c = testOpportunity.Id;
        testProposal.RecordTypeId = recordTypeId;
        testProposal.Apttus_Proposal__Approval_Stage__c = CON_CPQ.DRAFT;
        testProposal.Approval_Status__c = CON_CPQ.NONE;
        testProposal.Select_Pricing_Tool__c = CON_CPQ.AGREEMENT_SELECT_PRICING_TOOL_CPQ_UPT;
        testProposal.Scenario_Number__c = 123.0;
        testProposal.Scenario_Description__c = CON_CPQ.OPPORTUNITY_BALLPARK;
        testProposal.Budget_Iteration__c = 1;
        testProposal.RFP_Scenario__c = CON_CPQ.OPPORTUNITY_BALLPARK;
        testProposal.Apttus_Proposal__Proposal_Category__c = CON_CPQ.OPPORTUNITY_BALLPARK;
        insert testProposal;
        
    }
    
    @isTest
    static void testSetSelectedData() {
        Apttus_Proposal__Proposal__c testProposal = [SELECT Id, Name FROM Apttus_Proposal__Proposal__c LIMIT 1];
        
        Test.startTest();
            List<CNT_CPQ_CustomLookup.LookupValues> resultList = CNT_CPQ_CustomLookup.setSelectedData(CON_CPQ.APTTUS_PROPOSAL_PROPOSAL, CON_CPQ.APPROVAL_STAGE, CON_CPQ.NAME, '', '', CON_CPQ.NAME, testProposal.Name);
        Test.stopTest();
        
        System.assertEquals(resultList.size() > 0, true, 'Retunring the proposal record');
    }
    
    @isTest
    static void testFetchLookUpData() {
        
        Test.startTest();
            List<CNT_CPQ_CustomLookup.LookupValues> resultList = CNT_CPQ_CustomLookup.fetchLookUpData(CON_CPQ.DRAFT, CON_CPQ.APTTUS_PROPOSAL_PROPOSAL, CON_CPQ.APPROVAL_STAGE, CON_CPQ.NAME, '', '', false, 5);
        Test.stopTest();
        
        System.assertEquals(resultList.size() > 0, true, 'Retunring the proposal record');
    }
}